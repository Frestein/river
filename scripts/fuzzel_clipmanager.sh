#!/bin/dash

dir="$HOME/.config/river"

cliphist list | fuzzel -d -p 'Clipboard ' --config="$dir/fuzzel/fuzzel.ini" --tabs 1 | cliphist decode | wl-copy
