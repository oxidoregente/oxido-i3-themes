#!/bin/bash
# Cycle power profile: power-saver → balanced → performance
# oxido-i3-themes
source "$HOME/.config/themes/lang/active_lang.env" 2>/dev/null
LANG=${LANG:-es}
source "$HOME/.config/themes/lang/$LANG.sh" 2>/dev/null

CURRENT=$(bash "$HOME/.config/themes/scripts/set-power-profile.sh" get)
case "$CURRENT" in
    "performance")
        NEXT="balanced"
        ICON=""
        PROFILE="${L_BAT_BAL#*  }"
        ;;
    "balanced")
        NEXT="power-saver"
        ICON=""
        PROFILE="${L_BAT_SAVE#*  }"
        ;;
    "power-saver")
        NEXT="performance"
        ICON=""
        PROFILE="${L_BAT_PERF#*  }"
        ;;
    *)
        NEXT="balanced"
        ICON=""
        PROFILE="${L_BAT_BAL#*  }"
        ;;
esac
bash "$HOME/.config/themes/scripts/set-power-profile.sh" set "$NEXT"
~/.config/themes/scripts/notify-send.sh "$ICON" "Plan de energía" "$PROFILE" "low"
