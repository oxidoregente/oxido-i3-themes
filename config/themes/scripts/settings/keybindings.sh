#!/bin/bash
# ⌨️  Keybinding viewer — shows all i3 bindings in a searchable Rofi menu
CONFIG=~/.config/i3/config

# Parse all bindsym lines from i3 config (skip comments)
entries=$(grep "^bindsym\|^bindcode" "$CONFIG" 2>/dev/null | grep -v "^#" | \
    sed 's/bindsym //;s/bindcode //;s/exec --no-startup-id //;s/exec //' | \
    awk '{$1=$1};1' | sort)

[ -z "$entries" ] && {
    dunstify -u critical "⌨️  Bindings" "No se encontraron bindings en $CONFIG"
    exit 1
}

sel=$(echo "$entries" | rofi -dmenu -p "  ⌨️  Atajos de i3" -i \
    -theme-str 'window { width: 800; border-radius: 16px; background-color: #1e1e2e; }
    mainbox { children: [inputbar, listview]; spacing: 8px; padding: 12px; }
    inputbar { background-color: transparent; border-radius: 8px; padding: 8px 12px; text-color: #cdd6f4; }
    listview { spacing: 2px; dynamic: true; lines: 18; }
    element { border-radius: 6px; padding: 6px 10px; background-color: #313244; text-color: #cdd6f4; font: "FiraCode Nerd Font 9"; }
    element selected { background-color: #89b4fa; text-color: #1e1e2e; }')

[ -n "$sel" ] && {
    binding=$(echo "$sel" | awk '{print $1}')
    dunstify -u low "⌨️  Atajo" "Seleccionado: $binding" 
}
