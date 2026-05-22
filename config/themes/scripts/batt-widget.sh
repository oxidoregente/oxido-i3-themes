#!/bin/bash
BAT="/sys/class/power_supply/BAT0"
if [ ! -f "$BAT/status" ]; then
    echo "  AC"
    exit 0
fi

STATUS=$(<"$BAT/status")
CAP=$(<"$BAT/capacity")

if [ "$CAP" -ge 80 ]; then ICON=""
elif [ "$CAP" -ge 60 ]; then ICON=""
elif [ "$CAP" -ge 40 ]; then ICON=""
elif [ "$CAP" -ge 20 ]; then ICON=""
else ICON=""
fi

[ "$STATUS" = "Charging" ] && PREFIX=" " || PREFIX=""

echo " ${PREFIX}${ICON} $CAP%"
