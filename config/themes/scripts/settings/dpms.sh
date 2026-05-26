#!/bin/bash
# 💤  DPMS timeout adjuster
BACK_TO="${1:-$HOME/.config/themes/bin/rofi-settings.sh}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$SCRIPT_DIR/../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../scripts/rofi-builder.sh"
[ -f "$SCRIPT_DIR/../../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../../scripts/rofi-builder.sh"
CONFIG=~/.config/i3/config

CURRENT=$(grep "^exec.*xset dpms" "$CONFIG" 2>/dev/null | sed 's/.*xset dpms \([0-9]*\).*/\1/' | head -1)
[ -z "$CURRENT" ] && CURRENT=5

choices=$(printf "1 minuto\n3 minutos\n5 minutos\n10 minutos\n15 minutos\n30 minutos\nNunca (desactivar)\n$L_BACK" | rofi -dmenu -p "  💤  DPMS apagar: ${CURRENT}min" \
    -theme-str "$ROFI_THEME_SUB" -i)

[ -z "$choices" ] && exec "$BACK_TO"
[[ "$choices" == *"$L_BACK"* ]] && exec "$BACK_TO"

case "$choices" in
    *1*) VAL=60; LABEL="1 min" ;;
    *3*) VAL=180; LABEL="3 min" ;;
    *5*) VAL=300; LABEL="5 min" ;;
    *10*) VAL=600; LABEL="10 min" ;;
    *15*) VAL=900; LABEL="15 min" ;;
    *30*) VAL=1800; LABEL="30 min" ;;
    *Nunca*) VAL=0; xset -dpms; dunstify -u low "💤  DPMS" "Desactivado — pantalla no se apagará sola"; exec "$BACK_TO" ;;
    *) exec "$BACK_TO" ;;
esac

if grep -q "^exec.*xset dpms" "$CONFIG" 2>/dev/null; then
    sed -i "s/^exec.*--no-startup-id xset dpms.*/exec --no-startup-id xset dpms $VAL $((VAL+60)) $((VAL+120))/" "$CONFIG"
else
    echo "exec --no-startup-id xset dpms $VAL $((VAL+60)) $((VAL+120))" >> "$CONFIG"
fi
xset dpms $VAL $((VAL+60)) $((VAL+120))
dunstify -u low "💤  DPMS" "Apagar pantalla: $LABEL de inactividad"