#!/usr/bin/env bash


case "$1" in
  --in)
    hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor | awk '/^float.*/ {print $2 * 1.1}')
  ;;
--out)
    hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor | awk '/^float.*/ {print $2 * 0.9}')
  ;;
  *)
    echo "Användning:"
    echo "  $0 --in"
    echo "  $0 --out"
    exit 1
  ;;
esac
