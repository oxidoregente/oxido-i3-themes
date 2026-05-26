#!/bin/bash
# 📱  Aplicaciones predeterminadas
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIR="$SCRIPT_DIR"
[ -f "$SCRIPT_DIR/../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../scripts/rofi-builder.sh"
[ -f "$SCRIPT_DIR/../../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../../scripts/rofi-builder.sh"

ROFI_APPS="$ROFI_THEME_SUB"

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

    selected=$(printf "%s" "$choices" | rofi -dmenu -p "  $desc" -theme-str "$ROFI_APPS" -i -selected-row 0)
    if [ "$selected" = "✏️  Otra..." ]; then
        selected=$(echo "" | rofi -dmenu -p "  Escribe el comando" -theme-str "$ROFI_APPS")
    fi
    echo "$selected"
}

while true; do
    load_config
    choice=$(cat <<EOF | rofi -dmenu -p "  📱  Aplicaciones" -theme-str "$ROFI_APPS" -i
  Terminal        |  $TERMINAL
  Navegador       |  $BROWSER
  Archivos (GUI)  |  $FILE_MANAGER
  Archivos (CLI)  |  $TERMINAL_FILE_MANAGER
  Guardar perfil
  Cargar perfil
$L_BACK
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
            name=$(echo "" | rofi -dmenu -p "  Nombre del perfil" -theme-str "$ROFI_APPS")
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
            selected=$(printf "%s" "$profile" | rofi -dmenu -p "    Cargar perfil" -theme-str "$ROFI_APPS" -i)
            if [ -n "$selected" ] && [ -f "$PROFILES_DIR/$selected.conf" ]; then
                cp "$PROFILES_DIR/$selected.conf" "$CONF"
                dunstify -u low "  Perfil cargado" "$selected"
            fi ;;
        *"$L_BACK"*)
            exec ~/.config/themes/bin/rofi-settings.sh ;;
        *) exec ~/.config/themes/bin/rofi-settings.sh ;;
    esac
done
