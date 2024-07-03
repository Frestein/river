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
    tee "$dir/$file" | wl-copy --type image/png
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
    echo | LD_LIBRARY_PATH=/usr/local/lib bemenu -p "${1}" -c -i --fn 'JetBrainsMono Nerd Font 16' -B 2 -M 670 -s --binding vim --vim-esc-exits --tb '#81A1C1' --tf '#2E3440' --fb '#2E3440' --ff '#D8DEE9' --nb '#2E3440' --nf '#D8DEE9' --ab '#2E3440' --af '#D8DEE9' --hb '#2E3440' --hf '#2E3440' --sb '#434C5E' --sf '#B48EAD' --scb '#2E3440' --scf '#D8DEE9' --cb '#434C5E' --cf '#D8DEE9' --bdr '#81A1C1'
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

screenshot_type=$(echo -e "Instant\nTimer" | LD_LIBRARY_PATH=/usr/local/lib bemenu -p 'Screenshot type                             ' -l 2 -c -i --fn 'JetBrainsMono Nerd Font 16' -B 2 -M 670 -s --binding vim --vim-normal-mode --vim-esc-exits --tb '#81A1C1' --tf '#2E3440' --fb '#2E3440' --ff '#D8DEE9' --nb '#2E3440' --nf '#D8DEE9' --ab '#2E3440' --af '#D8DEE9' --hb '#81A1C1' --hf '#2E3440' --sb '#434C5E' --sf '#B48EAD' --scb '#2E3440' --scf '#D8DEE9' --cb '#434C5E' --cf '#D8DEE9' --bdr '#81A1C1')

case $screenshot_type in "Instant")

  RET=$(echo -e "Trim\nSelect window\nRemove white\nBordered\nScaled" |
    LD_LIBRARY_PATH=/usr/local/lib bemenu -l 10 \
    -p "Screenshot" \
    -c -i --fn 'JetBrainsMono Nerd Font 16' -B 2 -M 670 -s --binding vim --vim-normal-mode --vim-esc-exits --tb '#81A1C1' --tf '#2E3440' --fb '#2E3440' --ff '#D8DEE9' --nb '#2E3440' --nf '#D8DEE9' --ab '#2E3440' --af '#D8DEE9' --hb '#81A1C1' --hf '#2E3440' --sb '#434C5E' --sf '#B48EAD' --scb '#2E3440' --scf '#D8DEE9' --cb '#434C5E' --cf '#D8DEE9' --bdr '#81A1C1')

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
  countdown_time=$(func_get_input "Countdown")
  # Check if countdown_time is a number and greater than 0
  if [[ "$countdown_time" =~ ^[0-9]+$ ]] && [ "$countdown_time" -gt 0 ]; then
      countdown $countdown_time
      flameshot gui -r | copy_shot
      notify_view
  else
      dunstify -u low -h string:x-dunst-stack-tag:obscreenshot -i /usr/share/archcraft/icons/dunst/picture.png "Invalid countdown time."
  fi
  ;;
*) ;;
esac
