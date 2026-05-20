#!/bin/bash
# ▦  Gaps adjuster: inner or outer
TYPE="$1"  # inner or outer
CONFIG=~/.config/i3/config

[ "$TYPE" = "inner" ] && LABEL="Interiores" || LABEL="Exteriores"
CURRENT=$(grep "^gaps $TYPE" "$CONFIG" 2>/dev/null | awk '{print $3}')
[ -z "$CURRENT" ] && CURRENT=6

choices=$(printf "  0px\n▤  2px\n▦  4px\n▧  6px\n▨  8px\n▩  10px\n▣  12px\n▣  15px\n▣  20px\n⬅️  Volver" | rofi -dmenu -p "  ▦  Gaps $LABEL: ${CURRENT}px" \
    -theme-str 'window { width: 300; border-radius: 16px; background-color: #1e1e2e; }
    mainbox { children: [listview]; spacing: 4px; padding: 8px; }
    listview { spacing: 4px; dynamic: true; }
    element { border-radius: 10px; padding: 12px; background-color: #313244; text-color: #cdd6f4; }
    element selected { background-color: #89b4fa; text-color: #1e1e2e; }
    element-text { horizontal-align: 0.5; font: "FiraCode Nerd Font 12"; }' -i)

[ -z "$choices" ] && exit 0
[[ "$choices" == *"Volver"* ]] && exec ~/.config/themes/bin/rofi-settings.sh
VAL=$(echo "$choices" | grep -o '[0-9]\+' | head -1)
[ -z "$VAL" ] && exit 0

sed -i "s/^gaps $TYPE .*/gaps $TYPE $VAL/" "$CONFIG"
i3-msg "gaps $TYPE current set $VAL" 2>/dev/null
dunstify -u low "▦  Gaps $LABEL" "Cambiado a ${VAL}px"
