#!/usr/bin/env bash

MPV_SOCKET="/tmp/mpvpaper_socket"

if [[ ! -S "$MPV_SOCKET" ]]; then
    echo "mpv IPC-socket saknas. Är mpvpaper igång?" >&2
    exit 1
fi

CHAPTERS_JSON=$(echo '{ "command": ["get_property", "chapters"] }' | socat - "$MPV_SOCKET")

if [[ -z "$CHAPTERS_JSON" || "$CHAPTERS_JSON" == *"error"* ]]; then
    echo "Inga kapitel hittades." >&2
    exit 1
fi

CHAPTERS=$(echo "$CHAPTERS_JSON" | jq -r '.data[] | "\(.title) (\(.start))"' )
SELECTED=$(echo "$CHAPTERS" | wofi --dmenu -p "Välj kapitel")
START_TIME=$(echo "$SELECTED" | grep -oP '\(\K[0-9.]+(?=\))')

if [[ -n "$START_TIME" ]]; then
    echo '{ "command": ["seek", '"$START_TIME"', "absolute"] }' | socat - "$MPV_SOCKET" > /dev/null 2>&1
fi

