#!/bin/bash
# 🔊  Manejo de volumen y notificaciones para i3
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../themes/scripts/lang-builder.sh"

case $1 in
    up) 
        CURRENT_VOL=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '[0-9]+(?=%)' | head -1)
        if [ "$CURRENT_VOL" -lt 100 ]; then
            pactl set-sink-volume @DEFAULT_SINK@ +5%
        else
            pactl set-sink-volume @DEFAULT_SINK@ 100%
        fi
        ;;
    down) 
        pactl set-sink-volume @DEFAULT_SINK@ -5% 
        ;;
    mute) 
        pactl set-sink-mute @DEFAULT_SINK@ toggle 
        ;;
esac

VOL=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '[0-9]+(?=%)' | head -1)
MUTE=$(pactl get-sink-mute @DEFAULT_SINK@ | grep -Po '(?<=Mute: )(yes|no)')

if [ "$MUTE" == "yes" ]; then
    # Notificación de Silencio
    dunstify -a "oxido_system" -u low -h string:x-dunst-stack-tag:audio -h int:value:0 "🔇  Audio" "$L_NOT_DND_ON"
else
    # Notificación de Volumen con Barra de Progreso
    dunstify -a "oxido_system" -u low -h string:x-dunst-stack-tag:audio -h int:value:"$VOL" "$L_VOL_UP" "$VOL%"
fi
