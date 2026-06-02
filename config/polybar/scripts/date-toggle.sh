#!/bin/bash
# date-toggle.sh — Cambia entre formato de fecha corto y largo
# oxido-i3-themes
toggle_file="/tmp/polybar-date-alt"
if [ -f "$toggle_file" ]; then
    rm "$toggle_file"
else
    touch "$toggle_file"
fi

# No reiniciamos Polybar. El módulo center-bubble tiene 'interval = 1'
# y se actualizará solo en menos de un segundo con el nuevo tamaño.
