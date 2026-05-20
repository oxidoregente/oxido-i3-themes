#!/bin/bash
# 📸  Screenshot utility
DIR=~/.config/themes/scripts/settings
BASE_THEME=$(cat "$DIR/.rasi-base" 2>/dev/null || echo '* { font: "FiraCode Nerd Font 10"; }
window { width: 380; border-radius: 16px; background-color: #1e1e2e; }
mainbox { children: [listview]; spacing: 4px; padding: 8px; }
listview { spacing: 4px; dynamic: true; }
element { border-radius: 10px; padding: 12px; background-color: #313244; text-color: #cdd6f4; }
element selected { background-color: #89b4fa; text-color: #1e1e2e; }
element-icon { size: 1.4em; }
element-text { horizontal-align: 0.5; }')

SS_DIR=~/Imágenes/capturas
mkdir -p "$SS_DIR"
FNAME="Captura-$(date +%Y%m%d-%H%M%S).png"

choice=$(printf "🖼️  Seleccionar área\n🖥️  Pantalla completa\n  Ventana activa\n⏱️  Área con retardo 5s\n⬅️  Volver" | rofi -dmenu -p "  📸  Captura" -theme-str "$BASE_THEME" -i)

case "$choice" in
    *área*)
        maim -s "$SS_DIR/$FNAME" 2>/dev/null || import "$SS_DIR/$FNAME" 2>/dev/null
        dunstify -u low "📸  Captura" "Área guardada: $FNAME" -i "$SS_DIR/$FNAME" ;;
    *completa*)
        maim "$SS_DIR/$FNAME" 2>/dev/null || import -window root "$SS_DIR/$FNAME" 2>/dev/null
        dunstify -u low "📸  Captura" "Pantalla completa: $FNAME" -i "$SS_DIR/$FNAME" ;;
    *Ventana*)
        maim -i "$(xdotool getactivewindow)" "$SS_DIR/$FNAME" 2>/dev/null || import -window "$(xdotool getactivewindow)" "$SS_DIR/$FNAME" 2>/dev/null
        dunstify -u low "📸  Captura" "Ventana activa: $FNAME" -i "$SS_DIR/$FNAME" ;;
    *retardo*)
        dunstify -u normal "📸  Captura" "Tomando captura en 5s..."
        sleep 5
        maim -s "$SS_DIR/$FNAME" 2>/dev/null || import "$SS_DIR/$FNAME" 2>/dev/null
        dunstify -u low "📸  Captura" "Área (retardo): $FNAME" -i "$SS_DIR/$FNAME" ;;
    *"Volver"*) exec ~/.config/themes/bin/rofi-settings.sh ;;
    *) exit 0 ;;
esac
