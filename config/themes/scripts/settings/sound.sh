#!/bin/bash
# 🔊  Sound settings
DIR=~/.config/themes/scripts/settings
BASE_THEME=$(cat "$DIR/.rasi-base" 2>/dev/null || echo '* { font: "FiraCode Nerd Font 10"; }
window { width: 400; border-radius: 16px; background-color: #1e1e2e; }
mainbox { children: [listview]; spacing: 4px; padding: 8px; }
listview { spacing: 4px; dynamic: true; }
element { border-radius: 10px; padding: 10px 14px; background-color: #313244; text-color: #cdd6f4; }
element selected { background-color: #89b4fa; text-color: #1e1e2e; }
element-icon { size: 1.2em; }
element-text { horizontal-align: 0.5; }')

vol() { pactl get-sink-volume @DEFAULT_SINK@ | sed 's/.* \([0-9]*\)%.*/\1/' | head -1; }
mute() { pactl get-sink-mute @DEFAULT_SINK@ | grep -q yes && echo "🔇" || echo "🔊"; }
mic_mute() { pactl get-source-mute @DEFAULT_SOURCE@ | grep -q yes && echo "🔴" || echo "🎙️"; }

while true; do
    v=$(vol); m=$(mute); mm=$(mic_mute)
    choice=$(cat <<EOF | rofi -dmenu -p "  🔊  Sonido" -theme-str "$BASE_THEME" -i
  Subir volumen  |  ${v}%
  Bajar volumen  |  ${v}%
$m  Silenciar / Activar
  Mezclador (pavucontrol)
$mm  Silenciar micrófono
  Salida de audio ▸
⬅️  Volver
EOF
    )
    action=$(echo "$choice" | sed 's/  |.*//')
    case "$action" in
        "  Subir volumen")
            CUR=${v}
            if [ "$CUR" -lt 100 ]; then
                pactl set-sink-volume @DEFAULT_SINK@ +5%
            else
                pactl set-sink-volume @DEFAULT_SINK@ 100%
            fi
            dunstify -u low "  Volumen" "$(vol)%" -h string:x-dunst-stack-tag:audio -h int:value:"$(vol)" ;;
        "  Bajar volumen")
            pactl set-sink-volume @DEFAULT_SINK@ -5%
            dunstify -u low "  Volumen" "$(vol)%" -h string:x-dunst-stack-tag:audio -h int:value:"$(vol)" ;;
        *"Silenciar / Activar")
            pactl set-sink-mute @DEFAULT_SINK@ toggle
            [ "$(mute)" = "🔇" ] && dunstify -u low "🔇  Audio" "Silenciado" -h string:x-dunst-stack-tag:audio -h int:value:0
            ;;
        *"pavucontrol")
            pavucontrol & ;;
        *"micrófono")
            pactl set-source-mute @DEFAULT_SOURCE@ toggle ;;
        *"Salida de audio"*)
            exec "$DIR/sound-sink.sh" ;;
        *"Volver"*)
            exec ~/.config/themes/bin/rofi-settings.sh ;;
        *) exit 0 ;;
    esac
done
