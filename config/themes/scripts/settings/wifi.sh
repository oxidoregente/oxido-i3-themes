#!/bin/bash
# 🌐  WiFi network manager (requires nmcli)
if ! command -v nmcli &>/dev/null; then
    dunstify -u critical "🌐  WiFi" "nmcli no instalado"
    exit 1
fi

BACK_TO="${1:-$HOME/.config/themes/bin/rofi-settings.sh}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$SCRIPT_DIR/../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../scripts/rofi-builder.sh"
[ -f "$SCRIPT_DIR/../../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../../scripts/rofi-builder.sh"

nmcli radio wifi on 2>/dev/null

choice=$(printf "🔍  Escanear redes\n📶  Conectarse a red guardada\n📡  Mostrar conexión actual\n📴  Apagar WiFi\n$L_BACK" | rofi -dmenu -p "  $L_WIFI" -theme-str "$ROFI_THEME_SUB" -i)

[ -z "$choice" ] && exec "$BACK_TO"
[[ "$choice" == *"$L_BACK"* ]] && exec "$BACK_TO"

case "$choice" in
    *Escanear*)
        networks=$(nmcli -f SSID,SECURITY,SIGNAL,BARS device wifi list 2>/dev/null | tail -n +2)
        sel=$(echo "$networks" | rofi -dmenu -p "  📶  Redes disponibles" -theme-str "$ROFI_THEME_SUB" -i)
        [ -z "$sel" ] && exec "$BACK_TO"
        ssid=$(echo "$sel" | awk '{
            for(i=NF; i>=1; i--)
                if($i ~ /^[0-9]+$/) { sig=i; break }
            if(!sig) { print $1; exit }
            for(j=1; j<sig-1; j++) printf "%s%s", (j>1?" ":""), $j
            print ""
        }')
        nmcli device wifi connect "$ssid" 2>/dev/null && \
            dunstify -u low "📶  $L_WIFI" "Conectado a: $ssid" || \
            dunstify -u critical "📶  $L_WIFI" "Error al conectar a: $ssid (¿requiere contraseña?)"
        ;;
    *guardada*)
        saved=$(nmcli -t -f NAME connection show 2>/dev/null | grep -v "^$" | sort -u)
        sel=$(echo "$saved" | rofi -dmenu -p "  📶  Redes guardadas" -theme-str "$ROFI_THEME_SUB" -i)
        [ -n "$sel" ] && nmcli connection up "$sel" 2>/dev/null && \
            dunstify -u low "📶  $L_WIFI" "Conectado a: $sel"
        ;;
    *conexión*)
        info=$(nmcli -t -f GENERAL.DEVICE,GENERAL.STATE,GENERAL.CONNECTION device show 2>/dev/null | grep -A3 "GENERAL.STATE:100" | head -1)
        dunstify -u low "📡  $L_WIFI" "${info:-No conectado}"
        ;;
    *Apagar*)
        nmcli radio wifi off
        dunstify -u low "📴  $L_WIFI" "Desactivado" ;;
esac
exec "$BACK_TO"