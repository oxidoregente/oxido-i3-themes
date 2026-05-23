#!/bin/bash
# cputemp-widget.sh — Muestra temperatura del CPU para polybar

if command -v sensors &>/dev/null; then
    TEMP=$(sensors 2>/dev/null | awk '/^CPU:/ {sub(/\+/, "", $2); sub(/°C/, "", $2); print int($2); exit}')
    [ -z "$TEMP" ] && TEMP=$(sensors 2>/dev/null | awk '/^Package id 0:/ {sub(/\+/, "", $4); sub(/°C/, "", $4); print int($4); exit}')
    [ -z "$TEMP" ] && TEMP=$(sensors 2>/dev/null | awk '/^temp1:/ {sub(/\+/, "", $2); sub(/°C/, "", $2); print int($2); exit}')
fi

if [ -z "$TEMP" ]; then
    TEMP=$(cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | head -1)
    [ -n "$TEMP" ] && TEMP=$((TEMP / 1000))
fi

if [ -n "$TEMP" ]; then
    if [ "$TEMP" -ge 80 ]; then
        echo "%{F#e06c75} ${TEMP}°C%{F-}"
    elif [ "$TEMP" -ge 70 ]; then
        echo "%{F#e5c07b} ${TEMP}°C%{F-}"
    else
        echo "%{F#98c379} ${TEMP}°C%{F-}"
    fi
else
    echo "N/A"
fi
