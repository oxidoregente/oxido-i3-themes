#!/bin/bash
# set-power-profile.sh — Establece/obtiene perfil de energía con detección automática
# oxido-i3-themes
STATE_DIR="$HOME/.config/themes/state"
mkdir -p "$STATE_DIR"
STATED="$STATE_DIR/power_profile"

usage() {
    echo "Uso: set-power-profile.sh [get|set <profile>]"
    echo "Perfiles: power-saver, balanced, performance"
    exit 1
}

cmd="${1:-get}"

case "$cmd" in
    get)
        if command -v powerprofilesctl &>/dev/null; then
            powerprofilesctl get 2>/dev/null
        elif [ -f "$STATED" ]; then
            cat "$STATED"
        else
            echo "balanced"
        fi
        exit 0
        ;;
    set)
        profile="$2"
        [ -z "$profile" ] && usage
        echo "$profile" > "$STATED"

        # Method 1: powerprofilesctl
        if command -v powerprofilesctl &>/dev/null; then
            powerprofilesctl set "$profile" 2>/dev/null && exit 0
        fi

        # Method 2: TLP (requiere sudoers NOPASSWD como se documenta)
        if command -v tlp &>/dev/null; then
            case "$profile" in
                power-saver) tlp_cmd="bat" ;;
                *)           tlp_cmd="ac" ;;
            esac
            sudo -n /usr/sbin/tlp "$tlp_cmd" 2>/dev/null && exit 0
        fi

        # Method 3: cpupower
        if command -v cpupower &>/dev/null; then
            gov="powersave"
            [ "$profile" = "performance" ] && gov="performance"
            sudo -n cpupower frequency-set -g "$gov" 2>/dev/null && exit 0
        fi

        exit 0
        ;;
    *) usage ;;
esac
