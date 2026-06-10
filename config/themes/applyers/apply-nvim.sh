#!/bin/bash
# apply-nvim.sh — Aplica colores del tema actual a Neovim
# oxido-i3-themes
# Genera ~/.config/nvim/theme.lua a partir de los colores del tema activo.
# El archivo generado es cargado por init.lua mediante require('theme')

THEME_DIR="$1"
NVIM_THEME_FILE="$HOME/.config/nvim/theme.lua"
COLORS_FILE="$THEME_DIR/polybar/colors.ini"

if [ ! -f "$COLORS_FILE" ]; then
    notify-send -u low "Neovim Theme" "No se encontraron colores del tema para Neovim"
    exit 0
fi

# Extraer valores de color del archivo colors.ini
get_color() {
    grep "^$1 " "$COLORS_FILE" | head -1 | sed 's/.*= *//' | tr -d '[:space:]'
}

BG=$(get_color "background")
BG_ALT=$(get_color "background-alt")
FG=$(get_color "foreground")
PRIMARY=$(get_color "primary")
SECONDARY=$(get_color "secondary")
ALERT=$(get_color "alert")
DISABLED=$(get_color "disabled")
GREEN=$(get_color "green")
YELLOW=$(get_color "yellow")
PINK=$(get_color "pink")

# Si alguna variable obligatoria está vacía, salir
if [ -z "$BG" ] || [ -z "$FG" ]; then
    notify-send -u low "Neovim Theme" "Colores del tema incompletos para Neovim"
    exit 0
fi

# Usar python3 para derivar colores si está disponible
has_python3=false
command -v python3 &>/dev/null && has_python3=true

# Determinar UI_BG (fondo para paneles UI)
if [ -n "$BG_ALT" ]; then
    UI_BG="$BG_ALT"
elif $has_python3; then
    UI_BG=$(python3 -c "c='$BG'; h=c.lstrip('#'); r=max(0,int(h[0:2],16)-25); g=max(0,int(h[2:4],16)-25); b=max(0,int(h[4:6],16)-25); print(f'#{r:02x}{g:02x}{b:02x}')" 2>/dev/null)
else
    UI_BG="$BG"
fi
[ -z "$UI_BG" ] && UI_BG="$BG"

