#!/bin/bash
THEME_DIR="$1"
BG_DIR="$THEME_DIR/backgrounds"

# Buscar cualquier imagen en backgrounds/ (jpg, png, jpeg, webp)
WALLPAPER_FILE=$(find "$BG_DIR" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.jpeg' -o -iname '*.webp' \) 2>/dev/null | head -1)

if [ -z "$WALLPAPER_FILE" ]; then
    WALLPAPER_FILE=$(find "$THEME_DIR" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.png' \) 2>/dev/null | head -1)
fi

if [ -f "$WALLPAPER_FILE" ]; then
    nitrogen --set-zoom-fill "$WALLPAPER_FILE" --save 2>/dev/null || \
    feh --bg-fill "$WALLPAPER_FILE" 2>/dev/null
fi
