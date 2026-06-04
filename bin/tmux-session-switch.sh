#!/bin/bash

selected=$(tmux ls | awk '{print $1}' | fzf --tmux)

if [[ -z $selected ]]; then
  exit 0
fi

if tmux ls | grep -q attached; then
  tmux switch-client -t "$selected"
else
  tmux attach-session -t "$selected"
fi
