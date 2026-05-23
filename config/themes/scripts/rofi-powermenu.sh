#!/bin/bash
# rofi-powermenu.sh — Menú de apagado moderno en cuadrícula con etiquetas
# oxido-i3-themes

# Detectar rutas y cargar builder
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$SCRIPT_DIR/rofi-builder.sh" ] && source "$SCRIPT_DIR/rofi-builder.sh"
[ -f "$SCRIPT_DIR/../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../scripts/rofi-builder.sh"

shutdown="$L_POWER_OFF"
reboot="$L_REBOOT"
suspend="$L_SUSPEND"
lock="$L_LOCK"
logout="$L_LOGOUT"

options="$shutdown\n$reboot\n$suspend\n$lock\n$logout"

uptime_msg="$L_UPTIME"
uptime=$(uptime -p | sed 's/up //')

chosen=$(echo -e "$options" | rofi -dmenu \
    -p "SISTEMA" \
    -mesg "$uptime_msg: $uptime" \
    -theme-str "
window { 
    width: ${W_WIDE:-750}px; 
    border: ${ROFI_BORDER:-2}px solid; 
    border-radius: ${ROFI_RADIUS:-24}px; 
    border-color: $SEL; 
    background-color: $BG;
}
mainbox { 
    children: [ inputbar, message, listview ]; 
    padding: 30px; 
}
inputbar {
    enabled: true;
    margin: 0px 0px 10px 0px;
    padding: 10px;
    background-color: $BGA;
    border-radius: 12px;
    children: [ prompt ];
}
message {
    margin: 0px 0px 15px 0px;
    padding: 8px;
    background-color: transparent;
    text-color: $FG;
}
textbox {
    text-color: inherit;
    font: \"JetBrainsMono Nerd Font Mono 10\";
    horizontal-align: 0.5;
}
prompt {
    text-color: $SEL;
    font: \"JetBrainsMono Nerd Font Mono Bold ${ROFI_FONT_SIZE:-12}\";
    horizontal-align: 0.5;
}
listview { 
    columns: 5; 
    lines: 1; 
    spacing: 15px; 
    background-color: transparent; 
}
element { 
    orientation: vertical;
    padding: 25px 0px; 
    border-radius: 16px; 
    background-color: $BGA; 
    text-color: $FG; 
}
element-text { 
    font: \"JetBrainsMono Nerd Font Mono 11\"; 
    horizontal-align: 0.5; 
    vertical-align: 0.5; 
    text-color: inherit; 
}
element selected { 
    background-color: $SEL; 
    text-color: $BG; 
}
" -selected-row 2)

case $chosen in
    *$shutdown*) systemctl poweroff ;;
    *$reboot*)   systemctl reboot ;;
    *$lock*)     ~/.config/themes/bin/lock.sh ;;
    *$suspend*)  ~/.config/themes/bin/lock.sh && systemctl suspend ;;
    *$logout*)   i3-msg exit ;;
esac
