#!/bin/sh

color=$(slurp -p | grim -g - - | magick - txt: | awk 'NR==2 { print $3 }')
image=/tmp/${color}.png

if [[ "$color" ]]; then
  # copy color code to clipboard
  echo $color | tr -d "\n" | wl-copy
  # generate preview
  magick -size 48x48 xc:"$color" ${image}
  # notify about it
  dunstify -u low -h string:x-dunst-stack-tag:obcolorpicker -i ${image} "$color, copied to clipboard."
fi
