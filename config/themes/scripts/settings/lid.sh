#!/bin/bash
#  ️ Lid behavior switcher
BACK_TO="${1:-$HOME/.config/themes/bin/rofi-settings.sh}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$SCRIPT_DIR/../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../scripts/rofi-builder.sh"
[ -f "$SCRIPT_DIR/../../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../../scripts/rofi-builder.sh"

CURRENT_LID=$(grep "^HandleLidSwitch" /etc/systemd/logind.conf.d/lid-override.conf 2>/dev/null | cut -d= -f2)
[ -z "$CURRENT_LID" ] && CURRENT_LID=$(grep "^HandleLidSwitch=" /etc/systemd/logind.conf 2>/dev/null | cut -d= -f2)
[ -z "$CURRENT_LID" ] && CURRENT_LID="suspend"

case "$CURRENT_LID" in
    suspend) ICON="󰤁"; LABEL="Suspender" ;;
    ignore)  ICON="󰅶"; LABEL="Ignorar (no hacer nada)" ;;
    hibernate) ICON="󰒲"; LABEL="Hibernar" ;;
    lock) ICON="󰌾"; LABEL="Solo bloquear" ;;
    *) ICON="󰤁"; LABEL="$CURRENT_LID" ;;
esac

choices=$(printf "󰤄  Suspender\n󰅶  Ignorar (no hacer nada)\n󰒲  Hibernar\n󰌾  Solo bloquear\n$L_BACK" | rofi -dmenu -p "  󰤁  Tapa: ${LABEL}" \
    -theme-str "$ROFI_THEME_SUB" -i)

[ -z "$choices" ] && exec "$BACK_TO"
[[ "$choices" == *"$L_BACK"* ]] && exec "$BACK_TO"

case "$choices" in
    *Suspender*) VAL="suspend" ;;
    *Ignorar*) VAL="ignore" ;;
    *Hibernar*) VAL="hibernate" ;;
    *bloquear*) VAL="lock" ;;
    *) exec "$BACK_TO" ;;
esac

if pkexec sh -c "
    mkdir -p /etc/systemd/logind.conf.d
    echo '[Login]
HandleLidSwitch=$VAL' > /etc/systemd/logind.conf.d/lid-override.conf
    systemctl restart systemd-logind
"; then
    dunstify -u low "󰤁  Tapa" "Al cerrar tapa: $VAL"
else
    dunstify -u critical "󰤁  Tapa" "Error: no se pudo cambiar la configuración"
fi