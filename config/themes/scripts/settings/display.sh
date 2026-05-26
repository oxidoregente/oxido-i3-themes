#!/bin/bash
# ☀️  Display settings: brightness + wallpaper
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIR="$SCRIPT_DIR"
[ -f "$SCRIPT_DIR/../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../scripts/rofi-builder.sh"
[ -f "$SCRIPT_DIR/../../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../../scripts/rofi-builder.sh"

THEMES_BIN="$(cd "$DIR/../bin" 2>/dev/null && pwd || echo "$HOME/.config/themes/bin")"

bright() { brightnessctl -m | cut -d',' -f4 | tr -d '%'; }

while true; do
    b=$(bright)
    choice=$(cat <<EOF | rofi -dmenu -p "$L_DISPLAY" -theme-str "$ROFI_THEME_MAIN" -i
$L_BRIGHT_UP  |  ${b}%
$L_BRIGHT_DOWN  |  ${b}%
$L_WALL  ▸
$L_DPMS
$L_BACK
EOF
    )
    case "$choice" in
        *"$L_BRIGHT_UP"*)
            ~/.config/i3/brightness.sh "+5%" ;;
        *"$L_BRIGHT_DOWN"*)
            ~/.config/i3/brightness.sh "5%-" ;;
        *"$L_WALL"*)
            exec "$DIR/wallpaper.sh" ;;
        *"$L_DPMS"*)
            xset dpms force off
            dunstify -u low "$L_DISPLAY" "$L_NOT_DND_ON"
            exec "$THEMES_BIN/rofi-settings.sh" ;;
        *"$L_BACK"*)
            exec "$THEMES_BIN/rofi-settings.sh" ;;
        *) exec "$THEMES_BIN/rofi-settings.sh" ;;
    esac
done
