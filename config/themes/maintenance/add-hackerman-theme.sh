#!/bin/bash
set -e

THEME="hackerman"
THEMES_DIR="$HOME/.config/themes/themes"
TDIR="$THEMES_DIR/$THEME"
TEMPLATE="$THEMES_DIR/tokyo-night"

echo "=== Creando tema Hackerman ==="
mkdir -p "$TDIR"/{alacritty,backgrounds,btop,cava,conky,dunst,i3,picom,polybar,rofi}

# ===== COLORES OFICIALES OMARCHY =====
BG="#0B0C16"; BG_ALT="#121426"; FG="#ddf7ff"
PRIMARY="#82FB9C"; SECONDARY="#7cf8f7"
ALERT="#50f872"; DISABLED="#3E4058"
GREEN="#4fe88f"; PINK="#86a7df"; YELLOW="#50f7d4"
C0="#3E4058"; C1="#50f872"; C2="#4fe88f"; C3="#50f7d4"
C4="#829dd4"; C5="#86a7df"; C6="#7cf8f7"; C7="#85E1FB"
C8="#6a6e95"; C9="#85ff9d"; C10="#9cf7c2"; C11="#a4ffec"
C12="#c4d2ed"; C13="#cddbf4"; C14="#d1fffe"; C15="#ddf7ff"
BW="#0D0E1A"; BC="#0F1020"; BS="#111224"
DUNST_FRAME="#1a1c2e"

echo "  Colores ✓"

# ===== POLYBAR =====
cp "$TEMPLATE/polybar/config.ini" "$TDIR/polybar/config.ini"
sed -i \
  -e "s/background = #1a1b26/background = $BG/" \
  -e "s/foreground = #c0caf5/foreground = $FG/" \
  -e "s/bubble-ws = #303858/bubble-ws = $BW/" \
  -e "s/bubble-center = #304848/bubble-center = $BC/" \
  -e "s/bubble-sys = #383050/bubble-sys = $BS/" \
  -e "s/primary = #7aa2f7/primary = $PRIMARY/" \
  -e "s/secondary = #73daca/secondary = $SECONDARY/" \
  -e "s/alert = #f7768e/alert = $ALERT/" \
  -e "s/disabled = #565f89/disabled = $DISABLED/" \
  -e "s/green = #9ece6a/green = $GREEN/" \
  -e "s/pink = #bb9af7/pink = $PINK/" \
  -e "s/yellow = #e0af68/yellow = $YELLOW/" \
  "$TDIR/polybar/config.ini"

cat > "$TDIR/polybar/colors.ini" << COLS
[colors]
background = $BG
foreground = $FG
primary = $PRIMARY
secondary = $SECONDARY
alert = $ALERT
disabled = $DISABLED
green = $GREEN
pink = $PINK
yellow = $YELLOW
COLS
echo "  Polybar ✓"

# ===== ROFI =====
cp "$TEMPLATE/rofi/config.rasi" "$TDIR/rofi/config.rasi"
sed -i \
  -e "s/background:     #1a1b26/background:     $BG/" \
  -e "s/background-alt: #303858/background-alt: $BW/" \
  -e "s/foreground:     #c0caf5/foreground:     $FG/" \
  -e "s/selected:       #7aa2f7/selected:       $PRIMARY/" \
  -e "s/urgent:         #f7768e/urgent:         $ALERT/" \
  -e "s/border-col:     #383050/border-col:     $BS/" \
  -e "s/border-color:   #383050/border-color:   $BS/" \
  -e "s/placeholder-color: #383050/placeholder-color: $BS/" \
  -e "s/lightbg:        #303858/lightbg:        $BW/" \
  -e "s/lightfg:        #7aa2f7/lightfg:        $PRIMARY/" \
  -e "s/red:            #f7768e/red:            $ALERT/" \
  -e "s/blue:           #7aa2f7/blue:           $PRIMARY/" \
  "$TDIR/rofi/config.rasi"
echo "  Rofi ✓"

