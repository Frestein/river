#!/bin/bash

dir=$HOME/.config/river

run_command() {
  case "$1" in
  "Logout")
    riverctl exit
    ;;
  "Lock")
    waylock -ignore-empty-password \
      -init-color 0x2E3440 \
      -input-color 0x81A1C1 \
      -fail-color 0xBF616A
    ;;
  "Reload")
    riverctl spawn "$dir/init"
    ;;
  "Reboot")
    systemctl reboot
    ;;
  "Shutdown")
    systemctl poweroff
    ;;
  esac
}

menu=$(echo -en "󰍃 Logout\n Lock\n Reload\n Reboot\n Shutdown" | fuzzel --dmenu --prompt "Session Manager " -l 5)
selected=$(echo "$menu" | grep -o -E '[a-zA-Z]+')

run_command "$selected"
