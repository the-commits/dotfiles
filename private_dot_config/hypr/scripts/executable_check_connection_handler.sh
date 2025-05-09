#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
$SCRIPT_DIR/check_connection.sh

if [ $? -eq 0 ]; then
    echo "Internet verkar fungera! 🌍"
else
    echo "Ingen internetanslutning. 😢"
fi

