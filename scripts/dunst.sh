#!/bin/sh

# River directory
rdir="$HOME/.config/river"

# Launch dunst daemon
if [[ $(pidof dunst) ]]; then
  pkill dunst
fi

dunst -config "$rdir/dunstrc" &
