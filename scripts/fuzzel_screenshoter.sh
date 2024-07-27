#!/bin/sh

#-------[ internal functions ]-------#
{
  # notify and view screenshot
  notify_view() {
    notify_cmd_shot='notify-send -u low -h string:x-dunst-stack-tag:screenshot -i /usr/share/archcraft/icons/dunst/picture.png'
    ${notify_cmd_shot} "Copied to clipboard."
    paplay /usr/share/sounds/freedesktop/stereo/screen-capture.oga &>/dev/null &
    if [ -e "$screenshots_dir/$file" ] && [ -s "$screenshots_dir/$file" ]; then
      ${notify_cmd_shot} "Screenshot saved."
      qview "${screenshots_dir}/$file"
    else
      ${notify_cmd_shot} "Screenshot aborted."
    fi
  }
  # copy screenshot to clipboard
  copy_shot() {
    tee "$screenshots_dir/$file" | wl-copy --type image/png
  }
  # countdown
  countdown() {
    for sec in $(seq $1 -1 1); do
      notify-send -t 1000 -h string:x-dunst-stack-tag:screenshottimer -i /usr/share/archcraft/icons/dunst/timer.png "Taking shot in : $sec"
      sleep 1
    done
  }
  # a function to get custom value as input. Gets one string as input to be
  # used as message.
  func_get_input() {
    echo | fuzzel -d -p "${1}" -l 0 -P 0 --config="$river_dir/fuzzel/fuzzel.ini"
  }
}

#-------[ load config ]-------#
{
  #-------[ default values for config ]-------#
  ## define some default config so that we have something to fallback to if
  ## the user didn't have any config file.
  {
    #-------[ action - Bordered ]-------#
    {
      config_action_bordered_line_color="#81A1C1"
      config_action_bordered_line_thickness=2
      config_action_bordered_corner_radius=1
    }
  }

  #-------------[ file ]--------------#
  {
    time=$(date +%Y-%m-%d-%H-%M-%S)
    geometry=$(wlr-randr | grep "current" | awk "{print $1}")
    screenshots_dir="$(xdg-user-dir PICTURES)/Screenshots"
    file="Screenshot_${time}_${geometry}.png"
  }
  {
    # Directory
    if [[ ! -d "$screenshots_dir" ]]; then
      mkdir -p "$screenshots_dir"
    fi
  }
}

river_dir="$HOME/.config/river"

options=$(echo -e " Instant\n󰔛 Timer")
selected_option=$(echo "$options" | fuzzel -d \
  -l 2 \
  -p 'Screenshot type ' \
  --config="$river_dir/fuzzel/fuzzel.ini")
command=$(echo "$selected_option" | grep -o -E '[a-zA-Z]+')

case $command in "Instant")

  options=$(echo -e "󰆞 Trim\n󰀫 Alpha\n󰢡 Border\n Scale")
  selected_option=$(echo "$options" | fuzzel -d \
    -l 4 \
    -p 'Screenshot ' \
    --config="$river_dir/fuzzel/fuzzel.ini")
  command=$(echo "$selected_option" | grep -o -E '[a-zA-Z]+')

  sleep 0.1

  case $command in
  "Trim")
    flameshot gui -r |
      magick png:- -trim png:- |
      copy_shot
    notify_view
    ;;
  "Alpha")
    flameshot gui -r |
      magick png:- -transparent white -fuzz 90% png:- |
      copy_shot
    notify_view
    ;;
  "Border")
    flameshot gui -r |
      magick png:- \
        -format "roundrectangle 4,3 %[fx:w+0],%[fx:h+0] ${config_action_bordered_corner_radius},${config_action_bordered_corner_radius}" \
        -write info:/tmp/tmp.mvg \
        -alpha set -bordercolor "${config_action_bordered_line_color}" -border ${config_action_bordered_line_thickness} \
        \( +clone -alpha transparent -background none \
        -fill white -stroke none -strokewidth 0 -draw @/tmp/tmp.mvg \) \
        -compose DstIn -composite \
        \( +clone -alpha transparent -background none \
        -fill none -stroke "${config_action_bordered_line_color}" -strokewidth ${config_action_bordered_line_thickness} -draw @/tmp/tmp.mvg \) \
        -compose Over -composite png:- |
      copy_shot
    notify_view
    ;;
  "Scale")
    while :; do
      # get the value from user
      tmp_size=$(func_get_input "Resize (75%, 200x300) ")
      # remove spaces (can happen by accident
      tmp_size=$(echo "${tmp_size}" | sed 's/ //g')
      # make sure the variable is not empty
      if [ "$(echo "${tmp_size}" | wc -c)" == "0" ]; then
        continue
      fi

      if [ "$(echo "${tmp_size}" | grep -o -E '[0-9]+(%|x[0-9]+)')" == "${tmp_size}" ]; then
        break
      fi
    done

    if [[ -n "${tmp_size}" ]]; then
      flameshot gui -r |
        magick png:- -resize "${tmp_size}" png:- |
        copy_shot
      notify_view
    fi
    ;;
  *) ;;
  esac
  ;;
"Timer")
  countdown_time=$(func_get_input "Countdown ")
  # Check if countdown_time is a number and greater than 0
  if [[ "$countdown_time" =~ ^[0-9]+$ ]] && [ "$countdown_time" -gt 0 ]; then
      countdown $countdown_time
      flameshot gui -r | copy_shot
      notify_view
  else
      notify-send -u low -h string:x-dunst-stack-tag:screenshot -i /usr/share/archcraft/icons/dunst/picture.png "Invalid countdown time."
  fi
  ;;
*) ;;
esac
