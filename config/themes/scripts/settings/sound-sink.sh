#!/bin/bash
# 🔊  Audio output sink selector
SINKS=$(pactl list short sinks 2>/dev/null | awk '{print $2}')
CURRENT=$(pactl info 2>/dev/null | grep "Default Sink" | awk '{print $3}')

entries=""
while IFS= read -r sink; do
    desc=$(pactl list sinks 2>/dev/null | grep -A20 "Name: $sink" | grep "Description" | sed 's/.*Description: //')
    [ -z "$desc" ] && desc="$sink"
    mark=" "
    [ "$sink" = "$CURRENT" ] && mark="▶"
    entries+="$mark  $desc\n"
done <<< "$SINKS"
entries+="⬅️  Volver\n"
chosen=$(printf "%b" "$entries" | rofi -dmenu -p "    Salida de audio" \
    -theme-str 'window { width: 480; border-radius: 16px; background-color: #1e1e2e; }
    mainbox { children: [listview]; spacing: 4px; padding: 8px; }
    listview { spacing: 4px; dynamic: true; }
    element { border-radius: 10px; padding: 10px 14px; background-color: #313244; text-color: #cdd6f4; }
    element selected { background-color: #89b4fa; text-color: #1e1e2e; }' -i)

[ -z "$chosen" ] && exit 0
[[ "$chosen" == *"Volver"* ]] && exec ~/.config/themes/bin/rofi-settings.sh
chosen=$(echo "$chosen" | sed 's/^▶  //; s/^   //')
# find sink name by description
while IFS= read -r sink; do
    desc=$(pactl list sinks 2>/dev/null | grep -A20 "Name: $sink" | grep "Description" | sed 's/.*Description: //')
    [ "$desc" = "$chosen" ] && { pactl set-default-sink "$sink"; break; }
done <<< "$SINKS"
dunstify -u low "  Audio" "Salida cambiada a: $chosen"
