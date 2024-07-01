#!/bin/sh

# River directory
dir="$HOME/.config/river"

# Bemenu sudo askpass helper
export SUDO_ASKPASS="$dir/scripts/bemenu_askpass"

# Execute the application
sudo -A $1
