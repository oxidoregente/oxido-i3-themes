#!/bin/bash
# nowplaying.sh — Módulo Now Playing para Polybar (modo tail)
# oxido-i3-themes — Versión Orgánica (Auto-caps + Auto-BG)

# Reutiliza la detección inteligente de reproductor
source "$HOME/.config/polybar/scripts/playerctl-wrapper.sh"

get_player() {
    get_active_player
}

get_info() {
    local player=$(get_player)
    [ -z "$player" ] && { echo ""; return; }
    local title=$(playerctl -p "$player" metadata title 2>/dev/null)
    local artist=$(playerctl -p "$player" metadata artist 2>/dev/null)
    if [ -n "$title" ] && [ -n "$artist" ]; then
        echo "$title - $artist"
    elif [ -n "$title" ]; then
        echo "$title"
    else
        echo ""
    fi
}

get_symbol() {
    local player=$(get_player)
    [ -z "$player" ] && { echo ""; return; }
    local status=$(playerctl -p "$player" status 2>/dev/null)
    if [ "$status" = "Playing" ]; then
        echo ""
    elif [ "$status" = "Paused" ]; then
        echo ""
    else
        echo ""
    fi
}

scroll_text() {
    local window_len=24
    local delay=0.2
    local text=$(get_info)
    local padding='  '
    local text_length=${#text}
    local padded_text="$text$padding"
    local total_len=$((text_length + ${#padding}))
    local symbol=$(get_symbol)

    if [ -z "$text" ]; then
        echo ""
        sleep 2
        return
    fi

    # Formateo dinámico con caps y fondo de burbuja
    local fmt_start="  %{F$BUBBLE}%{B-}%{B$BUBBLE} %{F$PRIMARY}${symbol} "
    local fmt_end=" %{B-}%{F$BUBBLE}%{F-}"

    if ((text_length <= window_len)); then
        echo "${fmt_start}${padded_text}${fmt_end}"
        sleep 3
        return
    fi

    for ((i = 0; i < total_len; i++)); do
        symbol=$(get_symbol)
        fmt_start="  %{F$BUBBLE}%{B-}%{B$BUBBLE} %{F$PRIMARY}${symbol} "
        if ((i + window_len >= total_len)); then
            echo "${fmt_start}${padded_text:i}${padded_text:0:window_len - (total_len - i)}${fmt_end}"
        else
            echo "${fmt_start}${padded_text:i:window_len}${fmt_end}"
        fi
        sleep "$delay"
    done
}

main() {
    # Leer colores una sola vez al inicio (Polybar reinicia el script al cambiar de tema)
    BUBBLE=$(sed -n 's/^bubble-player *= *//p' "$HOME/.config/polybar/config.ini" | head -1)
    PRIMARY=$(sed -n 's/^primary *= *//p' "$HOME/.config/polybar/config.ini" | head -1)
    [ -z "$BUBBLE" ] && BUBBLE="#222122"
    [ -z "$PRIMARY" ] && PRIMARY="#b59790"

    while true; do
        scroll_text
    done
}

main
