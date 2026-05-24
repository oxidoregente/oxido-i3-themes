#!/bin/bash
# Cargar idioma activo para nombres de perfil
source "$HOME/.config/themes/lang/active_lang.env" 2>/dev/null
LANG=${LANG:-es}
source "$HOME/.config/themes/lang/$LANG.sh" 2>/dev/null

STATE_FILE="/tmp/polybar_batt_state"
BAT="/sys/class/power_supply/BAT0"

if [ ! -f "$BAT/status" ]; then
    echo "  AC"
    exit 0
fi

STATUS=$(< "$BAT/status")
CAP=$(< "$BAT/capacity")

# Iconos según nivel de batería
if [ "$CAP" -ge 80 ]; then
    ICON=""
elif [ "$CAP" -ge 60 ]; then
    ICON=""
elif [ "$CAP" -ge 40 ]; then
    ICON=""
elif [ "$CAP" -ge 20 ]; then
    ICON=""
else
    ICON=""
fi

# Estado de carga
if [ "$STATUS" = "Charging" ]; then
    PREFIX=" "
elif [ "$STATUS" = "Full" ]; then
    PREFIX=""
else
    PREFIX=""
fi

    # Mostrar info detallada con clic izquierdo
if [ -f "$STATE_FILE" ]; then
    PROFILE=$(powerprofilesctl get 2>/dev/null)
    case $PROFILE in
        "performance") PROFILE="${L_BAT_PERF#*  }" ;;
        "balanced")    PROFILE="${L_BAT_BAL#*  }" ;;
        "power-saver") PROFILE="${L_BAT_SAVE#*  }" ;;
        *)             PROFILE="" ;;
    esac
    TIME=$(acpi -b 2>/dev/null | grep -o '[0-9][0-9]:[0-9][0-9]:[0-9][0-9]' | head -1 | sed 's/:[0-9][0-9]$//')
    [ -z "$TIME" ] && TIME="--"
    echo " %{T2}${PREFIX}${ICON}%{T-} $CAP% ($TIME) $PROFILE"
else
    echo " %{T2}${PREFIX}${ICON}%{T-} $CAP%"
fi
