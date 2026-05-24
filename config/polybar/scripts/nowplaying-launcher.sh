#!/bin/bash
# nowplaying-launcher.sh — Lanza/mata la barra player según fuentes de audio
# oxido-i3-themes
#
# Adaptado de arkzuse/polybar-theme
# https://github.com/arkzuse/polybar-theme — MIT License
#
# La barra player aparece cuando HAY una app de audio activa (playerctl -l),
# incluso si está en pausa. Desaparece solo cuando se CIERRA la app (Spotify,
# YouTube, etc.), no al pausar.

PLAYER_ACTIVE="/tmp/polybar-player-active"

launch_player_bars() {
    if type "xrandr" > /dev/null; then
        for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
            MONITOR=$m polybar --reload player &
        done
    else
        polybar --reload player &
    fi
}

kill_player_bars() {
    pkill -f "polybar.*--reload.*player" 2>/dev/null
}

while true; do
    players=$(playerctl -l 2>/dev/null)
    if [ -n "$players" ]; then
        if [ ! -f "$PLAYER_ACTIVE" ]; then
            touch "$PLAYER_ACTIVE"
            launch_player_bars
        fi
    else
        if [ -f "$PLAYER_ACTIVE" ]; then
            rm -f "$PLAYER_ACTIVE"
            kill_player_bars
        fi
    fi
    sleep 2
done
