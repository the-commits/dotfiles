#!/usr/bin/env bash

# === Konfiguration ===
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VOLUME_FILE="$SCRIPT_DIR/.mpv_wallpaper_volume"
MPV_SOCKET="/tmp/mpvpaper_socket"
DEFAULT_VOLUME=50
STEP=5

# === Paths & Displays ===
DISPLAY_1="eDP-2"
DISPLAY_2="HDMI-A-1"

if $SCRIPT_DIR/check_connection.sh; then
  # eDP Playlist
  WALLPAPER_1="$HOME/Video/Wallpapers/pink-tree.mp4.webm"
  # WALLPAPER_1="https://www.youtube.com/watch?v=cjF-9In3hqU&list=PLA3yWitmH0O8bTvH4UDTUuBVmN0ZDxZ6R"
  # WALLPAPER_1="https://www.youtube.com/watch?v=CxtIMm68Fbs"
  # WALLPAPER_1="https://www.youtube.com/watch?v=cjF-9In3hqU"
else
  WALLPAPER_1="$HOME/Video/Wallpapers/pink-tree.mp4.webm"
  # WALLPAPER_1="$HOME/Video/Wallpapers/Chill_Music_Depp_FOCUS_Inspiring_Mix.webm"
fi
  
WALLPAPER_2="$HOME/Video/Wallpapers/pink-tree.mp4.webm"
# === Funktioner ===

load_volume() {
    [[ -f "$VOLUME_FILE" ]] && VOLUME=$(<"$VOLUME_FILE") || VOLUME=$DEFAULT_VOLUME
}

save_volume() {
    echo "$VOLUME" > "$VOLUME_FILE"
}

send_ipc() {
    [[ -S "$MPV_SOCKET" ]] && echo "$1" | socat - "$MPV_SOCKET" > /dev/null 2>&1
}

init() {
    mpvpaper -o "no-audio --input-ipc-server=$MPV_SOCKET --volume=$VOLUME --panscan=1 --loop-playlist shuffle" \
        "$DISPLAY_1" "$WALLPAPER_1" > /dev/null 2>&1 &

    mpvpaper -o "no-audio --panscan=1 --loop-playlist" \
        "$DISPLAY_2" "$WALLPAPER_2" > /dev/null 2>&1 &
}

# === Argumenthantering ===
load_volume

case "$1" in
    --start)
        pkill -f "mpvpaper"
        sleep 1
        [[ -S "$MPV_SOCKET" ]] && rm -f "$MPV_SOCKET"
        init
        exit 0
        ;;
    --volume)
        [[ "$2" =~ ^[0-9]+$ ]] && VOLUME="$2"
        ;;
    --volume-up)
        VOLUME=$((VOLUME + STEP))
        ;;
    --volume-down)
        VOLUME=$((VOLUME - STEP))
        ;;
    --chapter-next)
        send_ipc '{ "command": ["seek", "1", "chapter-relative"] }'
        exit 0
        ;;
    --chapter-prev)
        send_ipc '{ "command": ["seek", "-1", "chapter-relative"] }'
        exit 0
        ;;
    *)
        echo "Användning:"
        echo "  $0 --start"
        echo "  $0 --volume-up | --volume-down | --volume <0–100>"
        echo "  $0 --chapter-next | --chapter-prev"
        exit 1
        ;;
esac

# === Volymhantering om IPC är aktiv ===
[[ $VOLUME -gt 100 ]] && VOLUME=100
[[ $VOLUME -lt 0 ]] && VOLUME=0

save_volume
send_ipc '{ "command": ["set_property", "volume", '"$VOLUME"'] }'

