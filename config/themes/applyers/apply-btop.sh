#!/bin/bash
THEME_DIR="$1"
THEME_NAME=$(basename "$THEME_DIR")
BTOP_THEME="$THEME_DIR/btop/theme.theme"
BTOP_CONF="$HOME/.config/btop/btop.conf"
BTOP_THEMES_DIR="$HOME/.config/btop/themes"

if [ -f "$BTOP_THEME" ]; then
    mkdir -p "$BTOP_THEMES_DIR"
    cp "$BTOP_THEME" "$BTOP_THEMES_DIR/$THEME_NAME.theme"
    if [ -f "$BTOP_CONF" ]; then
        if grep -q "^color_theme" "$BTOP_CONF"; then
            sed -i "s/^color_theme = .*/color_theme = \"$THEME_NAME\"/" "$BTOP_CONF"
        else
            echo "color_theme = \"$THEME_NAME\"" >> "$BTOP_CONF"
        fi
    fi
fi
