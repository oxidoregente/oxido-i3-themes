#!/bin/bash
THEME_DIR="$1"
POWERSAVER_FLAG="/tmp/powersaver_active"

cp "$THEME_DIR/picom/picom.conf" ~/.config/picom/picom.conf

[ -f "$POWERSAVER_FLAG" ] && exit 0

killall -q picom 2>/dev/null
for _ in $(seq 1 10); do
    pgrep -u $UID -x picom >/dev/null || break
    sleep 0.3
done
picom --config ~/.config/picom/picom.conf &
disown
