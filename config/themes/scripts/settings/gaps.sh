#!/bin/bash
# ▦  Gaps adjuster: inner or outer
TYPE="$1"
BACK_TO="${2:-$HOME/.config/themes/bin/rofi-settings.sh}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$SCRIPT_DIR/../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../scripts/rofi-builder.sh"
[ -f "$SCRIPT_DIR/../../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../../scripts/rofi-builder.sh"
CONFIG=~/.config/i3/config

[ "$TYPE" = "inner" ] && LABEL="Interiores" || LABEL="Exteriores"
CURRENT=$(grep "^gaps $TYPE" "$CONFIG" 2>/dev/null | awk '{print $3}')
[ -z "$CURRENT" ] && CURRENT=6

choices=$(printf "  0px\n▤  2px\n▦  4px\n▧  6px\n▨  8px\n▩  10px\n▣  12px\n▣  15px\n▣  20px\n$L_BACK" | rofi -dmenu -p "  ▦  Gaps $LABEL: ${CURRENT}px" \
    -theme-str "$ROFI_THEME_SUB" -i)

[ -z "$choices" ] && exec "$BACK_TO"
[[ "$choices" == *"$L_BACK"* ]] && exec "$BACK_TO"
VAL=$(echo "$choices" | grep -o '[0-9]\+' | head -1)
[ -z "$VAL" ] && exec "$BACK_TO"

sed -i "s/^gaps $TYPE .*/gaps $TYPE $VAL/" "$CONFIG"
i3-msg "gaps $TYPE current set $VAL" 2>/dev/null
dunstify -u low "▦  Gaps $LABEL" "Cambiado a ${VAL}px"
exec "$BACK_TO"