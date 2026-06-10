#!/bin/bash
# ⚙️  Rofi Settings Center — categorías con salto automático a búsqueda
# oxido-i3-themes

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$SCRIPT_DIR/../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../scripts/rofi-builder.sh"
[ -f "$SCRIPT_DIR/rofi-builder.sh" ] && source "$SCRIPT_DIR/rofi-builder.sh"

DIR="${THEMES_ROOT:-$HOME/.config/themes}/scripts/settings"

vol() { pactl get-sink-volume @DEFAULT_SINK@ | sed 's/.* \([0-9]*\)%.*/\1/' | head -1; }
mute_status() { pactl get-sink-mute @DEFAULT_SINK@ | grep -q yes && echo "🔇" || echo "🔊"; }
mic_status() { pactl get-source-mute @DEFAULT_SOURCE@ | grep -q yes && echo "🔴" || echo "🎙️"; }
bright() { brightnessctl -m | cut -d',' -f4 | tr -d '%'; }

# Genera las opciones del buscador plano
opciones_busqueda() {
    v=$(vol); m=$(mute_status); mm=$(mic_status)
    cat <<OPTS
$L_VOL_UP
$L_VOL_DOWN
$m  $L_MUTE
$L_MIXER
$mm  $L_MIC_MUTE
$L_SINK  ▸
$L_BRIGHT_UP
$L_BRIGHT_DOWN
$L_WALL  ▸
$L_DPMS
$L_DND
$L_CLEAR
$L_HIST
$L_NOT_DURATION  ▸
$L_ANIM  ▸
$L_APPEAR  ▸
$L_WALLPAPER  ▸
$L_LOCKSCREEN  ▸
$L_POLY_LAYOUT  ▸
$L_PS
$L_POWER_PROFILE  ▸
$L_CLOCK_FMT  ▸
$L_SSHOT  ▸
$L_WIFI  ▸
$L_BT  ▸
$L_CPICKER
$L_CLIP  ▸
$L_SYSINFO  ▸
$L_LANG
$L_BACK
OPTS
}

