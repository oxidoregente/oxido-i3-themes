#!/bin/bash
# Inicia servicios según el modo (powersaver o normal)
POWERSAVER_FLAG="/tmp/powersaver_active"
CONKY_FLAG="$HOME/.config/themes/conky-enabled"

if [ ! -f "$POWERSAVER_FLAG" ]; then
    # Modo normal: iniciar picom si no está corriendo
    PICOM_BIN="$HOME/.local/bin/picom"
    if ! pgrep -x picom >/dev/null 2>&1; then
        "$PICOM_BIN" --config "$HOME/.config/picom/picom.conf" -b 2>/dev/null &
        disown
    fi

    # Iniciar conky si está habilitado
    if [ -f "$CONKY_FLAG" ]; then
        if ! pgrep -x conky >/dev/null 2>&1; then
            conky -c "$HOME/.config/conky/conky.conf" 2>/dev/null &
            disown
        fi
    fi
fi
