#!/bin/bash
THEME_DIR="$1"
CONKY_FLAG=~/.config/themes/conky-enabled
POWERSAVER_FLAG="/tmp/powersaver_active"

killall -q conky 2>/dev/null

[ -f "$POWERSAVER_FLAG" ] && exit 0
[ ! -f "$CONKY_FLAG" ] && exit 0

cp "$THEME_DIR/conky/conky.conf" ~/.config/conky/conky.conf
while pgrep -u $UID -x conky >/dev/null; do sleep 0.3; done
LANG_FILE="$HOME/.config/themes/lang/active_lang.env"
lang=$(grep '^LANG=' "$LANG_FILE" 2>/dev/null | cut -d'"' -f2)
[ -z "$lang" ] && lang="es"
export LC_TIME=$([ "$lang" = "en" ] && echo "en_US.utf8" || echo "es_VE.utf8")
conky -c ~/.config/conky/conky.conf &
disown
