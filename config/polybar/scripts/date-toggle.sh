#!/bin/bash
toggle_file="/tmp/polybar-date-alt"
if [ -f "$toggle_file" ]; then
    rm "$toggle_file"
else
    touch "$toggle_file"
fi
sleep 0.05
polybar-msg action "#date.hook.0" &>/dev/null &
