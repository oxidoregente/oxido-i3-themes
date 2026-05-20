#!/bin/bash
# Polybar DND indicator
STATE_FILE=~/.cache/dunst-dnd

if [ -f "$STATE_FILE" ]; then
    # DND active (notifications SILENCED)
    echo "%{F#f7768e} %{F-}"
else
    # Normal (notifications ON)
    echo "%{F#a6e3a1} %{F-}"
fi
