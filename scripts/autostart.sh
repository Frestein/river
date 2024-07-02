#!/bin/sh

# River directory
dir="$HOME/.config/river"

# Lauch statusbar
if [[ $(pidof yambar) ]]; then
  pkill yambar
fi
yambar -c "$dir/yambar/config.yml" &

# Set wallpaper
if [[ $(pidof wbg) ]]; then
  pkill wbg
fi
wbg "$dir/themes/nord/wallpaper" &

# Launch dunst daemon
if [[ $(pidof dunst) ]]; then
  pkill dunst
fi
dunst -config "$dir/dunstrc" &

## Mount Google Drive
if [[ ! $(pidof rclone) ]]; then
  rclone mount --daemon GoogleDriveMain: "$HOME/Google Drive" &
fi

# Launch jamesdsp
if [[ ! $(pidof jamesdsp) ]]; then
  jamesdsp -t &
fi