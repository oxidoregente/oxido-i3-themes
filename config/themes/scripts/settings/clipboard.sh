#!/bin/bash
# 📋  Clipboard manager — browse clipboard history via rofi
# Uses xclip for clipboard operations, stores history in temp file
HIST_FILE=/tmp/clipboard-history.txt
MAX=30

# save current clipboard if changed
CURRENT=$(xclip -o -selection clipboard 2>/dev/null)
[ -n "$CURRENT" ] && {
    head -$((MAX-1)) "$HIST_FILE" 2>/dev/null | grep -Fx "$CURRENT" >/dev/null || \
    { echo "$CURRENT" > /tmp/_clip_new.$$; [ -f "$HIST_FILE" ] && cat "$HIST_FILE" >> /tmp/_clip_new.$$; mv /tmp/_clip_new.$$ "$HIST_FILE"; }
}

# ensure file exists
[ ! -f "$HIST_FILE" ] && touch "$HIST_FILE"

entries=$(awk '!seen[$0]++' "$HIST_FILE" 2>/dev/null | head -20)
[ -z "$entries" ] && entries="(vacío)"
entries="$entries\n⬅️  Volver"

sel=$(echo -e "$entries" | rofi -dmenu -p "  📋  Portapapeles" -i \
    -theme-str 'window { width: 600; border-radius: 16px; background-color: #1e1e2e; }
    mainbox { children: [listview]; spacing: 4px; padding: 8px; }
    listview { spacing: 2px; dynamic: true; }
    element { border-radius: 6px; padding: 6px 10px; background-color: #313244; text-color: #cdd6f4; }
    element selected { background-color: #89b4fa; text-color: #1e1e2e; }')

[[ "$sel" == *"Volver"* ]] && exec ~/.config/themes/bin/rofi-settings.sh
[ -n "$sel" ] && [ "$sel" != "(vacío)" ] && {
    echo -n "$sel" | xclip -selection clipboard 2>/dev/null
    echo -n "$sel" | xclip -selection primary 2>/dev/null
    dunstify -u low "📋  Portapapeles" "Texto copiado: ${sel:0:50}..."
}
