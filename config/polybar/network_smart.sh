#!/bin/bash

# Interfaces de tu E480
ETH="enp3s0"
WLAN="wlp5s0"

get_bytes() {
    interface=$1
    type=$2 # rx_bytes o tx_bytes
    cat "/sys/class/net/$interface/statistics/${type}" 2>/dev/null || echo 0
}

# Detectar cuál está activa (Prioridad Ethernet)
if [ "$(cat /sys/class/net/$ETH/operstate 2>/dev/null)" = "up" ]; then
    ICON="󰈀"
    IFACE=$ETH
    NAME="Cable"
elif [ "$(cat /sys/class/net/$WLAN/operstate 2>/dev/null)" = "up" ]; then
    ICON=""
    IFACE=$WLAN
    NAME=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)
else
    echo "%{F#ff5555}󰖪 Desconectado%{F-}"
    exit 0
fi

# Calcular velocidad (intervalo de 1s)
R1=$(get_bytes $IFACE rx_bytes)
T1=$(get_bytes $IFACE tx_bytes)
sleep 1
R2=$(get_bytes $IFACE rx_bytes)
T2=$(get_bytes $IFACE tx_bytes)

# Convertir a KB/s
RX=$(( (R2 - R1) / 1024 ))
TX=$(( (T2 - T1) / 1024 ))

echo "$ICON $NAME %{F#8be9fd}󰁝 ${TX}KB/s%{F-} %{F#50fa7b}󰁅 ${RX}KB/s%{F-}"

