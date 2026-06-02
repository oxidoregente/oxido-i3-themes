#!/bin/bash
# ⌨️  Keybinding viewer — mejorado y multilenguaje (i18n)
# oxido-i3-themes

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source local variables for Rofi colors
[ -f "$SCRIPT_DIR/../rofi-builder.sh" ] && source "$SCRIPT_DIR/../rofi-builder.sh"
[ -f "$SCRIPT_DIR/../../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../../scripts/rofi-builder.sh"

# Source active language
[ -f "$HOME/.config/themes/lang/active_lang.env" ] && source "$HOME/.config/themes/lang/active_lang.env"
[ -z "$LANG" ] && LANG="es"
[ -f "$HOME/.config/themes/lang/${LANG}.sh" ] && source "$HOME/.config/themes/lang/${LANG}.sh"

CONFIG=~/.config/i3/config

# Traducciones dinámicas basadas en los archivos de lenguaje del sistema
translate_cmd() {
    local cmd="$1"
    case "$cmd" in
        *launch-terminal*) echo "${L_KB_TERM:-Terminal}" ;;
        *launch-browser*) echo "${L_KB_BROWSER:-Navegador}" ;;
        *rofi-settings*) echo "${L_KB_SETTINGS:-Centro de Control}" ;;
        *rofi-drun*) echo "${L_KB_LAUNCHER:-Lanzador de Apps}" ;;
        *rofi-layout-selector*) echo "${L_KB_LAYOUTS:-Diseños de Polybar}" ;;
        *rofi-theme-selector*) echo "${L_KB_THEMES:-Selector de Temas}" ;;
        *polybar-modules*) echo "${L_KB_MODULES:-Gestor de Módulos}" ;;
        *rofi-powermenu*) echo "${L_KB_POWERMENU:-Menú de Apagado}" ;;
        *toggle-conky*) echo "${L_KB_CONKY:-Toggle Conky}" ;;
        *toggle-powersaver*) echo "${L_KB_POWERSAVER:-Modo Ahorro}" ;;
        *toggle-dnd*) echo "${L_KB_DND:-Modo No Molestar}" ;;
        *notify-time*) echo "${L_KB_TIME:-Notificar Hora}" ;;
        *notify-battery*) echo "${L_KB_BATT:-Notificar Batería}" ;;
        *notify-weather*) echo "${L_KB_WEATHER:-Notificar Clima}" ;;
        *volume.sh*) echo "${L_NOT_VOL:-Volumen}" ;;
        *brightness.sh*) echo "${L_NOT_BRIGHT:-Brillo}" ;;
        *flameshot*) echo "${L_SSHOT:-Captura de pantalla}" ;;
        *kill*) echo "${L_KB_WIND_CLOSE:-Cerrar ventana}" ;;
        *i3-msg\ restart*) echo "${L_KB_RESTART_I3:-Reiniciar i3}" ;;
        *i3-msg\ exit*) echo "${L_KB_EXIT_I3:-Salir de la sesión}" ;;
        *floating\ toggle*) echo "${L_KB_FLOAT:-Ventana flotante}" ;;
        *fullscreen\ toggle*) echo "${L_KB_FULLSCREEN:-Pantalla completa}" ;;
        *keybindings.sh*) echo "${L_KB_HELP:-Ver atajos}" ;;
        *) echo "$cmd" ;;
    esac
}

# Traducir modificadores
translate_keys() {
    local keys="$1"
    if [ "$LANG" = "es" ]; then
        echo "$keys" | sed 's/\$mod/Super/g; s/Shift/Mayús/g; s/Control/Ctrl/g'
    else
        echo "$keys" | sed 's/\$mod/Super/g; s/Shift/Shift/g; s/Control/Ctrl/g'
    fi
}

# Parsear bindings
entries=$(grep -E "^\s*bindsym|^\s*bindcode" "$CONFIG" | grep -v "^\s*#" | \
    while read -r line; do
        # Limpiar la línea para extraer solo teclas y comando
        clean=$(echo "$line" | sed 's/bindsym //;s/bindcode //;s/--no-startup-id //;s/--release //;s/exec //g')
        keys=$(echo "$clean" | awk '{print $1}')
        cmd=$(echo "$clean" | cut -d' ' -f2-)
        
        [ -z "$cmd" ] && continue

        keys_clean=$(translate_keys "$keys")
        desc=$(translate_cmd "$cmd")
        
        printf "%-25s  ➜  %s\n" "$keys_clean" "$desc"
    done | sort -u)

if [ -z "$entries" ]; then
    notify-send "Atajos" "No se encontraron atajos"
    exit 1
fi

# Rofi con tema simplificado para evitar errores de parseo
sel=$(echo "$entries" | rofi -dmenu -p "  ⌨️  ${L_KB_HELP:-Atajos}" -i \
    -theme-str "window { width: 850px; border-radius: 12px; }
    listview { lines: 15; }
    element-text { font: \"JetBrainsMono Nerd Font Mono 11\"; }")

[ -n "$sel" ] && {
    desc=$(echo "$sel" | cut -d'➜' -f2 | xargs)
    key=$(echo "$sel" | cut -d'➜' -f1 | xargs)
    notify-send "⌨️  $desc" "$key"
}
