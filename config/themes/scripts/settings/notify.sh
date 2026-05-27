#!/bin/bash
# 🔔  Notification settings: DND, clear, history, duration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIR="$SCRIPT_DIR"
[ -f "$SCRIPT_DIR/../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../scripts/rofi-builder.sh"
[ -f "$SCRIPT_DIR/../../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../../scripts/rofi-builder.sh"

DND_FILE=~/.cache/dunst-dnd
DUNSTRC=~/.config/dunst/dunstrc

dnd_status() {
    if [ -f "$DND_FILE" ]; then echo "🔇  $L_DND:  ON  |  Click to toggle"
    else echo "🔊  $L_DND:  OFF  |  Click to toggle"; fi
}

current_duration() {
    local t=$(grep "^ *timeout" "$DUNSTRC" 2>/dev/null | head -1 | awk '{print $3}')
    echo "${t:-8}s"
}

while true; do
    choice=$(cat <<EOF | rofi -dmenu -p "  $L_NOTIFY" -theme-str "$ROFI_THEME_MAIN" -i
$(dnd_status)
$L_CLEAR
$L_HIST
$L_NOT_DURATION: $(current_duration) ▸
$L_BACK
EOF
    )
    case "$choice" in
        *"$L_DND"*)
            ~/.config/themes/scripts/toggle-dnd.sh ;;
        *"$L_CLEAR"*)
            dunstctl close-all
            dunstify -u low "$L_CLEAR" "All done" ;;
        *"$L_HIST"*)
            dunstctl history-pop ;;
        *"$L_NOT_DURATION"*)
            dur=$(printf "3 segundos\n5 segundos\n8 segundos\n15 segundos\n30 segundos\n∞  (fijo)" | \
                rofi -dmenu -p "  ⏱  $L_NOT_DURATION" -theme-str "$ROFI_THEME_SUB" -i)
            [ -z "$dur" ] && continue
            case "$dur" in
                *3*) VAL=3 ;;
                *5*) VAL=5 ;;
                *8*) VAL=8 ;;
                *15*) VAL=15 ;;
                *30*) VAL=30 ;;
                *∞*) VAL=0 ;;
                *) continue ;;
            esac
            sed -i "s/^    timeout = .*/    timeout = $VAL/" "$DUNSTRC"
            killall -q dunst 2>/dev/null; sleep 0.3
            dunst 2>/dev/null & disown
            dunstify -u low "$L_NOT_DURATION" "${VAL}s — aplicado" ;;
        *"$L_BACK"*)
            exec ~/.config/themes/bin/rofi-settings.sh ;;
        *) exec ~/.config/themes/bin/rofi-settings.sh ;;
    esac
done