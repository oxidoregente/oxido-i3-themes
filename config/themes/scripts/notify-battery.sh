#!/bin/bash
# 🔋  Notificación de batería i18n
REPO_DIR="/home/oxido/Documentos/oxido-i3-themes"
source "$REPO_DIR/config/themes/scripts/lang-builder.sh"

CAP=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo "0")
STATUS=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo "Unknown")

if [ "$CAP" -le 15 ]; then
    ICON="󰂃"; URG="critical"
elif [ "$CAP" -le 30 ]; then
    ICON="󰁼"; URG="normal"
elif [ "$CAP" -le 70 ]; then
    ICON="󰂀"; URG="low"
else
    ICON="󰁹"; URG="low"
fi

if [ "$STATUS" = "Charging" ]; then
    ICON="󰂄"
    MSG=$([ "$LANG" = "es" ] && echo "Cargando" || echo "Charging")
else
    MSG="$L_NOT_BAT"
fi

# Usar oxido_system para que siga las reglas de Dunst
dunstify -a "oxido_system" -u "$URG" -h string:x-dunst-stack-tag:battery "$ICON  $MSG" "$CAP%"
