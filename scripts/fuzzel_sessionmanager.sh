#!/bin/dash

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

options=$(echo "󰍃 Logout\n Lock\n Reload\n Reboot\n Shutdown")
selected_option=$(echo "$options" | fuzzel -d \
  -l 5 \
  -p "Session Manager " \
  --config="$dir/fuzzel/fuzzel.ini")
command=$(echo "$selected_option" | grep -o -E '[a-zA-Z]+')

run_command $command
