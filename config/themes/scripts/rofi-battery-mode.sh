#!/bin/bash
# rofi-battery-mode.sh — Menú para cambiar el perfil de energía
# oxido-i3-themes

# Evitar duplicados si se hace clic rápido
pidof -x rofi >/dev/null 2>&1 && exit 0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$SCRIPT_DIR/rofi-builder.sh" ] && source "$SCRIPT_DIR/rofi-builder.sh"
[ -f "$SCRIPT_DIR/../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../scripts/rofi-builder.sh"

current=$(powerprofilesctl get 2>/dev/null || echo "balanced")

option_save="$L_BAT_SAVE"
option_bal="$L_BAT_BAL"
option_perf="$L_BAT_PERF"

[ "$current" = "power-saver" ] && option_save="$option_save  $L_BAT_ACTIVE"
[ "$current" = "balanced" ] && option_bal="$option_bal  $L_BAT_ACTIVE"
[ "$current" = "performance" ] && option_perf="$option_perf  $L_BAT_ACTIVE"

options="$option_save\n$option_bal\n$option_perf"

chosen=$(echo -e "$options" | rofi -dmenu -p "$L_NOT_BAT" -i -theme-str "
window { width: 480px; border-radius: 24px; border-color: $SEL; background-color: $BG; }
mainbox { children: [ listview ]; padding: 20px; }
listview { columns: 1; lines: 3; spacing: 8px; dynamic: false; }
element { padding: 14px 16px; border-radius: 14px; text-color: $FG; background-color: $BGA; }
element selected { background-color: $SEL; text-color: $BG; }
element-text { vertical-align: 0.5; font: \"JetBrainsMono Nerd Font Mono 12\"; }
")

case "$chosen" in
    *Power*|*Ahorro*) powerprofilesctl set power-saver 2>/dev/null ;;
    *Balanced*|*Equilibrado*) powerprofilesctl set balanced 2>/dev/null ;;
    *Performance*|*Rendimiento*) powerprofilesctl set performance 2>/dev/null ;;
esac

polybar-msg action "#battery.module_exec" 2>/dev/null
