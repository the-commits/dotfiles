#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VOLUME_FILE="$SCRIPT_DIR/.mpv_wallpaper_volume"
DEFAULT_VOLUME=50
STEP=5
MPV_SOCKET="/tmp/mpvpaper_socket"

if [[ -f "$VOLUME_FILE" ]]; then
    VOLUME=$(cat "$VOLUME_FILE")
else
    VOLUME=$DEFAULT_VOLUME
    echo $VOLUME > "$VOLUME_FILE"
fi

case "$1" in
    --volume)
        [[ "$2" =~ ^[0-9]+$ ]] && VOLUME=$2
        ;;
    --volume-up)
        VOLUME=$((VOLUME + STEP))
        ;;
    --volume-down)
        VOLUME=$((VOLUME - STEP))
        ;;
esac

[[ $VOLUME -gt 100 ]] && VOLUME=100
[[ $VOLUME -lt 0 ]] && VOLUME=0
echo $VOLUME > "$VOLUME_FILE"

if [[ -S "$MPV_SOCKET" ]]; then
    echo '{ "command": ["set_property", "volume", '"$VOLUME"'] }' | socat - "$MPV_SOCKET" > /dev/null 2>&1
    exit 0
fi

# Starta om bara om IPC-socket inte finns (dvs mpv kör inte)
# Döda ändå för att vara säker, men bara i detta läge
pkill mpvpaper > /dev/null 2>&1

# Starta mpvpaper med IPC
mpvpaper -o "--input-ipc-server=$MPV_SOCKET --volume=$VOLUME --panscan=1 --loop-playlist" \
    "HDMI-A-1" "https://www.youtube.com/watch?v=-sZqtdT-GVw&t=14s" > /dev/null 2>&1 &

# Starta också den andra utan ljud
mpvpaper -o "no-audio --panscan=1 --loop-playlist" \
    "eDP-2" "/home/the-commits/Video/Wallpapers/4210523-uhd_3840_2160_24fps.mp4" > /dev/null 2>&1 &

