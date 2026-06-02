#!/bin/bash
# Lanzador de Polybar — detecta barras dinámicamente desde config.ini
# oxido-i3-themes
LOCKFILE="/tmp/polybar-launch.lock"

lockfile_clean() {
    if [ -d "$LOCKFILE" ]; then
        LOCK_PID=$(cat "$LOCKFILE/pid" 2>/dev/null || echo 0)
        if [ "$LOCK_PID" -gt 0 ] 2>/dev/null && kill -0 "$LOCK_PID" 2>/dev/null; then
            if ps -p "$LOCK_PID" -o comm= 2>/dev/null | grep -qE "polybar|launch"; then
                exit 0
            fi
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

CONFIG="$HOME/.config/polybar/config.ini"

export LANG=es_VE.utf8
export LC_TIME=es_VE.utf8

# Matar monitores anteriores (primero, para que no revivan barras)
kill -9 $(pgrep -f "player-monitor.sh" 2>/dev/null) 2>/dev/null
kill -9 $(pgrep -f "fullscreen-monitor.sh" 2>/dev/null) 2>/dev/null
sleep 0.2
rm -rf /tmp/polybar-player-monitor.lock /tmp/polybar-fullscreen.lock 2>/dev/null

# Matar barras polybar de forma elegante (SIGTERM)
killall -q polybar 2>/dev/null
TIMEOUT=10
while [ "$TIMEOUT" -gt 0 ] && pgrep -u $UID -x polybar >/dev/null; do
    sleep 0.1
    TIMEOUT=$((TIMEOUT - 1))
done

# Solo usar force kill si no han muerto tras 1 segundo
if pgrep -u $UID -x polybar >/dev/null; then
    killall -q -9 polybar 2>/dev/null
fi

# Detectar nombres de barras desde config.ini y lanzarlas
BARS=$(grep "^\[bar/" "$CONFIG" 2>/dev/null | sed 's/\[bar\/\(.*\)\]/\1/')
[ -z "$BARS" ] && BARS="top"

if type "xrandr" > /dev/null; then
    for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
        for bar in $BARS; do MONITOR=$m polybar --reload "$bar" & done
    done
else
    for bar in $BARS; do polybar --reload "$bar" & done
fi

# Monitor de pantalla completa (solo si i3 está disponible)
if command -v i3-msg &>/dev/null; then
    ~/.config/polybar/scripts/fullscreen-monitor.sh & disown
fi
