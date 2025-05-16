#!/usr/bin/env bash

# Sökväg till mpv's IPC-socket.
# !!! Synka denna med MPV_SOCKET i ditt mpv_wallpaper.sh !!!
MPV_SOCKET_PATH="/tmp/mpv_wallpaper.sock" # Exempel, matcha ditt mpv_wallpaper.sh
CHAPTER_INFO=""

# Försök hämta kapitelinformation om socketen är aktiv
if nc -U "$MPV_SOCKET_PATH" -w 1 <<< '{}' >/dev/null 2>&1; then
    json_query='{ "command": ["get_property", "chapter"] }
    { "command": ["get_property", "chapters"] }
    { "command": ["get_property", "path"] }
    { "command": ["get_property", "chapter-metadata/title"] }'

    response=$(echo -e "$json_query" | socat - "$MPV_SOCKET_PATH" 2>/dev/null)

    if [ -n "$response" ]; then
        current_chapter_num_json=$(echo "$response" | sed -n '1p')
        total_chapters_json=$(echo "$response" | sed -n '2p')
        media_path_json=$(echo "$response" | sed -n '3p')
        chapter_title_json=$(echo "$response" | sed -n '4p')

        current_chapter_num=$(echo "$current_chapter_num_json" | jq '.data // null')
        total_chapters=$(echo "$total_chapters_json" | jq '.data // 0')
        media_path=$(echo "$media_path_json" | jq -r '.data // ""')
        chapter_title=$(echo "$chapter_title_json" | jq -r '.data // ""')

        if [ -n "$media_path" ] && [ "$media_path" != "null" ] && \
           [ "$current_chapter_num" != "null" ] && [ "$current_chapter_num" -ge 0 ] && \
           [ "$total_chapters" -gt 0 ]; then
            
            display_chapter_num=$((current_chapter_num + 1))

            if [ -n "$chapter_title" ] && [ "$chapter_title" != "null" ]; then
                CHAPTER_INFO="Kap. $display_chapter_num: $chapter_title"
            else
                CHAPTER_INFO="Kap. $display_chapter_num/$total_chapters"
            fi
        fi
    fi
fi

if [ -z "$CHAPTER_INFO" ]; then
    ACTIVE_WINDOW_TITLE=$(hyprctl activewindow -j | jq -r '.title // ""' 2>/dev/null)

    if [ -z "$ACTIVE_WINDOW_TITLE" ]; then
        echo "A whole lotta nuthin'" # Din klassiker!
    else
        echo "$ACTIVE_WINDOW_TITLE"
    fi
else
    echo "$CHAPTER_INFO"
fi
