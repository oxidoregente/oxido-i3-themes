#!/bin/bash
if eww active-windows 2>/dev/null | grep -q "powermenu"; then
    eww close powermenu
    i3-msg mode "default" 2>/dev/null
else
    eww open powermenu
    i3-msg mode "$mode_eww" 2>/dev/null || i3-msg mode "eww" 2>/dev/null
fi
