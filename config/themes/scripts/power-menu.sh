#!/bin/bash

# Obtener el estado actual de la tapa
CURRENT_LID=$(grep "^HandleLidSwitch=" /etc/systemd/logind.conf 2>/dev/null | cut -d= -f2)
[ -z "$CURRENT_LID" ] && CURRENT_LID="suspend"

case "$CURRENT_LID" in
    suspend) LID_ICON="󰤁"; LID_LABEL="Tapa: Suspender"; LID_ALT="ignore"; LID_ALT_LABEL="Ignorar" ;;
    ignore)  LID_ICON="󰅶"; LID_LABEL="Tapa: Ignorar"; LID_ALT="suspend"; LID_ALT_LABEL="Suspender" ;;
    *)       LID_ICON="󰤁"; LID_LABEL="Tapa: $CURRENT_LID"; LID_ALT="suspend"; LID_ALT_LABEL="Suspender" ;;
esac

ENTRIES=""
add_entry() {
    [ -n "$ENTRIES" ] && ENTRIES="${ENTRIES}\n"
    ENTRIES="${ENTRIES}$1\0icon\x1f$2"
}

add_entry "󰌾  Bloquear pantalla" "system-lock-screen"
add_entry "󰤄  Suspender" "system-suspend"
add_entry "󰍃  Apagar pantalla" "video-display"
add_entry "󰒲  Hibernar" "system-suspend-hibernate"
add_entry "󰜉  Reiniciar" "system-reboot"
add_entry "󰐥  Apagar" "system-shutdown"
add_entry "${LID_ICON}  ${LID_ALT_LABEL} (al cerrar tapa)" "computer-laptop"

chosen=$(printf "%b" "$ENTRIES" | rofi -dmenu -i -p "  ⏻  Power" -show-icons \
    -theme-str "
* { font: \"FiraCode Nerd Font 11\"; }
window { width: 380; border-radius: 16px; background-color: #1e1e2e; }
mainbox { children: [listview]; spacing: 0; padding: 8px; }
listview { lines: 8; spacing: 4px; }
element { border-radius: 10px; padding: 10px; background-color: #313244; text-color: #cdd6f4; }
element selected { background-color: #89b4fa; text-color: #1e1e2e; }
element-icon { size: 1.2em; }
element-text { horizontal-align: 0.5; }
" -format s)

case "$chosen" in
    *"Bloquear pantalla")
        ~/.config/themes/bin/lock.sh ;;
    # NOTA: systemctl suspend sin lock.sh deliberadamente.
    # xss-lock (ejecutado en i3 config) captura la senal PrepareForSleep
    # de logind y ejecuta lock.sh automaticamente ANTES de suspender.
    *"Suspender")
        systemctl suspend ;;
    *"Apagar pantalla")
        xset dpms force off ;;
    *"Hibernar")
        systemctl hibernate ;;
    *"Reiniciar")
        systemctl reboot ;;
    *"Apagar")
        systemctl poweroff ;;
    *"cerrar tapa"*)
        # Cambiar comportamiento de la tapa via sudo
        dunstify -u critical "󰤁  Tapa" "Cambiando a: $LID_ALT_LABEL..."
        
        # Crear override file en /etc/systemd/logind.conf.d/
        # (sudo -A o pkexec para elevación)
        if pkexec sh -c "
            mkdir -p /etc/systemd/logind.conf.d
            echo '[Login]
HandleLidSwitch=$LID_ALT' > /etc/systemd/logind.conf.d/lid-override.conf
            systemctl restart systemd-logind
        "; then
            NEW_STATUS=$(grep "^HandleLidSwitch" /etc/systemd/logind.conf.d/lid-override.conf 2>/dev/null | cut -d= -f2)
            [ -z "$NEW_STATUS" ] && NEW_STATUS="$LID_ALT"
            ~/.config/themes/scripts/notify-send.sh "󰤁" "Tapa" "Ahora: $NEW_STATUS al cerrar la tapa" "normal"
        else
            ~/.config/themes/scripts/notify-send.sh "󰤁" "Tapa" "Error: no se pudo cambiar (permisos)" "critical"
        fi
        ;;
esac
