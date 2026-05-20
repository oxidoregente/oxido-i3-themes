#!/bin/bash
# Manejo de volumen y notificaciones para i3

case $1 in
    up) 
        # Obtenemos el volumen actual antes de subirlo
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

# --- El resto de tu código de notificación se queda igual ---
VOL=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '[0-9]+(?=%)' | head -1)
MUTE=$(pactl get-sink-mute @DEFAULT_SINK@ | grep -Po '(?<=Mute: )(yes|no)')

if [ "$MUTE" == "yes" ]; then
    notify-send "Audio" "Silenciado" -h string:x-dunst-stack-tag:audio -h int:value:0
else
    notify-send "Volumen" "${VOL}%" -h string:x-dunst-stack-tag:audio -h int:value:"$VOL"
fi
