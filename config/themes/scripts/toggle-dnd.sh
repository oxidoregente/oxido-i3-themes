#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$SCRIPT_DIR/lang-builder.sh" ] && source "$SCRIPT_DIR/lang-builder.sh"
[ -f "$SCRIPT_DIR/scripts/lang-builder.sh" ] && source "$SCRIPT_DIR/scripts/lang-builder.sh"

STATE_FILE=~/.cache/dunst-dnd

if [ -f "$STATE_FILE" ]; then
    rm -f "$STATE_FILE"
    dunstctl set-paused false
    dunstify -u low -t 3000 "  $L_DND" "$L_NOT_DND_OFF"
else
    dunstify -u low -t 2000 "  $L_DND" "$L_NOT_DND_ON"
    touch "$STATE_FILE"
    sleep 2
    dunstctl set-paused true
fi

polybar-msg hook dnd 2 2>/dev/null || true