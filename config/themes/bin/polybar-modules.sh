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

SEC_LABEL() {
    case "$1" in L) echo "IZQUIERDA" ;; C) echo "CENTRO" ;; R) echo "DERECHA" ;; *) echo "OCULTO" ;; esac
}

THEME="window { width: 480px; border-radius: 24px; border-color: $SEL; background-color: $BG; }
mainbox { children: [ inputbar, listview ]; padding: 20px; }
inputbar { margin: 0 0 12px 0; padding: 8px 12px; background-color: $BGA; border-radius: 12px; children: [ prompt ]; }
prompt { text-color: $SEL; font: \"JetBrainsMono Nerd Font Mono Bold 13\"; }
listview { columns: 1; lines: 16; spacing: 4px; dynamic: true; }
element { padding: 10px 14px; border-radius: 10px; text-color: $FG; }
element selected { background-color: $SEL; text-color: $BG; }
element-text { vertical-align: 0.5; font: \"JetBrainsMono Nerd Font Mono 11\"; }"

THEME_SUB="window { width: 420px; border-radius: 24px; border-color: $SEL; background-color: $BG; }
mainbox { children: [ listview ]; padding: 16px; }
listview { columns: 1; lines: 8; spacing: 6px; dynamic: false; }
element { padding: 12px 14px; border-radius: 12px; text-color: $FG; background-color: $BGA; }
element selected { background-color: $SEL; text-color: $BG; }
element-text { vertical-align: 0.5; font: \"JetBrainsMono Nerd Font Mono 11\"; }"

listar_en() {
    local sec="$1"
    local mods_var="MODS_$sec"
    local list=""
    for m in ${!mods_var}; do
        echo "$FIJOS" | grep -qw "$m" && continue
        list+="$m\n"
    done
    [ -n "$list" ] && list="${list%\\n}"
    echo -e "$list"
}

count_visibles() {
    local sec="$1" mods_var="MODS_$sec" count=0
    for m in ${!mods_var}; do
        echo "$FIJOS" | grep -qw "$m" || ((count++))
    done
    echo $count
}

mostrar_ocultos() {
    local items="" count=0
    for m in $LISTA_COMPLETA; do
        echo "$FIJOS" | grep -qw "$m" && continue
        [ -z "${MOD_SECTION[$m]}" ] && items+="$m\n" && ((count++))
    done
    [ "$count" -eq 0 ] && items="(No hay módulos ocultos)\n"
    items+="\n◀  Volver"
    
    chosen=$(echo -e "$items" | rofi -dmenu -p "📦 OCULTOS" -i -theme-str "$THEME_SUB")
    [ -z "$chosen" ] || echo "$chosen" | grep -q "Volver" && return
    echo "$chosen" | grep -q "No hay" && return
    
    # Mostrar: añadir a derecha
    MODS_RIGHT="$MODS_RIGHT $chosen"
    MODS_RIGHT=$(echo "$MODS_RIGHT" | tr -s ' ' | sed 's/^ *//;s/ *$//')
    escribir_modulos "right" "$MODS_RIGHT"
    MOD_SECTION["$chosen"]="R"
    apply_and_restart
}

seccion_menu() {
    local sec="$1" label=$(SEC_LABEL $sec)
    local mods_var="MODS_$sec"
    
    while true; do
        items=""
        for m in ${!mods_var}; do
            echo "$FIJOS" | grep -qw "$m" && continue
            items+="$m\n"
        done
        items+="\n↻  Reordenar sección\n⤴  Ocultar todos\n◀  Volver"
        
        chosen=$(echo -e "$items" | rofi -dmenu -p "📦 $label" -i -theme-str "$THEME_SUB")
        [ -z "$chosen" ] && return
        echo "$chosen" | grep -q "Volver" && return
        
        if echo "$chosen" | grep -q "Reordenar"; then
            reordenar_seccion "$sec"
            continue
        fi
        if echo "$chosen" | grep -q "Ocultar todos"; then
            ocultar_todos "$sec"
            return
        fi
        
        mod_menu "$chosen"
    done
}

reordenar_seccion() {
    local sec="$1" label=$(SEC_LABEL $sec)
    local mods_var="MODS_$sec"
    
    while true; do
        local -a mods=()
        items=""
        for m in ${!mods_var}; do
            echo "$FIJOS" | grep -qw "$m" && continue
            items+="⬆ $m\n⬇ $m\n"
            mods+=("$m")
        done
        items+="◀  Hecho"
        
        chosen=$(echo -e "$items" | rofi -dmenu -p "↻ $label" -i -theme-str "$THEME_SUB")
        [ -z "$chosen" ] && break
        echo "$chosen" | grep -q "Hecho" && break
        
        direccion=$(echo "$chosen" | grep -o '^[⬆⬇]')
        mod=$(echo "$chosen" | sed 's/^[⬆⬇] //')
        
        local -a mod_list=()
        for m in ${!mods_var}; do mod_list+=("$m"); done
        
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
    local mods_var="MODS_$sec"
    local ocultos=""
    for m in ${!mods_var}; do
        echo "$FIJOS" | grep -qw "$m" && continue
        ocultos+="$m "
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

mod_menu() {
    local mod="$1" sec="${MOD_SECTION[$mod]}"
    
    other_secs=""
    [ "$sec" != "L" ] && other_secs+="◀  Mover a IZQUIERDA\n"
    [ "$sec" != "C" ] && other_secs+="↔  Mover a CENTRO\n"
    [ "$sec" != "R" ] && other_secs+="▶  Mover a DERECHA\n"
    
    opts="${other_secs}⬆  Intercambiar con anterior\n⬇  Intercambiar con siguiente\n✕  Ocultar módulo\n◀  Volver"
    
    chosen=$(echo -e "$opts" | rofi -dmenu -p "$mod — $(SEC_LABEL $sec)" -i -theme-str "$THEME_SUB")
    [ -z "$chosen" ] && return
    echo "$chosen" | grep -q "Volver" && return
    
    if echo "$chosen" | grep -q "Ocultar"; then
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
    
    if echo "$chosen" | grep -q "Intercambiar con anterior"; then
        move_mod "$mod" -1; return
    fi
    if echo "$chosen" | grep -q "Intercambiar con siguiente"; then
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
    if [ "$sec" = "L" ]; then MODS_LEFT="$new_mods"
    elif [ "$sec" = "C" ]; then MODS_CENTER="$new_mods"
    else MODS_RIGHT="$new_mods"; fi
    
    escribir_modulos "left"   "$MODS_LEFT"
    escribir_modulos "center" "$MODS_CENTER"
    escribir_modulos "right"  "$MODS_RIGHT"
    apply_and_restart
}

restaurar_default() {
    opts="¿Restaurar todos los módulos a su posición original?\n\nSí, restaurar\nNo, cancelar"
    r=$(echo -e "$opts" | rofi -dmenu -p "↻ Restaurar" -i -theme-str "
window { width: 480px; border-radius: 24px; border-color: $SEL; background-color: $BG; }
mainbox { children: [ listview ]; padding: 20px; }
listview { columns: 1; lines: 2; spacing: 10px; dynamic: false; }
element { padding: 14px; border-radius: 14px; text-color: $FG; background-color: $BGA; }
element selected { background-color: $SEL; text-color: $BG; }
element-text { vertical-align: 0.5; font: \"JetBrainsMono Nerd Font Mono 12\"; }
prompt { text-color: $SEL; font: \"JetBrainsMono Nerd Font Mono Bold 13\"; }")
    [ -z "$r" ] && return
    if echo "$r" | grep -q "Sí"; then
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

count_sec() {
    local sec="$1" mods_var="MODS_$sec" count=0
    for m in ${!mods_var}; do echo "$FIJOS" | grep -qw "$m" || ((count++)); done
    echo "$count"
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
    
    items="◀  IZQUIERDA   ($c_l módulos)\n↔  CENTRO      ($c_c módulos)\n▶  DERECHA     ($c_r módulos)\n✕  OCULTOS     ($c_h módulos)\n\n↻  Restaurar valores por defecto\n✕  Cerrar"
    
    pick=$(echo -e "$items" | rofi -dmenu -p "📦 GESTOR DE MÓDULOS" -i -theme-str "$THEME")
    [ -z "$pick" ] && exit 0
    echo "$pick" | grep -q "Cerrar" && exit 0
    
    if echo "$pick" | grep -q "Restaurar"; then
        restaurar_default
        continue
    fi
    
    if echo "$pick" | grep -q "IZQUIERDA"; then
        seccion_menu "L"
    elif echo "$pick" | grep -q "CENTRO"; then
        seccion_menu "C"
    elif echo "$pick" | grep -q "DERECHA"; then
        seccion_menu "R"
    elif echo "$pick" | grep -q "OCULTOS"; then
        mostrar_ocultos
    fi
done
