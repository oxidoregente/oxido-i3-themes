#!/bin/bash
# Cava para Polybar - script continuo con FIFO y auto-hide
# Requiere: tail=true en el módulo polybar

FIFO="/tmp/cava-polybar.fifo"
CONFIG="/tmp/cava-polybar.conf"
CAVA_PID_FILE="/tmp/cava-polybar.pid"

cleanup() {
    [ -f "$CAVA_PID_FILE" ] && kill "$(cat "$CAVA_PID_FILE")" 2>/dev/null
    rm -f "$FIFO" "$CONFIG" "$CAVA_PID_FILE"
}
trap cleanup EXIT

# Crear FIFO
[ -p "$FIFO" ] || mkfifo "$FIFO"

# Escribir config de cava
cat > "$CONFIG" << 'CAVACFG'
[general]
bars = 10
framerate = 30
autosens = 1

[input]
method = pulse
source = auto

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 8
bar_delimiter = 32
frame_delimiter = 10

[smoothing]
noise_reduction = 20
integral = 0
CAVACFG

# Iniciar cava en background
cava -p "$CONFIG" > "$FIFO" 2>/dev/null &
echo $! > "$CAVA_PID_FILE"

# Mapa de números a caracteres de bloque
MAP='s/0/ /g; s/1/▁/g; s/2/▂/g; s/3/▃/g; s/4/▄/g; s/5/▅/g; s/6/▆/g; s/7/▇/g; s/8/█/g; s/9/█/g'

# Loop de lectura continua (tail=true en polybar mantiene esto vivo)
SILENT=0
while read -r line; do
    # Ignorar líneas vacías
    [ -z "$line" ] && continue
    
    # Detectar silencio (todo ceros o espacios)
    clean="${line// /}"
    if [ -z "$clean" ] || [[ "$line" =~ ^[0\ ]+$ ]]; then
        SILENT=$((SILENT + 1))
        if [ "$SILENT" -gt 15 ]; then
            echo " "
            continue
        fi
    else
        SILENT=0
    fi
    
    # Transformar a caracteres de bloque
    echo "$line" | sed "$MAP"
done < "$FIFO"