# ===== DUNST =====
cp "$TEMPLATE/dunst/dunstrc" "$TDIR/dunst/dunstrc"
sed -i \
  -e "s/background = \"#1a1b26\"/background = \"$BG\"/" \
  -e "s/foreground = \"#c0caf5\"/foreground = \"$FG\"/" \
  -e "s/frame_color = \"#73daca\"/frame_color = \"$DUNST_FRAME\"/" \
  -e "s/highlight = \"#7aa2f7\"/highlight = \"$PRIMARY\"/" \
  "$TDIR/dunst/dunstrc"
echo "  Dunst ✓"

# ===== I3 =====
cp "$TEMPLATE/i3/colors.conf" "$TDIR/i3/colors.conf"
sed -i \
  -e "s/set \\\$bg        #1a1b26/set \$bg        $BG/" \
  -e "s/set \\\$bg-alt    #2f3347/set \$bg-alt    $C0/" \
  -e "s/set \\\$fg        #c0caf5/set \$fg        $FG/" \
  -e "s/set \\\$primary   #7aa2f7/set \$primary   $PRIMARY/" \
  -e "s/set \\\$secondary #73daca/set \$secondary $SECONDARY/" \
  -e "s/set \\\$alert     #f7768e/set \$alert     $ALERT/" \
  -e "s/set \\\$disabled  #565f89/set \$disabled  $DISABLED/" \
  -e "s/set \\\$green     #9ece6a/set \$green     $GREEN/" \
  -e "s/set \\\$pink      #bb9af7/set \$pink      $PINK/" \
  -e "s/set \\\$yellow    #e0af68/set \$yellow    $YELLOW/" \
  "$TDIR/i3/colors.conf"
echo "  i3 ✓"

# ===== ALACRITTY =====
cp "$TEMPLATE/alacritty/theme.toml" "$TDIR/alacritty/theme.toml"
sed -i \
  -e "s/background = \"#1a1b26\"/background = \"$BG\"/" \
  -e "s/foreground = \"#c0caf5\"/foreground = \"$FG\"/" \
  -e "s/black   = \"#2f3347\"/black   = \"$C0\"/" \
  -e "s/red     = \"#f7768e\"/red     = \"$C1\"/" \
  -e "s/green   = \"#9ece6a\"/green   = \"$C2\"/" \
  -e "s/yellow  = \"#e0af68\"/yellow  = \"$C3\"/" \
  -e "s/blue    = \"#7aa2f7\"/blue    = \"$C4\"/" \
  -e "s/magenta = \"#bb9af7\"/magenta = \"$C5\"/" \
  -e "s/cyan    = \"#73daca\"/cyan    = \"$C6\"/" \
  -e "s/white   = \"#c0caf5\"/white   = \"$C7\"/" \
  -e "s/black   = \"#565f89\"/black   = \"$C8\"/" \
  -e "s/red     = \"#f7768e\"/red     = \"$C9\"/" \
  -e "s/green   = \"#9ece6a\"/green   = \"$C10\"/" \
  -e "s/yellow  = \"#e0af68\"/yellow  = \"$C11\"/" \
  -e "s/blue    = \"#7aa2f7\"/blue    = \"$C12\"/" \
  -e "s/magenta = \"#bb9af7\"/magenta = \"$C13\"/" \
  -e "s/cyan    = \"#73daca\"/cyan    = \"$C14\"/" \
  -e "s/white   = \"#ffffff\"/white   = \"$C15\"/" \
  "$TDIR/alacritty/theme.toml"
echo "  Alacritty ✓"

# ===== CONKY =====
cp "$TEMPLATE/conky/conky.conf" "$TDIR/conky/conky.conf"
sed -i \
  -e "s/default_color = '#c0caf5'/default_color = '$FG'/" \
  -e "s/color0 = '#7aa2f7'/color0 = '$PRIMARY'/" \
  -e "s/color1 = '#bb9af7'/color1 = '$PINK'/" \
  -e "s/color2 = '#73daca'/color2 = '$SECONDARY'/" \
  -e "s/color3 = '#9ece6a'/color3 = '$GREEN'/" \
  -e "s/color4 = '#e0af68'/color4 = '$YELLOW'/" \
  -e "s/#7aa2f7/$PRIMARY/g" \
  "$TDIR/conky/conky.conf"
echo "  Conky ✓"

