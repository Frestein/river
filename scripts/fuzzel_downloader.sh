#!/bin/sh

dir="$HOME/.config/river"

# Ask the user for a URL to download
url=$(echo | fuzzel -p 'Download ' -d -l 0 -P 0 --config="$dir/fuzzel/fuzzel.ini")

# Exit the script if the URL is empty
if [ -z "$url" ]; then
  exit 0
fi

# Specify the directory to save downloaded files
dir="Films/"

# Start the download
aria2c --seed-time 0 -d "$dir" "$url" &
