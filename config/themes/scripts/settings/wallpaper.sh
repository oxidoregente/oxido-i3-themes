#!/bin/bash
# 🖼️  Wallpaper selector: browse wallpapers in current theme
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$SCRIPT_DIR/../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../scripts/rofi-builder.sh"
[ -f "$SCRIPT_DIR/../../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../../scripts/rofi-builder.sh"

BACK_TO="appearance"
case "${1:-}" in
    --back-to=*) BACK_TO="${1#--back-to=}" ;;
    --back-to)   BACK_TO="${2:-appearance}" ;;
    appearance|main|display) BACK_TO="$1" ;;
esac
case "$BACK_TO" in
    appearance) BACK_TO_SCRIPT="$SCRIPT_DIR/appearance.sh" ;;
    main)       BACK_TO_SCRIPT="$HOME/.config/themes/bin/rofi-settings.sh" ;;
    display)    BACK_TO_SCRIPT="$SCRIPT_DIR/display.sh" ;;
    *)          BACK_TO_SCRIPT="$SCRIPT_DIR/appearance.sh" ;;
esac

THEME_DIR=$(readlink -f ~/.config/themes/current/theme 2>/dev/null)
[ -z "$THEME_DIR" ] && THEME_DIR=~/.config/themes/themes/dracula
WALL_DIR="$THEME_DIR/backgrounds"
CACHE_DIR=~/.cache/wallpaper-thumbs
mkdir -p "$CACHE_DIR"

current_wall() { grep "file=" ~/.config/nitrogen/bg-saved.cfg 2>/dev/null | head -1 | sed 's/.*file=//'; }

PINNED_FILE="$THEME_DIR/last-wallpaper"

shopt -s nullglob
entries="$L_BACK\0icon\x1fgo-previous\n"
[ -f "$PINNED_FILE" ] && entries="♻️  Restaurar wallpaper del tema\0icon\x1fweather-clear\n$entries"
files=()
for img in "$WALL_DIR"/*.{jpg,png,jpeg,webp,bmp}; do
    [ ! -f "$img" ] && continue
    name=$(basename "$img")
    thumb="$CACHE_DIR/$name"
    [ ! -f "$thumb" ] && convert "$img" -resize "240x135^" -gravity center -extent 240x135 "$thumb" 2>/dev/null
    files+=("$name")
    if [ "$img" = "$(current_wall)" ]; then
        entries+="▶ $name\0icon\x1f$thumb\n"
    else
        entries+="$name\0icon\x1f$thumb\n"
    fi
done

[ "${#files[@]}" -eq 0 ] && {
    dunstify -u critical "$L_WALLPAPER" "$L_NO_IMAGES"
    exec "$BACK_TO_SCRIPT"
}

ROFI_THEME_WALL="window { width: ${W_WIDE:-750}px; border-radius: ${ROFI_RADIUS:-16}px; border: ${ROFI_BORDER:-2}px solid; border-color: $SEL; background-color: $BG; }
mainbox { children: [inputbar, listview]; spacing: 12px; padding: 15px; }
inputbar { background-color: $BGA; border-radius: 12px; padding: 10px 15px; text-color: $FG; margin: 0px 0px 5px 0px; children: [prompt]; }
prompt { text-color: $SEL; }
listview { columns: 3; lines: 4; spacing: 10px; dynamic: false; }
element { orientation: vertical; border-radius: 14px; padding: 10px; background-color: $BGA; text-color: $FG; }
element selected { background-color: $SEL; text-color: $BG; }
element-icon { size: 5em; border-radius: 8px; }
element-text { horizontal-align: 0.5; vertical-align: 0.5; font: \"JetBrainsMono Nerd Font Mono ${ROFI_FONT_SIZE_SUB:-10}\"; }"

choice=$(printf "%b" "$entries" | rofi -dmenu -p "  $L_WALLPAPER" -show-icons -i -no-custom -theme-str "$ROFI_THEME_WALL" -format s)

[ -z "$choice" ] && exec "$BACK_TO_SCRIPT"
[[ "$choice" == *"$L_BACK"* ]] && exec "$BACK_TO_SCRIPT"

# Handle restore theme wallpaper
if [[ "$choice" == *"Restaurar"* ]]; then
    rm -f "$PINNED_FILE"
    THEME_DIR=$(readlink -f ~/.config/themes/current/theme 2>/dev/null)
    bash "$HOME/.config/themes/applyers/apply-wallpaper.sh" "$THEME_DIR"
    dunstify -u low "$L_WALLPAPER" "Wallpaper del tema restaurado"
    exec "$BACK_TO_SCRIPT"
fi

selected=$(echo "$choice" | sed 's/^▶ //')
wall_path="$WALL_DIR/$selected"
if [ -f "$wall_path" ]; then
    echo "$wall_path" > "$PINNED_FILE"
    # Kill desktop managers that might interfere with wallpaper
    killall -9 plank 2>/dev/null
    nitrogen --set-zoom-fill "$wall_path" --save 2>/dev/null
fi
dunstify -u low "$L_WALLPAPER" "$L_SET_AS_WALL: $selected"
exec "$BACK_TO_SCRIPT"