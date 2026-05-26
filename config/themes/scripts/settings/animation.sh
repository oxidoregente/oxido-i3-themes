#!/bin/bash
# 🎬  Animation settings — menú jerárquico con sub-menús
# Global, Por aplicación, Preestablecidos

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIR="$SCRIPT_DIR"
[ -f "$SCRIPT_DIR/../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../scripts/rofi-builder.sh"
[ -f "$SCRIPT_DIR/../../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../../scripts/rofi-builder.sh"

ROFI_ANIM="$ROFI_THEME_SUB"

ANIM_PICKER="$DIR/../../bin/animation-picker.sh"

# ─── Leer estado actual de animaciones (en español) ───
read_anim_state() {
    python3 -c "
import re, os
c = os.path.expanduser('~/.config/picom/picom.conf')
if not os.path.exists(c): print('Sin config'); exit()
with open(c) as f:
    lines = f.readlines()
r = next((i for i,l in enumerate(lines) if l.strip().startswith('rules:')), len(lines))

trig_es = {'open':'Abrir','close':'Cerrar','show':'Show','hide':'Hide'}
pre_es = {'appear':'Aparecer','disappear':'Desaparecer','fly-in':'Entrar volando','fly-out':'Salir volando','slide-in':'Entrar deslizando','slide-out':'Salir deslizando'}
arrow = {'up':'↑','down':'↓','left':'←','right':'→'}

s = {}
for t in ['open','close','show','hide']:
    for i in range(r):
        if lines[i].strip() == 'triggers = [\"' + t + '\"];' and lines[i].startswith('    ') and not lines[i].startswith('        '):
            d = {'preset':'?','direction':'','scale':'','duration':''}
            for j in range(i+1, min(i+6, r)):
                for k in d:
                    m = re.search(k + r'\s*=\s*\"?([^\"\n;]+)', lines[j])
                    if m: d[k] = m.group(1).strip()
            s[t] = d
            break

parts = []
for t in ['open','close','show','hide']:
    d = s.get(t, {'preset':'?'})
    p = d['preset']
    t_es = trig_es.get(t, t)
    p_es = pre_es.get(p, p)
    if d.get('duration') == '0.001' and d.get('scale') == '1.0':
        parts.append(f'{t_es}: Sin animación')
    elif d.get('direction'):
        a = arrow.get(d['direction'], d['direction'])
        parts.append(f'{t_es}: {p_es} {a}')
    elif d.get('scale') and d['scale'] != '?':
        parts.append(f'{t_es}: {p_es} ({d[\"scale\"]})')
    elif p != '?':
        parts.append(f'{t_es}: {p_es}')
    else:
        parts.append(f'{t_es}: ?')
print(' | '.join(parts))
"
}

# ─── Picker helpers (español → inglés para el backend) ───
pick_preset() {
    local trigger_en="$1"
    local trigger_es
    case "$trigger_en" in
        open)  trigger_es="abrir" ;;
        close) trigger_es="cerrar" ;;
        show)  trigger_es="mostrar workspace" ;;
        hide)  trigger_es="ocultar workspace" ;;
        *)     trigger_es="$trigger_en" ;;
    esac

    local choice=$(echo -e "Aparecer (zoom)\nDesaparecer\nEntrar volando\nSalir volando\nEntrar deslizando\nSalir deslizando\nSin animación" | \
        rofi -dmenu -p "Al $trigger_es" -theme-str "$ROFI_ANIM" -i)

    case "$choice" in
        *Aparecer*)           echo "appear" ;;
        *Desaparecer*)        echo "disappear" ;;
        *"Entrar volando"*)   echo "fly-in" ;;
        *"Salir volando"*)    echo "fly-out" ;;
        *"Entrar deslizando"*) echo "slide-in" ;;
        *"Salir deslizando"*)  echo "slide-out" ;;
        *"Sin animación"*)    echo "none" ;;
    esac
}

pick_direction() {
    local choice=$(echo -e "↑ Arriba\n↓ Abajo\n← Izquierda\n→ Derecha" | \
        rofi -dmenu -p "Dirección" -theme-str "$ROFI_ANIM" -i)

    case "$choice" in
        *Arriba*)     echo "up" ;;
        *Abajo*)      echo "down" ;;
        *Izquierda*)  echo "left" ;;
        *Derecha*)    echo "right" ;;
    esac
}

pick_duration() {
    local choice=$(echo -e "0.10s — Muy rápido\n0.15s — Rápido\n0.20s — Normal\n0.25s — Suave\n0.30s — Lento\n0.50s — Muy lento" | \
        rofi -dmenu -p "Velocidad" -theme-str "$ROFI_ANIM" -i -selected-row 2)

    echo "$choice" | cut -d's' -f1
}

