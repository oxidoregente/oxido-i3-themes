#!/bin/bash
# Lanzador de Polybar — detecta barras dinámicamente desde config.ini
# oxido-i3-themes
LOCKFILE="/tmp/polybar-launch.lock"
if ! mkdir "$LOCKFILE" 2>/dev/null; then
    exit 0
fi
trap 'rm -rf "$LOCKFILE"' EXIT

CONFIG="$HOME/.config/polybar/config.ini"

killall -q polybar 2>/dev/null
while pgrep -u $UID -x polybar >/dev/null; do sleep 0.3; done

export LANG=es_VE.utf8
export LC_TIME=es_VE.utf8

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
        sed -i "/^\[bar\/left\]/,/^\[bar\// {s/^width =.*/width = $LEFT_W%/; s/^offset-x =.*/offset-x = $LEFT_O%/;}" "$CONFIG"
        sed -i "/^\[bar\/center\]/,/^\[bar\// {s/^width =.*/width = $CENTER_W%/; s/^offset-x =.*/offset-x = $CENTER_O%/;}" "$CONFIG"
        sed -i "/^\[bar\/player\]/,/^\[bar\// {s/^width =.*/width = $PLAYER_W%/; s/^offset-x =.*/offset-x = $PLAYER_O%/;}" "$CONFIG"
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

# Matar monitores anteriores
pkill -f "player-monitor.sh" 2>/dev/null
pkill -f "fullscreen-monitor.sh" 2>/dev/null
sleep 0.3
rm -f /tmp/polybar-player-monitor.lock /tmp/polybar-fullscreen.lock

# Monitor de visibilidad de player bar (solo si existe [bar/player])
if grep -q "^\[bar/player\]" "$CONFIG" 2>/dev/null; then
    ~/.config/polybar/scripts/player-monitor.sh & disown
fi

# Monitor de pantalla completa (solo si i3 está disponible)
if command -v i3-msg &>/dev/null; then
    ~/.config/polybar/scripts/fullscreen-monitor.sh & disown
fi

