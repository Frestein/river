#!/bin/dash

# File name
time=$(date +%Y-%m-%d-%H-%M-%S)
geometry=$(wlr-randr | grep "current" | awk "{print $1}")
screenshots_dir="$(xdg-user-dir PICTURES)/Screenshots"
file="Screenshot_${time}_${geometry}.png"

# Screenshots directory
if [ ! -d "$screenshots_dir" ]; then
  mkdir -p "$screenshots_dir"
fi

# Notify and view screenshot
notify_view() {
  notify_cmd_shot='notify-send -u low -h string:x-dunst-stack-tag:flameshot -i /usr/share/archcraft/icons/dunst/picture.png'
  eval "$notify_cmd_shot 'Copied to clipboard.'"
  paplay /usr/share/sounds/freedesktop/stereo/screen-capture.oga >/dev/null 2>&1 &
  if [ -e "$screenshots_dir/$file" ] && [ -s "$screenshots_dir/$file" ]; then
    eval "$notify_cmd_shot 'Screenshot saved.'"
    qview "${screenshots_dir}/$file"
  else
    eval "$notify_cmd_shot 'Screenshot aborted.'"
  fi
}

copy_shot() {
  tee "$screenshots_dir/$file" | wl-copy --type image/png
}

countdown() {
  seq "$1" -1 1 | while read -r sec; do
    notify-send -t 1000 -h string:x-dunst-stack-tag:screenshottimer -i /usr/share/archcraft/icons/dunst/timer.png "Taking shot in: $sec"
    sleep 1
  done
}

shot() {
  mode="$1"
  shift
  extra_args="$*"
  eval flameshot "$mode" "$extra_args" -r | copy_shot
  notify_view
}

shotnow() {
  shot screen
}

shot5() {
  countdown 5
  sleep 0.5
  shot screen
}

shot10() {
  countdown 10
  sleep 0.5
  shot screen
}

shotarea() {
  shot gui
}

# Execute
if [ "$1" = "--now" ]; then
  shotnow
elif [ "$1" = "--in5" ]; then
  shot5
elif [ "$1" = "--in10" ]; then
  shot10
elif [ "$1" = "--area" ]; then
  shotarea
else
  echo "Available options: --now --in5 --in10 --area"
fi

exit 0
