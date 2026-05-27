#!/bin/bash
# apply-polybar.sh — Aplica configuración de Polybar (Split Bars)
# oxido-i3-themes
THEME_DIR="$1"
LAYOUT_FILE="$HOME/.config/themes/current-layout"
POSITION_FILE="$HOME/.config/themes/polybar-position"
CONFIG_DST="$HOME/.config/polybar/config.ini"

# Detect repo root from script location (applyers/ → themes/ → config/ → repo root)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# Sync layouts from repo if runtime directory missing layouts
LAYOUTS_DIR="$HOME/.config/polybar/layouts"
REPO_LAYOUTS="$REPO_ROOT/config/polybar/layouts"
if [ -d "$REPO_LAYOUTS" ]; then
    mkdir -p "$LAYOUTS_DIR"
    cp --update "$REPO_LAYOUTS"/*.ini "$LAYOUTS_DIR/"
fi

# Sync polybar scripts from repo
REPO_SCRIPTS="$REPO_ROOT/config/polybar/scripts"
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
    # Añade alpha=99 (~60% opaco) al background en la sección [colors]
    # para que el fondo de la barra sea semi-opaco pero las burbujas
    # (que usan bubble-ws/center/sys, no ${colors.background}) conserven
    # su color sólido. Elimina cualquier alpha existente y fuerza 99.
    # SED LIMITADO a [colors] — NO inlinea en las barras.
    bg_line=$(sed -n '/^\[colors\]/,/^\[/{/^background *=/p}' "$CONFIG_DST" | head -1)
    if [ -n "$bg_line" ]; then
        bg_val=$(echo "$bg_line" | sed 's/^background *= *//; s/ *$//')
        # Strip any existing alpha (8 hex chars) to get base 6-char color
        base_color=$(echo "$bg_val" | sed -n 's/^\(#[0-9a-fA-F]\{6\}\).*/\1/p')
        if [ -n "$base_color" ]; then
            sed -i "/^\[colors\]/,/^\[/{s/^background *=.*/background = ${base_color}CC/}" "$CONFIG_DST"
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

    # Inject date format (12h/24h) en todos los [module/date]
    FMT_FILE="$HOME/.config/themes/date-format"
    if [ -f "$FMT_FILE" ]; then
        DFMT=$(cat "$FMT_FILE")
        if [ "$DFMT" = "24h" ]; then
            sed -i "/^\[module\/date\]/,/^\[module\//{s/^date *=.*/date = %H:%M/}" "$CONFIG_DST"
        else
            sed -i "/^\[module\/date\]/,/^\[module\//{s/^date *=.*/date = %I:%M %p/}" "$CONFIG_DST"
        fi
    fi
elif [ -f "$THEME_DIR/polybar/config.ini" ]; then
    cp "$THEME_DIR/polybar/config.ini" "$CONFIG_DST"
elif [ -f "$THEME_DIR/polybar/colors.ini" ]; then
    cp "$THEME_DIR/polybar/colors.ini" "$CONFIG_DST"
fi

# Ensure config has at least one bar section, otherwise create a minimal default
if ! grep -q "^\[bar/" "$CONFIG_DST" 2>/dev/null; then
    cat >> "$CONFIG_DST" << 'DEFAULTBAR'

[bar/top]
width = 100%
height = 34
dpi = 96
background = ${colors.background}
foreground = ${colors.foreground}
font-0 = "JetBrainsMono Nerd Font Mono:size=11;3"
modules-left = xworkspaces
modules-center = date
modules-right = pulseaudio battery tray

[module/xworkspaces]
type = internal/xworkspaces
pin-workspaces = true
label-active = %name%
label-occupied = %name%
label-empty = %name%

[module/date]
type = internal/date
interval = 1
date = %H:%M
date-alt = %A, %d %B %Y

[module/pulseaudio]
type = internal/pulseaudio

[module/battery]
type = internal/battery
battery = BAT0
adapter = AC0
full-at = 98
format-charging = <animation-charging> %percentage%
format-discharging = <animation-discharging> %percentage%

[module/tray]
type = internal/tray
DEFAULTBAR
fi

~/.config/polybar/launch.sh
