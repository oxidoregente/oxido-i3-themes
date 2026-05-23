#!/bin/bash
# 󰥔  Notificación de hora i18n
REPO_DIR="/home/oxido/Documentos/oxido-i3-themes"
source "$REPO_DIR/config/themes/scripts/lang-builder.sh"

T=$(date '+%H:%M')
D=$(date '+%A, %d %B %Y')

# Traducir fecha si es necesario (el comando date usa el locale del sistema, 
# pero podemos forzar el formato o simplemente enviar el mensaje traducido)
MSG="$L_NOT_TIME"

dunstify -a "oxido_system" -u low -h string:x-dunst-stack-tag:time "󰥔  $T" "$D"
