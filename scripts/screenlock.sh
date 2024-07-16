#!/bin/dash

# River directory
dir="$HOME/.config/river"

"$dir/scripts/mpris_inhibitor.sh" || exit 1

swaylock -C "$dir/swaylock/swaylock.conf"

# waylock -ignore-empty-password \
#   -init-color 0x2E3440 \
#   -input-color 0x81A1C1 \
#   -fail-color 0xBF616A
