#!/bin/bash
# Lanza el gestor de archivos predeterminado según defaults.conf
CONF="$HOME/.config/themes/defaults.conf"
[ -f "$CONF" ] && source "$CONF"
exec ${FILE_MANAGER:-nemo} "$@"
