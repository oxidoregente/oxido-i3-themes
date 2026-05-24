#!/bin/bash
# player-monitor.sh — Mata/relanza la barra player y reajusta anchos
# oxido-i3-themes
#
# Cuando NO hay reproductor activo:
#   - Mata polybar player (libera el slot)
#   - Expande la barra center para ocupar el espacio liberado
# Cuando SÍ hay reproductor activo:
#   - Restaura el ancho original de la barra center
#   - Relanza polybar player en su slot
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

center_width_orig=""

set_center_width() {
    local pct="$1"
    sed -i "/^\[bar\/center\]/,/^\[bar\// s/^width =.*/width = $pct/" "$CONFIG"
}

restart_center() {
    pkill -f "^polybar --reload center" 2>/dev/null
    sleep 0.2
    local mon
    mon=$(detect_monitor)
    [ -n "$mon" ] && MONITOR="$mon" polybar --reload center 2>/dev/null &
    disown 2>/dev/null
}

kill_player() {
    pkill -f "^polybar --reload player" 2>/dev/null
}

start_player() {
    local mon
    mon=$(detect_monitor)
    if [ -n "$mon" ] && [ -f "$CONFIG" ]; then
        MONITOR="$mon" polybar --reload player 2>/dev/null &
        disown
    fi
}

adopt_no_player() {
    local w
    # Guardar ancho original de center solo una vez
    if [ -z "$center_width_orig" ]; then
        center_width_orig=$(sed -n '/^\[bar\/center\]/,/^\[bar\// s/^width = //p' "$CONFIG" | head -1)
        [ -z "$center_width_orig" ] && center_width_orig="12%"
    fi
    # Calcular nuevo ancho: center_actual + player + gaps
    w=$(python3 -c "
co = ${center_width_orig%\%}
w = round(co + 22.0, 1)  # 20 player + 2 gap
print(f'{w}%')
" 2>/dev/null)
    [ -z "$w" ] && w="34%"
    set_center_width "$w"
    kill_player
    restart_center
}

restore_player_widths() {
    [ -n "$center_width_orig" ] && set_center_width "$center_width_orig"
    kill_player
    sleep 0.15
    restart_center
    sleep 0.3
    start_player
}

sleep 0.5

prev_alive=""
while true; do
    alive=$(get_active_player)
    fs=$(is_fullscreen)
    should_show=0
    [ -n "$alive" ] && [ "$fs" = "0" ] && should_show=1

    if [ -n "$prev_alive" ]; then
        if [ "$should_show" = "1" ]; then
            if [ "$prev_alive" != "1" ]; then
                restore_player_widths
            fi
        elif [ "$prev_alive" = "1" ]; then
            adopt_no_player
        fi
    fi

    prev_alive="$should_show"
    sleep 2
done
