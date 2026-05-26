#!/bin/bash
# 📋  Clipboard manager — browse clipboard history via rofi
BACK_TO="${1:-$HOME/.config/themes/bin/rofi-settings.sh}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$SCRIPT_DIR/../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../scripts/rofi-builder.sh"
[ -f "$SCRIPT_DIR/../../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../../scripts/rofi-builder.sh"

HIST_FILE=/tmp/clipboard-history.txt
MAX=30

CURRENT=$(xclip -o -selection clipboard 2>/dev/null)
[ -n "$CURRENT" ] && {
    head -$((MAX-1)) "$HIST_FILE" 2>/dev/null | grep -Fx "$CURRENT" >/dev/null || \
    { echo "$CURRENT" > /tmp/_clip_new.$$; [ -f "$HIST_FILE" ] && cat "$HIST_FILE" >> /tmp/_clip_new.$$; mv /tmp/_clip_new.$$ "$HIST_FILE"; }
}

[ ! -f "$HIST_FILE" ] && touch "$HIST_FILE"

entries=$(awk '!seen[$0]++' "$HIST_FILE" 2>/dev/null | head -20)
[ -z "$entries" ] && entries="(vacío)"
entries="$entries\n$L_BACK"

sel=$(echo -e "$entries" | rofi -dmenu -p "  $L_CLIP" -i -theme-str "$ROFI_THEME_SUB")

[ -z "$sel" ] && exec "$BACK_TO"
[[ "$sel" == *"$L_BACK"* ]] && exec "$BACK_TO"

[ -n "$sel" ] && [ "$sel" != "(vacío)" ] && {
    echo -n "$sel" | xclip -selection clipboard 2>/dev/null
    echo -n "$sel" | xclip -selection primary 2>/dev/null
    dunstify -u low "$L_CLIP" "Texto copiado: ${sel:0:50}..."
}