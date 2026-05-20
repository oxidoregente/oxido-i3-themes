#!/bin/bash
# 🔵  Bluetooth manager (requires bluetoothctl)
if ! command -v bluetoothctl &>/dev/null; then
    dunstify -u critical "🔵  Bluetooth" "bluetoothctl no instalado"
    exit 1
fi

DIR=~/.config/themes/scripts/settings
BASE_THEME=$(cat "$DIR/.rasi-base" 2>/dev/null || echo '* { font: "FiraCode Nerd Font 10"; }
window { width: 420; border-radius: 16px; background-color: #1e1e2e; }
mainbox { children: [listview]; spacing: 4px; padding: 8px; }
listview { spacing: 4px; dynamic: true; }
element { border-radius: 10px; padding: 10px 14px; background-color: #313244; text-color: #cdd6f4; }
element selected { background-color: #89b4fa; text-color: #1e1e2e; }
element-icon { size: 1.2em; }
element-text { horizontal-align: 0.5; }')

BT_ON=$(bluetoothctl show 2>/dev/null | grep "Powered" | awk '{print $2}')

if [ "$BT_ON" = "yes" ]; then
    choice=$(printf "📴  Apagar Bluetooth\n🔍  Escanear dispositivos\n📋  Dispositivos emparejados\n⬅️  Volver" | rofi -dmenu -p "  🔵  Bluetooth: ON" -theme-str "$BASE_THEME" -i)
    case "$choice" in
        *Apagar*) bluetoothctl power off && dunstify -u low "🔵  Bluetooth" "Apagado" ;;
        *Escanear*)
            dunstify -u low "🔵  Bluetooth" "Escaneando..." &
            devices=$(bluetoothctl --timeout 10 scan on 2>/dev/null | grep "Device" | head -20)
            sel=$(echo "$devices" | rofi -dmenu -p "  🔵  Dispositivos" \
                -theme-str 'window { width: 500; border-radius: 16px; background-color: #1e1e2e; }
                mainbox { children: [listview]; spacing: 4px; padding: 8px; }
                listview { spacing: 2px; dynamic: true; }
                element { border-radius: 6px; padding: 6px 10px; background-color: #313244; text-color: #cdd6f4; font: "FiraCode Nerd Font 9"; }
                element selected { background-color: #89b4fa; text-color: #1e1e2e; }' -i)
            [ -n "$sel" ] && mac=$(echo "$sel" | awk '{print $2}') && \
                bluetoothctl pair "$mac" 2>/dev/null && \
                bluetoothctl trust "$mac" 2>/dev/null && \
                bluetoothctl connect "$mac" 2>/dev/null && \
                dunstify -u low "🔵  Bluetooth" "Conectado a $(echo "$sel" | cut -d' ' -f3-)" ;;
        *emparejados*)
            paired=$(bluetoothctl devices 2>/dev/null)
            sel=$(echo "$paired" | rofi -dmenu -p "  🔵  Emparejados" \
                -theme-str 'window { width: 500; border-radius: 16px; background-color: #1e1e2e; }
                mainbox { children: [listview]; spacing: 4px; padding: 8px; }
                listview { spacing: 2px; dynamic: true; }
                element { border-radius: 6px; padding: 6px 10px; background-color: #313244; text-color: #cdd6f4; font: "FiraCode Nerd Font 9"; }
                element selected { background-color: #89b4fa; text-color: #1e1e2e; }' -i)
            [ -n "$sel" ] && mac=$(echo "$sel" | awk '{print $2}') && \
                bluetoothctl connect "$mac" 2>/dev/null && \
                dunstify -u low "🔵  Bluetooth" "Conectado a $(echo "$sel" | cut -d' ' -f3-)" ;;
        *"Volver"*) exec ~/.config/themes/bin/rofi-settings.sh ;;
        *) exit 0 ;;
    esac
else
    choice=$(printf "🟢  Encender Bluetooth\n⬅️  Volver" | rofi -dmenu -p "  🔵  Bluetooth: OFF" -theme-str "$BASE_THEME" -i)
    [[ "$choice" == *"Volver"* ]] && exec ~/.config/themes/bin/rofi-settings.sh
    [[ "$choice" == *"Encender"* ]] && bluetoothctl power on && dunstify -u low "🔵  Bluetooth" "Encendido"
fi
