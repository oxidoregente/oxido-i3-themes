#!/bin/bash
# 󰖐  Muestra el clima vía wttr.in i18n
REPO_DIR="/home/oxido/Documentos/oxido-i3-themes"
source "$REPO_DIR/config/themes/scripts/lang-builder.sh"

# wttr.in soporta parámetros de idioma
W_LANG=$([ "$LANG" = "es" ] && echo "es" || echo "en")
WEATHER=$(curl -s "wttr.in?format=%C+%t&lang=$W_LANG" 2>/dev/null)

if [ -n "$WEATHER" ]; then
    ICON="󰖐"
    # Usar oxido_system para consistencia
    dunstify -a "oxido_system" -u normal -h string:x-dunst-stack-tag:weather "$ICON  $([ "$LANG" = "es" ] && echo "Clima" || echo "Weather")" "$WEATHER"
else
    dunstify -a "oxido_system" -u low "$([ "$LANG" = "es" ] && echo "Clima" || echo "Weather")" "$([ "$LANG" = "es" ] && echo "No se pudo obtener el clima" || echo "Could not get weather")"
fi
