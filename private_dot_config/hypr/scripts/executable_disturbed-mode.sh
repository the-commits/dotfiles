#!/usr/bin/env bash


WORKING_HOUR_START="08:00"
WORKING_HOUR_END="17:00"
CURRENT_TIME=$(date +%H:%M)
CURRENT_DAY=$(date +%w)

check_if_work_time()
{
  if [[ "$CURRENT_DAY" < "6" ]]; then
    if [[ "$CURRENT_TIME"  > "$WORKING_HOUR_START" ]] && [[ "$CURRENT_TIME" < "$WORKING_HOUR_END" ]]; then
      notify-send --app-name "disturbed-mode.sh" -t 5000 -u normal 'Slår på "Do Not Disturb"'
      makoctl mode -s do-not-disturb
    else
      notify-send --app-name "disturbed-mode.sh" -t 5000 -u low 'Slår av "Do not Disturb"'
      makoctl mode -s default 
    fi
  else
    notify-send --app-name "disturbed-mode.sh" -t 5000 -u low 'Slår av "Do not Disturb"'
    makoctl mode -s default 
  fi
}

check_if_work_time
