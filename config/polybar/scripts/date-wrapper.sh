#!/bin/bash
lang=$(cat "$HOME/.config/themes/lang/active_lang.env" 2>/dev/null | cut -d'"' -f2)
[ -z "$lang" ] && lang="es"
if [ "$lang" = "en" ]; then LOCALE="en_US.utf8"; else LOCALE="es_VE.utf8"; fi

FMT=$(cat "$HOME/.config/themes/date-format" 2>/dev/null || echo "12h")
if [ "$FMT" = "24h" ]; then TFORMAT="%H:%M"; else TFORMAT="%I:%M %p"; fi

if [ -f /tmp/polybar-date-alt ]; then
    LC_TIME=$LOCALE date "+%A, %d %B %Y"
else
    date "+$TFORMAT"
fi
