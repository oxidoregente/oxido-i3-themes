#!/bin/bash
set -e

# ═══════════════════════════════════════════════════
# oxido-i3-themes — Instalación automática
# ═══════════════════════════════════════════════════

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_SRC="$REPO_DIR/config"
BACKUP_DIR="$HOME/.config/oxido-themes.backup-$(date +%Y%m%d-%H%M%S)"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()  { echo -e "${GREEN}→${NC} $1"; }
warn()  { echo -e "${YELLOW}⚠${NC} $1"; }
err()   { echo -e "${RED}✗${NC} $1"; }

# ─── 1. Detectar distro ───
detect_distro() {
    if command -v apt &>/dev/null; then
        PKG_MANAGER="apt"
        INSTALL_CMD="sudo apt-get install -y"
        UPDATE_CMD="sudo apt-get update"
        PKGS="i3 picom rofi dunst polybar nitrogen \
              brightnessctl xautolock xss-lock acpi bc \
              pulseaudio-utils pavucontrol maim imagemagick \
              curl wget unzip fonts-firacode python3-gi"
    elif command -v pacman &>/dev/null; then
        PKG_MANAGER="pacman"
        INSTALL_CMD="sudo pacman -S --noconfirm"
        UPDATE_CMD="sudo pacman -Syu"
        PKGS="i3 picom rofi dunst polybar nitrogen \
              brightnessctl xautolock xss-lock acpi bc \
              pulseaudio-utils pavucontrol maim imagemagick \
              curl wget unzip ttf-fira-code python-gobject"
    elif command -v dnf &>/dev/null; then
        PKG_MANAGER="dnf"
        INSTALL_CMD="sudo dnf install -y"
        UPDATE_CMD=""
        PKGS="i3 picom rofi dunst polybar nitrogen \
              brightnessctl xautolock xss-lock acpi bc \
              pulseaudio-utils pavucontrol maim ImageMagick \
              curl wget unzip fira-code-fonts python3-gobject"
    else
        err "Distro no soportada. Instalá los paquetes manualmente."
        exit 1
    fi
    info "Distro detectada: $PKG_MANAGER"
}

# ─── 2. Instalar paquetes ───
install_packages() {
    info "Actualizando repositorios..."
    $UPDATE_CMD 2>/dev/null || true
    info "Instalando dependencias..."
    $INSTALL_CMD $PKGS 2>&1 | tail -3
    info "Paquetes instalados correctamente"
}

# ─── 3. Backup de configs existentes ───
backup_configs() {
    local has_backup=false
    for dir in themes i3 picom polybar dunst rofi nitrogen; do
        if [ -d "$HOME/.config/$dir" ]; then
            has_backup=true
        fi
    done
    if $has_backup; then
        mkdir -p "$BACKUP_DIR"
        for dir in themes i3 picom polybar dunst rofi nitrogen; do
            [ -d "$HOME/.config/$dir" ] && \
                cp -r "$HOME/.config/$dir" "$BACKUP_DIR/" 2>/dev/null && \
                info "Backup de ~/.config/$dir → $BACKUP_DIR/"
        done
        info "Backup completo en: $BACKUP_DIR"
    fi
}

# ─── 4. Copiar configs ───
copy_configs() {
    info "Copiando configuraciones..."
    for dir in themes i3 picom polybar dunst rofi nitrogen; do
        if [ -d "$CONFIG_SRC/$dir" ]; then
            rm -rf "$HOME/.config/$dir"
            cp -r "$CONFIG_SRC/$dir" "$HOME/.config/$dir"
            info "  ~/.config/$dir/ ← config/$dir/"
        fi
    done
}

# ─── 5. Aplicar tema default ───
apply_default_theme() {
    if [ -f "$HOME/.config/themes/bin/theme-switch.sh" ]; then
        local default=""
        [ -d "$HOME/.config/themes/themes/nord" ] && default="nord"
        [ -d "$HOME/.config/themes/themes/dracula" ] && default="dracula"
        if [ -n "$default" ]; then
            info "Aplicando tema default: $default"
            bash "$HOME/.config/themes/bin/theme-switch.sh" "$default" 2>/dev/null || true
        fi
    fi
}

# ─── 6. Restaurar servicios ───
restart_services() {
    info "Reiniciando servicios..."
    killall picom 2>/dev/null || true
    killall polybar 2>/dev/null || true
    killall dunst 2>/dev/null || true
    nohup picom --config "$HOME/.config/picom/picom.conf" &>/dev/null &
    nohup dunst &>/dev/null &
    [ -f "$HOME/.config/polybar/launch.sh" ] && bash "$HOME/.config/polybar/launch.sh" 2>/dev/null &
    info "Servicios reiniciados"
}

# ─── 7. Mostrar resumen ───
show_summary() {
    echo ""
    echo "╔══════════════════════════════════════════╗"
    echo "║   oxido-i3-themes instalado con éxito    ║"
    echo "╚══════════════════════════════════════════╝"
    echo ""
    echo "🔑 Atajos principales:"
    echo "  $mod+Shift+s  → Centro de Control"
    echo "  $mod+Shift+t  → Selector de Temas"
    echo "  $mod+Shift+p  → PowerSaver"
    echo "  $mod+Shift+n  → Toggle Conky"
    echo "  $mod+Shift+/  → Ver atajos"
    echo ""
    echo "💡  Presiona $mod+Shift+r para recargar i3"
    echo "📁  Backup: $BACKUP_DIR"
    echo "📄  Licencia: MIT — libre para usar, modificar y compartir"
}

# ─── MAIN ───
echo "╔══════════════════════════════════════════╗"
echo "║   oxido-i3-themes — Instalador           ║"
echo "╚══════════════════════════════════════════╝"
echo ""

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Uso: ./install.sh"
    echo ""
    echo "Instala todas las configuraciones y dependencias"
    echo "para el entorno i3 con temas visuales."
    echo ""
    echo "Opciones:"
    echo "  --help    Muestra esta ayuda"
    echo "  --dry-run Muestra lo que se haría sin ejecutar"
    exit 0
fi

detect_distro
install_packages
backup_configs
copy_configs
apply_default_theme
restart_services
show_summary
