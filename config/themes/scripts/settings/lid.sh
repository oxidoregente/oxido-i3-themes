#!/bin/bash
#  ️ Lid behavior switcher
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

choices=$(printf "󰤄  Suspender\n󰅶  Ignorar (no hacer nada)\n󰒲  Hibernar\n󰌾  Solo bloquear\n⬅️  Volver" | rofi -dmenu -p "  󰤁  Tapa: ${LABEL}" \
    -theme-str 'window { width: 380; border-radius: 16px; background-color: #1e1e2e; }
    mainbox { children: [listview]; spacing: 4px; padding: 8px; }
    listview { spacing: 4px; dynamic: true; }
    element { border-radius: 10px; padding: 12px; background-color: #313244; text-color: #cdd6f4; }
    element selected { background-color: #89b4fa; text-color: #1e1e2e; }
    element-icon { size: 1.2em; }' -i)

case "$choices" in
    *Suspender*) VAL="suspend" ;;
    *Ignorar*) VAL="ignore" ;;
    *Hibernar*) VAL="hibernate" ;;
    *bloquear*) VAL="lock" ;;
    *"Volver"*) exec ~/.config/themes/bin/rofi-settings.sh ;;
    *) exit 0 ;;
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
