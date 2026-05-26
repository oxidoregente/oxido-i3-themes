#!/bin/bash
# playerctl-wrapper.sh — Wrapper para playerctl con detección inteligente
# oxido-i3-themes — https://github.com/anomalyco/oxido-i3-themes
#
# Prioridad: 1) Playing > Paused  2) Reproductores nativos > Browsers
# Úsalo como reemplazo directo de playerctl en los clicks de polybar:
#   click-left = ~/.config/polybar/scripts/playerctl-wrapper.sh play-pause

get_active_player() {
    local native_playing=""
    local native_paused=""
    local browser_playing=""
    local browser_paused=""

    for player in $(playerctl -l 2>/dev/null); do
        status=$(playerctl -p "$player" status 2>/dev/null)
        [ "$status" != "Playing" ] && [ "$status" != "Paused" ] && continue
        title=$(playerctl -p "$player" metadata title 2>/dev/null)
        [ -z "$title" ] && continue
        length=$(playerctl -p "$player" metadata mpris:length 2>/dev/null)
        [ -z "$length" ] && continue

        case "$player" in
            spotify*|mpd|rhythmbox|vlc|audacious|clementine|strawberry|deadbeef|pragha|qmmp)
                if [ "$status" = "Playing" ]; then
                    [ -z "$native_playing" ] && native_playing="$player"
                else
                    [ -z "$native_paused" ] && native_paused="$player"
                fi
                ;;
            *)
                if [ "$status" = "Playing" ]; then
                    [ -z "$browser_playing" ] && browser_playing="$player"
                else
                    [ -z "$browser_paused" ] && browser_paused="$player"
                fi
                ;;
        esac
    done

    # Prioridad: native Playing > browser Playing > native Paused > browser Paused
    [ -n "$native_playing" ] && echo "$native_playing" && return
    [ -n "$browser_playing" ] && echo "$browser_playing" && return
    [ -n "$native_paused" ] && echo "$native_paused" && return
    [ -n "$browser_paused" ] && echo "$browser_paused" && return
    echo ""
}

main() {
    player=$(get_active_player)
    echo "[$(date +%H:%M:%S)] wrapper args=$* player='$player'" >> /tmp/polybar-click-debug.log
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
