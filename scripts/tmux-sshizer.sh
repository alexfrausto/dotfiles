#!/usr/bin/env bash

hosts=$(awk '/^Host / && $2 != "*" {print $2}' ~/.ssh/config)

if [[ -z "$hosts" ]]; then
    echo "No hosts found in ~/.ssh/config. Please add some!"
    sleep 2
    exit 1
fi

selected_host=$(echo "$hosts" | sk --margin 10% --color="bw" --prompt="🌐 SSH > ")

[[ -z "$selected_host" ]] && exit 0

session_name="server_${selected_host//./_}"
tmux_running=$(pgrep tmux)

if ! tmux has-session -t "$session_name" 2> /dev/null; then
    tmux new-session -ds "$session_name" "ssh $selected_host"
    
    tmux rename-window -t "$session_name:1" "remote"
fi

if [[ -z "$TMUX" ]] && [[ -z "$tmux_running" ]]; then
    tmux attach-session -t "$session_name"
elif [[ -z "$TMUX" ]]; then
    tmux attach-session -t "$session_name"
else
    tmux switch-client -t "$session_name"
fi
