#!/bin/bash
THEME_DIR="$1"
LAYOUT_FILE="$HOME/.config/themes/current-layout"
CONFIG_DST="$HOME/.config/polybar/config.ini"

# Sync layouts from repo if runtime directory missing layouts
LAYOUTS_DIR="$HOME/.config/polybar/layouts"
REPO_LAYOUTS="/home/oxido/Documentos/oxido-i3-themes/config/polybar/layouts"
if [ -d "$REPO_LAYOUTS" ]; then
    mkdir -p "$LAYOUTS_DIR"
    cp --update "$REPO_LAYOUTS"/*.ini "$LAYOUTS_DIR/"
fi

if [ -f "$LAYOUT_FILE" ] && [ -f "$LAYOUTS_DIR/$(cat "$LAYOUT_FILE").ini" ]; then
    LAYOUT_NAME=$(cat "$LAYOUT_FILE")
    if [ -f "$THEME_DIR/polybar/colors.ini" ]; then
        cat "$THEME_DIR/polybar/colors.ini" "$LAYOUTS_DIR/$LAYOUT_NAME.ini" > "$CONFIG_DST"
    else
        cp "$LAYOUTS_DIR/$LAYOUT_NAME.ini" "$CONFIG_DST"
    fi
elif [ -f "$THEME_DIR/polybar/config.ini" ]; then
    cp "$THEME_DIR/polybar/config.ini" "$CONFIG_DST"
else
    cp "$THEME_DIR/polybar/colors.ini" "$CONFIG_DST"
fi

~/.config/polybar/launch.sh