pick_animation() {
    local trigger="$1"
    local target=""
    [ $# -ge 2 ] && target="$2"

    local preset=$(pick_preset "$trigger")
    [ -z "$preset" ] && return

    local direction=""
    case "$preset" in
        none)
            local target_arg=""
            [ -n "$target" ] && target_arg="--target $target"
            "$ANIM_PICKER" "$trigger" "appear" "scale=1.0 duration=0.001" $target_arg
            dunstify -u low "🎬  Animación" "${target:-Global}: $trigger → Sin animación"
            return
            ;;
        fly-in|fly-out|slide-in|slide-out)
            direction=$(pick_direction)
            [ -z "$direction" ] && return
            ;;
    esac

    local duration=$(pick_duration)
    [ -z "$duration" ] && duration="0.20"

    local params="duration=$duration"
    [ -n "$direction" ] && params="direction=$direction $params"

    if [ -n "$target" ]; then
        "$ANIM_PICKER" "$trigger" "$preset" "$params" --target "$target"
    else
        "$ANIM_PICKER" "$trigger" "$preset" "$params"
    fi
    dunstify -u low "🎬  Animación" "${target:-Global}: $trigger → $preset"
}

# ─── Sub-menú Global ───
global_menu() {
    while true; do
        local cur=$(read_anim_state)
        local choice=$(cat << EOF | rofi -dmenu -p "  🎬  $L_GLOBAL" -theme-str "$ROFI_ANIM" -i -selected-row 1
$L_CURRENT: $cur
▸  $L_OPEN
▸  $L_CLOSE
▸  $L_SHOW
▸  $L_HIDE
$L_BACK
EOF
        )
        case "$choice" in
            *"$L_OPEN"*)  pick_animation "open" ;;
            *"$L_CLOSE"*) pick_animation "close" ;;
            *"$L_SHOW"*)  pick_animation "show" ;;
            *"$L_HIDE"*)  pick_animation "hide" ;;
            *"$L_BACK"*)  return ;;
            *) return ;;
        esac
    done
}

# ─── Sub-menú Por aplicación ───
per_app_menu() {
    while true; do
        local choice=$(cat << EOF | rofi -dmenu -p "  🎬  $L_PER_APP" -theme-str "$ROFI_ANIM" -i
▸  Alacritty — terminal
▸  Firefox — navegador
▸  Rofi — lanzador/menús
▸  Dunst — notificaciones
$L_BACK
EOF
        )
        case "$choice" in
            *Alacritty*) per_app_trigger "Alacritty" ;;
            *Firefox*)   per_app_trigger "Firefox" ;;
            *Rofi*)      per_app_trigger "Rofi" ;;
            *Dunst*)     per_app_trigger "Dunst" ;;
            *"$L_BACK"*) return ;;
            *) return ;;
        esac
    done
}

per_app_trigger() {
    local app="$1"
    while true; do
        local choice=$(cat << EOF | rofi -dmenu -p "  🎬  $app" -theme-str "$ROFI_ANIM" -i
▸  $L_OPEN
▸  $L_CLOSE
▸  $L_SHOW
▸  $L_HIDE
$L_BACK
EOF
        )
        case "$choice" in
            *"$L_OPEN"*)  pick_animation "open" "$app" ;;
            *"$L_CLOSE"*) pick_animation "close" "$app" ;;
            *"$L_SHOW"*)  pick_animation "show" "$app" ;;
            *"$L_HIDE"*)  pick_animation "hide" "$app" ;;
            *"$L_BACK"*)  return ;;
            *) return ;;
        esac
    done
}

# ─── Sub-menú Preestablecidos ───
presets_menu() {
    while true; do
        local choice=$(cat << EOF | rofi -dmenu -p "  🎬  $L_PRESETS" -theme-str "$ROFI_ANIM" -i -selected-row 0
◉  Clásico — Aparecer / Desaparecer (estándar)
○  GNOME — Entrar volando ↑ / Salir volando ↓
○  macOS — Aparecer / Salir volando ←
○  Windows 11 — Entrar volando ↑ / Salir volando →
○  Snap — ultra rápido (0.10s)
$L_BACK
EOF
        )
        case "$choice" in
            *Clásico*)  "$ANIM_PICKER" preset "clasico" ;;
            *GNOME*)    "$ANIM_PICKER" preset "gnome" ;;
            *macOS*)    "$ANIM_PICKER" preset "macos" ;;
            *Windows*)  "$ANIM_PICKER" preset "win11" ;;
            *Snap*)     "$ANIM_PICKER" preset "snap" ;;
            *"$L_BACK"*) return ;;
            *)          return ;;
        esac
    done
}

# ─── Menú principal ───
while true; do
    cur=$(read_anim_state)
    choice=$(cat << EOF | rofi -dmenu -p "  🎬  $L_ANIM" -theme-str "$ROFI_ANIM" -i -selected-row 1
$cur
▸  $L_GLOBAL
▸  $L_PER_APP
▸  $L_PRESETS
$L_BACK
EOF
    )
    case "$choice" in
        *"$L_GLOBAL"*)   global_menu ;;
        *"$L_PER_APP"*)  per_app_menu ;;
        *"$L_PRESETS"*)  presets_menu ;;
        *"$L_BACK"*)     exec ~/.config/themes/bin/rofi-settings.sh ;;
        *)               exec ~/.config/themes/bin/rofi-settings.sh ;;
    esac
done
