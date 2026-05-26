#!/bin/bash
# 🔧  System settings: service status, restart, system info
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIR="$SCRIPT_DIR"
[ -f "$SCRIPT_DIR/../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../scripts/rofi-builder.sh"
[ -f "$SCRIPT_DIR/../../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../../scripts/rofi-builder.sh"

status_icon() { pgrep -x "$1" >/dev/null 2>&1 && echo "" || echo ""; }

while true; do
    choice=$(cat <<EOF | rofi -dmenu -p "  $L_SYSTEM" -theme-str "$ROFI_THEME_MAIN" -i
$(status_icon picom)  Picom — compositor  [$L_SERVICE]
$(status_icon polybar)  Polybar — barra  [$L_SERVICE]
$(status_icon dunst)  Dunst — notificaciones  [$L_SERVICE]
$(status_icon conky)  Conky — widget escritorio  [$L_SERVICE]
$(status_icon xss-lock)  xss-lock — bloqueo por suspensión
$(status_icon xautolock)  xautolock — bloqueo por inactividad
$L_SYSINFO ▸
$L_BACK
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
        *"$L_SYSINFO"*)
            exec "$DIR/sysinfo.sh" ;;
        *"$L_BACK"*) exec ~/.config/themes/bin/rofi-settings.sh ;;
        *) exec ~/.config/themes/bin/rofi-settings.sh ;;
    esac
done
