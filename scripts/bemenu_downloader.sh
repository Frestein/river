#!/bin/sh

# Ask the user for a URL to download
url=$(bemenu -l 1 -p "Download")

# Exit the script if the URL is empty
if [ -z "$url" ]; then
  exit 0
fi

# Specify the directory to save downloaded files
dir="Films/"

# Start the download
aria2c --seed-time 0 -d "$dir" "$url" &
