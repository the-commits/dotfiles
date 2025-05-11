#!/usr/bin/env bash

if ping -c 1 -q -W 2 google.com | grep -q '1 received'; then
    exit 0
else
    exit 1
fi
