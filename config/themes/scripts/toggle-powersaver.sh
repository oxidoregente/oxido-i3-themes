#!/bin/bash
# Toggle PowerSaver Mode — Desactiva picom, conky, pone fondo sólido y polybar mínima
# oxido-i3-themes
LOCKFILE="/tmp/powersaver-toggle.lock"
STATE_DIR="$HOME/.config/themes/state"
STATE_FILE="$STATE_DIR/powersaver_active"
PREV_THEME_FILE="$STATE_DIR/powersaver_prev_theme"
PREV_PROFILE_FILE="$STATE_DIR/powersaver_prev_profile"
CURRENT_LINK="$HOME/.config/themes/current/theme"

mkdir -p "$STATE_DIR"

lockfile_clean() {
    if [ -d "$LOCKFILE" ]; then
        LOCK_PID=$(cat "$LOCKFILE/pid" 2>/dev/null || echo 0)
        if [ "$LOCK_PID" -gt 0 ] 2>/dev/null && kill -0 "$LOCK_PID" 2>/dev/null; then
            exit 0
        fi
        rm -rf "$LOCKFILE"
    fi
}

lockfile_create() {
    lockfile_clean
    mkdir "$LOCKFILE" 2>/dev/null || exit 0
    echo "$$" > "$LOCKFILE/pid"
}

lockfile_create
trap 'rm -rf "$LOCKFILE"' EXIT

# Source language
[ -f "$HOME/.config/themes/lang/active_lang.env" ] && source "$HOME/.config/themes/lang/active_lang.env"
[ -z "$LANG" ] && LANG="es"
[ -f "$HOME/.config/themes/lang/${LANG}.sh" ] && source "$HOME/.config/themes/lang/${LANG}.sh"

# Matar monitores antes de cualquier cambio
pkill -f "player-monitor.sh" 2>/dev/null
pkill -f "fullscreen-monitor.sh" 2>/dev/null

# ─── MODO RESTORE (re-aplicar powersaver desde startup) ───
if [ "$1" = "--restore" ]; then
    if [ ! -f "$STATE_FILE" ]; then
        exit 0
    fi
    # Re-aplicar sin toggle: matar picom/conky, aplicar tema, polybar
    killall -q picom conky 2>/dev/null
    sleep 0.3
    pgrep -x picom >/dev/null && pkill -9 -x picom 2>/dev/null
    pgrep -x conky >/dev/null && pkill -9 -x conky 2>/dev/null

    THEME_DIR="$HOME/.config/themes/themes/dracula-powersaver"
    if [ -d "$THEME_DIR" ]; then
        cp "$THEME_DIR/polybar/config.ini" "$HOME/.config/polybar/config.ini"
        cp "$THEME_DIR/i3/colors.conf" "$HOME/.config/i3/colors.conf"
        cp "$THEME_DIR/dunst/dunstrc" "$HOME/.config/dunst/dunstrc"
        cp "$THEME_DIR/rofi/config.rasi" "$HOME/.config/rofi/config.rasi"

        killall -q dunst 2>/dev/null
        TIMEOUT=20
        while [ "$TIMEOUT" -gt 0 ] && pgrep -x dunst >/dev/null; do
            sleep 0.1
            TIMEOUT=$((TIMEOUT - 1))
        done
        dunst 2>/dev/null &

        if command -v nitrogen &>/dev/null; then
            if [ -f "$THEME_DIR/backgrounds/wallpaper.jpg" ]; then
                nitrogen --set-zoom-fill "$THEME_DIR/backgrounds/wallpaper.jpg" 2>/dev/null
            else
                convert -size 1920x1080 xc:'#1a1a2e' /tmp/powersaver_bg.png 2>/dev/null
                nitrogen --set-zoom-fill /tmp/powersaver_bg.png 2>/dev/null
            fi
        fi
    fi

    ~/.config/polybar/launch.sh 2>/dev/null || polybar-msg cmd restart
    exit 0
fi

