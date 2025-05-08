#!/usr/bin/env bash

if [ -z "$1" ]; then
    echo "Användning: $0 /sökväg/till/filer"
    exit 1
fi

TARGET_DIR="$1"

if [ ! -d "$TARGET_DIR" ]; then
    exit 2
fi

PLAYLIST_FILE="$TARGET_DIR/wallpaper_playlist.m3u"
echo "#EXTM3U" > "$PLAYLIST_FILE"
find "$TARGET_DIR" -type f -iname "*.mp4" | sort >> "$PLAYLIST_FILE"

