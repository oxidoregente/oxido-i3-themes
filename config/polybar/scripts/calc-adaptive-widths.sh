#!/bin/bash
# calc-adaptive-widths.sh — Calcula anchos adaptativos para split bars
# oxido-i3-themes — https://github.com/anomalyco/oxido-i3-themes
# Dependencias: xrandr

get_monitor_width() {
    local monitor="$MONITOR"
    if [ -z "$monitor" ]; then
        monitor=$(xrandr --query | grep " primary" | grep -oP '^\S+' | head -1)
    fi
    if [ -z "$monitor" ]; then
        monitor=$(xrandr --query | grep " connected" | grep -v " disconnected" | head -1 | awk '{print $1}')
    fi
    xrandr --query | grep -A1 "^$monitor connected" | grep -oP '\d+(?=x\d+)' | head -1
}

WIDTH=$(get_monitor_width)
[ -z "$WIDTH" ] && WIDTH=1920

# Proporciones base mucho más compactas
GAP=1.5

# Mínimos absolutos en pixeles muy ajustados
# Contar workspaces activos para que la burbuja izquierda sea adaptativa
WS_COUNT=$(i3-msg -t get_workspaces 2>/dev/null | python3 -c "import sys, json; print(len(json.load(sys.stdin)))" 2>/dev/null || echo 1)
MIN_LEFT=$((120 + WS_COUNT * 22))

MIN_CENTER=85

# Si la fecha larga está activa, necesitamos mucho más espacio (380px)
if [ -f "/tmp/polybar-date-alt" ]; then
    MIN_CENTER=380
fi

MIN_PLAYER=240

VALUES=$(python3 -c "
w = $WIDTH
left = max(8.0, round($MIN_LEFT / w * 100, 1))
center = max(6.0, round($MIN_CENTER / w * 100, 1))
gap = $GAP
center_o = round(left + gap, 1)
player_o = round(center_o + center + gap, 1)
# Burbuja de sistema más amplia (36%) para evitar que el tray se encime
right_w = 36.0
right_o = round(100.0 - right_w, 1)
player_end = round(right_o - gap, 1)
player = max(round(player_end - player_o, 1), round($MIN_PLAYER / w * 100, 1))

print(f'{left}|{center}|{center_o}|{player}|{player_o}|{right_w}|{right_o}')
")

LEFT_PCT=$(echo "$VALUES" | cut -d'|' -f1)
CENTER_PCT=$(echo "$VALUES" | cut -d'|' -f2)
CENTER_O=$(echo "$VALUES" | cut -d'|' -f3)
PLAYER_PCT=$(echo "$VALUES" | cut -d'|' -f4)
PLAYER_O=$(echo "$VALUES" | cut -d'|' -f5)
RIGHT_PCT=$(echo "$VALUES" | cut -d'|' -f6)
RIGHT_O=$(echo "$VALUES" | cut -d'|' -f7)

echo "left=$LEFT_PCT|0"
echo "center=$CENTER_PCT|$CENTER_O"
echo "player=$PLAYER_PCT|$PLAYER_O"
echo "right=$RIGHT_PCT|$RIGHT_O"
