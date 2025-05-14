#!/usr/bin/env bash

config_file="$HOME/.config/hypr/scripts/mpv_wallpaper_config.sh"

if [ -f "$config_file" ]; then
  source "$config_file"
else
  echo "Kunde inte hitta konfigurationsfilen: $config_file"
  exit 1
fi

if [ -z "$VIDEO_WALLPAPER_DIR" ]; then
  echo "Variabeln VIDEO_WALLPAPER_DIR är inte definierad i konfigurationsfilen."
  exit 1
fi

video_files=($(find "$VIDEO_WALLPAPER_DIR" -maxdepth 1 -type f \( -name "*.webm" -o -name "*.mp4" -o -name "*.mkv" \) -print0 | sort -z | tr '\0' '\n'))

if [ ${#video_files[@]} -eq 0 ]; then
  echo "Inga webm-, mp4- eller mkv-filer hittades i katalogen: $VIDEO_WALLPAPER_DIR"
  exit 0
fi

# Läs current_index från filen, om den finns
if [ -f "$INDEX_FILE" ]; then
  current_index=$(cat "$INDEX_FILE")
else
  # Om filen inte finns, initiera current_index till 0
  current_index=0
fi

echo "Innehåll i video_files array:"
for file in "${video_files[@]}"; do
  echo "$file"
done

next_wallpaper() {
  if [ ${#video_files[@]} -gt 0 ]; then
    next_index=$(( (current_index + 1) % ${#video_files[@]} ))
    current_index="$next_index"
    next_wallpaper_path="${video_files[$current_index]}"

    # Spara current_index till filen
    echo "$current_index" > "$INDEX_FILE"

    "$SCRIPT_DIR/mpv_wallpaper.sh" --start "$next_wallpaper_path"
    echo "Current index: $current_index"
  else
    echo "Inga videofiler att visa."
  fi
}

previous_wallpaper() {
  if [ ${#video_files[@]} -gt 0 ]; then
    previous_index=$(( (current_index - 1 + ${#video_files[@]}) % ${#video_files[@]} ))
    current_index="$previous_index"
    previous_wallpaper_path="${video_files[$current_index]}"

    # Spara current_index till filen
    echo "$current_index" > "$INDEX_FILE"

    "$SCRIPT_DIR/mpv_wallpaper.sh" --start "$previous_wallpaper_path"
    echo "Current index: $current_index"
  else
    echo "Inga videofiler att visa."
  fi
}

# Kör nästa bakgrundsbild om skriptet anropas med 'next_wallpaper'
if [ "$1" = "next_wallpaper" ]; then
  next_wallpaper
fi

# Kör föregående bakgrundsbild om skriptet anropas med 'previous_wallpaper'
if [ "$1" = "previous_wallpaper" ]; then
  previous_wallpaper
fi
