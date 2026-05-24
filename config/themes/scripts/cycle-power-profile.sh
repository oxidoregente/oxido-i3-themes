#!/bin/bash
# Cargar idioma activo para nombres de perfil
source "$HOME/.config/themes/lang/active_lang.env" 2>/dev/null
LANG=${LANG:-es}
source "$HOME/.config/themes/lang/$LANG.sh" 2>/dev/null

CURRENT=$(powerprofilesctl get)
case "$CURRENT" in
    "performance")
        powerprofilesctl set balanced
        ICON=""
        PROFILE="${L_BAT_BAL#*  }"
        ;;
    "balanced")
        powerprofilesctl set power-saver
        ICON=""
        PROFILE="${L_BAT_SAVE#*  }"
        ;;
    "power-saver")
        powerprofilesctl set performance
        ICON=""
        PROFILE="${L_BAT_PERF#*  }"
        ;;
esac
~/.config/themes/scripts/notify-send.sh "$ICON" "Plan de energía" "$PROFILE" "low"