# ===== BTOP =====
cp "$TEMPLATE/btop/theme.theme" "$TDIR/btop/theme.theme"
sed -i \
  -e "s/main_bg.*=.*\"#1a1b26\"/theme[main_bg]=\"$BG\"/" \
  -e "s/main_fg.*=.*\"#c0caf5\"/theme[main_fg]=\"$FG\"/" \
  -e "s/title.*=.*\"#c0caf5\"/theme[title]=\"$FG\"/" \
  -e "s/hi_fg.*=.*\"#7aa2f7\"/theme[hi_fg]=\"$PRIMARY\"/" \
  -e "s/selected_bg.*=.*\"#7aa2f7\"/theme[selected_bg]=\"$PRIMARY\"/" \
  -e "s/selected_fg.*=.*\"#1a1b26\"/theme[selected_fg]=\"$BG\"/" \
  -e "s/inactive_fg.*=.*\"#565f89\"/theme[inactive_fg]=\"$DISABLED\"/" \
  -e "s/graph_text.*=.*\"#c0caf5\"/theme[graph_text]=\"$FG\"/" \
  -e "s/meter_bg.*=.*\"#24283b\"/theme[meter_bg]=\"$C0\"/" \
  -e "s/proc_misc.*=.*\"#7aa2f7\"/theme[proc_misc]=\"$PRIMARY\"/" \
  -e "s/cpu_box.*=.*\"#7aa2f7\"/theme[cpu_box]=\"$PRIMARY\"/" \
  -e "s/mem_box.*=.*\"#9ece6a\"/theme[mem_box]=\"$GREEN\"/" \
  -e "s/net_box.*=.*\"#f7768e\"/theme[net_box]=\"$ALERT\"/" \
  -e "s/proc_box.*=.*\"#73daca\"/theme[proc_box]=\"$SECONDARY\"/" \
  -e "s/div_line.*=.*\"#364049\"/theme[div_line]=\"$DUNST_FRAME\"/" \
  -e "s/temp_start.*=.*\"#7aa2f7\"/theme[temp_start]=\"$PRIMARY\"/" \
  -e "s/temp_mid.*=.*\"#bb9af7\"/theme[temp_mid]=\"$PINK\"/" \
  -e "s/temp_end.*=.*\"#f7768e\"/theme[temp_end]=\"$ALERT\"/" \
  -e "s/cpu_start.*=.*\"#7aa2f7\"/theme[cpu_start]=\"$PRIMARY\"/" \
  -e "s/cpu_mid.*=.*\"#73daca\"/theme[cpu_mid]=\"$SECONDARY\"/" \
  -e "s/cpu_end.*=.*\"#9ece6a\"/theme[cpu_end]=\"$GREEN\"/" \
  -e "s/free_start.*=.*\"#9ece6a\"/theme[free_start]=\"$GREEN\"/" \
  -e "s/free_mid.*=.*\"#73daca\"/theme[free_mid]=\"$SECONDARY\"/" \
  -e "s/free_end.*=.*\"#7aa2f7\"/theme[free_end]=\"$PRIMARY\"/" \
  -e "s/cached_start.*=.*\"#73daca\"/theme[cached_start]=\"$SECONDARY\"/" \
  -e "s/cached_mid.*=.*\"#7aa2f7\"/theme[cached_mid]=\"$PRIMARY\"/" \
  -e "s/cached_end.*=.*\"#bb9af7\"/theme[cached_end]=\"$PINK\"/" \
  -e "s/available_start.*=.*\"#e0af68\"/theme[available_start]=\"$YELLOW\"/" \
  -e "s/available_mid.*=.*\"#f7768e\"/theme[available_mid]=\"$ALERT\"/" \
  -e "s/available_end.*=.*\"#ff9e64\"/theme[available_end]=\"$YELLOW\"/" \
  -e "s/used_start.*=.*\"#7aa2f7\"/theme[used_start]=\"$PRIMARY\"/" \
  -e "s/used_mid.*=.*\"#bb9af7\"/theme[used_mid]=\"$PINK\"/" \
  -e "s/used_end.*=.*\"#f7768e\"/theme[used_end]=\"$ALERT\"/" \
  -e "s/download_start.*=.*\"#7aa2f7\"/theme[download_start]=\"$PRIMARY\"/" \
  -e "s/download_mid.*=.*\"#9ece6a\"/theme[download_mid]=\"$GREEN\"/" \
  -e "s/download_end.*=.*\"#73daca\"/theme[download_end]=\"$SECONDARY\"/" \
  -e "s/upload_start.*=.*\"#f7768e\"/theme[upload_start]=\"$ALERT\"/" \
  -e "s/upload_mid.*=.*\"#bb9af7\"/theme[upload_mid]=\"$PINK\"/" \
  -e "s/upload_end.*=.*\"#7aa2f7\"/theme[upload_end]=\"$PRIMARY\"/" \
  -e "s/process_start.*=.*\"#9ece6a\"/theme[process_start]=\"$GREEN\"/" \
  -e "s/process_mid.*=.*\"#7aa2f7\"/theme[process_mid]=\"$PRIMARY\"/" \
  -e "s/process_end.*=.*\"#565f89\"/theme[process_end]=\"$DISABLED\"/" \
  "$TDIR/btop/theme.theme"
