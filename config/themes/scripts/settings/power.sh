#!/bin/bash
# ⚡  Power settings: PowerSaver, DPMS, autolock, lid
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIR="$SCRIPT_DIR"
[ -f "$SCRIPT_DIR/../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../scripts/rofi-builder.sh"
[ -f "$SCRIPT_DIR/../../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../../scripts/rofi-builder.sh"

THEMES_BIN="$(cd "$DIR/../bin" 2>/dev/null && pwd || echo "$HOME/.config/themes/bin")"

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
$L_POWER_PROFILE: $(powerprofilesctl get 2>/dev/null || echo "—") ▸
$L_CLOCK_FMT: $(cat ~/.config/themes/date-format 2>/dev/null || echo "12h") ▸
💤  DPMS: 5 min ▸
$L_AUTOLOCK: 8 min ▸
$L_LID: ${CURRENT_LID} ▸
$L_BACK
EOF
    )
    case "$choice" in
        *"$L_PS"*)
            ~/.config/themes/scripts/toggle-powersaver.sh ;;
        *"$L_POWER_PROFILE"*)
            exec "$DIR/power-profile.sh" "$DIR/power.sh" ;;
        *"$L_CLOCK_FMT"*)
            exec "$DIR/clock-format.sh" "$DIR/power.sh" ;;
        *"DPMS"*)
            exec "$DIR/dpms.sh" "$DIR/power.sh" ;;
        *"$L_AUTOLOCK"*)
            exec "$DIR/autolock.sh" "$DIR/power.sh" ;;
        *"$L_LID"*)
            exec "$DIR/lid.sh" "$DIR/power.sh" ;;
        *"$L_BACK"*)
            exec "$THEMES_BIN/rofi-settings.sh" ;;
        *) exec ~/.config/themes/bin/rofi-settings.sh ;;
    esac
done
