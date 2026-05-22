#!/bin/bash
# animation-picker.sh — Configura animaciones para picom v13
# Uso: animation-picker.sh <trigger> <preset> [key=value ...] [--target <app>]
#       animation-picker.sh preset <nombre>
#       animation-picker.sh help
#
# Triggers: open, close, show, hide, geometry
# Presets: appear, disappear, fly-in, fly-out, slide-in, slide-out, geometry-change
# Targets: global (default), Alacritty, Firefox, Rofi, Dunst
# Presets nombre: clasico, gnome, macos, win11, snap
#
# Ejemplos:
#   animation-picker.sh close disappear
#   animation-picker.sh close fly-out direction=down duration=0.25
#   animation-picker.sh open appear scale=0.92 --target Alacritty
#   animation-picker.sh preset gnome

PICOM_DST="$HOME/.config/picom/picom.conf"
CURRENT_LINK="$HOME/.config/themes/current/theme"

show_help() {
    cat << EOF
Uso: animation-picker.sh <trigger> <preset> [parametros] [--target <app>]
     animation-picker.sh preset <nombre>
     animation-picker.sh help

Disparadores (trigger): open (abrir), close (cerrar), show, hide, geometry
Animaciones (preset):
  appear        — Aparecer (zoom)
  disappear     — Desaparecer (zoom inverso)
  fly-in        — Entrar volando
  fly-out       — Salir volando
  slide-in      — Entrar deslizando
  slide-out     — Salir deslizando
Parámetros: scale=<float> direction=<string> duration=<float>
Target: global (por defecto), Alacritty, Firefox, Rofi, Dunst
Presets completos: clasico, gnome, macos, win11, snap

Ejemplos:
  animation-picker.sh close disappear
  animation-picker.sh close fly-out direction=down duration=0.25
  animation-picker.sh open appear scale=0.92 duration=0.22 --target Alacritty
  animation-picker.sh preset gnome
EOF
}

# --- Argument parsing ---
TRIGGER=""
PRESET=""
TARGET=""
PARAMS=""
MODE="trigger"

while [ $# -gt 0 ]; do
    case "$1" in
        preset) MODE="preset"; PRESET_NAME="$2"; shift 2 ;;
        --target|-t) TARGET="$2"; shift 2 ;;
        help|--help|-h) show_help; exit 0 ;;
        *)
            if [ -z "$TRIGGER" ]; then
                TRIGGER="$1"
            elif [ -z "$PRESET" ]; then
                PRESET="$1"
            else
                PARAMS="$PARAMS $1"
            fi
            shift ;;
    esac
done

if [ "$MODE" = "preset" ]; then
    [ -z "$PRESET_NAME" ] && { echo "Error: nombre de preset requerido"; exit 1; }
    echo "=== Animation Picker → Preset: $PRESET_NAME ==="
else
    [ -z "$TRIGGER" ] && { echo "Error: trigger requerido"; show_help; exit 1; }
    [ -z "$PRESET" ] && { echo "Error: preset requerido"; show_help; exit 1; }
    echo "=== Animation Picker → $TRIGGER: $PRESET (destino: ${TARGET:-global}) ==="
fi

# Compute source paths for centralized includes
PICKER_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$PICKER_DIR/../../.." && pwd)"
GLOBAL_SRC="$REPO_ROOT/config/themes/animations/global.picom"
RULES_SRC="$REPO_ROOT/config/themes/animations/rules.picom"

export MODE TRIGGER PRESET TARGET PARAMS PRESET_NAME PICOM_DST CURRENT_LINK
export GLOBAL_SRC RULES_SRC

