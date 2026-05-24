#!/bin/bash
# toggle-battery-info.sh — Alterna entre vista simple y extendida del widget de batería
FLAG="/tmp/polybar_batt_extended"

if [ -f "$FLAG" ]; then
    rm -f "$FLAG"
else
    touch "$FLAG"
fi

# Pequeña pausa para que el flag se escriba antes del refresco
sleep 0.05
# Refrescar solo el módulo battery vía IPC (no afecta al tray)
polybar-msg action "#battery.module_exec" &>/dev/null &
