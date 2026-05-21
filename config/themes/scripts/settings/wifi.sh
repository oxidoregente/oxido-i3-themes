#!/bin/bash
# 🌐  WiFi network manager (requires nmcli)
if ! command -v nmcli &>/dev/null; then
    dunstify -u critical "🌐  WiFi" "nmcli no instalado"
    exit 1
fi

DIR=~/.config/themes/scripts/settings
BASE_THEME=$(cat "$DIR/.rasi-base" 2>/dev/null || echo '* { font: "FiraCode Nerd Font 10"; }
window { width: 480; border-radius: 16px; background-color: #1e1e2e; }
mainbox { children: [listview]; spacing: 4px; padding: 8px; }
listview { spacing: 4px; dynamic: true; }
element { border-radius: 10px; padding: 10px 14px; background-color: #313244; text-color: #cdd6f4; }
element selected { background-color: #89b4fa; text-color: #1e1e2e; }
element-icon { size: 1.2em; }
element-text { horizontal-align: 0.5; }')

# ensure wifi is on
nmcli radio wifi on 2>/dev/null

choice=$(printf "🔍  Escanear redes\n📶  Conectarse a red guardada\n📡  Mostrar conexión actual\n📴  Apagar WiFi\n⬅️  Volver" | rofi -dmenu -p "  🌐  WiFi" -theme-str "$BASE_THEME" -i)

case "$choice" in
    *Escanear*)
        networks=$(nmcli -f SSID,SECURITY,SIGNAL,BARS device wifi list 2>/dev/null | tail -n +2)
        sel=$(echo "$networks" | rofi -dmenu -p "  📶  Redes disponibles" \
            -theme-str 'window { width: 600; border-radius: 16px; background-color: #1e1e2e; }
            mainbox { children: [listview]; spacing: 4px; padding: 8px; }
            listview { spacing: 2px; dynamic: true; }
            element { border-radius: 6px; padding: 6px 10px; background-color: #313244; text-color: #cdd6f4; font: "FiraCode Nerd Font 9"; }
            element selected { background-color: #89b4fa; text-color: #1e1e2e; }' -i)
        [ -z "$sel" ] && exit 0
        ssid=$(echo "$sel" | awk '{
            for(i=NF; i>=1; i--)
                if($i ~ /^[0-9]+$/) { sig=i; break }
            if(!sig) { print $1; exit }
            for(j=1; j<sig-1; j++) printf "%s%s", (j>1?" ":""), $j
            print ""
        }')
        nmcli device wifi connect "$ssid" 2>/dev/null && \
            dunstify -u low "📶  WiFi" "Conectado a: $ssid" || \
            dunstify -u critical "📶  WiFi" "Error al conectar a: $ssid (¿requiere contraseña?)"
        ;;
    *guardada*)
        saved=$(nmcli -t -f NAME connection show 2>/dev/null | grep -v "^$" | sort -u)
        sel=$(echo "$saved" | rofi -dmenu -p "  📶  Redes guardadas" \
            -theme-str 'window { width: 400; border-radius: 16px; background-color: #1e1e2e; }
            mainbox { children: [listview]; spacing: 4px; padding: 8px; }
            listview { spacing: 4px; dynamic: true; }
            element { border-radius: 10px; padding: 10px; background-color: #313244; text-color: #cdd6f4; }
            element selected { background-color: #89b4fa; text-color: #1e1e2e; }' -i)
        [ -n "$sel" ] && nmcli connection up "$sel" 2>/dev/null && \
            dunstify -u low "📶  WiFi" "Conectado a: $sel"
        ;;
    *conexión*)
        info=$(nmcli -t -f GENERAL.DEVICE,GENERAL.STATE,GENERAL.CONNECTION device show 2>/dev/null | grep -A3 "GENERAL.STATE:100" | head -1)
        dunstify -u low "📡  Conexión" "${info:-No conectado}"
        ;;
    *Apagar*)
        nmcli radio wifi off
        dunstify -u low "📴  WiFi" "Desactivado" ;;
    *"Volver"*) exec ~/.config/themes/bin/rofi-settings.sh ;;
    *) exit 0 ;;
esac
