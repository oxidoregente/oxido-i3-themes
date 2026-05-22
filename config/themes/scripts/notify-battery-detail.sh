#!/bin/bash
BAT="/sys/class/power_supply/BAT0"
if [ ! -f "$BAT/status" ]; then
    ~/.config/themes/scripts/notify-send.sh "" "Batería" "No detectada" "critical"
    exit 0
fi
STATUS=$(< "$BAT/status")
CAP=$(< "$BAT/capacity")
PROFILE=$(powerprofilesctl get 2>/dev/null)
case "$PROFILE" in
    "performance") PROFILE_TXT="Rendimiento" ;;
    "balanced")    PROFILE_TXT="Equilibrado" ;;
    "power-saver") PROFILE_TXT="Ahorro" ;;
    *)             PROFILE_TXT="$PROFILE" ;;
esac
TIME=$(acpi -b 2>/dev/null | grep -o '[0-9][0-9]:[0-9][0-9]:[0-9][0-9]' | head -1 | sed 's/:[0-9][0-9]$//')
[ -z "$TIME" ] && TIME="--:--"
case "$STATUS" in
    "Charging") ICON=""; MSG="Cargando" ;;
    "Discharging") ICON=""; MSG="Descargando" ;;
    "Full") ICON=""; MSG="Completa" ;;
    *) ICON=""; MSG="$STATUS" ;;
esac
~/.config/themes/scripts/notify-send.sh "$ICON" "Batería: $CAP%" "${MSG} · ${TIME} restante · Plan: ${PROFILE_TXT}" "normal"
