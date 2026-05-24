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

# Proporciones base con gaps de 2% entre barras flotantes
GAP=2
# Los módulos de la derecha (sys-start .. sys-end + tray) ocupan ~42% estimado
# La barra player termina 10px ANTES de que empiecen los módulos derechos
RIGHT_PCT=42
GAP_PX=10

# Mínimos absolutos en pixeles para evitar overflow en monitores pequeños
MIN_LEFT=300
MIN_CENTER=160
MIN_PLAYER=300

VALUES=$(python3 -c "
w = $WIDTH
left = max(22.0, round($MIN_LEFT / w * 100, 1))
center = max(12.0, round($MIN_CENTER / w * 100, 1))
gap = $GAP
center_o = round(left + gap + 3, 1)
player_o = round(center_o + center + gap + 9, 1)
# Player termina 10px antes de los módulos derechos (RIGHT_PCT% del ancho)
right_pct = $RIGHT_PCT
gap_pct = round($GAP_PX / w * 100, 1)
player_end = round(100 - right_pct - gap_pct, 1)
player = max(round(player_end - player_o, 1), round($MIN_PLAYER / w * 100, 1))
print(f'{left}|{center}|{center_o}|{player}|{player_o}')
")

LEFT_PCT=$(echo "$VALUES" | cut -d'|' -f1)
CENTER_PCT=$(echo "$VALUES" | cut -d'|' -f2)
CENTER_O=$(echo "$VALUES" | cut -d'|' -f3)
PLAYER_PCT=$(echo "$VALUES" | cut -d'|' -f4)
PLAYER_O=$(echo "$VALUES" | cut -d'|' -f5)

echo "left=$LEFT_PCT|0"
echo "center=$CENTER_PCT|$CENTER_O"
echo "player=$PLAYER_PCT|$PLAYER_O"
