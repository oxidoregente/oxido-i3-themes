#!/bin/bash
THEME_DIR="$1"
cp "$THEME_DIR/i3/colors.conf" ~/.config/i3/colors.conf
i3-msg reload >/dev/null 2>&1
