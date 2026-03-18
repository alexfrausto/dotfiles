#!/usr/bin/env bash

configs=$(osascript -e 'tell application "Tunnelblick" to get name of configurations' | tr ',' '\n' | sed -e 's/^[[:space:]]*//')

if [[ -z "$configs" ]]; then
    echo "No VPN configurations found in Tunnelblick."
    sleep 2
    exit 1
fi

options="Disconnect All\n$configs"

selected=$(echo -e "$options" | sk --margin 10% --color="bw" --prompt="🛡️  VPN > ")

[[ -z "$selected" ]] && exit 0

if [[ "$selected" == "Disconnect All" ]]; then
    osascript -e 'tell application "Tunnelblick" to disconnect all'
    exit 0
fi

osascript -e 'tell application "Tunnelblick" to disconnect all'

sleep 1 

osascript -e "tell application \"Tunnelblick\" to connect \"$selected\""
