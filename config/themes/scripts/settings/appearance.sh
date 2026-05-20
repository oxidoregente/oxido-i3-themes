#!/bin/bash
# 🎨  Appearance settings: theme, conky, gaps, borders
DIR=~/.config/themes/scripts/settings
BASE_THEME=$(cat "$DIR/.rasi-base" 2>/dev/null || echo '* { font: "FiraCode Nerd Font 10"; }
window { width: 420; border-radius: 16px; background-color: #1e1e2e; }
mainbox { children: [listview]; spacing: 4px; padding: 8px; }
listview { spacing: 4px; dynamic: true; }
element { border-radius: 10px; padding: 10px 14px; background-color: #313244; text-color: #cdd6f4; }
element selected { background-color: #89b4fa; text-color: #1e1e2e; }
element-icon { size: 1.2em; }
element-text { horizontal-align: 0.5; }')

CURRENT_THEME=$(basename "$(readlink ~/.config/themes/current/theme)" 2>/dev/null)
CONKY_FILE=~/.config/themes/conky-enabled
GAPS_INNER=$(grep "^gaps inner" ~/.config/i3/config 2>/dev/null | awk '{print $3}')
GAPS_OUTER=$(grep "^gaps outer" ~/.config/i3/config 2>/dev/null | awk '{print $3}')
[ -z "$GAPS_INNER" ] && GAPS_INNER=6
[ -z "$GAPS_OUTER" ] && GAPS_OUTER=2

conky_status() {
    if [ -f "$CONKY_FILE" ]; then echo "  Activado"; else echo "  Desactivado"; fi
}

while true; do
    choice=$(cat <<EOF | rofi -dmenu -p "  🎨  Apariencia" -theme-str "$BASE_THEME" -i
🎨  Tema actual: ${CURRENT_THEME:-ninguno}  ▶
󰄧  Conky: $(conky_status)
▦  Gaps interiores: ${GAPS_INNER}px  ▸
▤  Gaps exteriores: ${GAPS_OUTER}px  ▸
⬅️  Volver
EOF
    )
    case "$choice" in
        *"Tema actual"*)
            exec ~/.config/themes/bin/rofi-theme-selector.sh ;;
        *"Conky"*)
            ~/.config/themes/bin/toggle-conky.sh ;;
        *"Gaps interiores"*)
            exec "$DIR/gaps.sh" inner ;;
        *"Gaps exteriores"*)
            exec "$DIR/gaps.sh" outer ;;
        *"Volver"*) exec ~/.config/themes/bin/rofi-settings.sh ;;
        *) exit 0 ;;
    esac
done
