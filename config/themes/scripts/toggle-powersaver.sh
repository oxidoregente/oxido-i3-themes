#!/bin/bash
# Toggle PowerSaver Mode — Desactiva picom, conky, pone fondo sólido y polybar mínima
LOCKFILE="/tmp/powersaver-toggle.lock"
STATE_FILE="/tmp/powersaver_active"
CURRENT_LINK="$HOME/.config/themes/current/theme"

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

if [ -f "$STATE_FILE" ]; then
    # SALIR DEL MODO AHORRO → restaurar tema original
    rm -f "$STATE_FILE"

    if [ -f /tmp/powersaver_prev_theme ]; then
        ORIG_THEME=$(cat /tmp/powersaver_prev_theme)
        rm -f /tmp/powersaver_prev_theme
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
    if [ -f /tmp/powersaver_prev_cpu_profile ]; then
        ORIG_CPU=$(cat /tmp/powersaver_prev_cpu_profile)
        rm -f /tmp/powersaver_prev_cpu_profile
        powerprofilesctl set "$ORIG_CPU" 2>/dev/null
    fi

    notify-send "PowerSaver" "☀ Modo normal restaurado"
else
    # ENTRAR EN MODO AHORRO
    touch "$STATE_FILE"

    # Guardar tema actual antes de cambiarlo
    if [ -L "$CURRENT_LINK" ]; then
        ORIG_THEME_DIR=$(readlink -f "$CURRENT_LINK")
        basename "$ORIG_THEME_DIR" > /tmp/powersaver_prev_theme
    fi

    # Guardar perfil de CPU actual y poner ahorro
    powerprofilesctl get > /tmp/powersaver_prev_cpu_profile 2>/dev/null
    powerprofilesctl set power-saver 2>/dev/null

    # Matar picom y conky con wait+force
    killall -q picom conky 2>/dev/null
    timeout=20
    while [ "$timeout" -gt 0 ] && (pgrep -x picom >/dev/null || pgrep -x conky >/dev/null); do
        sleep 0.1
        timeout=$((timeout - 1))
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
        timeout=20
        while [ "$timeout" -gt 0 ] && pgrep -x dunst >/dev/null; do
            sleep 0.1
            timeout=$((timeout - 1))
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

    notify-send "PowerSaver" "🌙 Modo ahorro activado (sin picom, sin conky)"
fi
