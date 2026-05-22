#!/bin/bash
CURRENT=$(powerprofilesctl get)
case "$CURRENT" in
    "performance")
        powerprofilesctl set balanced
        PROFILE="Equilibrado"
        ICON=""
        ;;
    "balanced")
        powerprofilesctl set power-saver
        PROFILE="Ahorro"
        ICON=""
        ;;
    "power-saver")
        powerprofilesctl set performance
        PROFILE="Rendimiento"
        ICON=""
        ;;
esac
~/.config/themes/scripts/notify-send.sh "$ICON" "Plan de energía" "$PROFILE" "low"
