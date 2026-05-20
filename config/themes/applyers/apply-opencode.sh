#!/bin/bash
# apply-opencode.sh: Aplica el tema de opencode según el tema activo
# Uso: apply-opencode.sh <ruta-al-tema>

THEME_NAME=$(basename "$1")
TUI_CONFIG="$HOME/.config/opencode/tui.json"

cat > "$TUI_CONFIG" << EOF
{
  "\$schema": "https://opencode.ai/tui.json",
  "theme": "$THEME_NAME"
}
EOF
