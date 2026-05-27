#!/bin/bash
# clock-format.sh — Toggle 12h / 24h para el reloj de polybar
# oxido-i3-themes
pidof -x rofi >/dev/null 2>&1 && exit 0
BACK_TO="${1:-$HOME/.config/themes/bin/rofi-settings.sh}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$SCRIPT_DIR/../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../scripts/rofi-builder.sh"
[ -f "$SCRIPT_DIR/../../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../../scripts/rofi-builder.sh"

FMT_FILE="$HOME/.config/themes/date-format"
current=$(cat "$FMT_FILE" 2>/dev/null || echo "12h")

opt_12="󱑎  12h"
opt_24="󱑏  24h"

[ "$current" = "12h" ] && opt_12="$opt_12  $L_BAT_ACTIVE"
[ "$current" = "24h" ] && opt_24="$opt_24  $L_BAT_ACTIVE"

choices=$(printf "%s\n%s\n%s" "$opt_12" "$opt_24" "$L_BACK" | \
    rofi -dmenu -p "$L_CLOCK_FMT" -i -theme-str "
window { width: 480px; border-radius: 24px; border-color: $SEL; background-color: $BG; }
mainbox { children: [ listview ]; padding: 20px; }
listview { columns: 1; lines: 3; spacing: 8px; dynamic: false; }
element { padding: 14px 16px; border-radius: 14px; text-color: $FG; background-color: $BGA; }
element selected { background-color: $SEL; text-color: $BG; }
element-text { vertical-align: 0.5; font: \"JetBrainsMono Nerd Font Mono 12\"; }
")

[ -z "$choices" ] && exec "$BACK_TO"
[[ "$choices" == *"$L_BACK"* ]] && exec "$BACK_TO"

if [[ "$choices" == *"12h"* ]] && [ "$current" != "12h" ]; then
    echo "12h" > "$FMT_FILE"
    if [ -f "$HOME/.config/polybar/config.ini" ]; then
        sed -i "/^\[module\/date\]/,/^\[module\//{s/^date *=.*/date = %I:%M %p/}" "$HOME/.config/polybar/config.ini"
    fi
elif [[ "$choices" == *"24h"* ]] && [ "$current" != "24h" ]; then
    echo "24h" > "$FMT_FILE"
    if [ -f "$HOME/.config/polybar/config.ini" ]; then
        sed -i "/^\[module\/date\]/,/^\[module\//{s/^date *=.*/date = %H:%M/}" "$HOME/.config/polybar/config.ini"
    fi
fi

polybar-msg action "#date.hook.0" 2>/dev/null
polybar-msg action "#center-bubble.hook.0" 2>/dev/null
polybar-msg cmd restart 2>/dev/null

exec "$BACK_TO"
