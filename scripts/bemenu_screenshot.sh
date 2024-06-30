#!/bin/sh

#-------[ internal functions ]-------#
{
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
  # a function to get custom value as input. Gets one string as input to be
  # used as message.
  func_get_input() {
    echo | dmenu -p "${1}"
  }
  # a function to read and parse config file. the input should be tha path to
  # the config file.
  func_parse_config() {
    local line section key value
    local regex_empty="^[[:blank:]]*$"
    local regex_comment="^[[:blank:]]*#"
    local regex_section="^[[:blank:]]*\[([[:alpha:]][[:alnum:]]*)\][[:blank:]]*$"
    local regex_keyval="^[[:blank:]]*([[:alpha:]_][[:alnum:]_]*)[[:blank:]]*=[[:blank:]]*[\"\']?([^\"\']*)[\"\']?"

    # read the lines line-by-line and create variables using the config
    while IFS='= ' read -r line; do
      # skip if the line is empty
      [[ "${line}" =~ ${regex_empty} ]] && continue
      # skip if the line is comment
      [[ "${line}" =~ ${regex_comment} ]] && continue
      # if the line matches regex for section
      if [[ "${line}" =~ ${regex_section} ]]; then
        section="${BASH_REMATCH[1]}"
        # echo "section=${section}"
      # if the line matches regex for key-value pair
      elif [[ "${line}" =~ ${regex_keyval} ]]; then
        key="${BASH_REMATCH[1]}"
        value="${BASH_REMATCH[2]}"
        # echo "${key} = ${value}"
      # if the line does not match any of the above
      else
        echo "The following line in config is invalid:"
        echo "${line}"
      fi

      # create varible synamically using the combination of section and key
      declare -g "config_${section}_${key}"="${value}"

    done <"${1}"
  }
}

#-------[ argument parsing ]-------#
{
  if [[ "${1}" == "--help" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "help" ]]; then
    cat <<'EOF'

dmenu_shot provides a menu with set of custom commands to
perform some simple automated image manipulation on screenshots
taken using Flameshot, and then putting them into clipboard.

Commands:
    -h, --help    To show this help

Menu:
    Instant:
      Trim:          It just trims the extra spaces around the
                     selected region.
      Select window: Waits for user to select a window, then take
                     screenshot of it.
      Remove white:  Useful to remove the white background. It will
                     replace white with transparent.
      Bordered:      Add border around the captured screenshot.
      Scaled:        Resize the screenshot either by percentage
                     (e.g 75%) or specific dimension (e.g 200x300).
    Timer:
      Countdown:     Take a screenshot after a countdown (in seconds).

EOF
    exit 0
  fi
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

  #-------[ read config file ]-------#
  {
    # get the config path from environmental variable, otherwise fall back to
    # the ~/.config/dmenu_shot/config.toml
    if [[ -v DMENU_SHOT_CONF_PATH ]]; then
      CONF_PATH="${DMENU_SHOT_CONF_PATH}"
    else
      CONF_PATH="${HOME}/.config/dmenu_shot/config.toml"
    fi

    # if the config file do exist
    if [[ -f "${CONF_PATH}" ]]; then
      func_parse_config "${CONF_PATH}"
    else
      echo "The config file was not found in ${CONF_PATH}"
      echo "Falling back to some defaults!"
    fi
  }

  #-------------[ file ]--------------#
  {
    time=$(date +%Y-%m-%d-%H-%M-%S)
    geometry=$(xrandr | grep 'current' | head -n1 | cut -d',' -f2 | tr -d '[:blank:],current')
    dir="$(xdg-user-dir PICTURES)/Screenshots"
    file="Screenshot_${time}_${geometry}.png"
  }
  {
    # Directory
    if [[ ! -d "$dir" ]]; then
      mkdir -p "$dir"
    fi
  }
}

screenshot_type=$(echo -e "Instant\nTimer" | dmenu -l 2 -vi -noi -p "Screenshot type ")

case $screenshot_type in "Instant")

  RET=$(echo -e "Trim\nSelect window\nRemove white\nBordered\nScaled" |
    dmenu -i \
      -vi \
      -l 10 \
      -noi \
      -p "Screenshot")

  sleep 0.1

  case $RET in
  Trim)
    flameshot gui -r |
      magick png:- -trim png:- |
      copy_shot
    notify_view
    ;;
  "Select window")
    # get the window ID
    TMP_WINDOW_ID=$(xdotool selectwindow)

    unset WINDOW X Y WIDTH HEIGHT SCREEN
    # eval $(xdotool selectwindow getwindowgeometry --shell)
    eval $(xdotool getwindowgeometry --shell "${TMP_WINDOW_ID}")

    # Put the window in focus
    xdotool windowfocus --sync "${TMP_WINDOW_ID}"
    sleep 0.05

    # run flameshot in gui mode in the desired coordinates
    flameshot gui --region "${WIDTH}x${HEIGHT}+${X}+${Y}" -r | copy_shot
    notify_view
    ;;
  "Remove white")
    flameshot gui -r |
      magick png:- -transparent white -fuzz 90% png:- |
      copy_shot
    notify_view
    ;;
  Bordered)
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
  Scaled)
    while :; do
      # get the value from user
      tmp_size=$(func_get_input "Resize (75%, 200x300)")
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
  countdown_time=$(func_get_input "Countdown (in seconds)")
  # Check if countdown_time is a number and greater than 0
  if [[ "$countdown_time" =~ ^[0-9]+$ ]] && [ "$countdown_time" -gt 0 ]; then
      countdown $countdown_time
      flameshot gui -r | copy_shot
      notify_view
  else
      dunstify -u low -h string:x-dunst-stack-tag:obscreenshot -i /usr/share/archcraft/icons/dunst/picture.png "Invalid countdown time. Skipping screenshot."
  fi
  ;;
*) ;;
esac
