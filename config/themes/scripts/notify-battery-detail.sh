#!/bin/bash
# Cargar idioma activo para nombres de perfil
source "$HOME/.config/themes/lang/active_lang.env" 2>/dev/null
LANG=${LANG:-es}
source "$HOME/.config/themes/lang/$LANG.sh" 2>/dev/null

BAT="/sys/class/power_supply/BAT0"
if [ ! -f "$BAT/status" ]; then
    ~/.config/themes/scripts/notify-send.sh "" "Batería" "No detectada" "critical"
    exit 0
fi
STATUS=$(< "$BAT/status")
CAP=$(< "$BAT/capacity")
PROFILE=$(powerprofilesctl get 2>/dev/null)
case "$PROFILE" in
    "performance") PROFILE_TXT="${L_BAT_PERF#*  }" ;;
    "balanced")    PROFILE_TXT="${L_BAT_BAL#*  }" ;;
    "power-saver") PROFILE_TXT="${L_BAT_SAVE#*  }" ;;
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
