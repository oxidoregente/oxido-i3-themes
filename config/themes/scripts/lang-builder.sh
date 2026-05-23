#!/bin/bash
# 🌍  Cargador de idiomas para oxido-i3-themes
# oxido-i3-themes

# Detectar ruta raíz
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ "$SCRIPT_DIR" == *"/scripts" ]]; then
    THEMES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
else
    THEMES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
fi

LANG_DIR="$THEMES_ROOT/lang"

# Cargar preferencia del usuario
[ -f "$LANG_DIR/active_lang.env" ] && source "$LANG_DIR/active_lang.env"
LANG=${LANG:-es}

# Cargar archivo de idioma
if [ -f "$LANG_DIR/$LANG.sh" ]; then
    source "$LANG_DIR/$LANG.sh"
else
    # Fallback al español
    [ -f "$LANG_DIR/es.sh" ] && source "$LANG_DIR/es.sh"
fi
