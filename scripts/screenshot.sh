#!/bin/sh

# File name
time=$(date +%Y-%m-%d-%H-%M-%S)
geometry=$(wlr-randr | grep "current" | awk "{print $1}")
screenshots_dir="$(xdg-user-dir PICTURES)/Screenshots"
file="Screenshot_${time}_${geometry}.png"

# Screenshots directory
if [[ ! -d "$screenshots_dir" ]]; then
  mkdir -p "$screenshots_dir"
fi

# Notify and view screenshot
notify_view() {
  notify_cmd_shot='notify-send -u low -h string:x-dunst-stack-tag:flameshot -i /usr/share/archcraft/icons/dunst/picture.png'
  ${notify_cmd_shot} "Copied to clipboard."
  paplay /usr/share/sounds/freedesktop/stereo/screen-capture.oga &>/dev/null &
  if [ -e "$screenshots_dir/$file" ] && [ -s "$screenshots_dir/$file" ]; then
    ${notify_cmd_shot} "Screenshot saved."
    qview "${screenshots_dir}/$file"
  else
    ${notify_cmd_shot} "Screenshot aborted."
  fi
}

copy_shot() {
  tee "$screenshots_dir/$file" | wl-copy --type image/png
}

countdown() {
  for sec in $(seq $1 -1 1); do
    notify-send -t 1000 -h string:x-dunst-stack-tag:screenshottimer -i /usr/share/archcraft/icons/dunst/timer.png "Taking shot in : $sec"
    sleep 1
  done
}

shot() {
  local mode="$1"
  local extra_args="${@:2}"
  flameshot $mode $extra_args -r | copy_shot
  notify_view
}

shotnow() {
  shot screen
}

shot5() {
  countdown 5
  sleep 1
  shot screen
}

shot10() {
  countdown 10
  sleep 1
  shot screen
}

shotarea() {
  shot gui
}

# Execute
if [[ "$1" == "--now" ]]; then
  shotnow
elif [[ "$1" == "--in5" ]]; then
  shot5
elif [[ "$1" == "--in10" ]]; then
  shot10
elif [[ "$1" == "--area" ]]; then
  shotarea
else
  echo -e "Available Options : --now --in5 --in10 --area"
fi

exit 0
