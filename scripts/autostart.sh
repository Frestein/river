#!/bin/dash

# River directory
dir="$HOME/.config/river"

# Fix the non-working xdg-desktop-portal-gtk service
systemctl --user import-environment

# Launch polkit agent
[ -z "$(pidof polkit-gnome-authentication-agent-1)" ] \
  && /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

# Launch mpd with playerctl mpd-mpris plugin
[ -z "$(pidof mpd)" ] && mpd && wait $! && mpd-mpris \
  || [ -z "$(pidof mpd-mpris)" ] && mpd-mpris &

# Set wallpaper
[ -n "$(pidof wbg)" ] && pkill wbg
wbg "$dir/themes/nord/wallpaper" &

# Launch statusbar
[ -n "$(pidof yambar)" ] && pkill yambar
yambar -c "$dir/yambar/config.yml" &

# Check and create mako config directory and file
MAKO_DIR="$HOME/.config/mako"
MAKO_CONFIG="$MAKO_DIR/config"
[ ! -d "$MAKO_DIR" ] && mkdir -p "$MAKO_DIR"
[ ! -f "$MAKO_CONFIG" ] && ln -sf "$dir/mako/config" "$MAKO_CONFIG"

# Launch notification daemon
[ -z "$(pidof mako)" ] && mako || makoctl reload &

# Launch foot server
[ -z "$(pidof foot)" ] && foot --server --config "$dir/foot/foot.ini" &

# Launch swayidle
[ -z "$(pidof swayidle)" ] && swayidle -w \
  timeout 600 "$dir/scripts/screenlock.sh" &
# TODO: Implement monitor power management feature
  # timeout 10 "wlopm --off \*;$dir/scripts/waylock.sh" resume "wlopm --on \*" \
  # before-sleep "$dir/scripts/waylock.sh"

# Launch key remapper
[ -n "$(pidof xremap)" ] && pkill xremap
xremap "$HOME/.xremap.yml" &

# Launch jamesdsp
[ -z "$(pidof jamesdsp)" ] && jamesdsp -t &

# Mount Google Drive
[ -z "$(pidof rclone)" ] && rclone mount --daemon GoogleDriveMain: "$HOME/Google Drive" &

# Set gsettings
"$dir/scripts/gsettings.sh" &

# Launch clipboard manager
[ -z "$(pidof wl-paste)" ] && wl-paste --watch cliphist store &
