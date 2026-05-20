#!/bin/bash
# 🎨  Color picker — pick a color from screen and copy to clipboard
if command -v hyprpicker &>/dev/null; then
    color=$(hyprpicker -a 2>/dev/null)
elif command -v colorpicker &>/dev/null; then
    color=$(colorpicker --one-shot --short 2>/dev/null)
elif command -v grabc &>/dev/null; then
    dunstify -u normal "🎨  Color picker" "Haz clic en un píxel..."
    color=$(grabc 2>/dev/null)
elif command -v import &>/dev/null; then
    dunstify -u normal "🎨  Color picker" "Haz clic en un píxel..."
    tmp=$(mktemp /tmp/colorpicker-XXXXXX.png)
    import -window root "$tmp" 2>/dev/null
    color=$(convert "$tmp" -crop 1x1+0+0 -format '%[hex:u]' info:- 2>/dev/null)
else
    dunstify -u critical "🎨  Color picker" "No hay picker instalado (hyprpicker, colorpicker, grabc, o ImageMagick)"
    exit 1
fi

if [ -n "$color" ]; then
    echo -n "$color" | xclip -selection clipboard 2>/dev/null || echo -n "$color" | xsel -ib 2>/dev/null
    dunstify -u low "🎨  Color" "$color copiado al portapapeles" -h string:bg_color:"#$color"
fi
