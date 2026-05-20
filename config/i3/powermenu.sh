#!/bin/bash

options=" Apagar\n Reiniciar\n Suspender\n Bloquear\n Salir"

chosen=$(echo -e "$options" | rofi -dmenu -i -p "Sistema:" -config ~/.config/rofi/config.rasi)

case $chosen in
    "⏻ Apagar") systemctl poweroff ;;
    "⟳ Reiniciar") systemctl reboot ;;
    " Suspender") betterlockscreen -l blur && systemctl suspend ;;
    "🔒Bloquear") betterlockscreen -l blur ;;
    " Salir") i3-msg exit ;;
esac
