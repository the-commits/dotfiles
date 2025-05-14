#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config_file="$SCRIPT_DIR/mpv_wallpaper_config.sh"

if [ -f "$config_file" ]; then
  source "$config_file"
else
  echo "Kunde inte hitta konfigurationsfilen: $config_file" >&2
  exit 1
fi

# Funktion för att hämta aktuell videofil från indexfilen
get_current_video() {
  if [ -f "$INDEX_FILE" ]; then
    current_index=$(cat "$INDEX_FILE")
    if [[ -z "$current_index" || ! "$current_index" =~ ^[0-9]+$ ]]; then
      echo "Ogiltigt index i: $INDEX_FILE" >&2
      return 1
    fi
    video_dir="$VIDEO_WALLPAPER_DIR"
    video_files=($(find "$video_dir" -maxdepth 1 -type f \( -name "*.webm" -o -name "*.mp4" -o -name "*.mkv" \) -print0 | sort -z | tr '\0' '\n'))
    if [[ "$current_index" -ge "${#video_files[@]}" ]]; then
      echo "Indexet är utanför arrayens gränser." >&2
      return 1
    fi
    echo "${video_files[$current_index]}"
    return 0
  else
    echo "Kunde inte hitta indexfilen: $INDEX_FILE" >&2
    return 1
  fi
}

# === Funktioner ===
load_volume() {
  [[ -f "$VOLUME_FILE" ]] && VOLUME=$(<"$VOLUME_FILE") || VOLUME=$DEFAULT_VOLUME
}

save_volume() {
  echo "$VOLUME" > "$VOLUME_FILE"
}

update_volume() {
  [[ $VOLUME -gt 100 ]] && VOLUME=100
  [[ $VOLUME -lt 0 ]] && VOLUME=0

  save_volume
  send_ipc '{ "command": ["set_property", "volume", '"$VOLUME"'] }'
}

load_chapter() {
  # För säkerhets skull, läs inte kapitlet från IPC vid start varje gång
  CHAPTER=$DEFAULT_CHAPTER
}

update_chapter() {
  [[ $CHAPTER -lt 0 ]] && CHAPTER=0
  send_ipc '{ "command": ["set_property", "chapter", '$CHAPTER'] }'
}

send_ipc() {
  [[ -S "$MPV_SOCKET" ]] && echo "$1" | socat - "$MPV_SOCKET" > /dev/null 1>&1
}

get_ipc() {
  [[ -S "$MPV_SOCKET" ]] && echo "$1" | socat - "$MPV_SOCKET" | jq .data
}

init() {
  local wallpaper_1_arg="$WALLPAPER_1"
  if [[ ! -z "$start_wallpaper" ]]; then
    wallpaper_1_arg="$start_wallpaper"
  fi

  mpvpaper -o "--input-ipc-server=$MPV_SOCKET  --volume=$VOLUME --panscan=1 --loop-playlist" \
    "$DISPLAY_1" "$wallpaper_1_arg" > /dev/null 2>&1 &

  mpvpaper -o "no-audio --panscan=1 --loop-playlist" \
    "$DISPLAY_2" "$WALLPAPER_2" > /dev/null 2>&1 &
}

# === Argumenthantering ===
load_volume
start_wallpaper=""

case "$1" in
  --start)
    if [[ ! -z "$2" ]]; then
      start_wallpaper="$2"
    fi
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
    if get_current_video current_video_path; then
      CHAPTER=$(get_ipc '{ "command": ["get_property", "chapter"] }')
      CHAPTER=$((CHAPTER + 1))
      update_chapter "$CHAPTER"
    fi
    exit 0
    ;;
  --chapter-prev)
    if get_current_video current_video_path; then
      CHAPTER=$(get_ipc '{ "command": ["get_property", "chapter"] }')
      CHAPTER=$((CHAPTER - 1))
      update_chapter "$CHAPTER"
    fi
    exit 0
    ;;
  --chapter)
    [[ "$2" =~ ^[0-9]+$ ]] && CHAPTER="$2"
    update_chapter "$CHAPTER"
    exit 0
    ;;
  *)
    echo "Användning:"
    echo "  $0 --start[=<video_path>]"
    echo "  $0 --volume-up | --volume-down | --volume <0–100>"
    echo "  $0 --chapter-next | --chapter-prev [--chapter <n>]"
    exit 1
    ;;
esac

