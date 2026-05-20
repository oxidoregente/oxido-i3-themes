#!/bin/bash
# 🔒  Autolock timeout adjuster
CONFIG=~/.config/i3/config
CURRENT=$(grep "^exec.*xautolock" "$CONFIG" 2>/dev/null | sed 's/.*xautolock -time \([0-9]*\).*/\1/')
[ -z "$CURRENT" ] && CURRENT=8

choices=$(printf "1 minuto\n2 minutos\n5 minutos\n8 minutos\n10 minutos\n15 minutos\n30 minutos\nDesactivar\n⬅️  Volver" | rofi -dmenu -p "  🔒  Bloqueo auto: ${CURRENT}min" \
    -theme-str 'window { width: 360; border-radius: 16px; background-color: #1e1e2e; }
    mainbox { children: [listview]; spacing: 4px; padding: 8px; }
    listview { spacing: 4px; dynamic: true; }
    element { border-radius: 10px; padding: 12px; background-color: #313244; text-color: #cdd6f4; }
    element selected { background-color: #89b4fa; text-color: #1e1e2e; }' -i)

[ -z "$choices" ] && exit 0
case "$choices" in
    *Desactivar*)
        killall xautolock 2>/dev/null
        sed -i 's/^exec.*xautolock.*/## xautolock desactivado/' "$CONFIG"
        dunstify -u low "🔒  Bloqueo auto" "Desactivado"
        exit 0 ;;
    *30*) VAL=30 ;;
    *15*) VAL=15 ;;
    *10*) VAL=10 ;;
    *8*) VAL=8 ;;
    *5*) VAL=5 ;;
    *2*) VAL=2 ;;
    *1*) VAL=1 ;;
    *"Volver"*) exec ~/.config/themes/bin/rofi-settings.sh ;;
    *) exit 0 ;;
esac

LOCKER="$HOME/.config/themes/bin/lock.sh"
# replace existing xautolock line
if grep -q "^exec.*xautolock" "$CONFIG"; then
    sed -i "s/^exec.*xautolock -time [0-9]* -locker.*/exec --no-startup-id xautolock -time $VAL -locker \"$LOCKER\" -detectsleep/" "$CONFIG"
fi

killall xautolock 2>/dev/null
sleep 0.3
xautolock -time $VAL -locker "$LOCKER" -detectsleep &
disown
dunstify -u low "🔒  Bloqueo auto" "${VAL} min de inactividad"
