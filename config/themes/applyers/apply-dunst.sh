#!/bin/bash
THEME_DIR="$1"
cp "$THEME_DIR/dunst/dunstrc" ~/.config/dunst/dunstrc
killall -q dunst 2>/dev/null
while pgrep -u $UID -x dunst >/dev/null; do sleep 0.3; done
dunst &
disown
