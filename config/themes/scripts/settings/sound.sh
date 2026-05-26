#!/bin/bash
# 🔊  Sound settings
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIR="$SCRIPT_DIR"
[ -f "$SCRIPT_DIR/../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../scripts/rofi-builder.sh"
[ -f "$SCRIPT_DIR/../../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../../scripts/rofi-builder.sh"

vol() { pactl get-sink-volume @DEFAULT_SINK@ | sed 's/.* \([0-9]*\)%.*/\1/' | head -1; }
mute() { pactl get-sink-mute @DEFAULT_SINK@ | grep -q yes && echo "🔇" || echo "🔊"; }
mic_mute() { pactl get-source-mute @DEFAULT_SOURCE@ | grep -q yes && echo "🔴" || echo "🎙️"; }

while true; do
    v=$(vol); m=$(mute); mm=$(mic_mute)
    choice=$(cat <<EOF | rofi -dmenu -p "$L_SOUND" -theme-str "$ROFI_THEME_MAIN" -i
$L_VOL_UP  |  ${v}%
$L_VOL_DOWN  |  ${v}%
$m  $L_MUTE
$L_MIXER
$mm  $L_MIC_MUTE
$L_SINK  ▸
$L_BACK
EOF
    )
    action=$(echo "$choice" | sed 's/  |.*//')
    case "$action" in
        *"$L_VOL_UP"*)
            CUR=${v}
            if [ "$CUR" -lt 100 ]; then
                pactl set-sink-volume @DEFAULT_SINK@ +5%
            else
                pactl set-sink-volume @DEFAULT_SINK@ 100%
            fi
            dunstify -u low "$L_NOT_VOL" "$(vol)%" -h string:x-dunst-stack-tag:audio -h int:value:"$(vol)" ;;
        *"$L_VOL_DOWN"*)
            pactl set-sink-volume @DEFAULT_SINK@ -5%
            dunstify -u low "$L_NOT_VOL" "$(vol)%" -h string:x-dunst-stack-tag:audio -h int:value:"$(vol)" ;;
        *"$L_MUTE"*)
            pactl set-sink-mute @DEFAULT_SINK@ toggle
            [ "$(mute)" = "🔇" ] && dunstify -u low "🔇  Audio" "$L_NOT_DND_ON" -h string:x-dunst-stack-tag:audio -h int:value:0
            ;;
        *"$L_MIXER"*)
            pavucontrol & ;;
        *"$L_MIC_MUTE"*)
            pactl set-source-mute @DEFAULT_SOURCE@ toggle ;;
        *"$L_SINK"*)
            exec "$DIR/sound-sink.sh" "$DIR/sound.sh" ;;
        *"$L_BACK"*)
            exec ~/.config/themes/bin/rofi-settings.sh ;;
        *) exec ~/.config/themes/bin/rofi-settings.sh ;;
    esac
done
