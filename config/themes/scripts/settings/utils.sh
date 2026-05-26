#!/bin/bash
# 📋  Utilities: screenshots, WiFi, Bluetooth, color picker, clipboard
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIR="$SCRIPT_DIR"
[ -f "$SCRIPT_DIR/../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../scripts/rofi-builder.sh"
[ -f "$SCRIPT_DIR/../../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../../scripts/rofi-builder.sh"

while true; do
    choice=$(cat <<EOF | rofi -dmenu -p "  $L_UTILS" -theme-str "$ROFI_THEME_MAIN" -i
$L_SSHOT  ▸
$L_WIFI  ▸
$L_BT  ▸
$L_CPICKER
$L_CLIP  ▸
$L_BACK
EOF
    )
    case "$choice" in
        *"$L_SSHOT"*) exec "$DIR/screenshot.sh" "$DIR/utils.sh" ;;
        *"$L_WIFI"*) exec "$DIR/wifi.sh" "$DIR/utils.sh" ;;
        *"$L_BT"*) exec "$DIR/bluetooth.sh" "$DIR/utils.sh" ;;
        *"$L_CPICKER"*) exec "$DIR/colorpicker.sh" ;;
        *"$L_CLIP"*) exec "$DIR/clipboard.sh" "$DIR/utils.sh" ;;
        *"$L_BACK"*) exec ~/.config/themes/bin/rofi-settings.sh ;;
        *) exec ~/.config/themes/bin/rofi-settings.sh ;;
    esac
done