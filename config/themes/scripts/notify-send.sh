#!/bin/bash
# 📬  Wrapper avanzado para notificaciones — oxido-i3-themes
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

# Construir comando dunstify
CMD="dunstify -a 'oxido_system' -u '$URGENCY'"

# Si hay stack-tag, añadirlo para que las notis se reemplacen entre sí
[ -n "$STACK_TAG" ] && CMD="$CMD -h string:x-dunst-stack-tag:$STACK_TAG"

# Título con icono
TITLE="$ICON  $SUMMARY"

if [ -n "$BODY" ]; then
    eval "$CMD '$TITLE' '$BODY'"
else
    eval "$CMD '$TITLE'"
fi
