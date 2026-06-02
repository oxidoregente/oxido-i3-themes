#!/bin/bash
THEME_DIR="$1"
PINNED_FILE="$THEME_DIR/last-wallpaper"

# Check if user has pinned a custom wallpaper
if [ -f "$PINNED_FILE" ]; then
    PINNED=$(cat "$PINNED_FILE")
    if [ -f "$PINNED" ]; then
        nitrogen --set-zoom-fill "$PINNED" --save 2>/dev/null || \
        feh --bg-fill "$PINNED" 2>/dev/null
        exit 0
    fi
fi

# Fallback: use theme default wallpaper
BG_DIR="$THEME_DIR/backgrounds"
WALLPAPER_FILE=$(find "$BG_DIR" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.jpeg' -o -iname '*.webp' \) 2>/dev/null | head -1)

if [ -z "$WALLPAPER_FILE" ]; then
    WALLPAPER_FILE=$(find "$THEME_DIR" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.png' \) 2>/dev/null | head -1)
fi

if [ -f "$WALLPAPER_FILE" ]; then
    nitrogen --set-zoom-fill "$WALLPAPER_FILE" --save 2>/dev/null || \
    feh --bg-fill "$WALLPAPER_FILE" 2>/dev/null
fi
