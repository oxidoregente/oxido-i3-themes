#!/bin/bash
# 🎨  Appearance settings: theme, conky, gaps, borders, wallpaper, lockscreen
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIR="$SCRIPT_DIR"
[ -f "$SCRIPT_DIR/../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../scripts/rofi-builder.sh"
[ -f "$SCRIPT_DIR/../../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../../scripts/rofi-builder.sh"

CURRENT_THEME=$(basename "$(readlink ~/.config/themes/current/theme)" 2>/dev/null)
CONKY_FILE=~/.config/themes/conky-enabled
GAPS_INNER=$(grep "^gaps inner" ~/.config/i3/config 2>/dev/null | awk '{print $3}')
GAPS_OUTER=$(grep "^gaps outer" ~/.config/i3/config 2>/dev/null | awk '{print $3}')
[ -z "$GAPS_INNER" ] && GAPS_INNER=6
[ -z "$GAPS_OUTER" ] && GAPS_OUTER=2

conky_status() {
    if [ -f "$CONKY_FILE" ]; then echo "󰄧  ON"; else echo "󰄧  OFF"; fi
}

current_layout() {
    local f="$HOME/.config/themes/current-layout"
    if [ -f "$f" ]; then echo "$(cat "$f")"; else echo "bubble"; fi
}

while true; do
    choice=$(cat <<EOF | rofi -dmenu -p "  $L_APPEAR" -theme-str "$ROFI_THEME_MAIN" -i
$L_CUR_THEME: ${CURRENT_THEME:-ninguno}  ▶
$L_WALLPAPER  ▸
$L_LOCKSCREEN  ▸
$L_POLY_LAYOUT: $(current_layout)  ▸
$L_CONKY_TOG: $(conky_status)
$L_GAPS_IN: ${GAPS_INNER}px  ▸
$L_GAPS_OUT: ${GAPS_OUTER}px  ▸
$L_BACK
EOF
    )
    case "$choice" in
        *"$L_CUR_THEME"*)
            exec ~/.config/themes/bin/rofi-theme-selector.sh ;;
        *"$L_WALLPAPER"*)
            exec "$DIR/wallpaper.sh" ;;
        *"$L_LOCKSCREEN"*)
            exec "$DIR/lockscreen.sh" ;;
        *"$L_POLY_LAYOUT"*)
            ~/.config/themes/bin/rofi-layout-selector.sh ;;
        *"$L_CONKY_TOG"*)
            ~/.config/themes/bin/toggle-conky.sh ;;
        *"$L_GAPS_IN"*)
            exec "$DIR/gaps.sh" inner "$DIR/appearance.sh" ;;
        *"$L_GAPS_OUT"*)
            exec "$DIR/gaps.sh" outer "$DIR/appearance.sh" ;;
        *"$L_BACK"*) exec ~/.config/themes/bin/rofi-settings.sh ;;
        *) exec ~/.config/themes/bin/rofi-settings.sh ;;
    esac
done
