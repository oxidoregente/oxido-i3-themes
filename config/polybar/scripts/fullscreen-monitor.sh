#!/bin/bash
# fullscreen-monitor.sh — Oculta/muestra polybar cuando una ventana entra/sale de fullscreen
# Busca en TODOS los nodos del árbol i3 (no solo el focused)

LOCKFILE="/tmp/polybar-fullscreen.lock"

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

get_fs() {
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

hide_all() {
    for pid in $(pgrep -x polybar 2>/dev/null); do
        polybar-msg -p "$pid" cmd hide 2>/dev/null
    done
}

show_all() {
    for pid in $(pgrep -x polybar 2>/dev/null); do
        polybar-msg -p "$pid" cmd show 2>/dev/null
    done
}

# Pequeña pausa para que i3 termine de arrancar tras un restart
sleep 0.3

prev=$(get_fs)
[ "$prev" = "1" ] && hide_all

# Suscribirse a eventos de ventana y binding
i3-msg -t subscribe -m '[ "window", "binding" ]' 2>/dev/null | while read -r _; do
    curr=$(get_fs)
    if [ "$curr" = "1" ] && [ "$prev" != "1" ]; then
        hide_all
    elif [ "$curr" = "0" ] && [ "$prev" != "0" ]; then
        show_all
    fi
    prev="$curr"
done

# Si la suscripción se rompe (e.g. i3 restart), restaurar barras
show_all
