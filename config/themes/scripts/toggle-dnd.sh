#!/bin/bash
STATE_FILE=~/.cache/dunst-dnd

if [ -f "$STATE_FILE" ]; then
    rm -f "$STATE_FILE"
    dunstctl set-paused false
    dunstify -u low "  Notificaciones" "Activadas — Modo normal" -i dialog-information
else
    touch "$STATE_FILE"
    dunstctl set-paused true
    dunstify -u critical "  No Molestar" "Notificaciones silenciadas" -i dialog-information
fi

# Force polybar to update indicator immediately
polybar-msg hook dnd 2 2>/dev/null || true
