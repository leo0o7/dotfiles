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
        bundle = p.get("bundleIdentifier", "")
        art = p.get("artworkData", "")

        if art:
            path = f"{ARTWORK_DIR}/sketchybar_artwork_{int(time.time())}.jpg"
            with open(path, "wb") as fh:
                fh.write(base64.b64decode(art, validate=True))
            os.system(
                f"sips -z 26 26 --setProperty format jpeg '{path}' >/dev/null 2>&1"
            )
            # clean up old files
            for f in os.listdir(ARTWORK_DIR):
                p2 = os.path.join(ARTWORK_DIR, f)
                if f.startswith("sketchybar_artwork_") and p2 != path:
                    os.remove(p2)
            last_artwork = path

        if playing:
            last_title, last_artist, last_bundle = title, artist, bundle

        # artwork arrives in a fake paused/empty event — re-emit for current track
        if not playing and title == "" and art:
            print(
                f"{last_title}\t{last_artist}\tplaying\t{last_bundle}\t{last_artwork}",
                flush=True,
            )
        else:
            print(
                f"{title}\t{artist}\t{'playing' if playing else 'paused'}\t{bundle}\t{last_artwork}",
                flush=True,
            )

    except Exception as e:
        print(f"ERROR: {e}", file=sys.stderr, flush=True)
