#!/bin/bash
# ⚡  Power settings: PowerSaver, DPMS, autolock, lid
REPO_DIR="/home/oxido/Documentos/oxido-i3-themes"
source "$REPO_DIR/config/themes/scripts/rofi-builder.sh"

DIR="$REPO_DIR/config/themes/scripts/settings"

PW_SAVER=/tmp/powersaver_active
CURRENT_LID=$(grep "^HandleLidSwitch" /etc/systemd/logind.conf.d/lid-override.conf 2>/dev/null | cut -d= -f2)
[ -z "$CURRENT_LID" ] && CURRENT_LID=$(grep "^HandleLidSwitch=" /etc/systemd/logind.conf 2>/dev/null | cut -d= -f2)
[ -z "$CURRENT_LID" ] && CURRENT_LID="suspend"

ps_status() {
    if [ -f "$PW_SAVER" ]; then echo "$L_BAT_ACTIVE"; else echo "OFF"; fi
}

while true; do
    choice=$(cat <<EOF | rofi -dmenu -p "$L_POWER" -theme-str "$ROFI_THEME_MAIN" -i
$L_PS: $(ps_status)
💤  DPMS: 5 min ▸
$L_AUTOLOCK: 8 min ▸
󰤁  $L_LID: ${CURRENT_LID} ▸
$L_BACK
EOF
    )
    case "$choice" in
        *"$L_PS"*)
            ~/.config/themes/scripts/toggle-powersaver.sh ;;
        *"DPMS"*)
            exec "$DIR/dpms.sh" ;;
        *"$L_AUTOLOCK"*)
            exec "$DIR/autolock.sh" ;;
        *"$L_LID"*)
            exec "$DIR/lid.sh" ;;
        *"$L_BACK"*)
            exec "$REPO_DIR/config/themes/bin/rofi-settings.sh" ;;
        *) exit 0 ;;
    esac
done
