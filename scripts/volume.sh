#!/bin/dash

icon_dir='/usr/share/archcraft/icons/dunst'
notify_cmd='notify-send -u low -h string:x-dunst-stack-tag:volume'

get_volume() {
  wpctl get-volume @DEFAULT_SINK@ | awk '{print int($2*100)}'
}

get_icon() {
  current="$(get_volume)"
  if [ "$current" -eq "0" ]; then
    icon="$icon_dir/volume-mute.png"
  elif [ "$current" -ge "0" ] && [ "$current" -le "30" ]; then
    icon="$icon_dir/volume-low.png"
  elif [ "$current" -ge "30" ] && [ "$current" -le "60" ]; then
    icon="$icon_dir/volume-mid.png"
  elif [ "$current" -ge "60" ] && [ "$current" -le "100" ]; then
    icon="$icon_dir/volume-high.png"
  fi
}

notify_user() {
  eval "$notify_cmd -i '$icon' 'Volume: $(get_volume)%'"
}

inc_volume() {
  [ "$(wpctl status | grep -c "MUTED")" = 1 ] && wpctl set-mute @DEFAULT_SINK@ 0
  wpctl set-volume @DEFAULT_SINK@ 5%+ -l 1.0 && get_icon && notify_user
}

dec_volume() {
  [ "$(wpctl status | grep -c "MUTED")" = 1 ] && wpctl set-mute @DEFAULT_SINK@ 0
  wpctl set-volume @DEFAULT_SINK@ 5%- -l 1.0 && get_icon && notify_user
}

toggle_mute() {
  if [ "$(wpctl status | grep -c "MUTED")" = 0 ]; then
    wpctl set-mute @DEFAULT_SINK@ toggle && eval "$notify_cmd -i '$icon_dir/volume-mute.png' 'Mute'"
  else
    wpctl set-mute @DEFAULT_SINK@ toggle && get_icon && eval "$notify_cmd -i '$icon' 'Unmute'"
  fi
}

# toggle_mic() {
# 	ID="`pulsemixer --list-sources | grep 'Default' | cut -d',' -f1 | cut -d' ' -f3`"
# 	if [[ `pulsemixer --id $ID --get-mute` == 0 ]]; then
# 		pulsemixer --id ${ID} --toggle-mute && ${notify_cmd} -i "$icon_dir/microphone-mute.png" "Microphone Switched OFF"
# 	else
# 		pulsemixer --id ${ID} --toggle-mute && ${notify_cmd} -i "$icon_dir/microphone.png" "Microphone Switched ON"
# 	fi
# }

# Execute accordingly
if [ "$1" = "--get" ]; then
  get_volume
elif [ "$1" = "--inc" ]; then
  inc_volume
elif [ "$1" = "--dec" ]; then
  dec_volume
elif [ "$1" = "--toggle" ]; then
  toggle_mute
# elif [[ "$1" == "--toggle-mic" ]]; then
# 	toggle_mic
else
  echo "$(get_volume)"%
fi
