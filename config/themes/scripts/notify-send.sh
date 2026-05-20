#!/bin/bash
# Wrapper para enviar notificaciones con iconos Nerd Font
# Uso: notify-send.sh "<icon>" "<summary>" "<body>" [urgency]
ICON="${1:-}"
SUMMARY="${2:-Notification}"
BODY="${3:-}"
URGENCY="${4:-normal}"
TITLE="$ICON  $SUMMARY"
if [ -n "$BODY" ]; then
    dunstify -u "$URGENCY" "$TITLE" "$BODY"
else
    dunstify -u "$URGENCY" "$TITLE"
fi
