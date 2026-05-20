#!/bin/bash
# 🔔  Notification settings: DND, position, clear, history
DIR=~/.config/themes/scripts/settings
BASE_THEME=$(cat "$DIR/.rasi-base" 2>/dev/null || echo '* { font: "FiraCode Nerd Font 10"; }
window { width: 400; border-radius: 16px; background-color: #1e1e2e; }
mainbox { children: [listview]; spacing: 4px; padding: 8px; }
listview { spacing: 4px; dynamic: true; }
element { border-radius: 10px; padding: 10px 14px; background-color: #313244; text-color: #cdd6f4; }
element selected { background-color: #89b4fa; text-color: #1e1e2e; }
element-icon { size: 1.2em; }
element-text { horizontal-align: 0.5; }')

DND_FILE=~/.cache/dunst-dnd

dnd_status() {
    if [ -f "$DND_FILE" ]; then echo "  No Molestar:  ACTIVO  |  Click para desactivar"
    else echo "  No Molestar:  INACTIVO  |  Click para activar"; fi
}

while true; do
    choice=$(cat <<EOF | rofi -dmenu -p "  🔔  Notificaciones" -theme-str "$BASE_THEME" -i
$(dnd_status)
󰆴  Limpiar notificaciones
󰋗  Historial de notificaciones
⬅️  Volver
EOF
    )
    case "$choice" in
        *"No Molestar"*)
            ~/.config/themes/scripts/toggle-dnd.sh
            ;;
        *"Limpiar"*)
            dunstctl close-all
            dunstify -u low "󰆴  Notificaciones" "Todas las notis fueron cerradas"
            ;;
        *"Historial"*)
            dunstctl history-pop
            ;;
        *"Volver"*) exec ~/.config/themes/bin/rofi-settings.sh ;;
        *) exit 0 ;;
    esac
done
