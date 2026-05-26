#!/bin/bash
# 🎨  Generador dinámico de temas RASI para oxido-i3-themes
# oxido-i3-themes

# Detectar ruta raíz
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ "$SCRIPT_DIR" == *"/scripts" ]]; then
    THEMES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
else
    THEMES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
fi

# Cargar escalas
SCALE_ENV="$THEMES_ROOT/rofi/scale.env"
[ -f "$SCALE_ENV" ] && source "$SCALE_ENV"

# Cargar idioma
source "$THEMES_ROOT/scripts/lang-builder.sh"

# Normalizar locale para rofi (después de lang-builder, que sobreescribe LANG)
if ! echo "$(locale -a 2>/dev/null)" | grep -qx "$LANG" >/dev/null 2>&1; then
    MATCH=$(locale -a 2>/dev/null | grep -im1 "^${LANG%%.*}\." 2>/dev/null)
    [ -n "$MATCH" ] && export LANG="$MATCH" || export LANG=C.utf8
fi

THEME_LINK="$THEMES_ROOT/current/theme"
[ ! -L "$THEME_LINK" ] && THEME_LINK="$THEMES_ROOT/themes/nord"
TDIR=$(readlink -f "$THEME_LINK")

get_color() {
    local key="$1" fallback="$2"
    local val=$(grep "^$key\s*=" "$TDIR/polybar/colors.ini" 2>/dev/null | cut -d= -f2 | tr -d ' "')
    [ -z "$val" ] && val=$(grep "^$key\s*=" "$TDIR/polybar/config.ini" 2>/dev/null | cut -d= -f2 | tr -d ' "')
    # Strip alpha channel (8-digit hex → 6-digit) for GTK CSS compatibility
    val=$(echo "${val:-$fallback}" | sed 's/^\(#[0-9a-fA-F]\{6\}\)[0-9a-fA-F]\{2\}$/\1/')
    echo "$val"
}

BG=$(get_color "background" "#1e1e2e")
BGA=$(get_color "background-alt" "#313244")
FG=$(get_color "foreground" "#cdd6f4")
SEL=$(get_color "primary" "#89b4fa")

# Calcular anchos basados en escala (forzar punto decimal para Python)
CLEAN_SCALE=$(echo "${ROFI_SCALE:-1.25}" | tr ',' '.')
W_MAIN=$(python3 -c "print(int(450 * $CLEAN_SCALE))")
W_SUB=$(python3 -c "print(int(400 * $CLEAN_SCALE))")
W_WIDE=$(python3 -c "print(int(750 * $CLEAN_SCALE))")

# Exportar para uso en los scripts
export W_MAIN W_SUB W_WIDE SEL BG BGA FG
export ROFI_THEME_MAIN="window { width: ${W_MAIN}px; border: ${ROFI_BORDER:-2}px solid; border-radius: ${ROFI_RADIUS:-16}px; border-color: $SEL; background-color: $BG; } mainbox { children: [ inputbar, listview ]; padding: 20px; } inputbar { margin: 0px 0px 15px 0px; padding: 10px; background-color: $BGA; border-radius: 12px; children: [ prompt ]; } prompt { text-color: $SEL; font: \"JetBrainsMono Nerd Font Mono Bold ${ROFI_FONT_SIZE:-12}\"; } listview { columns: 1; lines: 9; spacing: 8px; dynamic: true; } element { padding: 12px 15px; border-radius: 12px; text-color: $FG; } element selected { background-color: $SEL; text-color: $BG; } element-text { vertical-align: 0.5; font: \"JetBrainsMono Nerd Font Mono ${ROFI_FONT_SIZE:-12}\"; }"

export ROFI_THEME_SUB="window { width: ${W_SUB}px; border: ${ROFI_BORDER:-2}px solid; border-radius: ${ROFI_RADIUS:-16}px; border-color: $SEL; background-color: $BG; } mainbox { children: [ listview ]; padding: 15px; } listview { columns: 1; lines: 8; spacing: 5px; dynamic: true; } element { padding: 10px 12px; border-radius: 10px; text-color: $FG; } element selected { background-color: $SEL; text-color: $BG; } element-text { vertical-align: 0.5; font: \"JetBrainsMono Nerd Font Mono ${ROFI_FONT_SIZE_SUB:-10}\"; }"
