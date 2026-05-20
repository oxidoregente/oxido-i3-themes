#!/bin/bash
# 💤  DPMS timeout adjuster
CONFIG=~/.config/i3/config
CURRENT=$(grep "^exec.*xset dpms" "$CONFIG" 2>/dev/null | sed 's/.*xset dpms \([0-9]*\).*/\1/' | head -1)
[ -z "$CURRENT" ] && CURRENT=5

choices=$(printf "1 minuto\n3 minutos\n5 minutos\n10 minutos\n15 minutos\n30 minutos\nNunca (desactivar)\n⬅️  Volver" | rofi -dmenu -p "  💤  DPMS apagar: ${CURRENT}min" \
    -theme-str 'window { width: 360; border-radius: 16px; background-color: #1e1e2e; }
    mainbox { children: [listview]; spacing: 4px; padding: 8px; }
    listview { spacing: 4px; dynamic: true; }
    element { border-radius: 10px; padding: 12px; background-color: #313244; text-color: #cdd6f4; }
    element selected { background-color: #89b4fa; text-color: #1e1e2e; }
    element-icon { size: 1.2em; }' -i)

[ -z "$choices" ] && exit 0
case "$choices" in
    *1*) VAL=60; LABEL="1 min" ;;
    *3*) VAL=180; LABEL="3 min" ;;
    *5*) VAL=300; LABEL="5 min" ;;
    *10*) VAL=600; LABEL="10 min" ;;
    *15*) VAL=900; LABEL="15 min" ;;
    *30*) VAL=1800; LABEL="30 min" ;;
    *Nunca*) VAL=0; xset -dpms; dunstify -u low "💤  DPMS" "Desactivado — pantalla no se apagará sola"; exit 0 ;;
    *"Volver"*) exec ~/.config/themes/bin/rofi-settings.sh ;;
    *) exit 0 ;;
esac

if grep -q "^exec.*xset dpms" "$CONFIG" 2>/dev/null; then
    sed -i "s/^exec.*--no-startup-id xset dpms.*/exec --no-startup-id xset dpms $VAL $((VAL+60)) $((VAL+120))/" "$CONFIG"
else
    echo "exec --no-startup-id xset dpms $VAL $((VAL+60)) $((VAL+120))" >> "$CONFIG"
fi
xset dpms $VAL $((VAL+60)) $((VAL+120))
dunstify -u low "💤  DPMS" "Apagar pantalla: $LABEL de inactividad"
