#!/bin/dash

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
    "$dir/scripts/asroot.sh" foot yazi
    ;;
  "Nemo")
    "$dir/scripts/asroot.sh" HOME=/home/frestein nemo
    ;;
  esac
}

options=$(echo " Foot\n Neovim\n󰇥 Yazi\n Nemo")
selected_option=$(echo "$options" | fuzzel -d \
  -l 4 \
  -p "Root " \
  --config="$dir/fuzzel/fuzzel.ini")
command=$(echo "$selected_option" | grep -o -E '[a-zA-Z]+')

run_command $command
