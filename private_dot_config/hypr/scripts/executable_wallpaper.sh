#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MPVPAPER_PROCESS_NAME="mpvpaper"
WPAPERD_PROCESS_NAME="wpaperd"
MPVPAPER_START_CMD="$SCRIPT_DIR/mpv_wallpaper.sh --start"
WPAPERD_START_CMD="wpaperd -d"

start_mpvpaper() {
    echo "Startar $MPVPAPER_PROCESS_NAME från $SCRIPT_DIR..."
    eval "$MPVPAPER_START_CMD &"
    echo "$MPVPAPER_PROCESS_NAME har instruerats att starta."
}

stop_mpvpaper() {
    echo "Försöker stoppa $MPVPAPER_PROCESS_NAME..."
    if killall "$MPVPAPER_PROCESS_NAME" >/dev/null 2>&1; then
        echo "$MPVPAPER_PROCESS_NAME stoppad."
    else
        echo "$MPVPAPER_PROCESS_NAME kördes troligen inte eller kunde inte stoppas."
    fi
}

start_wpaperd() {
    echo "Startar $WPAPERD_PROCESS_NAME..."
    eval "$WPAPERD_START_CMD &"
    echo "$WPAPERD_PROCESS_NAME har instruerats att starta."
}

stop_wpaperd() {
    echo "Försöker stoppa $WPAPERD_PROCESS_NAME..."
    if killall "$WPAPERD_PROCESS_NAME" >/dev/null 2>&1; then
        echo "$WPAPERD_PROCESS_NAME stoppad."
    else
        echo "$WPAPERD_PROCESS_NAME kördes troligen inte eller kunde inte stoppas."
    fi
}

if [ "$1" == "--toggle" ]; then
    echo "Flaggan --toggle upptäckt. Kör växling av bakgrundsmotor..."

    if pgrep -x "$MPVPAPER_PROCESS_NAME" >/dev/null; then
        echo "$MPVPAPER_PROCESS_NAME är aktiv. Byter till $WPAPERD_PROCESS_NAME."
        stop_mpvpaper
        sleep 0.5
        start_wpaperd
    else
        echo "$MPVPAPER_PROCESS_NAME är inte aktiv. Byter till (eller återgår till) $MPVPAPER_PROCESS_NAME."
        stop_wpaperd
        start_mpvpaper
    fi
    echo "Toggle-funktionen är slutförd."
else
  source $SCRIPT_DIR/mpv_wallpaper.sh
fi
