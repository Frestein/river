#!/bin/bash

dir=$HOME/.config/river

run_command() {
  case "$1" in
  "Foot")
    "$dir/scripts/asroot.sh" foot
    ;;
  "Neovim")
    "$dir/scripts/asroot.sh" foot nvim
    ;;
  "Yazi")
    "$dir/scripts/asroot.sh" foot ~/.cargo/bin/yazi
    ;;
  "Nemo")
    "$dir/scripts/asroot.sh" HOME=/home/frestein nemo
    ;;
  esac
}

menu=$(echo -en " Foot\n Neovim\n󰇥 Yazi\n Nemo" | fuzzel -d -p "Root " -l 4)
selected=$(echo "$menu" | grep -o -E '[a-zA-Z]+')

run_command "$selected"
