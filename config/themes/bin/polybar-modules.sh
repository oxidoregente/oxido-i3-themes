#!/bin/bash
# polybar-modules.sh — Gestor visual de módulos Polybar
# oxido-i3-themes — $mod+Shift+m

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$SCRIPT_DIR/../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../scripts/rofi-builder.sh"

# Mapeo de sección a etiqueta según idioma
SEC_L() {
    case "$1" in L) echo "${L_MOD_LEFT:-◀  IZQUIERDA}" ;;
        C) echo "${L_MOD_CENTER:-↔  CENTRO}" ;;
        R) echo "${L_MOD_RIGHT:-▶  DERECHA}" ;;
        *) echo "${L_MOD_HIDDEN:-✕  OCULTOS}" ;; esac
}
SEC_LABEL() {
    local raw=$(SEC_L "$1")
    echo "$raw" | sed 's/^[^ ]* //'
}

LAYOUTS_DIR="$HOME/.config/polybar/layouts"
CURRENT_LAYOUT_FILE="$HOME/.config/themes/current-layout"
LAYOUT_NAME=$(cat "$CURRENT_LAYOUT_FILE" 2>/dev/null || echo "bubble")
LAYOUT_PATH="$LAYOUTS_DIR/$LAYOUT_NAME.ini"
[ ! -f "$LAYOUT_PATH" ] && LAYOUT_PATH="$HOME/Documentos/oxido-i3-themes/config/polybar/layouts/$LAYOUT_NAME.ini"
[ ! -f "$LAYOUT_PATH" ] && { echo "Layout no encontrado"; exit 1; }

FIJOS="ws-start ws-end center-start center-end sys-start sys-end"

_mods_of() {
    case "$1" in L) echo "$MODS_LEFT" ;; C) echo "$MODS_CENTER" ;; R) echo "$MODS_RIGHT" ;; esac
}
DECO_LEFT="ws-start ws-end"
DECO_CENTER="center-start center-end"
DECO_RIGHT="sys-start sys-end"

leer_modulos() {
    local section="$1"
    sed -n "s/^modules-$section *= *//p" "$LAYOUT_PATH" | head -1
}

escribir_modulos() {
    local section="$1" modules="$2"
    sed -i "s/^modules-$section *=.*/modules-$section = $modules/" "$LAYOUT_PATH"
}

ORIG_LEFT=$(leer_modulos "left")
ORIG_CENTER=$(leer_modulos "center")
ORIG_RIGHT=$(leer_modulos "right")

MODS_LEFT=$(leer_modulos "left")
MODS_CENTER=$(leer_modulos "center")
MODS_RIGHT=$(leer_modulos "right")

declare -A MOD_SECTION
for m in $MODS_LEFT;   do MOD_SECTION["$m"]="L"; done
for m in $MODS_CENTER; do MOD_SECTION["$m"]="C"; done
for m in $MODS_RIGHT;  do MOD_SECTION["$m"]="R"; done

LISTA_COMPLETA=$(grep "^\[module/" "$LAYOUT_PATH" | sed 's/\[module\///;s/\]//')

