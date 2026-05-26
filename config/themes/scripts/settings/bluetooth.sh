#!/bin/bash
# 🔵  Bluetooth manager (requires bluetoothctl)
if ! command -v bluetoothctl &>/dev/null; then
    dunstify -u critical "🔵  $L_BT" "bluetoothctl no instalado"
    exit 1
fi

BACK_TO="${1:-$HOME/.config/themes/bin/rofi-settings.sh}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$SCRIPT_DIR/../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../scripts/rofi-builder.sh"
[ -f "$SCRIPT_DIR/../../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../../scripts/rofi-builder.sh"

BT_ON=$(bluetoothctl show 2>/dev/null | grep "Powered" | awk '{print $2}')

if [ "$BT_ON" = "yes" ]; then
    choice=$(printf "📴  Apagar Bluetooth\n🔍  Escanear dispositivos\n📋  Dispositivos emparejados\n$L_BACK" | rofi -dmenu -p "  🔵  $L_BT: ON" -theme-str "$ROFI_THEME_SUB" -i)
    [ -z "$choice" ] && exec "$BACK_TO"
    [[ "$choice" == *"$L_BACK"* ]] && exec "$BACK_TO"

    case "$choice" in
        *Apagar*) bluetoothctl power off && dunstify -u low "🔵  $L_BT" "Apagado" ;;
        *Escanear*)
            dunstify -u low "🔵  $L_BT" "Escaneando..." &
            devices=$(bluetoothctl --timeout 10 scan on 2>/dev/null | grep "Device" | head -20)
            sel=$(echo "$devices" | rofi -dmenu -p "  🔵  Dispositivos" -theme-str "$ROFI_THEME_SUB" -i)
            [ -n "$sel" ] && mac=$(echo "$sel" | awk '{print $2}') && \
                bluetoothctl pair "$mac" 2>/dev/null && \
                bluetoothctl trust "$mac" 2>/dev/null && \
                bluetoothctl connect "$mac" 2>/dev/null && \
                dunstify -u low "🔵  $L_BT" "Conectado a $(echo "$sel" | cut -d' ' -f3-)" ;;
        *emparejados*)
            paired=$(bluetoothctl devices 2>/dev/null)
            sel=$(echo "$paired" | rofi -dmenu -p "  🔵  Emparejados" -theme-str "$ROFI_THEME_SUB" -i)
            [ -n "$sel" ] && mac=$(echo "$sel" | awk '{print $2}') && \
                bluetoothctl connect "$mac" 2>/dev/null && \
                dunstify -u low "🔵  $L_BT" "Conectado a $(echo "$sel" | cut -d' ' -f3-)" ;;
    esac
else
    choice=$(printf "🟢  Encender Bluetooth\n$L_BACK" | rofi -dmenu -p "  🔵  $L_BT: OFF" -theme-str "$ROFI_THEME_SUB" -i)
    [ -z "$choice" ] && exec "$BACK_TO"
    [[ "$choice" == *"$L_BACK"* ]] && exec "$BACK_TO"
    [[ "$choice" == *"Encender"* ]] && bluetoothctl power on && dunstify -u low "🔵  $L_BT" "Encendido"
fi
exec "$BACK_TO"