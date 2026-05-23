#!/bin/bash
# 核心 (Core) - oxido-i3-themes
# Detecta rutas y carga configuración básica

# Intentar detectar la ruta raíz (preferir .config si existe)
if [ -d "$HOME/.config/themes" ]; then
    THEMES_ROOT="$HOME/.config/themes"
else
    # Fallback al repo si no está instalado
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    THEMES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
fi

export THEMES_ROOT
export LANG_DIR="$THEMES_ROOT/lang"
export SCRIPTS_DIR="$THEMES_ROOT/scripts"
export BIN_DIR="$THEMES_ROOT/bin"

# Cargar escalas e idioma
[ -f "$THEMES_ROOT/rofi/scale.env" ] && source "$THEMES_ROOT/rofi/scale.env"
[ -f "$SCRIPTS_DIR/lang-builder.sh" ] && source "$SCRIPTS_DIR/lang-builder.sh"
