#!/bin/bash
#  ️ System information via notification
INFO=$(cat <<EOF
🏠  Host: $(hostname)
👤  Usuario: $(whoami)
🏗️  SO: $(lsb_release -sd 2>/dev/null || uname -sr)
🧠  Kernel: $(uname -r)
⏱️  Tiempo activo: $(uptime -p | sed 's/up //')
🔥  CPU: $(lscpu 2>/dev/null | grep "Model name" | sed 's/.*: *//' | head -c 50)
💾  RAM: $(free -h | awk '/Mem:/ {print $3 "/" $2}')
💿  Disco: $(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')
🖥️  Resolución: $(xdpyinfo 2>/dev/null | grep dimensions | awk '{print $2}' | head -1)
🎵  Audio: $(pactl info 2>/dev/null | grep "Default Sink" | awk '{print $3}')
EOF
)

dunstify -u low "󰍹  Sistema" "$INFO"
