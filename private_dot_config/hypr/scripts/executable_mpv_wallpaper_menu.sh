i#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config_file="$SCRIPT_DIR/mpv_wallpaper_config.sh"
index_file="$SCRIPT_DIR/mpv_wallpaper_index"

if [ -f "$config_file" ]; then
  source "$config_file"
else
  echo "Kunde inte hitta konfigurationsfilen: $config_file" >&2
  exit 1
fi

video_dir="$VIDEO_WALLPAPER_DIR"
video_files=($(find "$video_dir" -maxdepth 1 -type f \( -name "*.webm" -o -name "*.mp4" -o -name "*.mkv" \) -print0 | sort -z | tr '\0' '\n'))

if [ ! -f "$index_file" ]; then
  echo "Kunde inte hitta indexfilen: $index_file" >&2
  exit 1
fi

current_index=$(cat "$index_file")

if [[ -z "$current_index" || ! "$current_index" =~ ^[0-9]+$ ]]; then
  echo "Ogiltigt index i: $index_file" >&2
  exit 1
fi

if [[ "$current_index" -ge "${#video_files[@]}" ]]; then
  echo "Indexet är utanför arrayens gränser." >&2
  exit 1
fi

current_video="${video_files[$current_index]}"

if [[ -z "$current_video" ]]; then
  echo "Kunde inte hitta aktuell video." >&2
  exit 1
fi

CHAPTERS_JSON=$(ffprobe -v quiet -print_format json -show_chapters "$current_video")
if [[ -z "$CHAPTERS_JSON" || "$CHAPTERS_JSON" == *"error"* ]]; then
  echo "Inga kapitel hittades i: $current_video" >&2
  exit 1
fi

TITLES_ARRAY=$(echo "$CHAPTERS_JSON" | jq -r '.chapters[].tags.title')
if [[ -z "$TITLES_ARRAY" ]]; then
  echo "Kunde inte extrahera några titlar." >&2
  exit 1
fi

SELECTED_TITLE=$(echo "$TITLES_ARRAY" | wofi --dmenu -p "Välj kapitel")
if [[ -n "$SELECTED_TITLE" ]]; then
  CHAPTER_INDEX=$(echo "$TITLES_ARRAY" | awk -v title="$SELECTED_TITLE" '$0 == title {print NR; exit}')
  if [[ -n "$CHAPTER_INDEX" ]]; then
    CHAPTER_NUMBER=$((CHAPTER_INDEX - 1))
    "$MPV_WALLPAPER_SCRIPT" --chapter "$CHAPTER_NUMBER"
  fi
fi
