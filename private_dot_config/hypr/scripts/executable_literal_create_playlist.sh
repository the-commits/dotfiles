#!/usr/bin/env bash

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Användning: $0 /sökväg/till/filer /sökväg/till/ny/playlist.m3u"
  exit 1
fi

TARGET_DIR="$1"
PLAYLIST_OUTPUT_DIR="$(dirname "$2")"
PLAYLIST_FILE="$2"
mkdir -p "$PLAYLIST_OUTPUT_DIR"

if [ ! -d "$TARGET_DIR" ]; then
  echo "Fel: Katalogen '$TARGET_DIR' existerar inte."
  exit 2
fi

echo "#EXTM3U" > "$PLAYLIST_FILE"
find "$TARGET_DIR" -type f \( -iname "*.mp4" -o -iname "*.webm" \) | sort >> "$PLAYLIST_FILE"

echo "Spellista skapad i: $PLAYLIST_FILE"
