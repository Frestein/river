#!/bin/sh

# River directory
dir="$HOME/.config/river"

# Kill launched swww daemon
if [[ $(pidof swww-daemon) ]]; then
  pkill swww-daemon
fi

# Launch swww daemon
swww-daemon &

# Set wallpaper
swww img "$dir/themes/nord/wallpaper" &
