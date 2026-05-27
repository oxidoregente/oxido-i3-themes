#!/bin/bash
# center-bubble.sh — Wedge + Fecha + Wedge como una sola burbuja centrable
# oxido-i3-themes
lang=$(cat "$HOME/.config/themes/lang/active_lang.env" 2>/dev/null | cut -d'"' -f2)
[ -z "$lang" ] && lang="es"
if [ "$lang" = "en" ]; then LOCALE="en_US.utf8"; else LOCALE="es_VE.utf8"; fi

FMT=$(cat "$HOME/.config/themes/date-format" 2>/dev/null || echo "12h")
if [ "$FMT" = "24h" ]; then TFORMAT="%H:%M"; else TFORMAT="%I:%M %p"; fi

if [ -f /tmp/polybar-date-alt ]; then
    date_str=$(LC_TIME=$LOCALE date "+%A, %d %B %Y")
else
    date_str=$(date "+$TFORMAT")
fi

# Leer colores activos del config (pueden cambiar con el tema)
BG=$(sed -n 's/^background *= *//p' "$HOME/.config/polybar/config.ini" | head -1)
BUBBLE=$(sed -n 's/^bubble-center *= *//p' "$HOME/.config/polybar/config.ini" | head -1)
PRIMARY=$(sed -n 's/^primary *= *//p' "$HOME/.config/polybar/config.ini" | head -1)
[ -z "$BUBBLE" ] && BUBBLE="#222122"
[ -z "$PRIMARY" ] && PRIMARY="#b59790"
[ -z "$BG" ] && BG="#0c0b0c33"

# Wedge en color bubble (se funde con format-background) + fecha en primary
echo "%{F$BUBBLE}%{F-} %{F$PRIMARY}$date_str%{F-} %{F$BUBBLE}%{F-}"