mostrar_buscador() {
    local filtro="${1:-}"
    local extra=""
    [ -n "$filtro" ] && extra="-filter $filtro"
    choice=$(opciones_busqueda | rofi -dmenu -p "🔍  Buscar" -i -theme-str "$ROFI_THEME_MAIN" -format s $extra)
    [ -z "$choice" ] && return 1
    base=$(echo "$choice" | sed 's/  |.*//')

    v=$(vol); b=$(bright); m=$(mute_status)
    case "$base" in
        *"$L_VOL_UP"*)          CUR=${v}; [ "$CUR" -lt 100 ] && pactl set-sink-volume @DEFAULT_SINK@ +5% || pactl set-sink-volume @DEFAULT_SINK@ 100%
                                v2=$(vol); dunstify -u low "$L_NOT_VOL" "${v2}%" -h string:x-dunst-stack-tag:audio -h int:value:"${v2}" ;;
        *"$L_VOL_DOWN"*)        pactl set-sink-volume @DEFAULT_SINK@ -5%
                                v2=$(vol); dunstify -u low "$L_NOT_VOL" "${v2}%" -h string:x-dunst-stack-tag:audio -h int:value:"${v2}" ;;
        *"$L_MUTE"*)            pactl set-sink-mute @DEFAULT_SINK@ toggle
                                m2=$(mute_status); [ "$m2" = "🔇" ] && dunstify -u low "🔇  Audio" "$L_NOT_DND_ON" -h string:x-dunst-stack-tag:audio -h int:value:0 ;;
        *"$L_MIXER"*)           pavucontrol & ;;
        *"$L_MIC_MUTE"*)        pactl set-source-mute @DEFAULT_SOURCE@ toggle ;;
        *"$L_SINK"*)            exec "$DIR/sound-sink.sh" "$SCRIPT_DIR/rofi-settings.sh" ;;
        *"$L_BRIGHT_UP"*)       ~/.config/i3/brightness.sh "+5%" ;;
        *"$L_BRIGHT_DOWN"*)     ~/.config/i3/brightness.sh "5%-" ;;
        *"$L_WALL"*)            exec "$DIR/wallpaper.sh" main ;;
        *"$L_DPMS"*)            xset dpms force off; dunstify -u low "$L_DISPLAY" "DPMS off" ;;
        *"$L_DND"*)             ~/.config/themes/scripts/toggle-dnd.sh ;;
        *"$L_CLEAR"*)           dunstctl close-all ;;
        *"$L_HIST"*)            dunstctl history-pop ;;
        *"$L_NOT_DURATION"*)    exec "$DIR/notify.sh" ;;
        *"$L_ANIM"*)            exec "$DIR/animation.sh" ;;
        *"$L_APPEAR"*)          exec "$DIR/appearance.sh" ;;
        *"$L_WALLPAPER"*)       exec "$DIR/wallpaper.sh" main ;;
        *"$L_LOCKSCREEN"*)      exec "$DIR/lockscreen.sh" ;;
        *"$L_POLY_LAYOUT"*)     exec "$DIR/polybar-layout.sh" ;;
        *"$L_PS"*)              ~/.config/themes/scripts/toggle-powersaver.sh ;;
        *"$L_POWER_PROFILE"*)   exec "$DIR/power-profile.sh" "$SCRIPT_DIR/rofi-settings.sh" ;;
        *"$L_CLOCK_FMT"*)       exec "$DIR/clock-format.sh" "$SCRIPT_DIR/rofi-settings.sh" ;;
        *"$L_SSHOT"*)           exec "$DIR/screenshot.sh" "$SCRIPT_DIR/rofi-settings.sh" ;;
        *"$L_WIFI"*)            exec "$DIR/wifi.sh" "$SCRIPT_DIR/rofi-settings.sh" ;;
        *"$L_BT"*)              exec "$DIR/bluetooth.sh" "$SCRIPT_DIR/rofi-settings.sh" ;;
        *"$L_CPICKER"*)         exec "$DIR/colorpicker.sh" ;;
        *"$L_CLIP"*)            exec "$DIR/clipboard.sh" "$SCRIPT_DIR/rofi-settings.sh" ;;
        *"$L_SYSINFO"*)         exec "$DIR/sysinfo.sh" ;;
        *"$L_LANG"*)            exec "$DIR/language.sh" ;;
        *"$L_BACK"*)            return 1 ;;
    esac
    return 0
}

while true; do
    choice=$(cat <<EOF | rofi -dmenu -p "$L_CENTER" -i -theme-str "$ROFI_THEME_MAIN"
$L_APPS
$L_SOUND
$L_DISPLAY
$L_NOTIFY
$L_ANIM
$L_APPEAR
$L_WALLPAPER
$L_POWER
$L_SYSTEM
$L_UTILS
$L_LANG
EOF
    )

    [ -z "$choice" ] && exit 0

    case "$choice" in
        *"$L_APPS"*)    exec "$DIR/default-apps.sh" ;;
        *"$L_SOUND"*)   exec "$DIR/sound.sh" ;;
        *"$L_DISPLAY"*) exec "$DIR/display.sh" ;;
        *"$L_NOTIFY"*)  exec "$DIR/notify.sh" ;;
        *"$L_ANIM"*)    exec "$DIR/animation.sh" ;;
        *"$L_APPEAR"*)  exec "$DIR/appearance.sh" ;;
        *"$L_WALLPAPER"*) exec "$DIR/wallpaper.sh" main ;;
        *"$L_POWER"*)   exec "$DIR/power.sh" ;;
        *"$L_SYSTEM"*)  exec "$DIR/system.sh" ;;
        *"$L_UTILS"*)   exec "$DIR/utils.sh" ;;
        *"$L_LANG"*)    exec "$DIR/language.sh" ;;
        # Si no coincide con ninguna categoría → salta al buscador con el texto escrito
        *)              while mostrar_buscador "$choice"; do :; done ;;
    esac
done
