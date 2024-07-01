#!/bin/sh

# River directory
dir="$HOME/.config/river"

# Kill launched yambar
if [[ $(pidof yambar) ]]; then
  pkill yambar
fi

# Launch yambar
yambar -c "$dir/yambar/config.yml" &
