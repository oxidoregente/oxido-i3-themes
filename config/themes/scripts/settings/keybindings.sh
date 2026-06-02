#!/bin/bash
# ⌨️  Keybinding viewer — mejorado y multilenguaje
# oxido-i3-themes

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$SCRIPT_DIR/../rofi-builder.sh" ] && source "$SCRIPT_DIR/../rofi-builder.sh"
[ -f "$SCRIPT_DIR/../../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../../scripts/rofi-builder.sh"

CONFIG=~/.config/i3/config

# Traducciones rápidas para comandos comunes
translate_cmd() {
    local cmd="$1"
    case "$cmd" in
        *launch-terminal*) echo "Terminal" ;;
        *launch-browser*) echo "Navegador" ;;
        *rofi-settings*) echo "Centro de Control" ;;
        *rofi-drun*) echo "Lanzador de Apps" ;;
        *rofi-layout-selector*) echo "Layout de Polybar" ;;
        *rofi-theme-selector*) echo "Selector de Temas" ;;
        *rofi-powermenu*) echo "Menú de Apagado" ;;
        *toggle-conky*) echo "Toggle Conky" ;;
        *toggle-powersaver*) echo "Modo Ahorro" ;;
        *toggle-dnd*) echo "Modo No Molestar" ;;
        *notify-time*) echo "Notificar Hora" ;;
        *notify-battery*) echo "Notificar Batería" ;;
        *notify-weather*) echo "Notificar Clima" ;;
        *volume.sh*) echo "Control de Volumen" ;;
        *brightness.sh*) echo "Control de Brillo" ;;
        *flameshot*) echo "Captura de pantalla" ;;
        *kill*) echo "Cerrar ventana" ;;
        *i3-msg\ restart*) echo "Reiniciar i3" ;;
        *i3-msg\ exit*) echo "Salir de la sesión" ;;
        *) echo "$cmd" ;;
    esac
}

# Parsear bindings y limpiar nombres
entries=$(grep "^\s*bindsym\|^\s*bindcode" "$CONFIG" 2>/dev/null | grep -v "^\s*#" | \
    while read -r line; do
        # Extraer teclas y comando
        keys=$(echo "$line" | sed 's/bindsym //;s/bindcode //;s/--no-startup-id //;s/--release //;s/exec //g' | awk '{print $1}')
        cmd=$(echo "$line" | sed 's/bindsym //;s/bindcode //;s/--no-startup-id //;s/--release //;s/exec //g' | cut -d' ' -f2-)
        
        # Limpiar $mod
        keys_clean=$(echo "$keys" | sed 's/\$mod/Super/g; s/Shift/Mayús/g; s/Control/Ctrl/g')
        
        # Traducir comando
        desc=$(translate_cmd "$cmd")
        
        # Formatear línea: "TECLAS  ->  DESCRIPCIÓN"
        printf "%-25s  ➜  %s\n" "$keys_clean" "$desc"
    done | sort)

[ -z "$entries" ] && {
    dunstify -u critical "⌨️  $L_UTILS" "No shortcuts found"
    exit 1
}

# Usar el builder de rofi si está disponible para colores consistentes
sel=$(echo "$entries" | rofi -dmenu -p "  ⌨️  Atajos" -i \
    -theme-str "window { width: 850px; border-radius: ${ROFI_RADIUS:-16}px; border: ${ROFI_BORDER:-2}px solid; border-color: $SEL; background-color: $BG; }
    mainbox { children: [inputbar, listview]; spacing: 10px; padding: 15px; }
    inputbar { background-color: $BGA; border-radius: 12px; padding: 10px 15px; text-color: $FG; children: [prompt, entry]; }
    prompt { text-color: $SEL; }
    listview { columns: 1; lines: 15; spacing: 4px; dynamic: true; fixed-height: false; }
    element { border-radius: 8px; padding: 8px 12px; background-color: transparent; text-color: $FG; }
    element selected { background-color: $SEL; text-color: $BG; }
    element-text { font: \"JetBrainsMono Nerd Font Mono ${ROFI_FONT_SIZE_SUB:-10}\"; }")

[ -n "$sel" ] && {
    key=$(echo "$sel" | cut -d'➜' -f1 | xargs)
    desc=$(echo "$sel" | cut -d'➜' -f2 | xargs)
    dunstify -u low "⌨️  $desc" "$key"
}
