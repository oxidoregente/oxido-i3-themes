#!/bin/bash
# 📐  Polybar Layout Selector — cambia el diseño independientemente del tema
DIR=~/.config/themes/scripts/settings
BASE_THEME=$(cat "$DIR/.rasi-base" 2>/dev/null || echo '* { font: "FiraCode Nerd Font 10"; }
window { width: 400; border-radius: 16px; background-color: #1e1e2e; }
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

while true; do
    current_label=""
    [ -n "$CURRENT" ] && current_label=" (actual: $CURRENT)"
    
    choice=$(cat <<EOF | rofi -dmenu -p "  📐  Diseño Polybar" -theme-str "$BASE_THEME" -i
◉  bubble$([ "$CURRENT" = "bubble" ] && echo "  ✓")
○  minimal$([ "$CURRENT" = "minimal" ] && echo "  ✓")
○  blocks$([ "$CURRENT" = "blocks" ] && echo "  ✓")
○  floating$([ "$CURRENT" = "floating" ] && echo "  ✓")
○  powerline$([ "$CURRENT" = "powerline" ] && echo "  ✓")
───
⬅️  Volver
EOF
    )
    
    choice=$(echo "$choice" | sed 's/  ✓//')
    
    case "$choice" in
        *"bubble"*)
            echo "bubble" > "$CURRENT_FILE"
            CURRENT="bubble"
            dunstify -u low "📐  Layout Polybar" "Burbujas (clásico)"
            # Re-aplicar polybar con tema actual + nuevo layout
            THEME_LINK="$HOME/.config/themes/current/theme"
            if [ -L "$THEME_LINK" ]; then
                TDIR=$(readlink -f "$THEME_LINK")
                bash "$HOME/.config/themes/applyers/apply-polybar.sh" "$TDIR"
            fi
            ;;
        *"minimal"*)
            echo "minimal" > "$CURRENT_FILE"
            CURRENT="minimal"
            dunstify -u low "📐  Layout Polybar" "Minimal"
            THEME_LINK="$HOME/.config/themes/current/theme"
            if [ -L "$THEME_LINK" ]; then
                TDIR=$(readlink -f "$THEME_LINK")
                bash "$HOME/.config/themes/applyers/apply-polybar.sh" "$TDIR"
            fi
            ;;
        *"blocks"*)
            echo "blocks" > "$CURRENT_FILE"
            CURRENT="blocks"
            dunstify -u low "📐  Layout Polybar" "Bloques"
            THEME_LINK="$HOME/.config/themes/current/theme"
            if [ -L "$THEME_LINK" ]; then
                TDIR=$(readlink -f "$THEME_LINK")
                bash "$HOME/.config/themes/applyers/apply-polybar.sh" "$TDIR"
            fi
            ;;
        *"floating"*)
            echo "floating" > "$CURRENT_FILE"
            CURRENT="floating"
            dunstify -u low "📐  Layout Polybar" "Flotante"
            THEME_LINK="$HOME/.config/themes/current/theme"
            if [ -L "$THEME_LINK" ]; then
                TDIR=$(readlink -f "$THEME_LINK")
                bash "$HOME/.config/themes/applyers/apply-polybar.sh" "$TDIR"
            fi
            ;;
        *"powerline"*)
            echo "powerline" > "$CURRENT_FILE"
            CURRENT="powerline"
            dunstify -u low "📐  Layout Polybar" "Powerline"
            THEME_LINK="$HOME/.config/themes/current/theme"
            if [ -L "$THEME_LINK" ]; then
                TDIR=$(readlink -f "$THEME_LINK")
                bash "$HOME/.config/themes/applyers/apply-polybar.sh" "$TDIR"
            fi
            ;;
        *"Volver"*)
            exec ~/.config/themes/bin/rofi-settings.sh ;;
        *) exit 0 ;;
    esac
done
