#!/bin/bash
THEME_DIR="$1"
POWERSAVER_FLAG="/tmp/powersaver_active"

cp "$THEME_DIR/picom/picom.conf" ~/.config/picom/picom.conf

[ -f "$POWERSAVER_FLAG" ] && exit 0

killall -q picom 2>/dev/null
while pgrep -u $UID -x picom >/dev/null; do sleep 0.3; done
picom --config ~/.config/picom/picom.conf &
disown
