#!/bin/bash
# Lanza el navegador predeterminado según defaults.conf
CONF="$HOME/.config/themes/defaults.conf"
[ -f "$CONF" ] && source "$CONF"
exec ${BROWSER:-firefox} "$@"
