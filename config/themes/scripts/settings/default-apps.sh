#!/bin/bash
# 📱  Aplicaciones predeterminadas
DIR=~/.config/themes/scripts/settings
BASE_THEME=$(cat "$DIR/.rasi-base" 2>/dev/null || echo '* { font: "FiraCode Nerd Font 10"; }
window { width: 400; border-radius: 16px; background-color: #1e1e2e; }
mainbox { children: [listview]; spacing: 4px; padding: 8px; }
listview { spacing: 4px; dynamic: true; }
element { border-radius: 10px; padding: 10px 14px; background-color: #313244; text-color: #cdd6f4; }
element selected { background-color: #89b4fa; text-color: #1e1e2e; }
element-icon { size: 1.2em; }
element-text { horizontal-align: 0.5; }')

CONF="$HOME/.config/themes/defaults.conf"
PROFILES_DIR="$HOME/.config/themes/profiles"
CURRENT="$HOME/.config/themes/current-defaults"
mkdir -p "$PROFILES_DIR"

load_config() {
    [ -f "$CONF" ] && source "$CONF"
    TERMINAL=${TERMINAL:-alacritty}
    BROWSER=${BROWSER:-firefox}
    FILE_MANAGER=${FILE_MANAGER:-nemo}
    TERMINAL_FILE_MANAGER=${TERMINAL_FILE_MANAGER:-ranger}
}

save_config() {
    cat > "$CONF" << CONFEOF
# ─── Aplicaciones Predeterminadas ───
# Editado por el menú de Configuración → Aplicaciones
# No editar manualmente mientras el menú esté abierto

TERMINAL="$TERMINAL"
BROWSER="$BROWSER"
FILE_MANAGER="$FILE_MANAGER"
TERMINAL_FILE_MANAGER="$TERMINAL_FILE_MANAGER"
CONFEOF
}

pick_app() {
    local role="$1" desc="$2" current="$3"
    local choices
    case "$role" in
        terminal)
            choices="alacritty\nkitty\nurxvt\nst\ntermite\ngnome-terminal\nxterm\nwezterm\nfoot"
            ;;
        browser)
            choices="firefox\nchromium\nbrave\ngoogle-chrome\nvivaldi\nedge\nlibrewolf\nzen"
            ;;
        file_manager)
            choices="nemo\nthunar\nnautilus\npcmanfm\ndolphin\ncaja"
            ;;
        terminal_fm)
            choices="ranger\nlf\nnnn\nvifm\nmc"
            ;;
    esac
    # Add custom option
    choices="$choices\n✏️  Otra..."

    selected=$(printf "%s" "$choices" | rofi -dmenu -p "  $desc" -theme-str "$BASE_THEME" -i -select "$current")
    if [ "$selected" = "✏️  Otra..." ]; then
        selected=$(echo "" | rofi -dmenu -p "  Escribe el comando" -theme-str "$BASE_THEME")
    fi
    echo "$selected"
}

while true; do
    load_config
    choice=$(cat <<EOF | rofi -dmenu -p "  📱  Aplicaciones" -theme-str "$BASE_THEME" -i
  Terminal        |  $TERMINAL
  Navegador       |  $BROWSER
  Archivos (GUI)  |  $FILE_MANAGER
  Archivos (CLI)  |  $TERMINAL_FILE_MANAGER
  Guardar perfil
  Cargar perfil
⬅️  Volver
EOF
    )
    action=$(echo "$choice" | sed 's/  |.*//')
    case "$action" in
        *"Terminal"*)
            result=$(pick_app terminal "    Terminal" "$TERMINAL")
            [ -n "$result" ] && { TERMINAL="$result"; save_config; } ;;
        *"Navegador"*)
            result=$(pick_app browser "    Navegador" "$BROWSER")
            [ -n "$result" ] && { BROWSER="$result"; save_config; } ;;
        *"Archivos (GUI)"*)
            result=$(pick_app file_manager "    Archivos" "$FILE_MANAGER")
            [ -n "$result" ] && { FILE_MANAGER="$result"; save_config; } ;;
        *"Archivos (CLI)"*)
            result=$(pick_app terminal_fm "    Archivos CLI" "$TERMINAL_FILE_MANAGER")
            [ -n "$result" ] && { TERMINAL_FILE_MANAGER="$result"; save_config; } ;;
        *"Guardar perfil"*)
            name=$(echo "" | rofi -dmenu -p "  Nombre del perfil" -theme-str "$BASE_THEME")
            if [ -n "$name" ]; then
                cp "$CONF" "$PROFILES_DIR/$name.conf"
                dunstify -u low "  Perfil guardado" "$name"
            fi ;;
        *"Cargar perfil"*)
            profile=$(ls "$PROFILES_DIR"/*.conf 2>/dev/null | xargs -n1 basename | sed 's/\.conf$//')
            if [ -z "$profile" ]; then
                dunstify -u low "📭  Perfiles" "No hay perfiles guardados"
                continue
            fi
            selected=$(printf "%s" "$profile" | rofi -dmenu -p "    Cargar perfil" -theme-str "$BASE_THEME" -i)
            if [ -n "$selected" ] && [ -f "$PROFILES_DIR/$selected.conf" ]; then
                cp "$PROFILES_DIR/$selected.conf" "$CONF"
                dunstify -u low "  Perfil cargado" "$selected"
            fi ;;
        *"Volver"*)
            exec ~/.config/themes/bin/rofi-settings.sh ;;
        *) exit 0 ;;
    esac
done
