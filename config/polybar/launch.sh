#!/bin/bash
# Lanzador de Polybar - con lockfile para evitar duplicados
LOCKFILE="/tmp/polybar-launch.lock"
if ! mkdir "$LOCKFILE" 2>/dev/null; then
    exit 0
fi
trap 'rm -rf "$LOCKFILE"' EXIT

killall -q polybar 2>/dev/null
while pgrep -u $UID -x polybar >/dev/null; do sleep 0.3; done

# Forzar locale español para que el reloj muestre días en español
export LANG=es_VE.utf8
export LC_TIME=es_VE.utf8

if type "xrandr" > /dev/null; then
    for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
        MONITOR=$m polybar --reload top &
        disown
    done
else
    polybar --reload top &
    disown
fi
