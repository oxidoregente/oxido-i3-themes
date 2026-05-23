#!/bin/bash
# rofi-battery-mode.sh — Menú para cambiar el perfil de energía
# oxido-i3-themes

# Detectar rutas y cargar builder
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$SCRIPT_DIR/rofi-builder.sh" ] && source "$SCRIPT_DIR/rofi-builder.sh"

# Obtener modo actual
current=$(powerprofilesctl get 2>/dev/null || echo "balanced")

# Opciones con indicadores de estado
option_save="$L_BAT_SAVE"
option_bal="$L_BAT_BAL"
option_perf="$L_BAT_PERF"

[ "$current" = "power-saver" ] && option_save="$option_save  $L_BAT_ACTIVE"
[ "$current" = "balanced" ] && option_bal="$option_bal  $L_BAT_ACTIVE"
[ "$current" = "performance" ] && option_perf="$option_perf  $L_BAT_ACTIVE"

options="$option_save\n$option_bal\n$option_perf"

chosen=$(echo -e "$options" | rofi -dmenu -p "$L_NOT_BAT" -i -theme-str "$ROFI_THEME_SUB")

case "$chosen" in
    *Power*|*Ahorro*) powerprofilesctl set power-saver 2>/dev/null ;;
    *Balanced*|*Equilibrado*) powerprofilesctl set balanced 2>/dev/null ;;
    *Performance*|*Rendimiento*) powerprofilesctl set performance 2>/dev/null ;;
esac

# Forzar actualización inmediata del widget
pids=$(pidof polybar)
if [ -n "$pids" ]; then
    for pid in $pids; do
        kill -44 "$pid" 2>/dev/null
        kill -SIGRTMIN+10 "$pid" 2>/dev/null
    done
fi
