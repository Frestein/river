#!/bin/dash

players="mpd mpv firefox"

for player in $players; do
  if playerctl -p $(playerctl --list-all | grep "$player") status | grep -q "Playing"; then
    exit 1
  fi
done

exit 0
