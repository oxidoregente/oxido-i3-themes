#!/bin/bash
# player-monitor.sh — Muestra/oculta barra player y reajusta center bar
# oxido-i3-themes
#
# Usa polybar-msg cmd show/hide (override-redirect=true → sin strut).
# Cuando el player se oculta, expande la barra center para cerrar el hueco.
# Cuando aparece, restaura el ancho original de center.
# Lockfile previene múltiples instancias.

LOCKFILE="/tmp/polybar-player-monitor.lock"
LOG="/tmp/polybar-player-monitor.log"

lockfile_clean() {
    if [ -d "$LOCKFILE" ]; then
        LOCK_PID=$(cat "$LOCKFILE/pid" 2>/dev/null || echo 0)
        if [ "$LOCK_PID" -gt 0 ] 2>/dev/null && kill -0 "$LOCK_PID" 2>/dev/null; then
            exit 0
        fi
        rm -rf "$LOCKFILE"
    fi
}

lockfile_create() {
    lockfile_clean
    mkdir "$LOCKFILE" 2>/dev/null || exit 0
    echo "$$" > "$LOCKFILE/pid"
}

lockfile_create
trap 'rm -rf "$LOCKFILE"' EXIT

source "$HOME/.config/polybar/scripts/playerctl-wrapper.sh"
CONFIG="$HOME/.config/polybar/config.ini"

# Solo ejecutar si existe [bar/player] en la config
grep -q "^\[bar/player\]" "$CONFIG" 2>/dev/null || exit 0

EXPANDED_W="39%"  # center expandido cuando player está oculto
CENTER_O_PLAYER="29%"

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
center_offset_orig=""

save_center_orig() {
    [ -n "$center_width_orig" ] && return
    center_width_orig=$(sed -n '/^\[bar\/center\]/,/^\[bar\// s/^width = //p' "$CONFIG" | head -1)
    [ -z "$center_width_orig" ] && center_width_orig="12%"
    center_offset_orig=$(sed -n '/^\[bar\/center\]/,/^\[bar\// s/^offset-x = //p' "$CONFIG" | head -1)
    [ -z "$center_offset_orig" ] && center_offset_orig="27%"
}

set_center_width() {
    sed -i "/^\[bar\/center\]/,/^\[bar\// s/^width =.*/width = $1/" "$CONFIG"
}

set_center_offset() {
    sed -i "/^\[bar\/center\]/,/^\[bar\// s/^offset-x =.*/offset-x = $1/" "$CONFIG"
}

restart_center() {
    pkill -f "^polybar --reload center" 2>/dev/null
    sleep 0.2
    local mon
    mon=$(detect_monitor)
    [ -n "$mon" ] && MONITOR="$mon" polybar --reload center 2>/dev/null &
    disown 2>/dev/null
}

hide_player() {
    echo "[$(date +%H:%M:%S)] hide_player: killing player bar" >> "$LOG"
    pkill -f "^polybar --reload player" 2>/dev/null
}

show_player() {
    pgrep -f "^polybar --reload player" >/dev/null 2>&1 && {
        echo "[$(date +%H:%M:%S)] show_player: already running, skipping" >> "$LOG"
        return 0
    }
    local mon
    mon=$(detect_monitor)
    echo "[$(date +%H:%M:%S)] show_player: launching on $mon" >> "$LOG"
    [ -n "$mon" ] && MONITOR="$mon" polybar --reload player 2>/dev/null &
    disown 2>/dev/null
}

echo "[$(date +%H:%M:%S)] player-monitor iniciado" >> "$LOG"

# Initial hide: expand center bar to fill the gap
save_center_orig
hide_player
set_center_offset "$center_offset_orig"
set_center_width "$EXPANDED_W"
restart_center
prev_alive=0
while true; do
    alive=$(get_active_player)
    fs=$(is_fullscreen)
    should_show=0
    [ -n "$alive" ] && [ "$fs" = "0" ] && should_show=1

    echo "[$(date +%H:%M:%S)] loop: alive='$alive' fs=$fs should_show=$should_show prev=$prev_alive" >> "$LOG"

    # Sincronizar estado real de la barra con el estado deseado
    if pgrep -f "^polybar --reload player" >/dev/null 2>&1; then
        bar_running=true
    else
        bar_running=false
    fi

    if [ "$should_show" = "1" ] && ! $bar_running; then
        echo "[$(date +%H:%M:%S)] SHOW: barra caida, levantando ($alive)" >> "$LOG"
        save_center_orig
        set_center_offset "$CENTER_O_PLAYER"
        set_center_width "$center_width_orig"
        restart_center
        show_player
        prev_alive=1
    elif [ "$should_show" != "1" ] && $bar_running; then
        echo "[$(date +%H:%M:%S)] HIDE: sin player, matando barra" >> "$LOG"
        save_center_orig
        hide_player
        set_center_offset "$center_offset_orig"
        set_center_width "$EXPANDED_W"
        restart_center
        prev_alive=0
    else
        prev_alive="$should_show"
    fi

    prev_alive="$should_show"
    sleep 2
done