THEME="window { width: 480px; border-radius: 24px; border-color: $SEL; background-color: $BG; }
mainbox { children: [ inputbar, listview ]; padding: 20px; }
inputbar { margin: 0 0 12px 0; padding: 8px 12px; background-color: $BGA; border-radius: 12px; children: [ prompt ]; }
prompt { text-color: $SEL; font: \"JetBrainsMono Nerd Font Mono Bold 13\"; }
listview { columns: 1; lines: 8; spacing: 4px; dynamic: true; }
element { padding: 10px 14px; border-radius: 10px; text-color: $FG; }
element selected { background-color: $SEL; text-color: $BG; }
element-text { vertical-align: 0.5; font: \"JetBrainsMono Nerd Font Mono 11\"; }"

THEME_SUB="window { width: 420px; border-radius: 24px; border-color: $SEL; background-color: $BG; }
mainbox { children: [ listview ]; padding: 16px; }
listview { columns: 1; lines: 8; spacing: 6px; dynamic: true; }
element { padding: 12px 14px; border-radius: 12px; text-color: $FG; background-color: $BGA; }
element selected { background-color: $SEL; text-color: $BG; }
element-text { vertical-align: 0.5; font: \"JetBrainsMono Nerd Font Mono 11\"; }"

count_sec() {
    local sec="$1" count=0
    for m in $(_mods_of "$sec"); do echo "$FIJOS" | grep -qw "$m" || ((count++)); done
    echo "$count"
}

restaurar_default() {
    opts="${L_MOD_RESTORE_CONFIRM:-¿Restaurar todos los módulos a su posición original?}\n\n${L_MOD_RESTORE_YES:-Sí, restaurar}\n${L_MOD_RESTORE_NO:-No, cancelar}"
    r=$(echo -e "$opts" | rofi -dmenu -p "↻ ${L_MOD_RESTORE:-Restaurar}" -i -theme-str "
window { width: 480px; border-radius: 24px; border-color: $SEL; background-color: $BG; }
mainbox { children: [ listview ]; padding: 20px; }
listview { columns: 1; lines: 2; spacing: 10px; dynamic: false; }
element { padding: 14px; border-radius: 14px; text-color: $FG; background-color: $BGA; }
element selected { background-color: $SEL; text-color: $BG; }
element-text { vertical-align: 0.5; font: \"JetBrainsMono Nerd Font Mono 12\"; }
prompt { text-color: $SEL; font: \"JetBrainsMono Nerd Font Mono Bold 13\"; }")
    [ -z "$r" ] && return
    if echo "$r" | grep -qv "No,"; then
        escribir_modulos "left"   "$ORIG_LEFT"
        escribir_modulos "center" "$ORIG_CENTER"
        escribir_modulos "right"  "$ORIG_RIGHT"
        MODS_LEFT="$ORIG_LEFT"
        MODS_CENTER="$ORIG_CENTER"
        MODS_RIGHT="$ORIG_RIGHT"
        for m in $MODS_LEFT;   do MOD_SECTION["$m"]="L"; done
        for m in $MODS_CENTER; do MOD_SECTION["$m"]="C"; done
        for m in $MODS_RIGHT;  do MOD_SECTION["$m"]="R"; done
        apply_and_restart
    fi
}

mostrar_ocultos() {
    local items="" count=0
    for m in $LISTA_COMPLETA; do
        echo "$FIJOS" | grep -qw "$m" && continue
        [ -z "${MOD_SECTION[$m]}" ] && items+="$m\n" && ((count++))
    done
    [ "$count" -eq 0 ] && items="${L_MOD_NONE_HIDDEN:-(No hay módulos ocultos)}\n"
    items+="\n${L_MOD_BACK:-◀  Volver}"
    
    chosen=$(echo -e "$items" | rofi -dmenu -p "$(SEC_L H)" -i -theme-str "$THEME_SUB")
    [ -z "$chosen" ] || echo "$chosen" | grep -qE "Volver|Back" && return
    echo "$chosen" | grep -qE "No hay|No hidden" && return
    
    MODS_RIGHT="$MODS_RIGHT $chosen"
    MODS_RIGHT=$(echo "$MODS_RIGHT" | tr -s ' ' | sed 's/^ *//;s/ *$//')
    escribir_modulos "right" "$MODS_RIGHT"
    MOD_SECTION["$chosen"]="R"
    apply_and_restart
}

seccion_menu() {
    local sec="$1" label=$(SEC_LABEL $sec)
    
    while true; do
        items=""
        for m in $(_mods_of "$sec"); do
            echo "$FIJOS" | grep -qw "$m" && continue
            items+="$m\n"
        done
        items+="\n${L_MOD_REORDER:-↻  Reordenar sección}\n${L_MOD_HIDE_ALL:-⤴  Ocultar todos}\n${L_MOD_BACK:-◀  Volver}"
        
        chosen=$(echo -e "$items" | rofi -dmenu -p "$(SEC_L $sec)" -i -theme-str "$THEME_SUB")
        [ -z "$chosen" ] && return
        echo "$chosen" | grep -qE "Volver|Back" && return
        
        if echo "$chosen" | grep -qE "Reordenar|Reorder"; then
            reordenar_seccion "$sec"
            continue
        fi
        if echo "$chosen" | grep -qE "Ocultar todos|Hide all"; then
            ocultar_todos "$sec"
            return
        fi
        
        mod_menu "$chosen"
    done
}

reordenar_seccion() {
    local sec="$1" label=$(SEC_LABEL $sec)
    
    while true; do
        items=""
        for m in $(_mods_of "$sec"); do
            echo "$FIJOS" | grep -qw "$m" && continue
            items+="⬆ $m\n⬇ $m\n"
        done
        items+="${L_MOD_DONE:-◀  Hecho}"
        
        chosen=$(echo -e "$items" | rofi -dmenu -p "↻ $label" -i -theme-str "$THEME_SUB")
        [ -z "$chosen" ] && break
        echo "$chosen" | grep -qE "Hecho|Done" && break
        
        direccion=$(echo "$chosen" | grep -o '^[⬆⬇]')
        mod=$(echo "$chosen" | sed 's/^[⬆⬇] //')
        
        local -a mod_list=()
        for m in $(_mods_of "$sec"); do mod_list+=("$m"); done
        
        local pos=-1
        for i in "${!mod_list[@]}"; do
            [ "${mod_list[$i]}" = "$mod" ] && { pos=$i; break; }
        done
        [ "$pos" -eq -1 ] && continue
        
        if [ "$direccion" = "⬆" ]; then
            [ "$pos" -eq 0 ] && continue
            local tmp="${mod_list[$pos]}"
            mod_list[$pos]="${mod_list[$((pos-1))]}"
            mod_list[$((pos-1))]="$tmp"
        else
            [ "$pos" -eq "$((${#mod_list[@]}-1))" ] && continue
            local tmp="${mod_list[$pos]}"
            mod_list[$pos]="${mod_list[$((pos+1))]}"
            mod_list[$((pos+1))]="$tmp"
        fi
        
        local new_mods="${mod_list[*]}"
        if [ "$sec" = "L" ]; then MODS_LEFT="$new_mods"
        elif [ "$sec" = "C" ]; then MODS_CENTER="$new_mods"
        else MODS_RIGHT="$new_mods"; fi
        
        escribir_modulos "left"   "$MODS_LEFT"
        escribir_modulos "center" "$MODS_CENTER"
        escribir_modulos "right"  "$MODS_RIGHT"
        apply_and_restart
    done
}

ocultar_todos() {
    local sec="$1"
    for m in $(_mods_of "$sec"); do
        echo "$FIJOS" | grep -qw "$m" && continue
        unset MOD_SECTION["$m"]
    done
    
    if [ "$sec" = "L" ]; then MODS_LEFT="$DECO_LEFT"
    elif [ "$sec" = "C" ]; then MODS_CENTER="$DECO_CENTER"
    else MODS_RIGHT="$DECO_RIGHT"; fi
    
    escribir_modulos "left"   "$MODS_LEFT"
    escribir_modulos "center" "$MODS_CENTER"
    escribir_modulos "right"  "$MODS_RIGHT"
    apply_and_restart
}

change_section() {
    local mod="$1" new_sec="$2" old_sec="${MOD_SECTION[$mod]}"
    if [ "$old_sec" = "L" ]; then MODS_LEFT=$(echo "$MODS_LEFT" | sed "s/\b$mod\b//" | tr -s ' ')
    elif [ "$old_sec" = "C" ]; then MODS_CENTER=$(echo "$MODS_CENTER" | sed "s/\b$mod\b//" | tr -s ' ')
    else MODS_RIGHT=$(echo "$MODS_RIGHT" | sed "s/\b$mod\b//" | tr -s ' '); fi
    
    if [ "$new_sec" = "L" ]; then MODS_LEFT="$MODS_LEFT $mod"
    elif [ "$new_sec" = "C" ]; then MODS_CENTER="$MODS_CENTER $mod"
    else MODS_RIGHT="$MODS_RIGHT $mod"; fi
    
    for v in MODS_LEFT MODS_CENTER MODS_RIGHT; do
        local clean="${!v}"
        clean=$(echo "$clean" | tr -s ' ' | sed 's/^ *//;s/ *$//')
        eval "$v=\"$clean\""
    done
    
    escribir_modulos "left"   "$MODS_LEFT"
    escribir_modulos "center" "$MODS_CENTER"
    escribir_modulos "right"  "$MODS_RIGHT"
    MOD_SECTION["$mod"]="$new_sec"
    apply_and_restart
}

swap_positions() {
    local mod1="$1" mod2="$2"
    local sec="${MOD_SECTION[$mod1]}"
    
    local -a mod_list=()
    for m in $(_mods_of "$sec"); do mod_list+=("$m"); done
    
    local pos1=-1 pos2=-1
    for i in "${!mod_list[@]}"; do
        [ "${mod_list[$i]}" = "$mod1" ] && pos1=$i
        [ "${mod_list[$i]}" = "$mod2" ] && pos2=$i
    done
    [ "$pos1" -eq -1 ] || [ "$pos2" -eq -1 ] && return
    
    mod_list[$pos1]="$mod2"
    mod_list[$pos2]="$mod1"
    
    local new_mods="${mod_list[*]}"
    if [ "$sec" = "L" ]; then MODS_LEFT="$new_mods"
    elif [ "$sec" = "C" ]; then MODS_CENTER="$new_mods"
    else MODS_RIGHT="$new_mods"; fi
    
    escribir_modulos "left"   "$MODS_LEFT"
    escribir_modulos "center" "$MODS_CENTER"
    escribir_modulos "right"  "$MODS_RIGHT"
    apply_and_restart
}

swap_with_seleccion() {
    local mod="$1" sec="${MOD_SECTION[$mod]}"
    local items=""
    
    for m in $(_mods_of "$sec"); do
        echo "$FIJOS" | grep -qw "$m" && continue
        [ "$m" = "$mod" ] && continue
        items+="$m\n"
    done
    [ -z "$items" ] && return
    
    items+="\n${L_MOD_BACK:-◀  Volver}"
    
    chosen=$(echo -e "$items" | rofi -dmenu -p "${L_MOD_SWAP:-↔  Intercambiar con...}" -i -theme-str "$THEME_SUB")
    [ -z "$chosen" ] && return
    echo "$chosen" | grep -qE "Volver|Back" && return
    
    swap_positions "$mod" "$chosen"
}

mod_menu() {
    local mod="$1" sec="${MOD_SECTION[$mod]}"
    
    other_secs=""
    [ "$sec" != "L" ] && other_secs+="${L_MOD_MOVE_LEFT:-◀  Mover a IZQUIERDA}\n"
    [ "$sec" != "C" ] && other_secs+="${L_MOD_MOVE_CENTER:-↔  Mover a CENTRO}\n"
    [ "$sec" != "R" ] && other_secs+="${L_MOD_MOVE_RIGHT:-▶  Mover a DERECHA}\n"
    
    opts="${other_secs}${L_MOD_SWAP:-↔  Intercambiar con...}\n${L_MOD_HIDE:-✕  Ocultar módulo}\n${L_MOD_BACK:-◀  Volver}"
    
    chosen=$(echo -e "$opts" | rofi -dmenu -p "$mod — $(SEC_LABEL $sec)" -i -theme-str "$THEME_SUB")
    [ -z "$chosen" ] && return
    echo "$chosen" | grep -qE "Volver|Back" && return
    
    if echo "$chosen" | grep -qE "Ocultar|Hide"; then
        local old_sec="${MOD_SECTION[$mod]}"
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
    
    if echo "$chosen" | grep -qE "Intercambiar con|Swap with"; then
        swap_with_seleccion "$mod"
        return
    fi
    
    new_sec=""
    echo "$chosen" | grep -qE "IZQUIERDA|LEFT" && new_sec="L"
    echo "$chosen" | grep -qE "CENTRO|CENTER"    && new_sec="C"
    echo "$chosen" | grep -qE "DERECHA|RIGHT"   && new_sec="R"
    [ -z "$new_sec" ] && return
    change_section "$mod" "$new_sec"
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

# ─── NIVEL 1: SELECCIÓN DE SECCIÓN ─────────────────────
while true; do
    c_l=$(count_sec "L")
    c_c=$(count_sec "C")
    c_r=$(count_sec "R")
    c_h=0
    for m in $LISTA_COMPLETA; do
        echo "$FIJOS" | grep -qw "$m" && continue
        [ -z "${MOD_SECTION[$m]}" ] && ((c_h++))
    done
    
    s_left="${L_MOD_LEFT:-◀  IZQUIERDA}"
    s_center="${L_MOD_CENTER:-↔  CENTRO}"
    s_right="${L_MOD_RIGHT:-▶  DERECHA}"
    s_hidden="${L_MOD_HIDDEN:-✕  OCULTOS}"
    s_restore="${L_MOD_RESTORE:-↻  Restaurar valores por defecto}"
    s_close="${L_MOD_CLOSE:-✕  Cerrar}"
    
    items="$s_left   ($c_l)\n$s_center  ($c_c)\n$s_right     ($c_r)\n$s_hidden     ($c_h)\n\n$s_restore\n$s_close"
    
    pick=$(echo -e "$items" | rofi -dmenu -p "${L_MOD_TITLE:-📦  GESTOR DE MÓDULOS}" -i -theme-str "$THEME")
    [ -z "$pick" ] && exit 0
    echo "$pick" | grep -qE "Cerrar|Close" && exit 0
    
    if echo "$pick" | grep -qv "("; then
        for label in "$s_left" "$s_center" "$s_right" "$s_hidden"; do
            echo "$pick" | grep -qF "$label" && picked_label="$label"
        done
    fi
    
    if echo "$pick" | grep -qE "Restaurar|Restore"; then
        restaurar_default
        continue
    fi
    
    if echo "$pick" | grep -q "IZQUIERDA\|LEFT"; then seccion_menu "L"
    elif echo "$pick" | grep -q "CENTRO\|CENTER"; then seccion_menu "C"
    elif echo "$pick" | grep -q "DERECHA\|RIGHT"; then seccion_menu "R"
    elif echo "$pick" | grep -q "OCULTOS\|HIDDEN"; then mostrar_ocultos
    fi
done