echo "  Btop ✓"

# ===== CAVA =====
cat > "$TDIR/cava/config" << CAVA
[color]
gradient = 1
gradient_color_1 = '$C6'
gradient_color_2 = '$C4'
gradient_color_3 = '$C5'
gradient_color_4 = '$C1'
gradient_color_5 = '$PRIMARY'
gradient_color_6 = '$SECONDARY'
gradient_color_7 = '$GREEN'
gradient_color_8 = '$C6'
CAVA
echo "  Cava ✓"

# ===== PICOM (copiar template, ya tiene animaciones estándar) =====
cp "$TEMPLATE/picom/picom.conf" "$TDIR/picom/picom.conf"
echo "  Picom ✓"

# ===== WALLPAPERS =====
if [ -d "/tmp/omarchy-basecamp/themes/hackerman/backgrounds" ]; then
  cp /tmp/omarchy-basecamp/themes/hackerman/backgrounds/* "$TDIR/backgrounds/"
  echo "  Wallpapers copiados del repo Omarchy ✓"
else
  # Si no hay wallpapers oficiales, copiar uno genérico
  cp "$TEMPLATE/backgrounds/"* "$TDIR/backgrounds/" 2>/dev/null || true
  echo "  Wallpapers: usando defaults ✓"
fi

# ===== OPENCODE THEME =====
cat > "$HOME/.config/opencode/themes/$THEME.json" << OCODE
{
  "\$schema": "https://opencode.ai/theme.json",
  "defs": {
    "bg": "$BG",
    "fg": "$FG",
    "primary": "$PRIMARY",
    "secondary": "$SECONDARY",
    "accent": "$PINK",
    "error": "$ALERT",
    "warning": "$YELLOW",
    "success": "$GREEN",
    "info": "$PRIMARY"
  },
  "theme": {
    "primary": "$PRIMARY",
    "secondary": "$SECONDARY",
    "accent": "$PINK",
    "error": "$ALERT",
    "warning": "$YELLOW",
    "success": "$GREEN",
    "info": "$PRIMARY",
    "text": "$FG",
    "textMuted": "$SECONDARY",
    "background": "$BG",
    "backgroundPanel": "$BG",
    "backgroundElement": "$BG_ALT",
    "backgroundMenu": "$BG",
    "border": "$DISABLED",
    "borderActive": "$PRIMARY",
    "borderSubtle": "$BG_ALT",
    "selectedListItemText": "$FG",
    "syntaxComment": "$DISABLED",
    "syntaxKeyword": "$PINK",
    "syntaxFunction": "$PRIMARY",
    "syntaxVariable": "$FG",
    "syntaxString": "$GREEN",
    "syntaxNumber": "$YELLOW",
    "syntaxType": "$SECONDARY",
    "syntaxOperator": "$SECONDARY",
    "syntaxPunctuation": "$SECONDARY"
  }
}
OCODE
echo "  OpenCode theme ✓"

echo ""
echo "✓ Tema Hackerman creado exitosamente en $TDIR"
ls -la "$TDIR"/*/
