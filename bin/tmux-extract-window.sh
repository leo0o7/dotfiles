#!/bin/bash

active_window_name=$(tmux lsw | awk '/active/ { sub(/\*.*/, "", $2); print $2 }')

tmux new -dP -s "$active_window_name"
tmux movew -s ":$active_window_name" -t "$active_window_name:1"
tmux kill-window -t ":$active_window_name"

if tmux ls | grep attached; then
  tmux switch-client -t "$active_window_name"
else
  tmux a -t "$active_window_name"
fi
