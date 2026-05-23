#!/bin/bash
# toggle-battery-info.sh — Alterna entre vista simple y extendida del widget de batería
FLAG="/tmp/polybar_batt_extended"

if [ -f "$FLAG" ]; then
    rm -f "$FLAG"
else
    touch "$FLAG"
fi

# Notificar a polybar para actualizar inmediatamente (RTMIN+10)
# Intentamos varios métodos para asegurar que llegue la señal
pids=$(pidof polybar)
if [ -n "$pids" ]; then
    for pid in $pids; do
        kill -44 "$pid" 2>/dev/null # 44 es SIGRTMIN+10 en la mayoría de Linux
        kill -SIGRTMIN+10 "$pid" 2>/dev/null
    done
fi
