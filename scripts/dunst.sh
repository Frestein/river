#!/bin/sh

# River directory
dir="$HOME/.config/river"

# Kill launched dunst daemon
if [[ $(pidof dunst) ]]; then
  pkill dunst
fi

# Launch dunst daemon
dunst -config "$dir/dunstrc" &
