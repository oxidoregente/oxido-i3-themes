#!/bin/bash
# polybar-modules.sh — Gestor visual de módulos Polybar
# oxido-i3-themes — $mod+Shift+m

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$SCRIPT_DIR/../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../scripts/rofi-builder.sh"

LAYOUTS_DIR="$HOME/.config/polybar/layouts"
CURRENT_LAYOUT_FILE="$HOME/.config/themes/current-layout"
LAYOUT_NAME=$(cat "$CURRENT_LAYOUT_FILE" 2>/dev/null || echo "bubble")
LAYOUT_PATH="$LAYOUTS_DIR/$LAYOUT_NAME.ini"
[ ! -f "$LAYOUT_PATH" ] && LAYOUT_PATH="$HOME/Documentos/oxido-i3-themes/config/polybar/layouts/$LAYOUT_NAME.ini"
[ ! -f "$LAYOUT_PATH" ] && { echo "Layout no encontrado"; exit 1; }

FIJOS="ws-start ws-end center-start center-end sys-start sys-end"

leer_modulos() {
    local section="$1"
    sed -n "s/^modules-$section *= *//p" "$LAYOUT_PATH" | head -1
}

escribir_modulos() {
    local section="$1" modules="$2"
    sed -i "s/^modules-$section *=.*/modules-$section = $modules/" "$LAYOUT_PATH"
}

# Guardar estado original para poder restaurar
ORIG_LEFT=$(leer_modulos "left")
ORIG_CENTER=$(leer_modulos "center")
ORIG_RIGHT=$(leer_modulos "right")

restaurar_default() {
    opts="¿Restaurar todos los módulos a su posición original?\n\nSí, restaurar\nNo, cancelar"
    r=$(echo -e "$opts" | rofi -dmenu -p "↻ Restaurar" -i -theme-str "
window { width: 480px; border-radius: 24px; border-color: $SEL; background-color: $BG; }
mainbox { children: [ listview ]; padding: 20px; }
listview { columns: 1; lines: 2; spacing: 10px; dynamic: false; }
element { padding: 14px; border-radius: 14px; text-color: $FG; background-color: $BGA; }
element selected { background-color: $SEL; text-color: $BG; }
element-text { vertical-align: 0.5; font: \"JetBrainsMono Nerd Font Mono 12\"; }
prompt { text-color: $SEL; font: \"JetBrainsMono Nerd Font Mono Bold 13\"; }
")
    [ -z "$r" ] && return
    if echo "$r" | grep -q "Sí"; then
        escribir_modulos "left"   "$ORIG_LEFT"
        escribir_modulos "center" "$ORIG_CENTER"
        escribir_modulos "right"  "$ORIG_RIGHT"
        apply_and_restart
    fi
}

# Leer estado actual
MODS_LEFT=$(leer_modulos "left")
MODS_CENTER=$(leer_modulos "center")
MODS_RIGHT=$(leer_modulos "right")

declare -A MOD_SECTION
for m in $MODS_LEFT;   do MOD_SECTION["$m"]="L"; done
for m in $MODS_CENTER; do MOD_SECTION["$m"]="C"; done
for m in $MODS_RIGHT;  do MOD_SECTION["$m"]="R"; done

LISTA_COMPLETA=$(grep "^\[module/" "$LAYOUT_PATH" | sed 's/\[module\///;s/\]//')

SEC_LABEL() {
    case "$1" in
        L) echo "IZQUIERDA" ;;
        C) echo "CENTRO" ;;
        R) echo "DERECHA" ;;
        *) echo "OCULTO" ;;
    esac
}

SEC_SHORT() {
    case "$1" in
        L) echo "← IZQ" ;;
        C) echo "↔ CTR" ;;
        R) echo "→ DER" ;;
        *) echo "✕ OCL" ;;
    esac
}

