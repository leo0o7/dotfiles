#!/bin/bash
MEDIA_CONTROL=/opt/homebrew/bin/media-control
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

$MEDIA_CONTROL stream | python3 "$SCRIPT_DIR/parse_media.py" | while IFS=$'\t' read -r title artist state bundle artwork; do
  sketchybar --trigger media_update \
    "title=$title" \
    "artist=$artist" \
    "state=$state" \
    "bundle=$bundle" \
    "artwork=$artwork"
done
