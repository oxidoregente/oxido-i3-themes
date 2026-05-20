#!/bin/bash
THEME_DIR="$1"
if [ -f "$THEME_DIR/polybar/config.ini" ]; then
    cp "$THEME_DIR/polybar/config.ini" ~/.config/polybar/config.ini
else
    cp "$THEME_DIR/polybar/colors.ini" ~/.config/polybar/colors.ini
fi
~/.config/polybar/launch.sh
