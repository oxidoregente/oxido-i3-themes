#!/bin/bash
# 🔧  System settings: service status, restart, system info
DIR=~/.config/themes/scripts/settings
BASE_THEME=$(cat "$DIR/.rasi-base" 2>/dev/null || echo '* { font: "FiraCode Nerd Font 10"; }
window { width: 420; border-radius: 16px; background-color: #1e1e2e; }
mainbox { children: [listview]; spacing: 4px; padding: 8px; }
listview { spacing: 4px; dynamic: true; }
element { border-radius: 10px; padding: 10px 14px; background-color: #313244; text-color: #cdd6f4; }
element selected { background-color: #89b4fa; text-color: #1e1e2e; }
element-icon { size: 1.2em; }
element-text { horizontal-align: 0.5; }')

status_icon() { pgrep -x "$1" >/dev/null 2>&1 && echo "" || echo ""; }

while true; do
    choice=$(cat <<EOF | rofi -dmenu -p "  🔧  Sistema" -theme-str "$BASE_THEME" -i
$(status_icon picom)  Picom — compositor  [reiniciar]
$(status_icon polybar)  Polybar — barra  [reiniciar]
$(status_icon dunst)  Dunst — notificaciones  [reiniciar]
$(status_icon conky)  Conky — widget escritorio  [reiniciar]
$(status_icon xss-lock)  xss-lock — bloqueo por suspensión
$(status_icon xautolock)  xautolock — bloqueo por inactividad
󰍹  Información del sistema ▸
⬅️  Volver
EOF
    )
    case "$choice" in
        *"Picom"*)
            killall -q picom 2>/dev/null
            sleep 0.3
            picom --config ~/.config/picom/picom.conf -b 2>/dev/null &
            disown
            dunstify -u low "🔧  Picom" "Reiniciado" ;;
        *"Polybar"*)
            ~/.config/polybar/launch.sh
            dunstify -u low "🔧  Polybar" "Reiniciada" ;;
        *"Dunst"*)
            killall -q dunst 2>/dev/null
            sleep 0.3
            dunst 2>/dev/null &
            disown
            dunstify -u low "🔧  Dunst" "Reiniciado" ;;
        *"Conky"*)
            killall -q conky 2>/dev/null
            [ -f ~/.config/themes/conky-enabled ] && {
                conky -c ~/.config/conky/conky.conf 2>/dev/null &
                disown
            }
            dunstify -u low "🔧  Conky" "Reiniciado" ;;
        *"Información"*)
            exec "$DIR/sysinfo.sh" ;;
        *"Volver"*) exec ~/.config/themes/bin/rofi-settings.sh ;;
        *) exit 0 ;;
    esac
done
