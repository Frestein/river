#!/bin/sh

# file
time=$(date +%Y-%m-%d-%H-%M-%S)
geometry=$(xrandr | grep 'current' | head -n1 | cut -d',' -f2 | tr -d '[:blank:],current')
dir="$(xdg-user-dir PICTURES)/Screenshots"
file="Screenshot_${time}_${geometry}.png"

# directory
if [[ ! -d "$dir" ]]; then
  mkdir -p "$dir"
fi

# notify and view screenshot
notify_view() {
  notify_cmd_shot='dunstify -u low -h string:x-dunst-stack-tag:obscreenshot -i /usr/share/archcraft/icons/dunst/picture.png'
  ${notify_cmd_shot} "Copied to clipboard."
  paplay /usr/share/sounds/freedesktop/stereo/screen-capture.oga &>/dev/null &
  nsxiv -b "${dir}/$file"
  if [ -e "$dir/$file" ] && [ -s "$dir/$file" ]; then
    ${notify_cmd_shot} "Screenshot saved."
  else
    ${notify_cmd_shot} "Screenshot aborted."
  fi
}

# copy screenshot to clipboard
copy_shot() {
  tee "$dir/$file" | xclip -selection clipboard -t image/png
}

# countdown
countdown() {
  for sec in $(seq $1 -1 1); do
    dunstify -t 1000 -h string:x-dunst-stack-tag:screenshottimer -i /usr/share/archcraft/icons/dunst/timer.png "Taking shot in : $sec"
    sleep 1
  done
}

# screenshot
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

shotwin() {
  TMP_WINDOW_ID=$(xdotool selectwindow)
      
  unset WINDOW X Y WIDTH HEIGHT SCREEN
  eval $(xdotool getwindowgeometry --shell "${TMP_WINDOW_ID}")
  
  # Put the window in focus
  xdotool windowfocus --sync "${TMP_WINDOW_ID}"
  sleep 0.05
  
  # run flameshot in gui mode in the desired coordinates
  shot gui --region "${WIDTH}x${HEIGHT}+${X}+${Y}"
}

shotarea() {
  shot gui
}

# execute
if [[ "$1" == "--now" ]]; then
  shotnow
elif [[ "$1" == "--in5" ]]; then
  shot5
elif [[ "$1" == "--in10" ]]; then
  shot10
elif [[ "$1" == "--win" ]]; then
  shotwin
elif [[ "$1" == "--area" ]]; then
  shotarea
else
  echo -e "Available Options : --now --in5 --in10 --win --area"
fi

exit 0
