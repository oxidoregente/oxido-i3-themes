#!/bin/bash
POSITION_FILE="$HOME/.config/themes/polybar-position"

if [ -f "$POSITION_FILE" ]; then
    CURRENT=$(cat "$POSITION_FILE")
else
    CURRENT="top"
fi

if [ "$CURRENT" = "top" ]; then
    echo "bottom" > "$POSITION_FILE"
    NEW="bottom"
else
    echo "top" > "$POSITION_FILE"
    NEW="top"
fi

dunstify -u low "📐  Polybar Position" "Cambiado a: $NEW"

# Re-apply current layout with new position
LAYOUT=$(cat "$HOME/.config/themes/current-layout" 2>/dev/null || echo "bubble")
echo "$LAYOUT" > "$HOME/.config/themes/current-layout"
THEME_LINK="$HOME/.config/themes/current/theme"
if [ -L "$THEME_LINK" ]; then
    TDIR=$(readlink -f "$THEME_LINK")
    bash "$HOME/.config/themes/applyers/apply-polybar.sh" "$TDIR"
fi
