#!/bin/bash
# Genera previews para los 23 temas: captura real + overlay de paleta de colores
# Layout: btop (arriba), ranger (abajo-izq), nemo (abajo-der)

THEMES_DIR="$HOME/.config/themes"
REPO_DIR="$HOME/Documentos/oxido-i3-themes"
OVERLAY_SCRIPT="$THEMES_DIR/scripts/generate-overlay.py"

THEMES=(
    catppuccin-latte catppuccin-mocha dracula dracula-powersaver
    ethereal everforest flexoki-light gruvbox hackerman kanagawa
    last-horizon lumon matte-black miasma nord osaka-jade
    retro-82 ristretto rose-pine solitude tokyo-night vantablack white
)

# Guardar tamaño de letra original
ORIG_SIZE=$(grep '^size = ' ~/.config/alacritty/alacritty.toml | sed 's/^size = //')
echo "Tamaño de letra original: $ORIG_SIZE"

cleanup() {
    echo "Restaurando tamaño de letra a $ORIG_SIZE..."
    sed -i "s/^size = .*/size = $ORIG_SIZE/" ~/.config/alacritty/alacritty.toml
    i3-msg '[workspace="8"] kill' 2>/dev/null
}
trap cleanup EXIT

cambiar_fuente() {
    sed -i "s/^size = .*/size = $1/" ~/.config/alacritty/alacritty.toml
}

leer_color() {
    local theme=$1 var=$2
    local ini="$THEMES_DIR/themes/$theme/polybar/colors.ini"
    local val=""
    if [ -f "$ini" ]; then
        val=$(grep "^$var = " "$ini" | head -1 | sed 's/.*#//')
    else
        local iconf="$THEMES_DIR/themes/$theme/i3/colors.conf"
        case "$var" in
            background)      local iv="bg" ;;
            background-alt)  local iv="bg-alt" ;;
            foreground)      local iv="fg" ;;
            primary)         local iv="primary" ;;
            secondary)       local iv="secondary" ;;
            alert)           local iv="alert" ;;
            disabled)        local iv="disabled" ;;
            green)           local iv="green" ;;
            yellow)          local iv="yellow" ;;
            pink)            local iv="pink" ;;
        esac
        val=$(grep "^set \$$iv " "$iconf" | head -1 | sed 's/.*#//')
    fi
    echo "$val"
}

# Establecer tamaño 10 para las capturas
cambiar_fuente 10.0
sleep 2

PREVIEW_W=1800
PREVIEW_H=1012
OK=0
FAIL=0

for THEME in "${THEMES[@]}"; do
    echo ""
    echo "╔═══════════════════════════════════════════════════════════"
    echo "║  [$THEME] ($((OK+FAIL+1))/23)"
    echo "╚═══════════════════════════════════════════════════════════"

    if [ ! -d "$THEMES_DIR/themes/$THEME" ]; then
        echo "⚠  Tema no encontrado, saltando..."
        FAIL=$((FAIL+1))
        continue
    fi

    # Cambiar tema
    bash "$THEMES_DIR/bin/theme-switch.sh" "$THEME"
    sleep 3

    # Preparar workspace 8
    i3-msg 'workspace 8' >/dev/null
    sleep 0.3
    i3-msg '[workspace="8"] kill' >/dev/null
    sleep 0.5

    # ─── Layout: btop (top full), ranger (bot-left) + nemo (bot-right) ───
    # 1) Abrir btop → llena workspace
    alacritty -e btop &
    sleep 3

    # 2) splitv sobre btop → divide en vertical, espacio abajo vacío
    i3-msg 'splitv' >/dev/null
    sleep 0.5

    # 3) Abrir ranger → ocupa la mitad inferior
    alacritty -e ranger &
    sleep 2

    # 4) splith sobre ranger → divide en horizontal, espacio a la derecha
    i3-msg 'splith' >/dev/null
    sleep 0.5

    # 5) Abrir nemo → derecha de ranger
    nemo &
    sleep 3

    # Capturar pantalla
    import -window root "/tmp/shot_raw_${THEME}.png"
    if [ ! -f "/tmp/shot_raw_${THEME}.png" ]; then
        echo "✗  [$THEME] Fallo al capturar pantalla"
        i3-msg '[workspace="8"] kill' >/dev/null
        FAIL=$((FAIL+1))
        continue
    fi

    # Redimensionar
    convert "/tmp/shot_raw_${THEME}.png" \
        -resize ${PREVIEW_W}x${PREVIEW_H}^ \
        -gravity center -extent ${PREVIEW_W}x${PREVIEW_H} \
        "/tmp/shot_${THEME}.png"

    # Leer colores del tema
    echo "  Leyendo colores..."
    bg=$(leer_color $THEME background)
    bg_alt=$(leer_color $THEME background-alt)
    fg=$(leer_color $THEME foreground)
    primary=$(leer_color $THEME primary)
    secondary=$(leer_color $THEME secondary)
    alert=$(leer_color $THEME alert)
    disabled=$(leer_color $THEME disabled)
    green=$(leer_color $THEME green)
    yellow=$(leer_color $THEME yellow)
    pink=$(leer_color $THEME pink)

    echo "  bg=$bg bg_alt=$bg_alt fg=$fg primary=$primary"

    # Generar overlay
    W=$(identify -format "%w" "/tmp/shot_${THEME}.png")
    python3 "$OVERLAY_SCRIPT" \
        "$W" "$THEME" \
        "$bg" "$bg_alt" "$fg" "$primary" "$secondary" \
        "$alert" "$disabled" "$green" "$yellow" "$pink" \
        "/tmp/overlay_${THEME}.png"

    if [ ! -f "/tmp/overlay_${THEME}.png" ]; then
        echo "✗  [$THEME] Fallo al generar overlay"
        i3-msg '[workspace="8"] kill' >/dev/null
        FAIL=$((FAIL+1))
        continue
    fi

    # Componer preview final
    convert "/tmp/shot_${THEME}.png" "/tmp/overlay_${THEME}.png" \
        -gravity south -composite "/tmp/preview_${THEME}.png"

    # Copiar a ambas ubicaciones
    cp "/tmp/preview_${THEME}.png" "$REPO_DIR/config/themes/themes/$THEME/preview.png"
    cp "/tmp/preview_${THEME}.png" "$THEMES_DIR/themes/$THEME/preview.png"

    echo "✓  [$THEME] Preview guardada (${PREVIEW_W}x${PREVIEW_H})"
    OK=$((OK+1))

    # Limpiar workspace
    i3-msg '[workspace="8"] kill' >/dev/null
    sleep 1
done

echo ""
echo "╔═══════════════════════════════════════════════════════════"
echo "║  Resumen: $OK ok, $FAIL fallos"
echo "║  Tamaño de letra restaurado a $ORIG_SIZE"
echo "╚═══════════════════════════════════════════════════════════"