THEME_LIST="window { width: 560px; border-radius: 24px; border-color: $SEL; background-color: $BG; }
mainbox { children: [ inputbar, listview ]; padding: 20px; }
inputbar { margin: 0 0 12px 0; padding: 8px 12px; background-color: $BGA; border-radius: 12px; children: [ prompt ]; }
prompt { text-color: $SEL; font: \"JetBrainsMono Nerd Font Mono Bold 13\"; }
listview { columns: 1; lines: 20; spacing: 4px; dynamic: true; }
element { padding: 10px 14px; border-radius: 10px; text-color: $FG; }
element selected { background-color: $SEL; text-color: $BG; }
element-text { vertical-align: 0.5; font: \"JetBrainsMono Nerd Font Mono 11\"; }"

THEME_ACTION="window { width: 420px; border-radius: 24px; border-color: $SEL; background-color: $BG; }
mainbox { children: [ listview ]; padding: 16px; }
listview { columns: 1; lines: 6; spacing: 6px; dynamic: false; }
element { padding: 12px 14px; border-radius: 12px; text-color: $FG; background-color: $BGA; }
element selected { background-color: $SEL; text-color: $BG; }
element-text { vertical-align: 0.5; font: \"JetBrainsMono Nerd Font Mono 11\"; }"

main_menu() {
    while true; do
        items=""
        for mod in $LISTA_COMPLETA; do
            sec="${MOD_SECTION[$mod]:-}"
            if echo "$FIJOS" | grep -qw "$mod"; then
                items+="🔒 $(SEC_SHORT $sec)  $mod\n"
            elif [ -z "$sec" ]; then
                items+="✗  ---  $mod\n"
            else
                items+="✓  $(SEC_SHORT $sec)  $mod\n"
            fi
        done
        items+="\n↻  Restaurar valores por defecto\n✕  Cerrar"
        
        chosen=$(echo -e "$items" | rofi -dmenu -p "📦 GESTOR DE MÓDULOS" -i -theme-str "$THEME_LIST")
        [ -z "$chosen" ] && exit 0
        echo "$chosen" | grep -q "Cerrar" && exit 0
        
        if echo "$chosen" | grep -q "Restaurar"; then
            restaurar_default
            # Recargar estado local
            MODS_LEFT=$(leer_modulos "left")
            MODS_CENTER=$(leer_modulos "center")
            MODS_RIGHT=$(leer_modulos "right")
            for m in $MODS_LEFT;   do MOD_SECTION["$m"]="L"; done
            for m in $MODS_CENTER; do MOD_SECTION["$m"]="C"; done
            for m in $MODS_RIGHT;  do MOD_SECTION["$m"]="R"; done
            continue
        fi
        
        mod_name=$(echo "$chosen" | sed 's/^[✓✗🔒]  [←↔→✕] [A-Z]\{3,4\}  //')
        echo "$FIJOS" | grep -qw "$mod_name" && continue
        
        sec="${MOD_SECTION[$mod_name]:-}"
        if [ -z "$sec" ]; then
            # Mostrar módulo oculto
            MODS_RIGHT="$MODS_RIGHT $mod_name"
            MODS_RIGHT=$(echo "$MODS_RIGHT" | tr -s ' ' | sed 's/^ *//;s/ *$//')
            escribir_modulos "right" "$MODS_RIGHT"
            MOD_SECTION["$mod_name"]="R"
            apply_and_restart
        else
            action_menu "$mod_name"
        fi
    done
}

action_menu() {
    local mod="$1" sec="${MOD_SECTION[$mod]}"
    
    opts="⬆  Subir posición (dentro de $(SEC_LABEL $sec))\n⬇  Bajar posición\n◀  Mover a IZQUIERDA\n↔  Mover a CENTRO\n▶  Mover a DERECHA\n✕  Ocultar módulo\n◀  Volver"
    
    chosen=$(echo -e "$opts" | rofi -dmenu -p "$mod — $(SEC_LABEL $sec)" -i -theme-str "$THEME_ACTION")
    [ -z "$chosen" ] && return
    echo "$chosen" | grep -q "Volver" && return
    
    if echo "$chosen" | grep -q "Ocultar"; then
        old_sec="${MOD_SECTION[$mod]}"
        if [ "$old_sec" = "L" ]; then
            MODS_LEFT=$(echo "$MODS_LEFT" | sed "s/\b$mod\b//" | tr -s ' ')
            escribir_modulos "left"   "$MODS_LEFT"
        elif [ "$old_sec" = "C" ]; then
            MODS_CENTER=$(echo "$MODS_CENTER" | sed "s/\b$mod\b//" | tr -s ' ')
            escribir_modulos "center" "$MODS_CENTER"
        else
            MODS_RIGHT=$(echo "$MODS_RIGHT" | sed "s/\b$mod\b//" | tr -s ' ')
            escribir_modulos "right"  "$MODS_RIGHT"
        fi
        unset MOD_SECTION["$mod"]
        apply_and_restart
        return
    fi
    
    if echo "$chosen" | grep -q "Subir"; then
        move_mod "$mod" -1; return
    fi
    if echo "$chosen" | grep -q "Bajar"; then
        move_mod "$mod" 1; return
    fi
    
    new_sec=""
    echo "$chosen" | grep -q "IZQUIERDA" && new_sec="L"
    echo "$chosen" | grep -q "CENTRO"    && new_sec="C"
    echo "$chosen" | grep -q "DERECHA"   && new_sec="R"
    [ -z "$new_sec" ] && return
    
    change_section "$mod" "$new_sec"
}

change_section() {
    local mod="$1" new_sec="$2" old_sec="${MOD_SECTION[$mod]}"
    
    # Remover de sección actual
    if [ "$old_sec" = "L" ]; then
        MODS_LEFT=$(echo "$MODS_LEFT" | sed "s/\b$mod\b//" | tr -s ' ')
    elif [ "$old_sec" = "C" ]; then
        MODS_CENTER=$(echo "$MODS_CENTER" | sed "s/\b$mod\b//" | tr -s ' ')
    else
        MODS_RIGHT=$(echo "$MODS_RIGHT" | sed "s/\b$mod\b//" | tr -s ' ')
    fi
    
    # Añadir al final de nueva sección
    if [ "$new_sec" = "L" ]; then
        MODS_LEFT="$MODS_LEFT $mod"
    elif [ "$new_sec" = "C" ]; then
        MODS_CENTER="$MODS_CENTER $mod"
    else
        MODS_RIGHT="$MODS_RIGHT $mod"
    fi
    
    MODS_LEFT=$(echo "$MODS_LEFT" | tr -s ' ' | sed 's/^ *//;s/ *$//')
    MODS_CENTER=$(echo "$MODS_CENTER" | tr -s ' ' | sed 's/^ *//;s/ *$//')
    MODS_RIGHT=$(echo "$MODS_RIGHT" | tr -s ' ' | sed 's/^ *//;s/ *$//')
    
    escribir_modulos "left"   "$MODS_LEFT"
    escribir_modulos "center" "$MODS_CENTER"
    escribir_modulos "right"  "$MODS_RIGHT"
    MOD_SECTION["$mod"]="$new_sec"
    apply_and_restart
}

move_mod() {
    local mod="$1" direction="$2"
    local sec="${MOD_SECTION[$mod]}"
    local mods_var="MODS_$sec"
    local -a mod_list=(${!mods_var})
    
    local pos=-1
    for i in "${!mod_list[@]}"; do
        [ "${mod_list[$i]}" = "$mod" ] && { pos=$i; break; }
    done
    [ "$pos" -eq -1 ] && return
    
    local new_pos=$((pos + direction))
    [ "$new_pos" -lt 0 ] || [ "$new_pos" -ge "${#mod_list[@]}" ] && return
    
    local tmp="${mod_list[$pos]}"
    mod_list[$pos]="${mod_list[$new_pos]}"
    mod_list[$new_pos]="$tmp"
    
    local new_mods="${mod_list[*]}"
    if [ "$sec" = "L" ]; then
        MODS_LEFT="$new_mods"
        escribir_modulos "left"   "$MODS_LEFT"
    elif [ "$sec" = "C" ]; then
        MODS_CENTER="$new_mods"
        escribir_modulos "center" "$MODS_CENTER"
    else
        MODS_RIGHT="$new_mods"
        escribir_modulos "right"  "$MODS_RIGHT"
    fi
    apply_and_restart
}

apply_and_restart() {
    local theme_dir=$(readlink "$HOME/.config/themes/current/theme")
    if [ -n "$theme_dir" ] && [ -f "$theme_dir/polybar/colors.ini" ]; then
        cat "$theme_dir/polybar/colors.ini" "$LAYOUT_PATH" > "$HOME/.config/polybar/config.ini"
        sed -i "/^\[bar\/top\]/a bottom = false" "$HOME/.config/polybar/config.ini"
    fi
    killall polybar 2>/dev/null; sleep 0.3
    "$HOME/.config/polybar/launch.sh" &>/dev/null & disown
}

main_menu
