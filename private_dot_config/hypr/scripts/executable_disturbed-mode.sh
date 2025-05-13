#!/usr/bin/env bash

WORKING_HOUR_START="08:00"
WORKING_HOUR_END="17:00"
CURRENT_TIME=$(date +%H:%M)
CURRENT_DAY=$(date +%w)

get_current_mode() {
  makoctl mode
}

check_if_work_time() {
  local new_mode
  local current_mode=$(get_current_mode)

  if [[ "$CURRENT_DAY" -lt "6" ]]; then
    if [[ "$CURRENT_TIME" > "$WORKING_HOUR_START" ]] && [[ "$CURRENT_TIME" < "$WORKING_HOUR_END" ]]; then
      new_mode="do-not-disturb"
    else
      new_mode="default"
    fi
  else
    new_mode="default"
  fi

  if [[ "$new_mode" != "$current_mode" ]]; then
    makoctl mode -s "$new_mode"
    if [[ "$new_mode" == "do-not-disturb" ]]; then
      notify-send --app-name "disturbed-mode.sh" -t 5000 -u normal 'Slår på "Do Not Disturb"'
    else
      notify-send --app-name "disturbed-mode.sh" -t 5000 -u low 'Slår av "Do Not Disturb"'
    fi
  fi
}

check_if_work_time
