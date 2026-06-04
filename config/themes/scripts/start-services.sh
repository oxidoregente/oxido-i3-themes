#!/bin/bash
# Inicia servicios según el modo (powersaver o normal)
# oxido-i3-themes
STATE_DIR="$HOME/.config/themes/state"
POWERSAVER_FLAG="$STATE_DIR/powersaver_active"
CONKY_FLAG="$HOME/.config/themes/conky-enabled"

mkdir -p "$STATE_DIR"

if [ -f "$POWERSAVER_FLAG" ]; then
    # Modo powersaver: re-aplicar configuración powersaver
    bash "$HOME/.config/themes/scripts/toggle-powersaver.sh" --restore
fi

# Iniciar picom si no está corriendo (y no estamos en powersaver)
if [ ! -f "$POWERSAVER_FLAG" ]; then
    PICOM_BIN="$HOME/.local/bin/picom"
    if ! pgrep -x picom >/dev/null 2>&1; then
        "$PICOM_BIN" --config "$HOME/.config/picom/picom.conf" -b 2>/dev/null &
        disown
    fi

    # Iniciar conky si está habilitado
    if [ -f "$CONKY_FLAG" ]; then
        if ! pgrep -x conky >/dev/null 2>&1; then
            LANG_FILE="$HOME/.config/themes/lang/active_lang.env"
            lang=$(grep '^LANG=' "$LANG_FILE" 2>/dev/null | cut -d'"' -f2)
            [ -z "$lang" ] && lang="es"
            export LC_TIME=$([ "$lang" = "en" ] && echo "en_US.utf8" || echo "es_VE.utf8")
            conky -c "$HOME/.config/conky/conky.conf" 2>/dev/null &
            disown
        fi
    fi
fi

# Restaurar perfil de energía guardado
if [ -f "$STATE_DIR/power_profile" ]; then
    SAVED=$(cat "$STATE_DIR/power_profile")
    bash "$HOME/.config/themes/scripts/set-power-profile.sh" set "$SAVED" 2>/dev/null
fi
