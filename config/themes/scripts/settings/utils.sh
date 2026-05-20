#!/bin/bash
# 📋  Utilities: screenshots, WiFi, Bluetooth, color picker, clipboard
DIR=~/.config/themes/scripts/settings
BASE_THEME=$(cat "$DIR/.rasi-base" 2>/dev/null || echo '* { font: "FiraCode Nerd Font 10"; }
window { width: 420; border-radius: 16px; background-color: #1e1e2e; }
mainbox { children: [listview]; spacing: 4px; padding: 8px; }
listview { spacing: 4px; dynamic: true; }
element { border-radius: 10px; padding: 10px 14px; background-color: #313244; text-color: #cdd6f4; }
element selected { background-color: #89b4fa; text-color: #1e1e2e; }
element-icon { size: 1.2em; }
element-text { horizontal-align: 0.5; }')

while true; do
    choice=$(cat <<EOF | rofi -dmenu -p "  📋  Utilidades" -theme-str "$BASE_THEME" -i
📸  Captura de pantalla ▸
🌐  Red WiFi ▸
🔵  Bluetooth ▸
🎨  Color picker
📋  Portapapeles ▸
⬅️  Volver
EOF
    )
    case "$choice" in
        *"Captura"*) exec "$DIR/screenshot.sh" ;;
        *"WiFi"*) exec "$DIR/wifi.sh" ;;
        *"Bluetooth"*) exec "$DIR/bluetooth.sh" ;;
        *"Color"*) exec "$DIR/colorpicker.sh" ;;
        *"Portapapeles"*) exec "$DIR/clipboard.sh" ;;
        *"Volver"*) exec ~/.config/themes/bin/rofi-settings.sh ;;
        *) exit 0 ;;
    esac
done
