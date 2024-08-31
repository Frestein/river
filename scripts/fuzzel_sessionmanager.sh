#!/bin/dash

dir="$HOME/.config/river"

run_command() {
  case "$1" in
  "Logout")
    riverctl exit
    ;;
  "Lock")
    swaylock -C "$dir/swaylock/swaylock.conf"
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

options="󰍃 Logout\n Lock\n Reload\n Reboot\n Shutdown"
selected_option=$(echo "$options" | fuzzel -d \
  -l 5 \
  -p "Session " \
  --config="$dir/fuzzel/fuzzel.ini")
command=$(echo "$selected_option" | grep -o -E '[a-zA-Z]+')

run_command "$command"
