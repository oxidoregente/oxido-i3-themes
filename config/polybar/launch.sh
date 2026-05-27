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
pkill -f "player-monitor.sh" 2>/dev/null
pkill -f "fullscreen-monitor.sh" 2>/dev/null
sleep 0.2
rm -rf /tmp/polybar-player-monitor.lock /tmp/polybar-fullscreen.lock 2>/dev/null

# Matar barras polybar con timeout y force kill
pkill -x polybar 2>/dev/null
TIMEOUT=5
while [ "$TIMEOUT" -gt 0 ] && pgrep -x polybar >/dev/null; do
    sleep 0.3
    TIMEOUT=$((TIMEOUT - 1))
done
pgrep -x polybar >/dev/null && pkill -9 -x polybar 2>/dev/null

# Anchos adaptativos solo si existen las barras del layout bubble
if grep -q "^\[bar/left\]" "$CONFIG" 2>/dev/null; then
    ADAPTIVE=$($HOME/.config/polybar/scripts/calc-adaptive-widths.sh)
    if [ -n "$ADAPTIVE" ]; then
        LEFT_W=$(echo "$ADAPTIVE" | grep "^left=" | cut -d= -f2 | cut -d\| -f1)
        LEFT_O=$(echo "$ADAPTIVE" | grep "^left=" | cut -d\| -f2)
        CENTER_W=$(echo "$ADAPTIVE" | grep "^center=" | cut -d= -f2 | cut -d\| -f1)
        CENTER_O=$(echo "$ADAPTIVE" | grep "^center=" | cut -d\| -f2)
        PLAYER_W=$(echo "$ADAPTIVE" | grep "^player=" | cut -d= -f2 | cut -d\| -f1)
        PLAYER_O=$(echo "$ADAPTIVE" | grep "^player=" | cut -d\| -f2)
        # Validate: all values must be positive numbers
        if echo "$LEFT_W $LEFT_O $CENTER_W $CENTER_O $PLAYER_W $PLAYER_O" | \
             grep -qE '^[0-9]+(\.[0-9]+)?( [0-9]+(\.[0-9]+)?)*$' && \
             [ "$(echo "$LEFT_W > 0" | bc -l 2>/dev/null)" = 1 ] && \
             [ "$(echo "$CENTER_W > 0" | bc -l 2>/dev/null)" = 1 ] && \
             [ "$(echo "$PLAYER_W > 0" | bc -l 2>/dev/null)" = 1 ]; then
            sed -i "/^\[bar\/left\]/,/^\[bar\// {s/^width =.*/width = $LEFT_W%/; s/^offset-x =.*/offset-x = $LEFT_O%/;}" "$CONFIG"
            sed -i "/^\[bar\/center\]/,/^\[bar\// {s/^width =.*/width = $CENTER_W%/; s/^offset-x =.*/offset-x = $CENTER_O%/;}" "$CONFIG"
            sed -i "/^\[bar\/player\]/,/^\[bar\// {s/^width =.*/width = $PLAYER_W%/; s/^offset-x =.*/offset-x = $PLAYER_O%/;}" "$CONFIG"
        fi
    fi
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

# Monitor de visibilidad de player bar (solo si existe [bar/player])
if grep -q "^\[bar/player\]" "$CONFIG" 2>/dev/null; then
    ~/.config/polybar/scripts/player-monitor.sh & disown
fi

# Monitor de pantalla completa (solo si i3 está disponible)
if command -v i3-msg &>/dev/null; then
    ~/.config/polybar/scripts/fullscreen-monitor.sh & disown
fi

