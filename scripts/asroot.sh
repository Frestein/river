#!/bin/sh

rdir="$HOME/.config/river"

# rofi sudo askpass helper
export SUDO_ASKPASS="$rdir/scripts/bemenu_askpass"

# execute the application
sudo -A $1
