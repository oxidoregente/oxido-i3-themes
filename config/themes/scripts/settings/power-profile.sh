#!/bin/bash
# power-profile.sh — Menú para seleccionar perfil de energía (CPU)
# oxido-i3-themes
pidof -x rofi >/dev/null 2>&1 && exit 0
BACK_TO="${1:-$HOME/.config/themes/bin/rofi-settings.sh}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$SCRIPT_DIR/../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../scripts/rofi-builder.sh"
[ -f "$SCRIPT_DIR/../../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../../scripts/rofi-builder.sh"

current=$(powerprofilesctl get 2>/dev/null || echo "balanced")

opt_save="$L_BAT_SAVE"
opt_bal="$L_BAT_BAL"
opt_perf="$L_BAT_PERF"

[ "$current" = "power-saver" ] && opt_save="$opt_save  $L_BAT_ACTIVE"
[ "$current" = "balanced" ] && opt_bal="$opt_bal  $L_BAT_ACTIVE"
[ "$current" = "performance" ] && opt_perf="$opt_perf  $L_BAT_ACTIVE"

choices=$(printf "%s\n%s\n%s\n%s" "$opt_save" "$opt_bal" "$opt_perf" "$L_BACK" | \
    rofi -dmenu -p "$L_POWER_PROFILE" -i -theme-str "
window { width: 480px; border-radius: 24px; border-color: $SEL; background-color: $BG; }
mainbox { children: [ listview ]; padding: 20px; }
listview { columns: 1; lines: 4; spacing: 8px; dynamic: false; }
element { padding: 14px 16px; border-radius: 14px; text-color: $FG; background-color: $BGA; }
element selected { background-color: $SEL; text-color: $BG; }
element-text { vertical-align: 0.5; font: \"JetBrainsMono Nerd Font Mono 12\"; }
")

[ -z "$choices" ] && exec "$BACK_TO"
[[ "$choices" == *"$L_BACK"* ]] && exec "$BACK_TO"

case "$choices" in
    *"$L_BAT_SAVE"*) powerprofilesctl set power-saver 2>/dev/null ;;
    *"$L_BAT_BAL"*) powerprofilesctl set balanced 2>/dev/null ;;
    *"$L_BAT_PERF"*) powerprofilesctl set performance 2>/dev/null ;;
esac

polybar-msg action "#battery.module_exec" 2>/dev/null
exec "$BACK_TO"
