#!/bin/bash
# ⚡  Power settings: PowerSaver, DPMS, autolock, lid
DIR=~/.config/themes/scripts/settings
BASE_THEME=$(cat "$DIR/.rasi-base" 2>/dev/null || echo '* { font: "FiraCode Nerd Font 10"; }
window { width: 440; border-radius: 16px; background-color: #1e1e2e; }
mainbox { children: [listview]; spacing: 4px; padding: 8px; }
listview { spacing: 4px; dynamic: true; }
element { border-radius: 10px; padding: 10px 14px; background-color: #313244; text-color: #cdd6f4; }
element selected { background-color: #89b4fa; text-color: #1e1e2e; }
element-icon { size: 1.2em; }
element-text { horizontal-align: 0.5; }')

PW_SAVER=/tmp/powersaver_active
CURRENT_LID=$(grep "^HandleLidSwitch" /etc/systemd/logind.conf.d/lid-override.conf 2>/dev/null | cut -d= -f2)
[ -z "$CURRENT_LID" ] && CURRENT_LID=$(grep "^HandleLidSwitch=" /etc/systemd/logind.conf 2>/dev/null | cut -d= -f2)
[ -z "$CURRENT_LID" ] && CURRENT_LID="suspend"

ps_status() {
    if [ -f "$PW_SAVER" ]; then echo "  Activado — sin picom, sin conky"; else echo "  Desactivado — modo normal"; fi
}

while true; do
    choice=$(cat <<EOF | rofi -dmenu -p "  ⚡  Energía" -theme-str "$BASE_THEME" -i
🌙  PowerSaver: $(ps_status)
💤  DPMS apagar pantalla: 5 min ▸
🔒  Bloqueo automático: 8 min ▸
󰤁  Tapa al cerrar: ${CURRENT_LID} ▸
⬅️  Volver
EOF
    )
    case "$choice" in
        *"PowerSaver"*)
            ~/.config/themes/scripts/toggle-powersaver.sh ;;
        *"DPMS"*)
            exec "$DIR/dpms.sh" ;;
        *"Bloqueo automático"*)
            exec "$DIR/autolock.sh" ;;
        *"Tapa"*)
            exec "$DIR/lid.sh" ;;
        *"Volver"*) exec ~/.config/themes/bin/rofi-settings.sh ;;
        *) exit 0 ;;
    esac
done
