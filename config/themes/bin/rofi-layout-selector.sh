#!/bin/bash
# rofi-layout-selector.sh — Selecciona layout de Polybar vía rofi
# oxido-i3-themes — $mod+Shift+l

LAYOUTS_DIR="$HOME/.config/polybar/layouts"
REPO_LAYOUTS="$HOME/Documentos/oxido-i3-themes/config/polybar/layouts"
CURRENT_LAYOUT_FILE="$HOME/.config/themes/current-layout"
CURRENT=$(cat "$CURRENT_LAYOUT_FILE" 2>/dev/null || echo "bubble")

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -f "$SCRIPT_DIR/../scripts/rofi-builder.sh" ]; then
    source "$SCRIPT_DIR/../scripts/rofi-builder.sh"
fi

[ -z "$ROFI_THEME_SUB" ] && ROFI_THEME_SUB='window { width: 380px; border-radius: 16px; background-color: #1e1e2e; }
mainbox { children: [ listview ]; spacing: 4px; padding: 8px; }
listview { spacing: 4px; dynamic: true; }
element { border-radius: 10px; padding: 10px 14px; background-color: #313244; text-color: #cdd6f4; }
element selected { background-color: #89b4fa; text-color: #1e1e2e; }'

items=""
for f in "$LAYOUTS_DIR"/*.ini; do
    name=$(basename "$f" .ini)
    [ "$name" = "$CURRENT" ] && items+="▶ $name (actual)\n" || items+="$name\n"
done

# Si no hay layouts locales, leer del repo
if [ -z "$items" ]; then
    for f in "$REPO_LAYOUTS"/*.ini; do
        [ ! -f "$f" ] && continue
        name=$(basename "$f" .ini)
        [ "$name" = "$CURRENT" ] && items+="▶ $name (actual)\n" || items+="$name\n"
    done
fi

[ -z "$items" ] && { rofi -e "No se encontraron layouts en $LAYOUTS_DIR"; exit 1; }

chosen=$(echo -e "$items" | rofi -dmenu -p "Layout" -i -theme-str "$ROFI_THEME_SUB" 2>/dev/null)
[ -z "$chosen" ] && exit 0

# Extraer nombre (sacar ▶ y (actual))
name=$(echo "$chosen" | sed 's/^▶ //; s/ (actual)//')

if [ "$name" != "$CURRENT" ]; then
    echo "$name" > "$CURRENT_LAYOUT_FILE"
    ~/.config/themes/applyers/apply-polybar.sh "$(readlink ~/.config/themes/current/theme)" &>/dev/null & disown
fi
