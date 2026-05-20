#!/bin/bash
# 🖼️  Wallpaper selector: browse wallpapers in current theme
THEME_DIR=$(readlink -f ~/.config/themes/current/theme 2>/dev/null)
[ -z "$THEME_DIR" ] && THEME_DIR=~/.config/themes/themes/dracula
WALL_DIR="$THEME_DIR/backgrounds"
CACHE_DIR=~/.cache/wallpaper-thumbs
mkdir -p "$CACHE_DIR"

current_wall() { grep "file=" ~/.config/nitrogen/bg-saved.cfg 2>/dev/null | head -1 | sed 's/.*file=//'; }

# generate thumbs for wallpapers
shopt -s nullglob
entries=""
for img in "$WALL_DIR"/*.{jpg,png,jpeg,webp,bmp}; do
    [ ! -f "$img" ] && continue
    name=$(basename "$img")
    thumb="$CACHE_DIR/$name"
    [ ! -f "$thumb" ] && convert "$img" -resize "240x135^" -gravity center -extent 240x135 "$thumb" 2>/dev/null
    CURRENT=""
    [ "$img" = "$(current_wall)" ] && CURRENT="▶"
    entries+="$CURRENT $name\0icon\x1f$thumb\n"
done

[ -z "$entries" ] && {
    dunstify -u critical "🖼️  Wallpapers" "No hay wallpapers en $WALL_DIR"
    exit 0
}

chosen=$(printf "%b" "$entries" | rofi -dmenu -p "  🖼️  Wallpaper" -show-icons -i \
    -theme-str 'window { width: 600; border-radius: 16px; background-color: #1e1e2e; }
    mainbox { children: [inputbar, listview]; spacing: 8px; padding: 12px; }
    inputbar { background-color: transparent; border-radius: 8px; padding: 8px 12px; text-color: #cdd6f4; }
    listview { columns: 3; lines: 4; spacing: 8px; dynamic: false; }
    element { orientation: vertical; border-radius: 12px; padding: 8px; background-color: #313244; text-color: #cdd6f4; }
    element selected { background-color: #89b4fa; text-color: #1e1e2e; }
    element-icon { size: 4em; border-radius: 6px; }
    element-text { horizontal-align: 0.5; vertical-align: 0.5; font: "FiraCode Nerd Font 9"; }')

[ -z "$chosen" ] && exit 0
chosen=$(echo "$chosen" | sed 's/^▶ //; s/^ *//')
wall_path="$WALL_DIR/$chosen"
[ -f "$wall_path" ] && nitrogen --set-zoom-fill "$wall_path" 2>/dev/null
dunstify -u low "🖼️  Wallpaper" "Cambiado a: $chosen"
