#!/bin/bash
# Lanzador de Polybar (Split Bars) - con lockfile para evitar duplicados
# oxido-i3-themes
LOCKFILE="/tmp/polybar-launch.lock"
if ! mkdir "$LOCKFILE" 2>/dev/null; then
    exit 0
fi
trap 'rm -rf "$LOCKFILE"' EXIT

killall -q polybar 2>/dev/null
while pgrep -u $UID -x polybar >/dev/null; do sleep 0.3; done

export LANG=es_VE.utf8
export LC_TIME=es_VE.utf8

if type "xrandr" > /dev/null; then
    for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
        MONITOR=$m polybar --reload left &
        MONITOR=$m polybar --reload center &
        MONITOR=$m polybar --reload right &
        MONITOR=$m polybar --reload player &
    done
else
    polybar --reload left &
    polybar --reload center &
    polybar --reload right &
    polybar --reload player &
fi

# Monitor de visibilidad de player bar (IPC show/hide)
rm -f /tmp/polybar-player-monitor.lock
~/.config/polybar/scripts/player-monitor.sh & disown
