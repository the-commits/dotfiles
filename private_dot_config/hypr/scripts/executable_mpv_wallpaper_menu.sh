#!/usr/bin/env bash

VIDEO_PATH="$HOME/Video/Wallpapers/neon-city-music.webm"
MPV_WALLPAPER_SCRIPT="$HOME/.config/hypr/scripts/mpv_wallpaper.sh"

if [[ ! -f "$MPV_WALLPAPER_SCRIPT" ]]; then
    echo "Kunde inte hitta mpv_wallpaper.sh på: $MPV_WALLPAPER_SCRIPT" >&2
    exit 1
fi

CHAPTERS_JSON=$(ffprobe -v quiet -print_format json -show_chapters "$VIDEO_PATH")
if [[ -z "$CHAPTERS_JSON" || "$CHAPTERS_JSON" == *"error"* ]]; then
    echo "Inga kapitel hittades i: $VIDEO_PATH" >&2
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
