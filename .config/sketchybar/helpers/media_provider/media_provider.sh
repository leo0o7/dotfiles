#!/bin/bash
MEDIA_CONTROL=/opt/homebrew/bin/media-control
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
$MEDIA_CONTROL stream | python3 "$SCRIPT_DIR/parse_media.py" 2>>/tmp/sketchybar_media.log | while IFS=$'\t' read -r title artist state bundle artwork; do
  echo "[$(date +%H:%M:%S)] state=$state title=$title artwork=$artwork" >>/tmp/sketchybar_media.log
  sketchybar --trigger media_update \
    "title=$title" \
    "artist=$artist" \
    "state=$state" \
    "bundle=$bundle" \
    "artwork=$artwork"
done
