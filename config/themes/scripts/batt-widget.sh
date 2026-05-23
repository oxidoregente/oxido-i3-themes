#!/bin/bash
# batt-widget.sh — Widget Premium para Polybar
# oxido-i3-themes

FLAG="/tmp/polybar_batt_extended"

# Detección automática del dispositivo de batería
BAT=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -1)
if [ -z "$BAT" ] || [ ! -f "$BAT/status" ]; then
    echo "  AC "
    exit 0
fi

STATUS=$(cat "$BAT/status")
CAP=$(cat "$BAT/capacity")

# Iconos Modernos (Nerd Font v3)
if [ "$STATUS" = "Charging" ]; then
    [ "$CAP" -ge 95 ] && ICON="󱟦" || \
    [ "$CAP" -ge 80 ] && ICON="󱟥" || \
    [ "$CAP" -ge 60 ] && ICON="󱟤" || \
    [ "$CAP" -ge 40 ] && ICON="󱟣" || \
    [ "$CAP" -ge 20 ] && ICON="󱟢" || ICON="󱟡"
    PREFIX="󱐋"
else
    [ "$CAP" -ge 95 ] && ICON="󰁹" || \
    [ "$CAP" -ge 80 ] && ICON="󰂂" || \
    [ "$CAP" -ge 60 ] && ICON="󰂀" || \
    [ "$CAP" -ge 40 ] && ICON="󰁾" || \
    [ "$CAP" -ge 20 ] && ICON="󰁼" || ICON="󰂃"
    PREFIX=""
fi

if [ -f "$FLAG" ]; then
    # VISTA EXTENDIDA
    
    # Perfil de energía
    PROF_RAW=$(powerprofilesctl get 2>/dev/null)
    case "$PROF_RAW" in
        "performance") PROF="🚀" ;;
        "balanced")    PROF="⚖️" ;;
        "power-saver") PROF="🍃" ;;
        *)             PROF="" ;;
    esac

    # Tiempo restante con ACPI (limpio)
    if [ "$STATUS" != "Charging" ] && [ "$STATUS" != "Full" ]; then
        TIME=$(acpi -b 2>/dev/null | grep -o '[0-9][0-9]:[0-9][0-9]:[0-9][0-9]' | head -1 | sed 's/:[0-9][0-9]$//')
        [ -z "$TIME" ] && TIME="--"
        INFO="($TIME)"
    else
        INFO="⚡"
    fi

    echo " %{T2}${PREFIX}${ICON}%{T-} $CAP% $INFO $PROF "
else
    # VISTA SIMPLE
    echo " %{T2}${PREFIX}${ICON}%{T-} $CAP% "
fi
