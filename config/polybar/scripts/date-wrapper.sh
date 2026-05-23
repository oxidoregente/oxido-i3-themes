#!/bin/bash
if [ -f /tmp/polybar-date-alt ]; then
    LC_TIME=es_VE.utf8 date "+%A, %d %B %Y"
else
    date "+%I:%M %p"
fi
