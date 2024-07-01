#!/bin/sh

# River directory
dir="$HOME/.config/river"

# Launch statusbar
"$dir/scripts/yambar.sh"

# Set wallpaper
"$dir/scripts/swww.sh"

# Lauch notification daemon
"$dir/scripts/dunst.sh"

## Mount Google Drive
if [[ ! $(pidof rclone) ]]; then
  rclone mount --daemon GoogleDriveMain: "$HOME/Google Drive" &
fi

# Launch jamesdsp
if [[ ! $(pidof jamesdsp) ]]; then
  jamesdsp -t &
fi
