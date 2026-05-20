#!/bin/bash
THEME_DIR="$1"
CONKY_FLAG=~/.config/themes/conky-enabled
POWERSAVER_FLAG="/tmp/powersaver_active"

killall -q conky 2>/dev/null

[ -f "$POWERSAVER_FLAG" ] && exit 0
[ ! -f "$CONKY_FLAG" ] && exit 0

cp "$THEME_DIR/conky/conky.conf" ~/.config/conky/conky.conf
while pgrep -u $UID -x conky >/dev/null; do sleep 0.3; done
conky -c ~/.config/conky/conky.conf &
disown
