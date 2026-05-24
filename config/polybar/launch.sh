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
    # Calcular anchos adaptativos antes de lanzar
    ADAPTIVE=$($HOME/.config/polybar/scripts/calc-adaptive-widths.sh)
    if [ -n "$ADAPTIVE" ]; then
        LEFT_W=$(echo "$ADAPTIVE" | grep "^left=" | cut -d= -f2 | cut -d\| -f1)
        LEFT_O=$(echo "$ADAPTIVE" | grep "^left=" | cut -d\| -f2)
        CENTER_W=$(echo "$ADAPTIVE" | grep "^center=" | cut -d= -f2 | cut -d\| -f1)
        CENTER_O=$(echo "$ADAPTIVE" | grep "^center=" | cut -d\| -f2)
        PLAYER_W=$(echo "$ADAPTIVE" | grep "^player=" | cut -d= -f2 | cut -d\| -f1)
        PLAYER_O=$(echo "$ADAPTIVE" | grep "^player=" | cut -d\| -f2)
        # Parchear config.ini para barras flotantes
        sed -i "/^\[bar\/left\]/,/^\[bar\// {s/^width =.*/width = $LEFT_W%/; s/^offset-x =.*/offset-x = $LEFT_O%/;}" "$HOME/.config/polybar/config.ini"
        sed -i "/^\[bar\/center\]/,/^\[bar\// {s/^width =.*/width = $CENTER_W%/; s/^offset-x =.*/offset-x = $CENTER_O%/;}" "$HOME/.config/polybar/config.ini"
        sed -i "/^\[bar\/player\]/,/^\[bar\// {s/^width =.*/width = $PLAYER_W%/; s/^offset-x =.*/offset-x = $PLAYER_O%/;}" "$HOME/.config/polybar/config.ini"
    fi
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
# Matar monitores anteriores primero
pkill -f "player-monitor.sh" 2>/dev/null
sleep 0.3
rm -rf /tmp/polybar-player-monitor.lock
~/.config/polybar/scripts/player-monitor.sh & disown

