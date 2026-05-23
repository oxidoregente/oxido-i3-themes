#!/bin/bash
# toggle-battery-info.sh — Alterna entre vista simple y extendida del widget de batería
FLAG="/tmp/polybar_batt_extended"

if [ -f "$FLAG" ]; then
    rm -f "$FLAG"
else
    touch "$FLAG"
fi

# Refrescar solo el módulo battery vía IPC (no afecta al tray)
polybar-msg action "#battery.module_exec" 2>/dev/null
