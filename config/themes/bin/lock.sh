#!/bin/bash
if ! command -v i3lock-color &>/dev/null; then
    notify-send -u critical "Lock Screen" "Error: i3lock-color no está instalado"
    exit 1
fi
THEME_DIR="$HOME/.config/themes/current/theme"

get_color() {
    local key="$1" fallback="$2"
    local val=$(grep "^$key=" "$THEME_DIR/polybar/colors.ini" 2>/dev/null | cut -d= -f2 | tr -d ' "')
    [ -z "$val" ] && val=$(grep "^$key=" "$THEME_DIR/polybar/config.ini" 2>/dev/null | cut -d= -f2 | tr -d ' "')
    echo "${val:-$fallback}"
}

read_hex() {
    local c=$(get_color "$1" "$2")
    echo "${c#\#}"
}

BG=$(read_hex "background" "1e1e2e")
FG=$(read_hex "foreground" "cdd6f4")
PRIMARY=$(read_hex "primary" "89b4fa")
ALERT=$(read_hex "alert" "f38ba8")
GREEN=$(read_hex "green" "a6e3a1")
DISABLED=$(read_hex "disabled" "585b70")

LOCK_IMG="$THEME_DIR/unlock.png"
[ ! -f "$LOCK_IMG" ] && LOCK_IMG="$HOME/.config/themes/themes/tokyo-night/unlock.png"
[ ! -f "$LOCK_IMG" ] && LOCK_IMG=""

i3lock-color \
    --ignore-empty-password \
    --indicator \
    --clock \
    --radius 100 \
    --ring-width 5 \
    --line-color="${BG}00" \
    --inside-color="${BG}cc" \
    --ring-color="${PRIMARY}ff" \
    --insidever-color="${GREEN}33" \
    --ringver-color="${GREEN}ff" \
    --insidewrong-color="${ALERT}33" \
    --ringwrong-color="${ALERT}ff" \
    --keyhl-color="${GREEN}ff" \
    --bshl-color="${ALERT}ff" \
    --separator-color="${DISABLED}88" \
    --time-color="${FG}ff" \
    --date-color="${DISABLED}ff" \
    --verif-color="${FG}ff" \
    --wrong-color="${ALERT}ff" \
    --modif-color="${FG}ff" \
    --layout-color="${FG}ff" \
    --greeter-color="${DISABLED}ff" \
    --greeter-font="JetBrainsMono Nerd Font Mono" \
    --time-font="JetBrainsMono Nerd Font Mono" \
    --date-font="JetBrainsMono Nerd Font Mono" \
    --time-str="%H:%M" \
    --date-str="%A, %d %B" \
    --verif-text="✓" \
    --wrong-text="✗" \
    --noinput-text="" \
    --greeter-text="" \
    --greeter-pos="x+0:y-100" \
    --time-pos="x+0:y-50" \
    --date-pos="x+0:y-25" \
    ${LOCK_IMG:+--image "$LOCK_IMG" --fill} \
    2>/dev/null
