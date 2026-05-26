#!/bin/bash
# 🌍  Language selector for oxido-i3-themes
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR/../../../.."
THEMES_DIR="$HOME/.config/themes"

# Cargar builder de Rofi (colores, escalas e idioma actual)
source "$THEMES_DIR/scripts/rofi-builder.sh"

# Reiniciar conky con el nuevo locale
restart_conky() {
    [ -f "$HOME/.config/themes/conky-enabled" ] || return 0
    local lang
    lang=$(grep '^LANG=' "$HOME/.config/themes/lang/active_lang.env" 2>/dev/null | cut -d'"' -f2)
    lang="${lang:-es}"
    killall -q conky 2>/dev/null
    sleep 0.3
    export LC_TIME=$([ "$lang" = "en" ] && echo "en_US.utf8" || echo "es_VE.utf8")
    conky -c "$HOME/.config/conky/conky.conf" 2>/dev/null &
    disown
}

# Opciones
opt_es="🇪S  Español"
opt_en="🇺S  English"

[ "$LANG" = "es" ] && opt_es="$opt_es  $L_BAT_ACTIVE"
[ "$LANG" = "en" ] && opt_en="$opt_en  $L_BAT_ACTIVE"

choice=$(echo -e "$opt_es\n$opt_en\n$L_BACK" | rofi -dmenu -p "$L_LANG" -theme-str "$ROFI_THEME_SUB" -i)

case "$choice" in
    *Español*) 
        echo 'LANG="es"' > "$THEMES_DIR/lang/active_lang.env"
        echo 'LANG="es"' > "$REPO_DIR/config/themes/lang/active_lang.env"
        dunstify -u low "🌍  Idioma" "Cambiado a Español"
        ;;
    *English*) 
        echo 'LANG="en"' > "$THEMES_DIR/lang/active_lang.env"
        echo 'LANG="en"' > "$REPO_DIR/config/themes/lang/active_lang.env"
        dunstify -u low "🌍  Language" "Switched to English"
        ;;
    *"$L_BACK"*) 
        exec "$THEMES_DIR/bin/rofi-settings.sh"
        ;;
esac

# Reiniciar conky para que tome el nuevo LC_TIME
restart_conky

# Volver al menú principal para ver los cambios
exec "$THEMES_DIR/bin/rofi-settings.sh"
