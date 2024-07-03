#!/bin/sh

# River directory
dir="$HOME/.config/river"

# Fix the non-working xdg-desktop-portal-gtk service
systemctl --user import-environment

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

# Launch foot server
if [[ ! $(pidof foot) ]]; then
  foot --server &
fi

# Launch swayidle
if [[ ! $(pidof swayidle) ]]; then
  swayidle -w \
    timeout 300 "$dir/scripts/waylock.sh" &
fi

# Launch mpd with playerctl mpd-mpris plugin
if [[ ! $(pidof mpd) ]]; then
  mpd &
  wait $!
  mpd-mpris &
elif [[ ! $(pidof mpd-mpris) ]]; then
  mpd-mpris &
fi
