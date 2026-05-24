#!/bin/bash
CONKY_FLAG=~/.config/themes/conky-enabled
POWERSAVER_FLAG="/tmp/powersaver_active"
THEME_DIR=$(readlink -f ~/.config/themes/current/theme 2>/dev/null)

[ -f "$POWERSAVER_FLAG" ] && notify-send "Conky" "En modo powersaver" && exit 0

if [ -f "$CONKY_FLAG" ]; then
    rm -f "$CONKY_FLAG"
    killall -q conky 2>/dev/null
    notify-send "Conky" "Desactivado"
else
    touch "$CONKY_FLAG"
    if [ -n "$THEME_DIR" ] && [ -f "$THEME_DIR/conky/conky.conf" ]; then
        cp "$THEME_DIR/conky/conky.conf" ~/.config/conky/conky.conf
    fi
    LANG_FILE="$HOME/.config/themes/lang/active_lang.env"
    lang=$(grep '^LANG=' "$LANG_FILE" 2>/dev/null | cut -d'"' -f2)
    [ -z "$lang" ] && lang="es"
    export LC_TIME=$([ "$lang" = "en" ] && echo "en_US.utf8" || echo "es_VE.utf8")
    conky -c ~/.config/conky/conky.conf &
    disown
    notify-send "Conky" "Activado"
fi
