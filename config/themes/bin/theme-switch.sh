#!/bin/bash

THEMES_DIR="$HOME/.config/themes"
CURRENT_LINK="$THEMES_DIR/current/theme"
THEME_NAME="$1"

if [ -z "$THEME_NAME" ]; then
    echo "Uso: theme-switch.sh <nombre-del-tema>"
    echo "Temas disponibles:"
    ls -1 "$THEMES_DIR/themes/"
    exit 1
fi

THEME_DIR="$THEMES_DIR/themes/$THEME_NAME"

if [ ! -d "$THEME_DIR" ]; then
    notify-send -u critical "Theme Switcher" "Tema '$THEME_NAME' no encontrado"
    exit 1
fi

# Prevent powersaver indicator from blocking
rm -f /tmp/powersaver_active

# Actualizar symlink
rm -f "$CURRENT_LINK"
ln -s "$THEME_DIR" "$CURRENT_LINK"

# Ejecutar applyers
APPS=(
    "apply-wallpaper.sh"
    "apply-lockscreen.sh"
    "apply-polybar.sh"
    "apply-picom.sh"
    "apply-dunst.sh"
    "apply-rofi.sh"
    "apply-conky.sh"
    "apply-i3.sh"
)
for app in "${APPS[@]}"; do
    APPLYER="$THEMES_DIR/applyers/$app"
    if [ -f "$APPLYER" ]; then
        bash "$APPLYER" "$THEME_DIR"
    fi
done

bash "$THEMES_DIR/applyers/apply-alacritty.sh" "$THEME_DIR" 2>/dev/null
bash "$THEMES_DIR/applyers/apply-btop.sh" "$THEME_DIR" 2>/dev/null
bash "$THEMES_DIR/applyers/apply-cava.sh" "$THEME_DIR" 2>/dev/null
bash "$THEMES_DIR/applyers/apply-opencode.sh" "$THEME_DIR" 2>/dev/null

notify-send -i preferences-desktop-theme "Theme Switcher" "Tema cambiado a: ${THEME_NAME^}"
