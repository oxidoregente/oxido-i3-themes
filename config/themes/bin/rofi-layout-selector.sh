#!/bin/bash
# rofi-layout-selector.sh — Selecciona layout de Polybar vía rofi
# oxido-i3-themes — $mod+Shift+l

LAYOUTS_DIR="$HOME/.config/polybar/layouts"
REPO_LAYOUTS="/home/oxido/Documentos/oxido-i3-themes/config/polybar/layouts"
CURRENT_LAYOUT_FILE="$HOME/.config/themes/current-layout"
CURRENT=$(cat "$CURRENT_LAYOUT_FILE" 2>/dev/null || echo "bubble")

[ -f "$SCRIPT_DIR/../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../scripts/rofi-builder.sh"

THEME="window { width: 380px; border-radius: 20px; border-color: $SEL; background-color: $BG; }
mainbox { children: [ inputbar, listview ]; padding: 16px; }
inputbar { margin: 0 0 10px 0; padding: 8px 12px; background-color: $BGA; border-radius: 10px; children: [ prompt ]; }
prompt { text-color: $SEL; font: \"JetBrainsMono Nerd Font Mono Bold 13\"; }
listview { columns: 1; lines: 10; spacing: 4px; dynamic: true; }
element { padding: 10px 14px; border-radius: 10px; text-color: $FG; }
element selected { background-color: $SEL; text-color: $BG; }
element-text { vertical-align: 0.5; font: \"JetBrainsMono Nerd Font Mono 11\"; }"

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

chosen=$(echo -e "$items" | rofi -dmenu -p "Layout" -i -theme-str "$THEME")
[ -z "$chosen" ] && exit 0

# Extraer nombre (sacar ▶ y (actual))
name=$(echo "$chosen" | sed 's/^▶ //; s/ (actual)//')

if [ "$name" != "$CURRENT" ]; then
    echo "$name" > "$CURRENT_LAYOUT_FILE"
    ~/.config/themes/applyers/apply-polybar.sh "$(readlink ~/.config/themes/current/theme)" &>/dev/null & disown
fi
