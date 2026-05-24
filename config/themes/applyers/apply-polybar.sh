#!/bin/bash
# apply-polybar.sh — Aplica configuración de Polybar (Split Bars)
# oxido-i3-themes
THEME_DIR="$1"
LAYOUT_FILE="$HOME/.config/themes/current-layout"
POSITION_FILE="$HOME/.config/themes/polybar-position"
CONFIG_DST="$HOME/.config/polybar/config.ini"

# Sync layouts from repo if runtime directory missing layouts
LAYOUTS_DIR="$HOME/.config/polybar/layouts"
REPO_LAYOUTS="/home/oxido/Documentos/oxido-i3-themes/config/polybar/layouts"
if [ -d "$REPO_LAYOUTS" ]; then
    mkdir -p "$LAYOUTS_DIR"
    cp --update "$REPO_LAYOUTS"/*.ini "$LAYOUTS_DIR/"
fi

# Sync polybar scripts from repo
REPO_SCRIPTS="/home/oxido/Documentos/oxido-i3-themes/config/polybar/scripts"
SCRIPTS_DST="$HOME/.config/polybar/scripts"
if [ -d "$REPO_SCRIPTS" ]; then
    mkdir -p "$SCRIPTS_DST"
    cp --update "$REPO_SCRIPTS"/*.sh "$SCRIPTS_DST/"
fi

# Read position (default: top)
if [ -f "$POSITION_FILE" ]; then
    POLYBAR_POSITION=$(cat "$POSITION_FILE")
else
    POLYBAR_POSITION="top"
fi
[ "$POLYBAR_POSITION" = "bottom" ] && BOTTOM="true" || BOTTOM="false"

if [ -f "$LAYOUT_FILE" ] && [ -f "$LAYOUTS_DIR/$(cat "$LAYOUT_FILE").ini" ]; then
    LAYOUT_NAME=$(cat "$LAYOUT_FILE")
    if [ -f "$THEME_DIR/polybar/colors.ini" ]; then
        cat "$THEME_DIR/polybar/colors.ini" "$LAYOUTS_DIR/$LAYOUT_NAME.ini" > "$CONFIG_DST"
    else
        cp "$LAYOUTS_DIR/$LAYOUT_NAME.ini" "$CONFIG_DST"
    fi
    # Add 80% transparencia (alpha=33) al background en la sección [colors]
    # para que se adapte al color de cada tema con transparencia uniforme.
    # Elimina cualquier alpha existente (temas como last-horizon ya traen AA)
    # y fuerza 33 (20% opacidad = 80% transparente).
    # SED LIMITADO a [colors] — NO inlinea en las barras.
    bg_line=$(sed -n '/^\[colors\]/,/^\[/{/^background *=/p}' "$CONFIG_DST" | head -1)
    if [ -n "$bg_line" ]; then
        bg_val=$(echo "$bg_line" | sed 's/^background *= *//; s/ *$//')
        # Strip any existing alpha (8 hex chars) to get base 6-char color
        base_color=$(echo "$bg_val" | sed -n 's/^\(#[0-9a-fA-F]\{6\}\).*/\1/p')
        if [ -n "$base_color" ]; then
            sed -i "/^\[colors\]/,/^\[/{s/^background *=.*/background = ${base_color}33/}" "$CONFIG_DST"
        fi
    fi

    # Remove tray-position = none (conflicts with internal/tray module)
    sed -i '/^tray-position *= *none/d' "$CONFIG_DST"

    # Inject bottom, transparent, and override-redirect in all bar sections
    # override-redirect se omite si el layout ya lo define (split bars: left/center/player=true, right=false)
    # Para layouts single-bar ([bar/top]), override-redirect=false es default y el tray module funciona
    for bar in $(grep "^\[bar/" "$CONFIG_DST" | sed 's/\[bar\/\(.*\)\]/\1/'); do
        sed -i "/^\[bar\/$bar\]/a bottom = $BOTTOM" "$CONFIG_DST"
        if ! sed -n "/^\[bar\/$bar\]/,/^\[bar\//p" "$CONFIG_DST" | grep -q "transparent"; then
            sed -i "/^\[bar\/$bar\]/a transparent = true" "$CONFIG_DST"
        fi
        if ! sed -n "/^\[bar\/$bar\]/,/^\[bar\//p" "$CONFIG_DST" | grep -q "override-redirect"; then
            sed -i "/^\[bar\/$bar\]/a override-redirect = false" "$CONFIG_DST"
        fi
    done
elif [ -f "$THEME_DIR/polybar/config.ini" ]; then
    cp "$THEME_DIR/polybar/config.ini" "$CONFIG_DST"
else
    cp "$THEME_DIR/polybar/colors.ini" "$CONFIG_DST"
fi

~/.config/polybar/launch.sh
