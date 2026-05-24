#!/bin/bash
# player-monitor.sh — Muestra/oculta la barra player vía IPC según fuentes activas
# oxido-i3-themes
#
# Reemplaza nowplaying-launcher.sh. En lugar de matar/relanzar polybar,
# usa polybar-msg cmd show/hide sobre el PID de la barra player.
# Lockfile previene múltiples instancias.

LOCKFILE="/tmp/polybar-player-monitor.lock"
if ! mkdir "$LOCKFILE" 2>/dev/null; then
    exit 0
fi
trap 'rm -rf "$LOCKFILE"' EXIT

sleep 0.5

# Ocultar todas las barras player al inicio
for pid in $(pgrep -f "polybar.*--reload.*player" 2>/dev/null); do
    polybar-msg -p "$pid" cmd hide 2>/dev/null
done

while true; do
    players=$(playerctl -l 2>/dev/null)
    pids=$(pgrep -f "polybar.*--reload.*player" 2>/dev/null)
    for pid in $pids; do
        if [ -n "$players" ]; then
            polybar-msg -p "$pid" cmd show 2>/dev/null
        else
            polybar-msg -p "$pid" cmd hide 2>/dev/null
        fi
    done
    sleep 2
done
