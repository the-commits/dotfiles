#!/bin/bash

if pgrep -x "hypridle" > /dev/null; then
  notify-send "idle inhibitor deactivated"
  killall -9 hypridle
else
  notify-send "idle inhibitor activated"
  hypridle &> /dev/null &
fi

