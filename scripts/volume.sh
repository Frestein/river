#!/bin/sh

# Icons
iDIR='/usr/share/archcraft/icons/dunst'
notify_cmd='dunstify -u low -h string:x-dunst-stack-tag:obvolume'

# Get Volume
get_volume() {
  echo "$(wpctl get-volume @DEFAULT_SINK@ | awk '{print int($2*100)}')"
}

# Get icons
get_icon() {
  current="$(get_volume)"
  if [[ "$current" -eq "0" ]]; then
    icon="$iDIR/volume-mute.png"
  elif [[ ("$current" -ge "0") && ("$current" -le "30") ]]; then
    icon="$iDIR/volume-low.png"
  elif [[ ("$current" -ge "30") && ("$current" -le "60") ]]; then
    icon="$iDIR/volume-mid.png"
  elif [[ ("$current" -ge "60") && ("$current" -le "100") ]]; then
    icon="$iDIR/volume-high.png"
  fi
}

# Notify
notify_user() {
  ${notify_cmd} -i "$icon" "Volume : $(get_volume)%"
}

# Increase Volume
inc_volume() {
  [[ $(wpctl status | grep -c "MUTED") == 1 ]] && wpctl set-mute @DEFAULT_SINK@ 0
  wpctl set-volume @DEFAULT_SINK@ 5%+ -l 1.0 && get_icon && notify_user
}

# Decrease Volume
dec_volume() {
  [[ $(wpctl status | grep -c "MUTED") == 1 ]] && wpctl set-mute @DEFAULT_SINK@ 0
  wpctl set-volume @DEFAULT_SINK@ 5%- -l 1.0 && get_icon && notify_user
}

# Toggle Mute
toggle_mute() {
  if [[ $(wpctl status | grep -c "MUTED") == 0 ]]; then
    wpctl set-mute @DEFAULT_SINK@ toggle && ${notify_cmd} -i "$iDIR/volume-mute.png" "Mute"
  else
    wpctl set-mute @DEFAULT_SINK@ toggle && get_icon && ${notify_cmd} -i "$icon" "Unmute"
  fi
}

# Toggle Mic
# toggle_mic() {
# 	ID="`pulsemixer --list-sources | grep 'Default' | cut -d',' -f1 | cut -d' ' -f3`"
# 	if [[ `pulsemixer --id $ID --get-mute` == 0 ]]; then
# 		pulsemixer --id ${ID} --toggle-mute && ${notify_cmd} -i "$iDIR/microphone-mute.png" "Microphone Switched OFF"
# 	else
# 		pulsemixer --id ${ID} --toggle-mute && ${notify_cmd} -i "$iDIR/microphone.png" "Microphone Switched ON"
# 	fi
# }

# Execute accordingly
if [[ "$1" == "--get" ]]; then
  get_volume
elif [[ "$1" == "--inc" ]]; then
  inc_volume
elif [[ "$1" == "--dec" ]]; then
  dec_volume
elif [[ "$1" == "--toggle" ]]; then
  toggle_mute
# elif [[ "$1" == "--toggle-mic" ]]; then
# 	toggle_mic
else
  echo $(get_volume)%
fi
