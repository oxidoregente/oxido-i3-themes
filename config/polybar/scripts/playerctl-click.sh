#!/bin/bash
# playerctl-click.sh — Manejador de clicks para nowplaying
# Llama directamente a playerctl play-pause/next sin wrapper
echo "[$(date +%H:%M:%S)] click.sh llamado con: $*" >> /tmp/polybar-click-debug.log
playerctl "$@"
