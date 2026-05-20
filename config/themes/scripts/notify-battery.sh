#!/bin/bash
CAP=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo "0")
STATUS=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo "Unknown")

if [ "$CAP" -le 15 ]; then
    ICON="󰂃"; URG="critical"
elif [ "$CAP" -le 30 ]; then
    ICON="󰁼"; URG="normal"
elif [ "$CAP" -le 50 ]; then
    ICON="󰁾"; URG="normal"
elif [ "$CAP" -le 70 ]; then
    ICON="󰂀"; URG="low"
elif [ "$CAP" -le 85 ]; then
    ICON="󰂂"; URG="low"
else
    ICON="󰁹"; URG="low"
fi

[ "$STATUS" = "Charging" ] && ICON="󰂄" && MSG="Cargando: ${CAP}%" || MSG="Batería: ${CAP}%"

~/.config/themes/scripts/notify-send.sh "$ICON" "Batería" "$MSG" "$URG"
