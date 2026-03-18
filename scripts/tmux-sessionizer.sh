#!/bin/bash

DIRS=(
    "$HOME/projects/personal"
    "$HOME/projects/work/qro"
    "$HOME/vaults"
    "$HOME/.config"
)

if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$(fd . "${DIRS[@]}" --type=dir --max-depth=1 --full-path --base-directory $HOME \
        | sed "s|^$HOME/||" \
        | sk --margin 10% --color="bw")

    [[ $selected ]] && selected="$HOME/$selected"
fi

[[ ! $selected ]] && exit 0

selected_name=$(basename "$selected" | tr . _)

if ! tmux has-session -t "$selected_name"; then
    tmux new-session -ds "$selected_name" -c "$selected"

    # Window 1: Rename to 'editor' and instantly launch Neovim
    tmux rename-window -t "$selected_name:1" 'editor'
    tmux send-keys -t "$selected_name:1" 'nvim .' C-m

    # Window 2: Create a background terminal window for CLI tasks
    tmux new-window -t "$selected_name" -n 'term' -c "$selected"
    
    # Focus back on the editor window so you are ready to code immediately
    tmux select-window -t "$selected_name:1"
fi

tmux switch-client -t "$selected_name"
