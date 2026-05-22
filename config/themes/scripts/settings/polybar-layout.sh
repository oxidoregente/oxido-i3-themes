#!/bin/bash
# 📐  Polybar Layout Selector — cambia el diseño independientemente del tema
DIR=~/.config/themes/scripts/settings
BASE_THEME=$(cat "$DIR/.rasi-base" 2>/dev/null || echo '* { font: "FiraCode Nerd Font 10"; }
window { width: 420; border-radius: 16px; background-color: #1e1e2e; }
mainbox { children: [listview]; spacing: 4px; padding: 8px; }
listview { spacing: 4px; dynamic: true; }
element { border-radius: 10px; padding: 10px 14px; background-color: #313244; text-color: #cdd6f4; }
element selected { background-color: #89b4fa; text-color: #1e1e2e; }
element-icon { size: 1.2em; }
element-text { horizontal-align: 0.5; }')

LAYOUTS_DIR="$HOME/.config/polybar/layouts"
CURRENT_FILE="$HOME/.config/themes/current-layout"
mkdir -p "$LAYOUTS_DIR"

# Sync layouts from repo if missing
REPO_LAYOUTS="/home/oxido/Documentos/oxido-i3-themes/config/polybar/layouts"
if [ -d "$REPO_LAYOUTS" ]; then
    cp -n "$REPO_LAYOUTS"/*.ini "$LAYOUTS_DIR/" 2>/dev/null
fi

CURRENT=""
[ -f "$CURRENT_FILE" ] && CURRENT=$(cat "$CURRENT_FILE")

POSITION_FILE="$HOME/.config/themes/polybar-position"
[ -f "$POSITION_FILE" ] && POSITION=$(cat "$POSITION_FILE") || POSITION="top"

apply_layout() {
    local name="$1"
    local label="$2"
    echo "$name" > "$CURRENT_FILE"
    CURRENT="$name"
    dunstify -u low "📐  Layout Polybar" "$label"
    THEME_LINK="$HOME/.config/themes/current/theme"
    if [ -L "$THEME_LINK" ]; then
        TDIR=$(readlink -f "$THEME_LINK")
        bash "$HOME/.config/themes/applyers/apply-polybar.sh" "$TDIR"
    fi
}

while true; do
    choice=$(cat <<EOF | rofi -dmenu -p "  📐  Diseño Polybar" -theme-str "$BASE_THEME" -i
◉  bubble$([ "$CURRENT" = "bubble" ] && echo "  ✓")
○  minimal$([ "$CURRENT" = "minimal" ] && echo "  ✓")
○  blocks$([ "$CURRENT" = "blocks" ] && echo "  ✓")
○  floating$([ "$CURRENT" = "floating" ] && echo "  ✓")
○  powerline$([ "$CURRENT" = "powerline" ] && echo "  ✓")
○  default$([ "$CURRENT" = "default" ] && echo "  ✓")
○  sharp$([ "$CURRENT" = "sharp" ] && echo "  ✓")
○  colorblocks$([ "$CURRENT" = "colorblocks" ] && echo "  ✓")
○  material$([ "$CURRENT" = "material" ] && echo "  ✓")
○  rounded$([ "$CURRENT" = "rounded" ] && echo "  ✓")
○  panel$([ "$CURRENT" = "panel" ] && echo "  ✓")
○  dual$([ "$CURRENT" = "dual" ] && echo "  ✓")
○  hack$([ "$CURRENT" = "hack" ] && echo "  ✓")
○  docky$([ "$CURRENT" = "docky" ] && echo "  ✓")
○  cynthia$([ "$CURRENT" = "cynthia" ] && echo "  ✓")
───
📍  Posición: $POSITION$([ "$POSITION" = "top" ] && echo "  " || echo "  ")
⬅️  Volver
EOF
    )
    
    choice=$(echo "$choice" | sed 's/  ✓//')
    
    case "$choice" in
        *"bubble"*) apply_layout "bubble" "Burbujas (clásico)" ;;
        *"minimal"*) apply_layout "minimal" "Minimal" ;;
        *"blocks"*) apply_layout "blocks" "Bloques" ;;
        *"floating"*) apply_layout "floating" "Flotante" ;;
        *"powerline"*) apply_layout "powerline" "Powerline" ;;
        *"default"*) apply_layout "default" "Plano (por defecto)" ;;
        *"sharp"*) apply_layout "sharp" "Pestañas sharp" ;;
        *"colorblocks"*) apply_layout "colorblocks" "Bloques de color" ;;
        *"material"*) apply_layout "material" "Material You" ;;
        *"rounded"*) apply_layout "rounded" "Ultra-redondeado" ;;
        *"panel"*) apply_layout "panel" "Panel (Win11/GNOME)" ;;
        *"dual"*) apply_layout "dual" "Dividido (Dual)" ;;
        *"hack"*) apply_layout "hack" "Hack (terminal aesthetic)" ;;
        *"docky"*) apply_layout "docky" "Docky (macOS-style dock)" ;;
        *"cynthia"*) apply_layout "cynthia" "Cynthia (two-tone modern)" ;;
        *"Posición"*) bash "$DIR/toggle-position.sh"; exec "$0" ;;
        *"Volver"*) exec ~/.config/themes/bin/rofi-settings.sh ;;
        *) exit 0 ;;
    esac
done
