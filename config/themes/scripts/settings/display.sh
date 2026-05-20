#!/bin/bash
# ☀️  Display settings: brightness + wallpaper
DIR=~/.config/themes/scripts/settings
BASE_THEME=$(cat "$DIR/.rasi-base" 2>/dev/null || echo '* { font: "FiraCode Nerd Font 10"; }
window { width: 420; border-radius: 16px; background-color: #1e1e2e; }
mainbox { children: [listview]; spacing: 4px; padding: 8px; }
listview { spacing: 4px; dynamic: true; }
element { border-radius: 10px; padding: 10px 14px; background-color: #313244; text-color: #cdd6f4; }
element selected { background-color: #89b4fa; text-color: #1e1e2e; }
element-icon { size: 1.2em; }
element-text { horizontal-align: 0.5; }')

bright() { brightnessctl -m | cut -d',' -f4 | tr -d '%'; }
THEME_DIR=$(readlink -f ~/.config/themes/current/theme 2>/dev/null)
WALL_DIR="${THEME_DIR:-$HOME/.config/themes/themes/dracula}/backgrounds"

while true; do
    b=$(bright)
    choice=$(cat <<EOF | rofi -dmenu -p "  ☀️  Pantalla" -theme-str "$BASE_THEME" -i
☀️  Subir brillo +5%  |  ${b}%
🌙  Bajar brillo -5%  |  ${b}%
🖼️  Cambiar wallpaper ▸
💡  Apagar pantalla (DPMS)
⬅️  Volver
EOF
    )
    case "$choice" in
        *"Subir brillo"*)
            ~/.config/i3/brightness.sh "+5%" ;;
        *"Bajar brillo"*)
            ~/.config/i3/brightness.sh "5%-" ;;
        *"wallpaper"*)
            exec "$DIR/wallpaper.sh" ;;
        *"Apagar"*)
            xset dpms force off
            dunstify -u low "💡  Pantalla" "Apagada por DPMS"
            exit 0 ;;
        *"Volver"*) exec ~/.config/themes/bin/rofi-settings.sh ;;
        *) exit 0 ;;
    esac
done
