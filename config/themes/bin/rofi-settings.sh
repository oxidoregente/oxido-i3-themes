#!/bin/bash
# ⚙️  Rofi Settings Center — main navigation menu
# All sub-scripts are standalone and can be bound directly to keys

DIR=~/.config/themes/scripts/settings
BASE_THEME=$(cat "$DIR/.rasi-base" 2>/dev/null || echo '* { font: "FiraCode Nerd Font 10"; }
window { width: 400; border-radius: 16px; background-color: #1e1e2e; }
mainbox { children: [listview]; spacing: 4px; padding: 8px; }
listview { spacing: 4px; dynamic: true; }
element { border-radius: 10px; padding: 12px; background-color: #313244; text-color: #cdd6f4; }
element selected { background-color: #89b4fa; text-color: #1e1e2e; }
element-icon { size: 1.4em; }
element-text { horizontal-align: 0.5; }')

choice=$(cat <<EOF | rofi -dmenu -p "  ⚙️  Centro de Control" -theme-str "$BASE_THEME" -i
📱  Aplicaciones
🔊  Sonido
☀️  Pantalla
🔔  Notificaciones
🎬  Animaciones
🎨  Apariencia
⚡  Energía
🔧  Sistema
📋  Utilidades
EOF
)

case "$choice" in
    *"Aplicaciones") exec "$DIR/default-apps.sh" ;;
    *"Sonido")     exec "$DIR/sound.sh" ;;
    *"Pantalla")   exec "$DIR/display.sh" ;;
    *"Notificaciones") exec "$DIR/notify.sh" ;;
    *"Animaciones") exec "$DIR/animation.sh" ;;
    *"Apariencia") exec "$DIR/appearance.sh" ;;
    *"Energía")    exec "$DIR/power.sh" ;;
    *"Sistema")    exec "$DIR/system.sh" ;;
    *"Utilidades") exec "$DIR/utils.sh" ;;
esac
