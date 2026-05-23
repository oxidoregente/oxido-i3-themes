#!/bin/bash
lang=$(cat "$HOME/.config/themes/lang/active_lang.env" 2>/dev/null | cut -d'"' -f2)
[ -z "$lang" ] && lang="es"
if [ "$lang" = "en" ]; then LOCALE="en_US.utf8"; else LOCALE="es_VE.utf8"; fi

if [ -f /tmp/polybar-date-alt ]; then
    LC_TIME=$LOCALE date "+%A, %d %B %Y"
else
    date "+%I:%M %p"
fi