# SEL_BG (fondo de selección — mezcla suave entre primary y bg)
if $has_python3; then
    SEL_BG=$(python3 -c "
c='${PRIMARY:-#888888}'
b='$BG'
ch=c.lstrip('#'); bh=b.lstrip('#')
rr=int(ch[0:2],16); rg=int(ch[2:4],16); rb=int(ch[4:6],16)
br=int(bh[0:2],16); bg=int(bh[2:4],16); bb=int(bh[4:6],16)
r=int(rr*0.3 + br*0.7); g=int(rg*0.3 + bg*0.7); b=int(rb*0.3 + bb*0.7)
print(f'#{r:02x}{g:02x}{b:02x}')
" 2>/dev/null) || SEL_BG="$DISABLED"
else
    SEL_BG="${DISABLED:-#444444}"
fi

# CL_BG (cursorline)
if $has_python3; then
    CL_BG=$(python3 -c "
c='$BG'
h=c.lstrip('#')
r=int(h[0:2],16)
g=int(h[2:4],16)
b=int(h[4:6],16)
r=min(255,r+15); g=min(255,g+15); b=min(255,b+15)
print(f'#{r:02x}{g:02x}{b:02x}')
" 2>/dev/null) || CL_BG="$UI_BG"
else
    CL_BG="$UI_BG"
fi

# LINE_NR_FG (número de línea)
if $has_python3 && [ -n "$DISABLED" ]; then
    LINE_NR_FG=$(python3 -c "
c='$DISABLED'
h=c.lstrip('#')
r=int(h[0:2],16); g=int(h[2:4],16); b=int(h[4:6],16)
r=min(255,r+50); g=min(255,g+50); b=min(255,b+50)
print(f'#{r:02x}{g:02x}{b:02x}')
" 2>/dev/null) || LINE_NR_FG="$DISABLED"
else
    LINE_NR_FG="${DISABLED:-#666666}"
fi

# Calcular colores semi-transparentes para Diff
calc_diff_bg() {
    local base=$1; local suffix=$2
    if $has_python3; then
        python3 -c "
c='$base'
h=c.lstrip('#')
r=int(h[0:2],16); g=int(h[2:4],16); b=int(h[4:6],16)
r=int(r*0.2+($BG_R*0.8))
g=int(g*0.2+($BG_G*0.8))
b=int(b*0.2+($BG_B*0.8))
print(f'#{r:02x}{g:02x}{b:02x}')
" 2>/dev/null || echo "#${suffix}"
    else
        echo "#${suffix}"
    fi
}

# Obtener componentes RGB del fondo para mezcla
if $has_python3; then
    BG_R=$(python3 -c "h='$BG'.lstrip('#'); print(int(h[0:2],16))" 2>/dev/null) || BG_R=0
    BG_G=$(python3 -c "h='$BG'.lstrip('#'); print(int(h[2:4],16))" 2>/dev/null) || BG_G=0
    BG_B=$(python3 -c "h='$BG'.lstrip('#'); print(int(h[4:6],16))" 2>/dev/null) || BG_B=0
fi

DIFF_ADD=$(calc_diff_bg "$GREEN"  "335533")
DIFF_CHANGE=$(calc_diff_bg "$YELLOW" "555533")
DIFF_DELETE=$(calc_diff_bg "$ALERT" "553333")
DIFF_TEXT=$(calc_diff_bg "$PRIMARY" "334466")

cat > "$NVIM_THEME_FILE" << LUA
-- theme.lua — Generado automáticamente por oxido-i3-themes
-- Tema activo: $(basename "$(readlink -f "$THEME_DIR")")
-- No modifiques este archivo, se sobrescribe al cambiar de tema.

local c = {
  bg        = "${BG}",
  bg_alt    = "${UI_BG}",
  fg        = "${FG}",
  primary   = "${PRIMARY}",
  secondary = "${SECONDARY}",
  alert     = "${ALERT}",
  disabled  = "${DISABLED}",
  green     = "${GREEN}",
  yellow    = "${YELLOW}",
  pink      = "${PINK}",
  cursorline = "${CL_BG}",
  linemr    = "${LINE_NR_FG}",
  sel_bg    = "${SEL_BG}",
  diff_add  = "${DIFF_ADD}",
  diff_change = "${DIFF_CHANGE}",
  diff_delete = "${DIFF_DELETE}",
  diff_text = "${DIFF_TEXT}",
}

local function h(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

-- ─── Editor ───
h("Normal",       { fg = c.fg, bg = c.bg })
h("NormalFloat",  { fg = c.fg, bg = c.bg_alt })
h("EndOfBuffer",  { fg = c.bg_alt })

-- ─── Números de línea ───
h("LineNr",        { fg = c.linemr })
h("CursorLineNr",  { fg = c.primary })
h("CursorLine",    { bg = c.cursorline })
h("CursorColumn",  { bg = c.cursorline })

-- ─── Selección / Búsqueda ───
h("Visual",        { bg = c.sel_bg })
h("VisualNOS",     { bg = c.sel_bg })
h("Search",        { fg = c.bg, bg = c.yellow })
h("IncSearch",     { fg = c.bg, bg = c.primary })
h("CurSearch",     { fg = c.bg, bg = c.alert })

-- ─── Ventanas ───
h("WinSeparator",  { fg = c.disabled })
h("VertSplit",     { fg = c.disabled })
h("ColorColumn",   { bg = c.cursorline })
h("SignColumn",    { bg = c.bg })
h("Conceal",       { fg = c.disabled })

-- ─── Plegado ───
h("Folded",        { fg = c.disabled, bg = c.bg_alt })
h("FoldColumn",    { fg = c.disabled, bg = c.bg })

-- ─── Pestañas ───
h("TabLine",       { fg = c.disabled, bg = c.bg_alt })
h("TabLineSel",    { fg = c.fg, bg = c.bg })
h("TabLineFill",   { bg = c.bg_alt })

-- ─── Línea de estado ───
h("StatusLine",    { fg = c.fg, bg = c.bg_alt })
h("StatusLineNC",  { fg = c.disabled, bg = c.bg_alt })
h("WildMenu",      { fg = c.bg, bg = c.primary })

-- ─── Menú emergente ───
h("Pmenu",         { fg = c.fg, bg = c.bg_alt })
h("PmenuSel",      { fg = c.bg, bg = c.primary })
h("PmenuSbar",     { bg = c.disabled })
h("PmenuThumb",    { bg = c.primary })

-- ─── Mensajes ───
h("MsgArea",       { fg = c.fg })
h("ModeMsg",       { fg = c.primary })
h("MoreMsg",       { fg = c.primary })
h("WarningMsg",    { fg = c.yellow })
h("ErrorMsg",      { fg = c.alert, bg = c.bg })
h("Question",      { fg = c.green })

-- ─── Diagnóstico ───
h("DiagnosticOk",           { fg = c.green })
h("DiagnosticError",        { fg = c.alert })
h("DiagnosticWarn",         { fg = c.yellow })
h("DiagnosticInfo",         { fg = c.primary })
h("DiagnosticHint",         { fg = c.secondary })
h("DiagnosticUnderlineError", { sp = c.alert, undercurl = true })
h("DiagnosticUnderlineWarn",  { sp = c.yellow, undercurl = true })
h("DiagnosticUnderlineInfo",  { sp = c.primary, undercurl = true })
h("DiagnosticUnderlineHint",  { sp = c.secondary, undercurl = true })

-- ─── Diferencias ───
h("DiffAdd",       { bg = c.diff_add })
h("DiffChange",    { bg = c.diff_change })
h("DiffDelete",    { bg = c.diff_delete })
h("DiffText",      { bg = c.diff_text })

-- ─── Sintaxis: Comentarios ───
h("Comment",       { fg = c.disabled, italic = true })
h("SpecialComment",{ fg = c.disabled, italic = true })
h("Todo",          { fg = c.bg, bg = c.yellow })

-- ─── Sintaxis: Constantes ───
h("Constant",      { fg = c.secondary })
h("String",        { fg = c.green })
h("Character",     { fg = c.green })
h("Number",        { fg = c.secondary })
h("Boolean",       { fg = c.secondary })
h("Float",         { fg = c.secondary })

-- ─── Sintaxis: Identificadores ───
h("Identifier",    { fg = c.fg })
h("Function",      { fg = c.primary })

-- ─── Sintaxis: Sentencias ───
h("Statement",     { fg = c.pink })
h("Conditional",   { fg = c.pink })
h("Repeat",        { fg = c.pink })
h("Label",         { fg = c.pink })
h("Operator",      { fg = c.secondary })
h("Keyword",       { fg = c.pink })
h("Exception",     { fg = c.pink })

-- ─── Sintaxis: Tipos ───
h("Type",          { fg = c.yellow })
h("StorageClass",  { fg = c.yellow })
h("Structure",     { fg = c.yellow })
h("Typedef",       { fg = c.yellow })

-- ─── Sintaxis: Preprocesador ───
h("PreProc",       { fg = c.alert })
h("Include",       { fg = c.alert })
h("Define",        { fg = c.alert })
h("Macro",         { fg = c.alert })
h("PreCondit",     { fg = c.alert })

-- ─── Sintaxis: Especial ───
h("Special",       { fg = c.pink })
h("SpecialChar",   { fg = c.pink })
h("Delimiter",     { fg = c.fg })
h("Tag",           { fg = c.primary })

-- ─── Sintaxis: Subrayado ───
h("Underlined",    { fg = c.primary, underline = true })

-- ─── Sintaxis: Errores ───
h("Error",         { fg = c.alert })
h("Noise",         { fg = c.disabled })

-- ─── Spell ───
h("SpellBad",      { sp = c.alert, undercurl = true })
h("SpellCap",      { sp = c.yellow, undercurl = true })
h("SpellLocal",    { sp = c.primary, undercurl = true })
h("SpellRare",     { sp = c.pink, undercurl = true })

-- ─── LSP ───
h("LspReferenceText",  { bg = c.sel_bg })
h("LspReferenceRead",  { bg = c.sel_bg })
h("LspReferenceWrite", { bg = c.sel_bg })

-- ─── Árbol de directorios / NetRW ───
h("Directory",     { fg = c.primary })
h("Title",         { fg = c.primary, bold = true })

-- ─── Barra lateral (NvimTree, etc.) ───
h("NvimTreeNormal",      { fg = c.fg, bg = c.bg })
h("NvimTreeVertSplit",   { fg = c.disabled, bg = c.bg })
LUA

chmod 644 "$NVIM_THEME_FILE"
notify-send -i terminal "Neovim Theme" "Tema aplicado a Neovim ($(basename "$THEME_DIR"))"
