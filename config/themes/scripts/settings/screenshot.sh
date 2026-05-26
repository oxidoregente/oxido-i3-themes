#!/bin/bash
# 📸  Screenshot utility
BACK_TO="${1:-$HOME/.config/themes/bin/rofi-settings.sh}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$SCRIPT_DIR/../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../scripts/rofi-builder.sh"
[ -f "$SCRIPT_DIR/../../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../../scripts/rofi-builder.sh"

SS_DIR=~/Imágenes/capturas
mkdir -p "$SS_DIR"
FNAME="Captura-$(date +%Y%m%d-%H%M%S).png"

choice=$(printf "🖼️  Seleccionar área\n🖥️  Pantalla completa\n  Ventana activa\n⏱️  Área con retardo 5s\n$L_BACK" | rofi -dmenu -p "  $L_SSHOT" -theme-str "$ROFI_THEME_SUB" -i)

[ -z "$choice" ] && exec "$BACK_TO"
[[ "$choice" == *"$L_BACK"* ]] && exec "$BACK_TO"

case "$choice" in
    *área*)
        maim -s "$SS_DIR/$FNAME" 2>/dev/null || import "$SS_DIR/$FNAME" 2>/dev/null
        dunstify -u low "$L_SSHOT" "Área guardada: $FNAME" -i "$SS_DIR/$FNAME" ;;
    *completa*)
        maim "$SS_DIR/$FNAME" 2>/dev/null || import -window root "$SS_DIR/$FNAME" 2>/dev/null
        dunstify -u low "$L_SSHOT" "Pantalla completa: $FNAME" -i "$SS_DIR/$FNAME" ;;
    *Ventana*)
        maim -i "$(xdotool getactivewindow)" "$SS_DIR/$FNAME" 2>/dev/null || import -window "$(xdotool getactivewindow)" "$SS_DIR/$FNAME" 2>/dev/null
        dunstify -u low "$L_SSHOT" "Ventana activa: $FNAME" -i "$SS_DIR/$FNAME" ;;
    *retardo*)
        dunstify -u normal "$L_SSHOT" "Tomando captura en 5s..."
        sleep 5
        maim -s "$SS_DIR/$FNAME" 2>/dev/null || import "$SS_DIR/$FNAME" 2>/dev/null
        dunstify -u low "$L_SSHOT" "Área (retardo): $FNAME" -i "$SS_DIR/$FNAME" ;;
esac
exec "$BACK_TO"