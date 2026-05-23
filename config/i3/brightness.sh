#!/bin/bash
# ☀️  Control de brillo con notificaciones i18n
REPO_DIR="/home/oxido/Documentos/oxido-i3-themes"
source "$REPO_DIR/config/themes/scripts/lang-builder.sh"

MAX_LIMIT=100
MIN_LIMIT=5

MAX=$(brightnessctl max)
ACTUAL=$(brightnessctl get)

if [[ "$1" == *"+"* ]]; then
    PCT=${1//[+%]/}
    NEW=$((ACTUAL + MAX * PCT / 100))
    [ "$NEW" -gt "$MAX" ] && NEW=$MAX
    brightnessctl set "$NEW"
elif [[ "$1" == *%- ]]; then
    PCT=${1//[%-]/}
    NEW=$((ACTUAL - MAX * PCT / 100))
    MIN_VAL=$((MAX * MIN_LIMIT / 100))
    [ "$NEW" -lt "$MIN_VAL" ] && NEW=$MIN_VAL
    brightnessctl set "$NEW"
else
    brightnessctl set "$1"
fi

VAL=$(brightnessctl -m | cut -d, -f4)
INTVAL=${VAL%\%}

# Notificación de Brillo con Barra de Progreso y Stack Tag
dunstify -a "oxido_system" -u low -h string:x-dunst-stack-tag:brightness -h int:value:"$INTVAL" "☀️  $L_NOT_BRIGHT" "$VAL"
