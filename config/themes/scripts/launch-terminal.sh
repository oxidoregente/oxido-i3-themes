#!/bin/bash
# Lanza el terminal predeterminado según defaults.conf
CONF="$HOME/.config/themes/defaults.conf"
[ -f "$CONF" ] && source "$CONF"
exec ${TERMINAL:-alacritty} "$@"
