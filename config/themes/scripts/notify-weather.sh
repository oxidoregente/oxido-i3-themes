#!/bin/bash
# Muestra el clima vía wttr.in (requiere curl)
WEATHER=$(curl -s "wttr.in?format=%C+%t&lang=es" 2>/dev/null)
if [ -n "$WEATHER" ]; then
    ICON="󰖐"
    ~/.config/themes/scripts/notify-send.sh "$ICON" "Clima" "$WEATHER" "normal"
else
    ~/.config/themes/scripts/notify-send.sh "󰖐" "Clima" "No se pudo obtener el clima" "low"
fi
