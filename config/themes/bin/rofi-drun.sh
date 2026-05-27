#!/bin/bash
# 🚀  Rofi App Launcher — lanzador de aplicaciones con barra de búsqueda
# oxido-i3-themes — $mod+d

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$SCRIPT_DIR/../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../scripts/rofi-builder.sh"

rofi -show drun -show-icons -p "🔍  Apps" -location 0 -monitor -1 -theme-str "$ROFI_THEME_MAIN"
