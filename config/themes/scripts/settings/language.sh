#!/bin/bash
# 🌍  Language selector for oxido-i3-themes
DIR=$(dirname "$0")
REPO_DIR="/home/oxido/Documentos/oxido-i3-themes"

# Cargar builder de Rofi (colores, escalas e idioma actual)
source "$REPO_DIR/config/themes/scripts/rofi-builder.sh"

# Opciones
opt_es="🇪S  Español"
opt_en="🇺S  English"

[ "$LANG" = "es" ] && opt_es="$opt_es  $L_BAT_ACTIVE"
[ "$LANG" = "en" ] && opt_en="$opt_en  $L_BAT_ACTIVE"

choice=$(echo -e "$opt_es\n$opt_en\n$L_BACK" | rofi -dmenu -p "$L_LANG" -theme-str "$ROFI_THEME_SUB" -i)

case "$choice" in
    *Español*) 
        echo 'LANG="es"' > "$REPO_DIR/config/themes/lang/active_lang.env"
        dunstify -u low "🌍  Idioma" "Cambiado a Español"
        ;;
    *English*) 
        echo 'LANG="en"' > "$REPO_DIR/config/themes/lang/active_lang.env"
        dunstify -u low "🌍  Language" "Switched to English"
        ;;
    *"$L_BACK"*) 
        exec "$REPO_DIR/config/themes/bin/rofi-settings.sh"
        ;;
esac

# Volver al menú principal para ver los cambios
exec "$REPO_DIR/config/themes/bin/rofi-settings.sh"
