#!/bin/bash
# ☀️  Display settings: brightness + wallpaper
REPO_DIR="/home/oxido/Documentos/oxido-i3-themes"
source "$REPO_DIR/config/themes/scripts/rofi-builder.sh"

DIR="$REPO_DIR/config/themes/scripts/settings"

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
            exit 0 ;;
        *"$L_BACK"*)
            exec "$REPO_DIR/config/themes/bin/rofi-settings.sh" ;;
        *) exit 0 ;;
    esac
done
