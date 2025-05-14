#!/usr/bin/env bash

# === Konfiguration ===
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VOLUME_FILE="$SCRIPT_DIR/.mpv_wallpaper_volume"
MPV_WALLPAPER_SCRIPT="$SCRIPT_DIR/mpv_wallpaper.sh"
WALLPAPER_DIR="$HOME/Video/Wallpapers"
VIDEO_WALLPAPER_DIR="$WALLPAPER_DIR/Musikbakgrund"
MPV_SOCKET="/tmp/mpvpaper_socket"
DEFAULT_VOLUME=50
STEP=5
DEFAULT_CHAPTER=0

# === Paths & Displays ===
DISPLAY_1="eDP-2"
DISPLAY_2="HDMI-A-1"

# === Check connection ===
HAZ_CONNECTION=$SCRIPT_DIR/check_connection.sh

if $HAZ_CONNECTION; then
  WALLPAPER_1="$VIDEO_WALLPAPER_DIR/neon-city-music.webm"
  WALLPAPER_2="$WALLPAPER_DIR/spirit-tree.webm"
else
  WALLPAPER_1="$VIDEO_WALLPAPER_DIR/neon-city-music.webm"
  WALLPAPER_2="$WALLPAPER_DIR/spirit-tree.webm"
fi
