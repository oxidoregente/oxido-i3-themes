#!/bin/bash
# ⚙️  Rofi Settings Center — main navigation menu
# Unifica el acceso a toda la configuración del sistema con UI moderna

# Detectar rutas y cargar builder
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$SCRIPT_DIR/../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../scripts/rofi-builder.sh"
[ -f "$SCRIPT_DIR/rofi-builder.sh" ] && source "$SCRIPT_DIR/rofi-builder.sh"

DIR="${THEMES_ROOT:-$HOME/.config/themes}/scripts/settings"

choice=$(cat <<EOF | rofi -dmenu -p "$L_CENTER" -i -theme-str "$ROFI_THEME_MAIN"
$L_APPS
$L_SOUND
$L_DISPLAY
$L_NOTIFY
$L_ANIM
$L_APPEAR
$L_POWER
$L_SYSTEM
$L_UTILS
$L_LANG
EOF
)

case "$choice" in
    *"$L_APPS"*)   exec "$DIR/default-apps.sh" ;;
    *"$L_SOUND"*)  exec "$DIR/sound.sh" ;;
    *"$L_DISPLAY"*) exec "$DIR/display.sh" ;;
    *"$L_NOTIFY"*) exec "$DIR/notify.sh" ;;
    *"$L_ANIM"*)   exec "$DIR/animation.sh" ;;
    *"$L_APPEAR"*) exec "$DIR/appearance.sh" ;;
    *"$L_POWER"*)  exec "$DIR/power.sh" ;;
    *"$L_SYSTEM"*) exec "$DIR/system.sh" ;;
    *"$L_UTILS"*)  exec "$DIR/utils.sh" ;;
    *"$L_LANG"*)   exec "$DIR/language.sh" ;;
esac
