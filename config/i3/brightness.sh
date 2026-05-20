#!/bin/bash

MAX_LIMIT=80   # Límite superior en %
MIN_LIMIT=5    # Límite inferior en %

MAX=$(brightnessctl max)
CAP=$((MAX * MAX_LIMIT / 100))
ACTUAL=$(brightnessctl get)

if [[ "$1" == *"+"* ]]; then
    PCT=${1//[+%]/}
    NEW=$((ACTUAL + MAX * PCT / 100))
    [ "$NEW" -gt "$CAP" ] && NEW=$CAP
    brightnessctl set "$NEW"
elif [[ "$1" == *%- ]]; then
    PCT=${1//[%-]/}
    NEW=$((ACTUAL - MAX * PCT / 100))
    MIN=$((MAX * MIN_LIMIT / 100))
    [ "$NEW" -lt "$MIN" ] && NEW=$MIN
    brightnessctl set "$NEW"
else
    brightnessctl set "$1"
fi

VAL=$(brightnessctl -m | cut -d, -f4)
INTVAL=${VAL%\%}
notify-send "Brillo" "$VAL" -h string:x-dunst-stack-tag:brightness -h int:value:"$INTVAL"
