x#!/bin/bash

# Obtener el volumen actual del "Sink" por defecto (solo el número)
current_vol=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '[0-9]+(?=%)' | head -n 1)

# Si el volumen es menor a 100, subirlo un 5%
if [ "$current_vol" -lt 100 ]; then
    pactl set-sink-volume @DEFAULT_SINK@ +5%
else
    # Si ya es 100 o más, forzarlo a quedarse en 100
    pactl set-sink-volume @DEFAULT_SINK@ 100%
fi
