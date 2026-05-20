#!/bin/bash
STATE_FILE="/tmp/polybar_batt_state"

# Leer directamente de los archivos es instantáneo
STATUS=$(< /sys/class/power_supply/BAT0/status)
CAP=$(< /sys/class/power_supply/BAT0/capacity)

# Solo ejecutamos comandos externos si son estrictamente necesarios
RAW_PROFILE=$(powerprofilesctl get)

case $RAW_PROFILE in
    "performance")  PROFILE="Rendimiento" ;;
    "balanced")     PROFILE="Equilibrado" ;;
    "power-saver")  PROFILE="Ahorro" ;;
esac

# Solo pedimos el tiempo si no estamos en AC
if [ "$STATUS" != "Charging" ] && [ "$STATUS" != "Full" ]; then
    TIME=$(acpi -b | grep -Po '\d+:\d+(?=:\d+)' | head -n 1)
else
    TIME="AC"
fi

[ -z "$TIME" ] && TIME="--"

if [ -f "$STATE_FILE" ]; then
    echo "  $CAP% ($TIME) [$PROFILE] "
else
    echo "  $CAP% "
fi
