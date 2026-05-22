#!/bin/bash
for win in powermenu control-center; do
    if eww active-windows 2>/dev/null | grep -q "$win"; then
        eww close "$win"
        sleep 0.1
    fi
done
i3-msg mode "default" 2>/dev/null