output=$(python3 << 'PYEOF'
import os, re

MODE = os.environ.get('MODE', '')
TRIGGER = os.environ.get('TRIGGER', '')
PRESET = os.environ.get('PRESET', '')
TARGET = os.environ.get('TARGET', '')
PARAMS_STR = os.environ.get('PARAMS', '').strip()
PRESET_NAME = os.environ.get('PRESET_NAME', '')
PICOM_DST = os.environ.get('PICOM_DST', '')
CURRENT_LINK = os.environ.get('CURRENT_LINK', '')

PRESETS = {
    "clasico": {
        "open":  {"preset": "appear", "scale": "0.92", "duration": "0.22"},
        "close": {"preset": "disappear", "scale": "1.05", "duration": "0.2"},
        "show":  {"preset": "fly-in", "direction": "up", "duration": "0.2"},
        "hide":  {"preset": "fly-out", "direction": "down", "duration": "0.15"},
    },
    "gnome": {
        "open":  {"preset": "fly-in", "direction": "up", "duration": "0.2"},
        "close": {"preset": "fly-out", "direction": "down", "duration": "0.15"},
        "show":  {"preset": "slide-in", "direction": "up", "duration": "0.2"},
        "hide":  {"preset": "slide-out", "direction": "down", "duration": "0.15"},
    },
    "macos": {
        "open":  {"preset": "appear", "scale": "0.90", "duration": "0.3"},
        "close": {"preset": "fly-out", "direction": "left", "duration": "0.25"},
        "show":  {"preset": "fly-in", "direction": "up", "duration": "0.2"},
        "hide":  {"preset": "fly-out", "direction": "down", "duration": "0.15"},
    },
    "win11": {
        "open":  {"preset": "fly-in", "direction": "up", "duration": "0.2"},
        "close": {"preset": "fly-out", "direction": "right", "duration": "0.2"},
        "show":  {"preset": "appear", "scale": "0.95", "duration": "0.15"},
        "hide":  {"preset": "disappear", "scale": "1.05", "duration": "0.1"},
    },
    "snap": {
        "open":  {"preset": "appear", "scale": "0.95", "duration": "0.1"},
        "close": {"preset": "disappear", "scale": "1.02", "duration": "0.08"},
        "show":  {"preset": "appear", "scale": "0.95", "duration": "0.08"},
        "hide":  {"preset": "disappear", "scale": "1.02", "duration": "0.06"},
    },
}

VALID_TRIGGERS = {"open", "close", "show", "hide", "geometry"}
VALID_PRESETS = {"appear", "disappear", "fly-in", "fly-out", "slide-in", "slide-out", "geometry-change"}


def parse_params(param_str):
    params = {}
    for item in param_str.split():
        if '=' in item:
            k, v = item.split('=', 1)
            params[k] = v
    return params


def build_block(trigger, preset, params, indent=4):
    pad = ' ' * indent
    lines = [f'{pad}triggers = ["{trigger}"];']
    lines.append(f'{pad}preset = "{preset}";')
    if preset in ('appear', 'disappear'):
        scale = params.get('scale', '0.92' if preset == 'appear' else '1.05')
        lines.append(f'{pad}scale = {scale};')
    elif preset in ('fly-in', 'fly-out', 'slide-in', 'slide-out'):
        direction = params.get('direction', 'up')
        lines.append(f'{pad}direction = "{direction}";')
    duration = params.get('duration', '0.2')
    lines.append(f'{pad}duration = {duration};')
    return lines


def find_closing(lines, start_idx):
    for j in range(start_idx + 1, min(start_idx + 20, len(lines))):
        stripped = lines[j].strip()
        if re.match(r'^\s*\}\s*,?\s*(\{|\);)?\s*$', stripped):
            return j
    return None


def find_global_trigger(lines, trigger):
    """Find a global animation trigger line (indent 4, before rules: section)."""
    target = f'    triggers = ["{trigger}"];'
    rules_start = -1
    for i, line in enumerate(lines):
        if line.strip().startswith('rules:'):
            rules_start = i
            break
    for i, line in enumerate(lines):
        if line.rstrip() == target:
            if rules_start >= 0 and i > rules_start:
                continue
            return i
    return None


def find_rule_match(lines, app_name, start=0):
    """Find the rule line that matches an app name (case-insensitive class_g match)."""
    for i in range(start, len(lines)):
        if 'class_g' in lines[i] and app_name.lower() in lines[i].lower():
            return i
    return None


def find_animations_block(lines, rule_start):
    """Find the animations = ({ ... }) block within a rule."""
    for i in range(rule_start, min(rule_start + 30, len(lines))):
        if 'animations = ({' in lines[i]:
            return i
    return None


def find_trigger_in_section(lines, trigger, section_start, section_end):
    """Find a trigger line with indent 8 within a section."""
    target = f'        triggers = ["{trigger}"];'
    for i in range(section_start, min(section_end or len(lines), len(lines))):
        if lines[i].rstrip() == target:
            return i
    return None


def update_file(filepath, trigger, preset, params, target=None, quiet=False):
    if not os.path.exists(filepath):
        if not quiet:
            print(f"  → Saltando: {filepath} no existe")
        return False

    with open(filepath, 'r') as f:
        content = f.read()
    lines = content.split('\n')

    if target:
        app = target
        rule_start = find_rule_match(lines, app)
        if rule_start is None:
            if not quiet:
                print(f"  ✗ No se encontró regla para '{app}' en {os.path.basename(filepath)}")
            return False

        anim_start = find_animations_block(lines, rule_start)
        if anim_start is None:
            if not quiet:
                print(f"  ✗ No hay animations block para '{app}' en {os.path.basename(filepath)}")
            return False

        tline = find_trigger_in_section(lines, trigger, anim_start, anim_start + 30)
        if tline is None:
            if not quiet:
                print(f"  ✗ No se encontró trigger '{trigger}' en regla '{app}'")
            return False

        cline = find_closing(lines, tline)
        if cline is None:
            if not quiet:
                print(f"  ✗ No se pudo determinar el cierre del bloque para '{trigger}' en '{app}'")
            return False

        new_block = build_block(trigger, preset, params, indent=8)
        lines[tline:cline] = new_block
    else:
        tline = find_global_trigger(lines, trigger)
        if tline is None:
            print(f"  ✗ No se encontró trigger global '{trigger}' en {os.path.basename(filepath)}")
            return False

        cline = find_closing(lines, tline)
        if cline is None:
            print(f"  ✗ No se pudo determinar el cierre del bloque global '{trigger}'")
            return False

        new_block = build_block(trigger, preset, params, indent=4)
        lines[tline:cline] = new_block

    with open(filepath, 'w') as f:
        f.write('\n'.join(lines) + '\n')

    print(f"  ✓ {os.path.basename(filepath)}")
    return True


def find_all_app_rules(lines):
    """Encuentra todos los nombres de app con reglas de animación per-app."""
    apps = []
    for i, line in enumerate(lines):
        if 'class_g' in line and 'match' in line:
            for j in range(i, min(i + 15, len(lines))):
                if 'animations = ({' in lines[j]:
                    m = re.search(r"class_g\s*=\s*'([^']+)'", line)
                    if m:
                        apps.append(m.group(1))
                    break
    return apps


def apply_preset_to_file(filepath, preset_name):
    if preset_name not in PRESETS:
        print(f"  ✗ Preset desconocido: {preset_name}")
        return False

    preset = PRESETS[preset_name]
    success = True

    # Aplica triggers globales primero
    for trig, p_params in preset.items():
        p = p_params['preset']
        pp = {k: v for k, v in p_params.items() if k != 'preset'}
        result = update_file(filepath, trig, p, pp)
        if not result:
            success = False

    # Cascade: aplica el mismo preset a todas las reglas per-app
    with open(filepath, 'r') as f:
        lines = f.read().split('\n')

    for app in find_all_app_rules(lines):
        for trig, p_params in preset.items():
            p = p_params['preset']
            pp = {k: v for k, v in p_params.items() if k != 'preset'}
            result = update_file(filepath, trig, p, pp, target=app, quiet=True)
            if not result:
                success = False

    return success


# --- Collect files to update ---
global_src = os.environ.get('GLOBAL_SRC', '')
rules_src = os.environ.get('RULES_SRC', '')

# Si se apunta a una app específica → solo rules.picom
# Si es global → solo global.picom
# Si es preset → ambos (global + cascade a per-app)
if MODE == "preset":
    files_to_update = []
    if os.path.exists(global_src):
        files_to_update.append(global_src)
    if os.path.exists(rules_src):
        files_to_update.append(rules_src)
    for f in files_to_update:
        apply_preset_to_file(f, PRESET_NAME)
else:
    params = parse_params(PARAMS_STR)
    target = TARGET or None
    if target:
        if os.path.exists(rules_src):
            update_file(rules_src, TRIGGER, PRESET, params, target=target)
    else:
        if os.path.exists(global_src):
            update_file(global_src, TRIGGER, PRESET, params, target=None)

print("DONE")
PYEOF
)

echo "$output"
updated=$(echo "$output" | grep -c "✓" 2>/dev/null || true)

# Restart picom only if files were updated
if [ "$updated" -gt 0 ]; then
    killall -q picom 2>/dev/null || true
    sleep 0.3
    picom --config "$PICOM_DST" &>/dev/null &
    disown
fi

# Notify
if [ "$MODE" = "preset" ]; then
    notify-send -i preferences-desktop-display "Animation Picker" "Preset aplicado: $PRESET_NAME"
    dunstify -u low "🎬  Animación" "Preset: $PRESET_NAME"
else
    target_msg="${TARGET:-global}"
    notify-send -i preferences-desktop-display "Animation Picker" "$target_msg: $TRIGGER → $PRESET"
    dunstify -u low "🎬  Animación" "$target_msg — $TRIGGER: $PRESET"
fi

echo "✓ Listo"
