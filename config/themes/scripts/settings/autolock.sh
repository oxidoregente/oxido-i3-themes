#!/bin/bash
# 🔒  Autolock timeout adjuster
BACK_TO="${1:-$HOME/.config/themes/bin/rofi-settings.sh}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$SCRIPT_DIR/../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../scripts/rofi-builder.sh"
[ -f "$SCRIPT_DIR/../../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../../scripts/rofi-builder.sh"
CONFIG=~/.config/i3/config

CURRENT=$(grep "^exec.*xautolock" "$CONFIG" 2>/dev/null | sed 's/.*xautolock -time \([0-9]*\).*/\1/')
[ -z "$CURRENT" ] && CURRENT=8

choices=$(printf "1 minuto\n2 minutos\n5 minutos\n8 minutos\n10 minutos\n15 minutos\n30 minutos\nDesactivar\n$L_BACK" | rofi -dmenu -p "  🔒  Bloqueo auto: ${CURRENT}min" \
    -theme-str "$ROFI_THEME_SUB" -i)

[ -z "$choices" ] && exec "$BACK_TO"
[[ "$choices" == *"$L_BACK"* ]] && exec "$BACK_TO"

case "$choices" in
    *Desactivar*)
        killall xautolock 2>/dev/null
        sed -i 's/^exec.*xautolock.*/## xautolock desactivado/' "$CONFIG"
        dunstify -u low "🔒  Bloqueo auto" "Desactivado"
        exec "$BACK_TO" ;;
    *30*) VAL=30 ;;
    *15*) VAL=15 ;;
    *10*) VAL=10 ;;
    *8*) VAL=8 ;;
    *5*) VAL=5 ;;
    *2*) VAL=2 ;;
    *1*) VAL=1 ;;
    *) exec "$BACK_TO" ;;
esac

LOCKER="$HOME/.config/themes/bin/lock.sh"
if grep -q "^exec.*xautolock" "$CONFIG"; then
    sed -i "s/^exec.*xautolock -time [0-9]* -locker.*/exec --no-startup-id xautolock -time $VAL -locker \"$LOCKER\" -detectsleep/" "$CONFIG"
fi

killall xautolock 2>/dev/null
sleep 0.3
xautolock -time $VAL -locker "$LOCKER" -detectsleep &
disown
dunstify -u low "🔒  Bloqueo auto" "${VAL} min de inactividad"