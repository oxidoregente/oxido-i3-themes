#!/bin/bash

# Función para convertir unidades a Bits (x8)
format_speed() {
    local bytes=$1
    # Convertimos Bytes a Bits
    local bits=$((bytes * 8))
    
    if [ "$bits" -gt 1000000 ]; then
        # Mbps (Megabits) con un decimal
        val=$(echo "scale=1; $bits / 1000000" | bc -l)
        LC_NUMERIC=C printf "%.1f Mbps" "$val"
    else
        # Kbps (Kilobits)
        echo "$((bits / 1000)) Kbps"
    fi
}

read_bytes() {
    awk '{rx += $2; tx += $10} END {print rx, tx}' /proc/net/dev
}

# Lectura inicial
read1=$(read_bytes)
sleep 1
# Segunda lectura
read2=$(read_bytes)

rx1=$(echo $read1 | cut -d' ' -f1)
tx1=$(echo $read1 | cut -d' ' -f2)
rx2=$(echo $read2 | cut -d' ' -f1)
tx2=$(echo $read2 | cut -d' ' -f2)

down=$((rx2 - rx1))
up=$((tx2 - tx1))

echo "%{F#50fa7b}↓%{F-} $(format_speed $down)  %{F#8be9fd}↑%{F-} $(format_speed $up)"
