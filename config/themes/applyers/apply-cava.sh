#!/bin/bash
THEME_DIR="$1"
CAVA_CFG="$THEME_DIR/cava/config"
CAVA_DST="$HOME/.config/cava/config"

if [ -f "$CAVA_CFG" ]; then
    cp "$CAVA_CFG" "$CAVA_DST"
    # Reload cava colors if running
    CAVA_PID=$(pgrep -x cava 2>/dev/null | head -1)
    if [ -n "$CAVA_PID" ]; then
        kill -USR2 "$CAVA_PID" 2>/dev/null
    fi
fi
