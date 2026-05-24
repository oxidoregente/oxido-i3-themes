#!/bin/bash
# player-monitor.sh — Mata/relanza la barra player según reproductores activos
# oxido-i3-themes
#
# Cuando no hay reproductor activo: mata el proceso polybar player
# para que el strut se libere y no deje espacio vacío.
# Cuando aparece un reproductor activo: relanza la barra player.
# Lockfile previene múltiples instancias.

LOCKFILE="/tmp/polybar-player-monitor.lock"
if ! mkdir "$LOCKFILE" 2>/dev/null; then
    exit 0
fi
trap 'rm -rf "$LOCKFILE"' EXIT

source "$HOME/.config/polybar/scripts/playerctl-wrapper.sh"
CONFIG="$HOME/.config/polybar/config.ini"

is_fullscreen() {
    i3-msg -t get_tree 2>/dev/null | python3 -c "
import sys, json
t = json.load(sys.stdin)
def f(n):
    if n.get('fullscreen_mode', 0) == 1 and n.get('type') in ('con', 'floating_con'):
        return True
    for c in n.get('nodes', []) + n.get('floating_nodes', []):
        if f(c): return True
    return False
print('1' if f(t) else '0')
" 2>/dev/null || echo "0"
}

detect_monitor() {
    xrandr --query 2>/dev/null | grep " connected" | head -1 | cut -d" " -f1
}

kill_player() {
    pkill -f "polybar.*--reload.*player" 2>/dev/null
}

start_player() {
    local mon
    mon=$(detect_monitor)
    if [ -n "$mon" ] && [ -f "$CONFIG" ]; then
        MONITOR="$mon" polybar --reload player 2>/dev/null &
        disown
    fi
}

sleep 0.5

# Matar barra player al inicio (no deja strut)
kill_player

prev_alive=""
while true; do
    alive=$(get_active_player)
    fs=$(is_fullscreen)
    should_show=0
    [ -n "$alive" ] && [ "$fs" = "0" ] && should_show=1

    if [ "$should_show" = "1" ]; then
        if [ "$prev_alive" != "1" ]; then
            player_pid=$(pgrep -f "polybar.*--reload.*player" 2>/dev/null | head -1)
            [ -z "$player_pid" ] && start_player
        fi
    else
        if [ "$prev_alive" = "1" ]; then
            kill_player
        fi
    fi

    prev_alive="$should_show"
    sleep 2
done
