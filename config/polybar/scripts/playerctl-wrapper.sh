#!/bin/bash
# playerctl-wrapper.sh — Wrapper para playerctl con detección inteligente
# oxido-i3-themes — https://github.com/anomalyco/oxido-i3-themes
#
# Prioridad: 1) Playing > Paused  2) Reproductores nativos > Browsers
# Úsalo como reemplazo directo de playerctl en los clicks de polybar:
#   click-left = ~/.config/polybar/scripts/playerctl-wrapper.sh play-pause

get_active_player() {
    local playing=""

    for player in $(playerctl -l 2>/dev/null); do
        status=$(playerctl -p "$player" status 2>/dev/null)
        [ "$status" != "Playing" ] && continue
        # Solo si tiene metadata real — ignora browsers sin contenido activo
        title=$(playerctl -p "$player" metadata title 2>/dev/null)
        [ -z "$title" ] && continue
        # Preferir reproductores nativos sobre browsers
        case "$player" in
            spotify*|mpd|rhythmbox|vlc|audacious|clementine|strawberry|deadbeef|pragha|qmmp)
                echo "$player"
                return
                ;;
        esac
        [ -z "$playing" ] && playing="$player"
    done

    [ -n "$playing" ] && echo "$playing" && return
    echo ""
}

main() {
    player=$(get_active_player)
    if [ -n "$player" ]; then
        exec playerctl -p "$player" "$@"
    else
        exec playerctl "$@"
    fi
}

# Solo ejecutar main si se invoca directamente, no al hacer source
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    main "$@"
fi
