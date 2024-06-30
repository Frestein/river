#!/bin/sh

# Qtile directory
rdir="$HOME/.config/river"

# Lauch notification daemon
"$rdir/scripts/dunst.sh"

# Launch statusbar
yambar -c "$rdir/yambar/config.yml" &

# Set wallpaper
swww-daemon &

swww img "$rdir/themes/nord/wallpaper" &

## Mount Google Drive
rclone mount --daemon GoogleDriveMain: "$HOME/Google Drive" &

## Launch jamesdsp
jamesdsp -t &
