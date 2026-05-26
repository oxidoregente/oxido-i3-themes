#!/bin/bash
# 🔊  Audio output sink selector
BACK_TO="${1:-$HOME/.config/themes/bin/rofi-settings.sh}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$SCRIPT_DIR/../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../scripts/rofi-builder.sh"
[ -f "$SCRIPT_DIR/../../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../../scripts/rofi-builder.sh"

SINKS=$(pactl list short sinks 2>/dev/null | awk '{print $2}')
CURRENT=$(pactl info 2>/dev/null | grep "Default Sink" | awk '{print $3}')

entries="$L_BACK\n"
while IFS= read -r sink; do
    desc=$(pactl list sinks 2>/dev/null | grep -A20 "Name: $sink" | grep "Description" | sed 's/.*Description: //')
    [ -z "$desc" ] && desc="$sink"
    mark=" "
    [ "$sink" = "$CURRENT" ] && mark="▶"
    entries+="$mark  $desc\n"
done <<< "$SINKS"

chosen=$(printf "%b" "$entries" | rofi -dmenu -p "  $L_SINK" -theme-str "$ROFI_THEME_SUB" -i)

[ -z "$chosen" ] && exec "$BACK_TO"
[[ "$chosen" == *"$L_BACK"* ]] && exec "$BACK_TO"

chosen=$(echo "$chosen" | sed 's/^▶  //; s/^   //')
while IFS= read -r sink; do
    desc=$(pactl list sinks 2>/dev/null | grep -A20 "Name: $sink" | grep "Description" | sed 's/.*Description: //')
    [ "$desc" = "$chosen" ] && { pactl set-default-sink "$sink"; break; }
done <<< "$SINKS"
dunstify -u low "$L_SINK" "Salida cambiada a: $chosen"