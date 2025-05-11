#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VOLUME_FILE="$SCRIPT_DIR/.mpv_wallpaper_volume"
DEFAULT_VOLUME=50
MPV_SOCKET="/tmp/mpvpaper_socket"

if [[ -f "$VOLUME_FILE" ]]; then
    VOLUME=$(cat "$VOLUME_FILE")
else
    VOLUME=$DEFAULT_VOLUME
    echo $VOLUME > "$VOLUME_FILE"
fi

mpvpaper -o "--input-ipc-server=$MPV_SOCKET --volume=50 --panscan=1 --loop-playlist" \
        "HDMI-A-1" "/home/the-commits/Video/Wallpapers/Chill_Music_Depp_FOCUS_Inspiring_Mix.web" > /dev/null 2>&1 &
mpvpaper -o "no-audio --panscan=1 --loop-playlist" \
        "eDP-2" "/home/the-commits/Video/Wallpapers/4210523-uhd_3840_2160_24fps.mp4" > /dev/null 2>&1 &