# ─── TOGGLE ───
if [ -f "$STATE_FILE" ]; then
    # SALIR DEL MODO AHORRO → restaurar tema original
    rm -f "$STATE_FILE"

    if [ -f "$PREV_THEME_FILE" ]; then
        ORIG_THEME=$(cat "$PREV_THEME_FILE")
        rm -f "$PREV_THEME_FILE"
        bash "$HOME/.config/themes/bin/theme-switch.sh" "$ORIG_THEME"
    else
        if command -v picom &>/dev/null; then
            picom --config "$HOME/.config/picom/picom.conf" -b 2>/dev/null &
            disown
        fi
        if [ -f "$HOME/.config/themes/conky-enabled" ]; then
            conky -c "$HOME/.config/conky/conky.conf" 2>/dev/null &
            disown
        fi
        ~/.config/polybar/launch.sh 2>/dev/null || polybar-msg cmd restart
    fi

    # Restaurar perfil de CPU original
    if [ -f "$PREV_PROFILE_FILE" ]; then
        ORIG_CPU=$(cat "$PREV_PROFILE_FILE")
        rm -f "$PREV_PROFILE_FILE"
        bash "$HOME/.config/themes/scripts/set-power-profile.sh" set "$ORIG_CPU"
    fi

    dunstify -a "oxido_system" -u low \
        -h string:x-dunst-stack-tag:powersaver \
        -i "" "PowerSaver" "${L_PS_OFF:-☀ PowerSaver desactivado}"
else
    # ENTRAR EN MODO AHORRO
    touch "$STATE_FILE"

    echo "$$" > "$STATE_FILE"

    # Guardar tema actual antes de cambiarlo
    if [ -L "$CURRENT_LINK" ]; then
        ORIG_THEME_DIR=$(readlink -f "$CURRENT_LINK")
        basename "$ORIG_THEME_DIR" > "$PREV_THEME_FILE"
    fi

    # Guardar perfil de CPU actual y poner ahorro
    bash "$HOME/.config/themes/scripts/set-power-profile.sh" get > "$PREV_PROFILE_FILE" 2>/dev/null
    bash "$HOME/.config/themes/scripts/set-power-profile.sh" set power-saver

    # Matar picom y conky de forma elegante
    killall -q picom conky 2>/dev/null
    TIMEOUT=20
    while [ "$TIMEOUT" -gt 0 ] && (pgrep -x picom >/dev/null || pgrep -x conky >/dev/null); do
        sleep 0.1
        TIMEOUT=$((TIMEOUT - 1))
    done

    pgrep -x picom >/dev/null && pkill -9 -x picom 2>/dev/null
    pgrep -x conky >/dev/null && pkill -9 -x conky 2>/dev/null

    # Aplicar tema powersaver
    THEME_DIR="$HOME/.config/themes/themes/dracula-powersaver"
    if [ -d "$THEME_DIR" ]; then
        rm -f "$CURRENT_LINK"
        ln -s "$THEME_DIR" "$CURRENT_LINK"

        cp "$THEME_DIR/polybar/config.ini" "$HOME/.config/polybar/config.ini"
        cp "$THEME_DIR/i3/colors.conf" "$HOME/.config/i3/colors.conf"
        cp "$THEME_DIR/dunst/dunstrc" "$HOME/.config/dunst/dunstrc"
        cp "$THEME_DIR/rofi/config.rasi" "$HOME/.config/rofi/config.rasi"

        killall -q dunst 2>/dev/null
        TIMEOUT=20
        while [ "$TIMEOUT" -gt 0 ] && pgrep -x dunst >/dev/null; do
            sleep 0.1
            TIMEOUT=$((TIMEOUT - 1))
        done
        dunst 2>/dev/null &

        # Fondo sólido oscuro
        if command -v nitrogen &>/dev/null; then
            if [ -f "$THEME_DIR/backgrounds/wallpaper.jpg" ]; then
                nitrogen --set-zoom-fill "$THEME_DIR/backgrounds/wallpaper.jpg" 2>/dev/null
            else
                convert -size 1920x1080 xc:'#1a1a2e' /tmp/powersaver_bg.png 2>/dev/null
                nitrogen --set-zoom-fill /tmp/powersaver_bg.png 2>/dev/null
            fi
        fi
    fi

    # Polybar minimalista
    ~/.config/polybar/launch.sh 2>/dev/null || polybar-msg cmd restart

    dunstify -a "oxido_system" -u low \
        -h string:x-dunst-stack-tag:powersaver \
        -i "" "PowerSaver" "${L_PS_ON:-🌙 PowerSaver activado}"
fi
