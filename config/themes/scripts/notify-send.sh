#!/bin/bash
# Wrapper avanzado para notificaciones — oxido-i3-themes
# Soporta i18n, iconos Nerd Font y etiquetas de apilamiento (stack-tag)
# Uso: notify-send.sh "<icon>" "<summary>" "<body>" [urgency] [stack-tag]

ICON="${1:-}"
SUMMARY="${2:-Notification}"
BODY="${3:-}"
URGENCY="${4:-normal}"
STACK_TAG="${5:-}"

# Cargar traducciones si están disponibles
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$SCRIPT_DIR/lang-builder.sh" ] && source "$SCRIPT_DIR/lang-builder.sh"

TITLE="$ICON  $SUMMARY"

ARGS=(-a "oxido_system" -u "$URGENCY")
[ -n "$STACK_TAG" ] && ARGS+=(-h "string:x-dunst-stack-tag:$STACK_TAG")

if [ -n "$BODY" ]; then
    dunstify "${ARGS[@]}" "$TITLE" "$BODY"
else
    dunstify "${ARGS[@]}" "$TITLE"
fi
