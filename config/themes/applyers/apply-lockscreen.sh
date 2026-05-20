#!/bin/bash
# apply-lockscreen.sh: Aplica pantalla de bloqueo personalizada del tema
# Uso: apply-lockscreen.sh <ruta-al-tema>

THEME_DIR="$1"
THEME_NAME=$(basename "$THEME_DIR")
UNLOCK_IMG="$THEME_DIR/unlock.png"
LOCK_DIR="$HOME/.config/themes/current/lock"

mkdir -p "$LOCK_DIR"

if [ -f "$UNLOCK_IMG" ]; then
    cp "$UNLOCK_IMG" "$LOCK_DIR/lock.png"
    notify-send -i "$UNLOCK_IMG" "Lock Screen" "Fondo de bloqueo: $THEME_NAME"
else
    echo "  ✗ No hay unlock.png para $THEME_NAME"
fi
