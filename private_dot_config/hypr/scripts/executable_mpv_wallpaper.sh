#!/usr/bin/env bash

# === Konfiguration ===
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VOLUME_FILE="$SCRIPT_DIR/.mpv_wallpaper_volume"
CHAPTER_FILE="$SCRIPT_DIR/.mpv_wallpaper_chapter"
MPV_SOCKET="/tmp/mpvpaper_socket"
DEFAULT_VOLUME=50
STEP=5
DEFAULT_CHAPTER=0

# === Paths & Displays ===
DISPLAY_1="eDP-2"
DISPLAY_2="HDMI-A-1"

if $SCRIPT_DIR/check_connection.sh; then
  # eDP Playlist
  WALLPAPER_1="$HOME/Video/Wallpapers/neon-city-music.webm"
  WALLPAPER_2="$HOME/Video/Wallpapers/spirit-tree.webm"
else
  WALLPAPER_1="$HOME/Video/Wallpapers/neon-city-music.webm"
  WALLPAPER_2="$HOME/Video/Wallpapers/spirit-tree.webm"
fi
  

# === Funktioner ===
load_volume() {
    [[ -f "$VOLUME_FILE" ]] && VOLUME=$(<"$VOLUME_FILE") || VOLUME=$DEFAULT_VOLUME
}

save_volume() {
    echo "$VOLUME" > "$VOLUME_FILE"
}

update_volume() {
  # === Volymhantering om IPC är aktiv ===
  $VOLUME=$1
  [[ $VOLUME -gt 100 ]] && VOLUME=100
  [[ $VOLUME -lt 0 ]] && VOLUME=0

  save_volume
  send_ipc '{ "command": ["set_property", "volume", '"$VOLUME"'] }'
}

load_chapter() {
    [[ -f "$CHAPTER_FILE" ]] && CHAPTER=$(<"$CHAPTER_FILE") || CHAPTER=$DEFAULT_CHAPTER
}

save_chapter() {
    echo "$CHAPTER" > "$CHAPTER_FILE"
}

update_chapter() {
  $CHAPTER=$1
  [[ $CHAPTER -lt 0 ]] && CHAPTER=0

  save_chapter
  send_ipc '{ "command": ["set_property", "chapter", '$CHAPTER'] }'
}

send_ipc() {
    [[ -S "$MPV_SOCKET" ]] && echo "$1" | socat - "$MPV_SOCKET" > /dev/null 2>&1
}

init() {
    mpvpaper -o "--input-ipc-server=$MPV_SOCKET --volume=$VOLUME --panscan=1 --loop-playlist" \
        "$DISPLAY_1" "$WALLPAPER_1" > /dev/null 2>&1 &

    mpvpaper -o "no-audio --panscan=1 --loop-playlist" \
        "$DISPLAY_2" "$WALLPAPER_2" > /dev/null 2>&1 &
}

# === Argumenthantering ===
load_volume
load_chapter

case "$1" in
    --start)
        pkill -f "mpvpaper"
        sleep 1
        [[ -S "$MPV_SOCKET" ]] && rm -f "$MPV_SOCKET"
        init
        exit 0
        ;;
    --volume-up)
        VOLUME=$((VOLUME + STEP))
        update_volume $VOLUME
        exit 0
        ;;
    --volume-down)
        VOLUME=$((VOLUME - STEP))
        update_volume $VOLUME
        exit 0
        ;;
    --volume)
        [[ "$2" =~ ^[0-9]+$ ]] && VOLUME="$2"
        update_volume $VOLUME
        exit 0
        ;;
    --chapter-next)
        CHAPTER=$((CHAPTER + 1))
        update_chapter $CHAPTER
        exit 0
        ;;
    --chapter-prev)
        CHAPTER=$((CHAPTER - 1))
        update_chapter $CHAPTER
        exit 0
        ;;
    --chapter)
        [[ "$2" =~ ^[0-9]+$ ]] && CHAPTER="$2"
        update_chapter $CHAPTER
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
