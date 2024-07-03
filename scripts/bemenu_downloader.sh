#!/bin/sh

# Ask the user for a URL to download
url=$(echo | LD_LIBRARY_PATH=/usr/local/lib bemenu -p "Download" -c -i --fn 'JetBrainsMono Nerd Font 16' -B 2 -M 670 -s --binding vim --vim-normal-mode --vim-esc-exits --tb '#81A1C1' --tf '#2E3440' --fb '#2E3440' --ff '#D8DEE9' --nb '#2E3440' --nf '#D8DEE9' --ab '#2E3440' --af '#D8DEE9' --hb '#2E3440' --hf '#2E3440' --sb '#434C5E' --sf '#B48EAD' --scb '#2E3440' --scf '#D8DEE9' --cb '#434C5E' --cf '#D8DEE9' --bdr '#81A1C1')

# Exit the script if the URL is empty
if [ -z "$url" ]; then
  exit 0
fi

# Specify the directory to save downloaded files
dir="Films/"

# Start the download
aria2c --seed-time 0 -d "$dir" "$url" &
