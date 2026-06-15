#!/usr/bin/env python3
"""Media provider for sketchybar.

Reads now-playing info from media-control and fires sketchybar triggers.
Replaces the fragile bash+python pipeline with a single reliable process.
"""

import subprocess
import threading
import time
import json
import sys
import base64
import os
import signal
import pathlib

ARTWORK_DIR = pathlib.Path("/tmp")
MEDIA_CONTROL = "/opt/homebrew/bin/media-control"

state = {
    "title": "",
    "artist": "",
    "album": "",
    "playing": False,
    "bundle": "",
    "elapsed_micros": 0,
    "duration_micros": 0,
    "timestamp_micros": 0,
    "artwork_path": "",
    "content_id": "",
}
state_lock = threading.Lock()
last_content_id = ""


def fetch_artwork():
    """Fetch artwork via one-shot get, save resized image, return path."""
    try:
        r = subprocess.run(
            [MEDIA_CONTROL, "get"],
            capture_output=True, text=True, timeout=5,
        )
        payload = json.loads(r.stdout)
        # get outputs payload directly (no wrapper)
        if not payload or not isinstance(payload, dict):
            return ""
        art_b64 = payload.get("artworkData") or ""
        if not art_b64:
            return ""

        mime = payload.get("artworkMimeType", "image/jpeg") or "image/jpeg"
        ext = ".png" if "png" in mime else ".tiff" if "tiff" in mime else ".jpg"
        path = ARTWORK_DIR / f"sketchybar_artwork_{int(time.time() * 1000)}{ext}"

        with open(path, "wb") as f:
            f.write(base64.b64decode(art_b64))

        os.system(f"sips -z 26 26 --setProperty format jpeg '{path}' >/dev/null 2>&1")

        for f in ARTWORK_DIR.iterdir():
            if f.name.startswith("sketchybar_artwork_") and f != path:
                try:
                    f.unlink()
                except OSError:
                    pass

        return str(path)
    except Exception:
        return ""


def set_artwork(path):
    with state_lock:
        state["artwork_path"] = path


def stream_reader():
    """Background thread: reads media-control stream, updates global state."""
    global last_content_id

    while True:
        try:
            proc = subprocess.Popen(
                [MEDIA_CONTROL, "stream", "--micros", "--no-artwork", "--debounce=200"],
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL,
                text=True,
                bufsize=1,
            )
            for line in proc.stdout:
                line = line.strip()
                if not line:
                    continue
                try:
                    data = json.loads(line)
                except json.JSONDecodeError:
                    continue

                payload = data.get("payload", {})

                with state_lock:
                    if not payload:
                        state["playing"] = False
                        state["title"] = ""
                        state["artist"] = ""
                        state["bundle"] = ""
                        state["content_id"] = ""
                        continue

                    state["playing"] = payload.get("playing", False)
                    state["bundle"] = payload.get("bundleIdentifier") or ""
                    state["elapsed_micros"] = payload.get("elapsedTimeMicros") or 0
                    state["duration_micros"] = payload.get("durationMicros") or 0
                    state["timestamp_micros"] = payload.get("timestampEpochMicros") or 0

                    cid = payload.get("contentItemIdentifier") or ""
                    title = payload.get("title") or ""
                    artist = payload.get("artist") or ""

                    if cid and cid != last_content_id:
                        last_content_id = cid
                        state["title"] = title
                        state["artist"] = artist
                        state["content_id"] = cid
                        threading.Thread(
                            target=lambda: set_artwork(fetch_artwork()),
                            daemon=True,
                        ).start()

            proc.wait()
        except Exception:
            pass
        time.sleep(1)


def format_micros(us):
    if not us or us < 0:
        return "0:00"
    s = us // 1_000_000
    return f"{s // 60}:{s % 60:02d}"


had_content = False


def trigger():
    """Fire sketchybar trigger with current state."""
    global had_content

    with state_lock:
        t = state["title"]
        a = state["artist"]
        p = state["playing"]
        b = state["bundle"]
        art = state["artwork_path"]
        elapsed = state["elapsed_micros"]
        duration = state["duration_micros"]
        ts = state["timestamp_micros"]
        alb = state["album"]

    if t:
        had_content = True
    elif had_content:
        had_content = False
    else:
        return

    if p and ts > 0:
        elapsed += int(time.time() * 1_000_000) - ts

    subprocess.run(
        [
            "sketchybar", "--trigger", "media_update",
            f"title={t}",
            f"artist={a}",
            f"state={'playing' if p else 'paused'}",
            f"bundle={b}",
            f"artwork={art}",
            f"elapsed={format_micros(elapsed)}",
            f"duration={format_micros(duration)}",
            f"elapsed_micros={elapsed}",
            f"duration_micros={duration}",
            f"album={alb}",
        ],
        capture_output=True,
    )


def initial_fetch():
    """Populate state from one-shot get so the bar shows immediately."""
    try:
        r = subprocess.run(
            [MEDIA_CONTROL, "get", "--micros"],
            capture_output=True, text=True, timeout=5,
        )
        payload = json.loads(r.stdout)
        # get outputs payload directly (no wrapper)
        if payload and isinstance(payload, dict):
            with state_lock:
                state["title"] = payload.get("title") or ""
                state["artist"] = payload.get("artist") or ""
                state["album"] = payload.get("album") or ""
                state["playing"] = payload.get("playing", False)
                state["bundle"] = payload.get("bundleIdentifier") or ""
                state["elapsed_micros"] = payload.get("elapsedTimeMicros") or 0
                state["duration_micros"] = payload.get("durationMicros") or 0
                state["timestamp_micros"] = payload.get("timestampEpochMicros") or 0
                state["content_id"] = payload.get("contentItemIdentifier") or ""
                global last_content_id
                last_content_id = state["content_id"]
    except Exception:
        pass

    threading.Thread(target=lambda: set_artwork(fetch_artwork()), daemon=True).start()


def main():
    initial_fetch()
    thread = threading.Thread(target=stream_reader, daemon=True)
    thread.start()
    while True:
        trigger()
        time.sleep(1)


if __name__ == "__main__":
    signal.signal(signal.SIGINT, lambda s, f: sys.exit(0))
    signal.signal(signal.SIGTERM, lambda s, f: sys.exit(0))
    main()
