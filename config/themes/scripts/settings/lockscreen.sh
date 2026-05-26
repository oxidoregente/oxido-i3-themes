#!/bin/bash
# 🔒  Lock screen background selector for oxido-i3-themes
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIR="$SCRIPT_DIR"
[ -f "$SCRIPT_DIR/../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../scripts/rofi-builder.sh"
[ -f "$SCRIPT_DIR/../../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../../scripts/rofi-builder.sh"

THEME_DIR=$(readlink -f ~/.config/themes/current/theme 2>/dev/null)
[ -z "$THEME_DIR" ] && THEME_DIR=~/.config/themes/themes/dracula
WALL_DIR="$THEME_DIR/backgrounds"
CACHE_DIR=~/.cache/lock-thumbs
mkdir -p "$CACHE_DIR"

gen_thumb() {
    local src="$1" name="$2" thumb="$CACHE_DIR/$name"
    [ ! -f "$thumb" ] && convert "$src" -resize "240x135^" -gravity center -extent 240x135 "$thumb" 2>/dev/null
    echo "$thumb"
}

entries="$L_BACK\0icon\x1fgo-previous\n"
labels=()
files=()

if [ -f "$THEME_DIR/unlock.png" ]; then
    thumb=$(gen_thumb "$THEME_DIR/unlock.png" "unlock.png")
    labels+=("🔒  unlock.png ($L_CURRENT)")
    files+=("$THEME_DIR/unlock.png")
    entries+="🔒  unlock.png ($L_CURRENT)\0icon\x1f$thumb\n"
fi

shopt -s nullglob
for img in "$WALL_DIR"/*.{jpg,png,jpeg,webp,bmp}; do
    [ ! -f "$img" ] && continue
    name=$(basename "$img")
    thumb=$(gen_thumb "$img" "wall-$name")
    labels+=("$name")
    files+=("$img")
    entries+="$name\0icon\x1f$thumb\n"
done

[ "${#files[@]}" -eq 0 ] && {
    dunstify -u critical "$L_LOCKSCREEN" "$L_NO_IMAGES"
    exec "$SCRIPT_DIR/appearance.sh"
}

ROFI_THEME_LOCK="window { width: ${W_WIDE:-750}px; border-radius: ${ROFI_RADIUS:-16}px; border: ${ROFI_BORDER:-2}px solid; border-color: $SEL; background-color: $BG; }
mainbox { children: [inputbar, listview]; spacing: 12px; padding: 15px; }
inputbar { background-color: $BGA; border-radius: 12px; padding: 10px 15px; text-color: $FG; margin: 0px 0px 5px 0px; children: [prompt]; }
prompt { text-color: $SEL; }
listview { columns: 3; lines: 4; spacing: 10px; dynamic: false; }
element { orientation: vertical; border-radius: 14px; padding: 10px; background-color: $BGA; text-color: $FG; }
element selected { background-color: $SEL; text-color: $BG; }
element-icon { size: 5em; border-radius: 8px; }
element-text { horizontal-align: 0.5; vertical-align: 0.5; font: \"JetBrainsMono Nerd Font Mono ${ROFI_FONT_SIZE_SUB:-10}\"; }"

choice=$(printf "%b" "$entries" | rofi -dmenu -p "  🔒  $L_LOCKSCREEN" -show-icons -i -no-custom -theme-str "$ROFI_THEME_LOCK" -format s)

[ -z "$choice" ] && exec "$SCRIPT_DIR/appearance.sh"
[[ "$choice" == *"$L_BACK"* ]] && exec "$SCRIPT_DIR/appearance.sh"

selected=""
for i in "${!labels[@]}"; do
    if [[ "$choice" == "${labels[$i]}"* ]]; then
        selected="${files[$i]}"
        break
    fi
done

[ -z "$selected" ] && exec "$SCRIPT_DIR/appearance.sh"

if [ -f "$selected" ]; then
    cp "$selected" "$THEME_DIR/unlock.png"
    ~/.config/themes/applyers/apply-lockscreen.sh "$THEME_DIR" >/dev/null 2>&1
    dunstify -i "$THEME_DIR/unlock.png" -u low "$L_LOCKSCREEN" "$L_SET_AS_LOCK: $(basename "$selected")"
fi
exec "$SCRIPT_DIR/appearance.sh"