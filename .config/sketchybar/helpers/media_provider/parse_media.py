import sys
import json
import base64
import os
import shutil
import time

ARTWORK_DIR = "/tmp"
MEDIA_ARTWORK = "/tmp/sketchybar_media_artwork"  # media-control's own cache
last_artwork = ""
last_title = ""
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
        artwork_path = ""
        if art:
            out = f"{ARTWORK_DIR}/sketchybar_artwork_{int(time.time())}.jpg"
            for f in os.listdir(ARTWORK_DIR):
                if f.startswith("sketchybar_artwork_"):
                    try:
                        os.remove(os.path.join(ARTWORK_DIR, f))
                    except:
                        pass
            try:
                raw = base64.b64decode(art, validate=True)
                with open(out, "wb") as fh:
                    fh.write(raw)
            except Exception:
                if os.path.isfile(art):
                    shutil.copy2(art, out)
            os.system(
                f"sips -z 26 26 --setProperty format jpeg '{out}' >/dev/null 2>&1"
            )
            artwork_path = out
            last_artwork = out
        elif playing and title != last_title:
            # new track but artwork not in payload yet — wait for media-control to update its cache
            time.sleep(0.5)
            out = f"{ARTWORK_DIR}/sketchybar_artwork_{int(time.time())}.jpg"
            if os.path.isfile(MEDIA_ARTWORK):
                for f in os.listdir(ARTWORK_DIR):
                    if f.startswith("sketchybar_artwork_"):
                        try:
                            os.remove(os.path.join(ARTWORK_DIR, f))
                        except:
                            pass
                os.system(
                    f"sips -z 26 26 --setProperty format jpeg --out '{out}' '{MEDIA_ARTWORK}' >/dev/null 2>&1"
                )
                artwork_path = out
                last_artwork = out
            else:
                artwork_path = last_artwork
        elif playing:
            artwork_path = last_artwork
        last_title = title
        print(f"{title}\t{artist}\t{state}\t{bundle}\t{artwork_path}", flush=True)
    except Exception as e:
        print(f"ERROR: {e}", file=sys.stderr, flush=True)
