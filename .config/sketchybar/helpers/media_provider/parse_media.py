import sys
import json
import base64
import os
import time

ARTWORK_DIR = "/tmp"
last_artwork = ""
last_title = ""
last_artist = ""
last_bundle = ""


def save_artwork(raw_bytes):
    out = f"{ARTWORK_DIR}/sketchybar_artwork_{int(time.time())}.jpg"
    with open(out, "wb") as fh:
        fh.write(raw_bytes)
    ret = os.system(f"sips -z 26 26 --setProperty format jpeg '{out}' >/dev/null 2>&1")
    if ret == 0 and os.path.isfile(out) and os.path.getsize(out) > 0:
        return out
    try:
        os.remove(out)
    except:
        pass
    return None


def cleanup_old(keep):
    for f in os.listdir(ARTWORK_DIR):
        if f.startswith("sketchybar_artwork_"):
            p = os.path.join(ARTWORK_DIR, f)
            if p != keep:
                try:
                    os.remove(p)
                except:
                    pass


for line in sys.stdin:
    line = line.strip()
    if not line:
        continue
    try:
        d = json.loads(line)
        p = d.get("payload", {})
        title = p.get("title", "").replace("\t", " ").replace("\n", " ")
        artist = p.get("artist", "").replace("\t", " ").replace("\n", " ")
        playing = p.get("playing", False)
        state = "playing" if playing else "paused"
        bundle = p.get("bundleIdentifier", "")
        art = p.get("artworkData", "")

        if art:
            try:
                raw = base64.b64decode(art, validate=True)
            except Exception:
                raw = None
            if raw:
                new = save_artwork(raw)
                if new:
                    cleanup_old(keep=new)
                    last_artwork = new

        if playing:
            last_title = title
            last_artist = artist
            last_bundle = bundle

        # artwork arrived in a paused/empty event — re-emit for the current track
        if not playing and title == "" and art and last_title != "":
            print(
                f"{last_title}\t{last_artist}\tplaying\t{last_bundle}\t{last_artwork}",
                flush=True,
            )
        else:
            print(f"{title}\t{artist}\t{state}\t{bundle}\t{last_artwork}", flush=True)

    except Exception as e:
        print(f"ERROR: {e}", file=sys.stderr, flush=True)
