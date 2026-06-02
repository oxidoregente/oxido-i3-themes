#!/bin/bash
THEMES_DIR="$HOME/.config/themes/themes"

declare -A BG FG PRIMARY SECONDARY ALERT DISABLED GREEN PINK YELLOW
declare -A C0 C1 C2 C3 C4 C5 C6 C7 C8 C9 C10 C11 C12 C13 C14 C15

# ====== DARK THEMES (use Omarchy colors directly) ======

# everforest
BG[everforest]="#2d353b"; FG[everforest]="#d3c6aa"
PRIMARY[everforest]="#7fbbb3"; SECONDARY[everforest]="#83c092"
ALERT[everforest]="#e67e80"; DISABLED[everforest]="#475258"
GREEN[everforest]="#a7c080"; PINK[everforest]="#d699b6"; YELLOW[everforest]="#dbbc7f"
C0[everforest]="#475258"; C1[everforest]="#e67e80"; C2[everforest]="#a7c080"
C3[everforest]="#dbbc7f"; C4[everforest]="#7fbbb3"; C5[everforest]="#d699b6"
C6[everforest]="#83c092"; C7[everforest]="#d3c6aa"; C8[everforest]="#475258"
C9[everforest]="#e67e80"; C10[everforest]="#a7c080"; C11[everforest]="#dbbc7f"
C12[everforest]="#7fbbb3"; C13[everforest]="#d699b6"; C14[everforest]="#83c092"
C15[everforest]="#d3c6aa"
BW[everforest]=$((16#2d)); BW_WIDTH[everforest]=2

# kanagawa
BG[kanagawa]="#1f1f28"; FG[kanagawa]="#dcd7ba"
PRIMARY[kanagawa]="#7e9cd8"; SECONDARY[kanagawa]="#6a9589"
ALERT[kanagawa]="#c34043"; DISABLED[kanagawa]="#54546d"
GREEN[kanagawa]="#76946a"; PINK[kanagawa]="#957fb8"; YELLOW[kanagawa]="#c0a36e"
C0[kanagawa]="#090618"; C1[kanagawa]="#c34043"; C2[kanagawa]="#76946a"
C3[kanagawa]="#c0a36e"; C4[kanagawa]="#7e9cd8"; C5[kanagawa]="#957fb8"
C6[kanagawa]="#6a9589"; C7[kanagawa]="#c8c093"; C8[kanagawa]="#727169"
C9[kanagawa]="#e82424"; C10[kanagawa]="#98bb6c"; C11[kanagawa]="#e6c384"
C12[kanagawa]="#7fb4ca"; C13[kanagawa]="#938aa9"; C14[kanagawa]="#7aa89f"
C15[kanagawa]="#dcd7ba"

# matte-black
BG[matte-black]="#121212"; FG[matte-black]="#bebebe"
PRIMARY[matte-black]="#e68e0d"; SECONDARY[matte-black]="#bebebe"
ALERT[matte-black]="#D35F5F"; DISABLED[matte-black]="#333333"
GREEN[matte-black]="#FFC107"; PINK[matte-black]="#D35F5F"; YELLOW[matte-black]="#FFC107"
C0[matte-black]="#333333"; C1[matte-black]="#D35F5F"; C2[matte-black]="#FFC107"
C3[matte-black]="#b91c1c"; C4[matte-black]="#e68e0d"; C5[matte-black]="#D35F5F"
C6[matte-black]="#bebebe"; C7[matte-black]="#bebebe"; C8[matte-black]="#8a8a8d"
C9[matte-black]="#B91C1C"; C10[matte-black]="#FFC107"; C11[matte-black]="#b90a0a"
C12[matte-black]="#f59e0b"; C13[matte-black]="#B91C1C"; C14[matte-black]="#eaeaea"
C15[matte-black]="#ffffff"

# osaka-jade
BG[osaka-jade]="#111c18"; FG[osaka-jade]="#C1C497"
PRIMARY[osaka-jade]="#509475"; SECONDARY[osaka-jade]="#2DD5B7"
ALERT[osaka-jade]="#FF5345"; DISABLED[osaka-jade]="#53685B"
GREEN[osaka-jade]="#549e6a"; PINK[osaka-jade]="#D2689C"; YELLOW[osaka-jade]="#459451"
C0[osaka-jade]="#23372B"; C1[osaka-jade]="#FF5345"; C2[osaka-jade]="#549e6a"
C3[osaka-jade]="#459451"; C4[osaka-jade]="#509475"; C5[osaka-jade]="#D2689C"
C6[osaka-jade]="#2DD5B7"; C7[osaka-jade]="#F6F5DD"; C8[osaka-jade]="#53685B"
C9[osaka-jade]="#db9f9c"; C10[osaka-jade]="#63b07a"; C11[osaka-jade]="#E5C736"
C12[osaka-jade]="#ACD4CF"; C13[osaka-jade]="#75bbb3"; C14[osaka-jade]="#8CD3CB"
C15[osaka-jade]="#9eebb3"

# ristretto
BG[ristretto]="#2c2525"; FG[ristretto]="#e6d9db"
PRIMARY[ristretto]="#f38d70"; SECONDARY[ristretto]="#85dacc"
ALERT[ristretto]="#fd6883"; DISABLED[ristretto]="#72696a"
GREEN[ristretto]="#adda78"; PINK[ristretto]="#a8a9eb"; YELLOW[ristretto]="#f9cc6c"
C0[ristretto]="#72696a"; C1[ristretto]="#fd6883"; C2[ristretto]="#adda78"
C3[ristretto]="#f9cc6c"; C4[ristretto]="#f38d70"; C5[ristretto]="#a8a9eb"
C6[ristretto]="#85dacc"; C7[ristretto]="#e6d9db"; C8[ristretto]="#948a8b"
C9[ristretto]="#ff8297"; C10[ristretto]="#c8e292"; C11[ristretto]="#fcd675"
C12[ristretto]="#f8a788"; C13[ristretto]="#bebffd"; C14[ristretto]="#9bf1e1"
C15[ristretto]="#f1e5e7"

# ====== LIGHT THEMES (adapt to dark background) ======

# rose-pine (original light: bg=#faf4ed, fg=#575279)
BG[rose-pine]="#232136"; FG[rose-pine]="#e0def4"
PRIMARY[rose-pine]="#56949f"; SECONDARY[rose-pine]="#d7827e"
ALERT[rose-pine]="#b4637a"; DISABLED[rose-pine]="#6e6a86"
GREEN[rose-pine]="#286983"; PINK[rose-pine]="#907aa9"; YELLOW[rose-pine]="#ea9d34"
C0[rose-pine]="#393552"; C1[rose-pine]="#b4637a"; C2[rose-pine]="#286983"
C3[rose-pine]="#ea9d34"; C4[rose-pine]="#56949f"; C5[rose-pine]="#907aa9"
C6[rose-pine]="#d7827e"; C7[rose-pine]="#e0def4"; C8[rose-pine]="#6e6a86"
C9[rose-pine]="#b4637a"; C10[rose-pine]="#286983"; C11[rose-pine]="#ea9d34"
C12[rose-pine]="#56949f"; C13[rose-pine]="#907aa9"; C14[rose-pine]="#d7827e"
C15[rose-pine]="#e0def4"

# catppuccin-latte (original light: bg=#eff1f5, fg=#4c4f69)
BG[catppuccin-latte]="#1e1e2e"; FG[catppuccin-latte]="#cdd6f4"
PRIMARY[catppuccin-latte]="#1e66f5"; SECONDARY[catppuccin-latte]="#179299"
ALERT[catppuccin-latte]="#d20f39"; DISABLED[catppuccin-latte]="#5c5f77"
GREEN[catppuccin-latte]="#40a02b"; PINK[catppuccin-latte]="#ea76cb"; YELLOW[catppuccin-latte]="#df8e1d"
C0[catppuccin-latte]="#bcc0cc"; C1[catppuccin-latte]="#d20f39"; C2[catppuccin-latte]="#40a02b"
C3[catppuccin-latte]="#df8e1d"; C4[catppuccin-latte]="#1e66f5"; C5[catppuccin-latte]="#ea76cb"
C6[catppuccin-latte]="#179299"; C7[catppuccin-latte]="#5c5f77"; C8[catppuccin-latte]="#acb0be"
C9[catppuccin-latte]="#d20f39"; C10[catppuccin-latte]="#40a02b"; C11[catppuccin-latte]="#df8e1d"
C12[catppuccin-latte]="#1e66f5"; C13[catppuccin-latte]="#ea76cb"; C14[catppuccin-latte]="#179299"
C15[catppuccin-latte]="#6c6f85"

# flexoki-light (original light: bg=#FFFCF0, fg=#100F0F)
BG[flexoki-light]="#1c1c1c"; FG[flexoki-light]="#dad8ce"
PRIMARY[flexoki-light]="#205EA6"; SECONDARY[flexoki-light]="#3AA99F"
ALERT[flexoki-light]="#D14D41"; DISABLED[flexoki-light]="#878580"
GREEN[flexoki-light]="#879A39"; PINK[flexoki-light]="#CE5D97"; YELLOW[flexoki-light]="#D0A215"
C0[flexoki-light]="#DAD8CE"; C1[flexoki-light]="#D14D41"; C2[flexoki-light]="#879A39"
C3[flexoki-light]="#D0A215"; C4[flexoki-light]="#205EA6"; C5[flexoki-light]="#CE5D97"
C6[flexoki-light]="#3AA99F"; C7[flexoki-light]="#B7B5AC"; C8[flexoki-light]="#100F0F"
C9[flexoki-light]="#D14D41"; C10[flexoki-light]="#879A39"; C11[flexoki-light]="#D0A215"
C12[flexoki-light]="#4385BE"; C13[flexoki-light]="#CE5D97"; C14[flexoki-light]="#3AA99F"
C15[flexoki-light]="#CECDC3"

# ====== GENERATE THEMES ======

for theme in everforest kanagawa matte-black osaka-jade ristretto rose-pine catppuccin-latte flexoki-light; do
    echo "=== Generating $theme ==="
    TDIR="$THEMES_DIR/$theme"
    
    # Copy template from tokyo-night for structure
    cp "$THEMES_DIR/tokyo-night/polybar/config.ini" "$TDIR/polybar/config.ini"
    cp "$THEMES_DIR/tokyo-night/polybar/colors.ini" "$TDIR/polybar/" 2>/dev/null || true
    cp "$THEMES_DIR/tokyo-night/rofi/config.rasi" "$TDIR/rofi/config.rasi"
    cp "$THEMES_DIR/tokyo-night/dunst/dunstrc" "$TDIR/dunst/dunstrc"
    cp "$THEMES_DIR/tokyo-night/i3/colors.conf" "$TDIR/i3/colors.conf"
    cp "$THEMES_DIR/tokyo-night/conky/conky.conf" "$TDIR/conky/conky.conf"
    cp "$THEMES_DIR/tokyo-night/alacritty/theme.toml" "$TDIR/alacritty/theme.toml"
    cp "$THEMES_DIR/tokyo-night/btop/theme.theme" "$TDIR/btop/theme.theme"
    cp "$THEMES_DIR/tokyo-night/backgrounds/"* "$TDIR/backgrounds/" 2>/dev/null || true
    
    # ====== Replace polybar colors ======
    sed -i "s/background = #1a1b26/background = ${BG[$theme]}/" "$TDIR/polybar/config.ini"
    sed -i "s/foreground = #c0caf5/foreground = ${FG[$theme]}/" "$TDIR/polybar/config.ini"
    sed -i "s/bubble-ws = #303858/bubble-ws = ${BG[$theme]}/" "$TDIR/polybar/config.ini"
    sed -i "s/bubble-center = #304848/bubble-center = ${BG[$theme]}/" "$TDIR/polybar/config.ini"
    sed -i "s/bubble-sys = #383050/bubble-sys = ${BG[$theme]}/" "$TDIR/polybar/config.ini"
    sed -i "s/primary = #7aa2f7/primary = ${PRIMARY[$theme]}/" "$TDIR/polybar/config.ini"
    sed -i "s/secondary = #73daca/secondary = ${SECONDARY[$theme]}/" "$TDIR/polybar/config.ini"
    sed -i "s/alert = #f7768e/alert = ${ALERT[$theme]}/" "$TDIR/polybar/config.ini"
    sed -i "s/disabled = #565f89/disabled = ${DISABLED[$theme]}/" "$TDIR/polybar/config.ini"
    sed -i "s/green = #9ece6a/green = ${GREEN[$theme]}/" "$TDIR/polybar/config.ini"
    sed -i "s/pink = #bb9af7/pink = ${PINK[$theme]}/" "$TDIR/polybar/config.ini"
    sed -i "s/yellow = #e0af68/yellow = ${YELLOW[$theme]}/" "$TDIR/polybar/config.ini"
    
    # ====== Fix bubble colors (darker tints based on theme) ======
    # Use a slightly lighter version of bg with tint
    # We'll approximate by using bg as bubble colors (they're already dark enough)
    # bubble-ws stays as bg (left segment blends with bg - the ws-pad spacer)
    # For proper tinted segments, we'd need to compute per-theme, but for now use bg
    
    # ====== Replace rofi colors ======
    sed -i "s/background:     #1a1b26/background:     ${BG[$theme]}/" "$TDIR/rofi/config.rasi"
    sed -i "s/background-alt: #303858/background-alt: ${BG[$theme]}/" "$TDIR/rofi/config.rasi"
    sed -i "s/foreground:     #c0caf5/foreground:     ${FG[$theme]}/" "$TDIR/rofi/config.rasi"
    sed -i "s/selected:       #7aa2f7/selected:       ${PRIMARY[$theme]}/" "$TDIR/rofi/config.rasi"
    sed -i "s/urgent:         #f7768e/urgent:         ${ALERT[$theme]}/" "$TDIR/rofi/config.rasi"
    sed -i "s/border-col:     #383050/border-col:     ${DISABLED[$theme]}/" "$TDIR/rofi/config.rasi"
    sed -i "s/border-color:   #383050/border-color:   ${DISABLED[$theme]}/" "$TDIR/rofi/config.rasi"
    sed -i "s/placeholder-color: #383050/placeholder-color: ${DISABLED[$theme]}/" "$TDIR/rofi/config.rasi"
    sed -i "s/lightbg:        #303858/lightbg:        ${BG[$theme]}/" "$TDIR/rofi/config.rasi"
    sed -i "s/lightfg:        #7aa2f7/lightfg:        ${PRIMARY[$theme]}/" "$TDIR/rofi/config.rasi"
    sed -i "s/red:            #f7768e/red:            ${ALERT[$theme]}/" "$TDIR/rofi/config.rasi"
    sed -i "s/blue:           #7aa2f7/blue:           ${PRIMARY[$theme]}/" "$TDIR/rofi/config.rasi"
    
    # ====== Replace dunst colors ======
    sed -i "s/background = \"#1a1b26\"/background = \"${BG[$theme]}\"/" "$TDIR/dunst/dunstrc"
    sed -i "s/foreground = \"#c0caf5\"/foreground = \"${FG[$theme]}\"/" "$TDIR/dunst/dunstrc"
    sed -i "s/frame_color = \"#303858\"/frame_color = \"${BG[$theme]}\"/" "$TDIR/dunst/dunstrc"
    sed -i "s/highlight = \"#7aa2f7\"/highlight = \"${PRIMARY[$theme]}\"/" "$TDIR/dunst/dunstrc"
    
    # ====== Replace i3 colors ======
    sed -i "s/set \$bg/#191a26/set \$bg ${BG[$theme]}/" "$TDIR/i3/colors.conf"
    sed -i "s/set \$fg/#c0caf5/set \$fg ${FG[$theme]}/" "$TDIR/i3/colors.conf"
    sed -i "s/set \$primary/#7aa2f7/set \$primary ${PRIMARY[$theme]}/" "$TDIR/i3/colors.conf"
    sed -i "s/set \$alert/#f7768e/set \$alert ${ALERT[$theme]}/" "$TDIR/i3/colors.conf"
    
    # ====== Replace Alacritty ANSI colors ======
    sed -i "s/background = \"#1a1b26\"/background = \"${BG[$theme]}\"/" "$TDIR/alacritty/theme.toml"
    sed -i "s/foreground = \"#c0caf5\"/foreground = \"${FG[$theme]}\"/" "$TDIR/alacritty/theme.toml"
    sed -i "s/black   = \"#414868\"/black   = \"${C0[$theme]}\"/" "$TDIR/alacritty/theme.toml"
    sed -i "s/red     = \"#f7768e\"/red     = \"${C1[$theme]}\"/" "$TDIR/alacritty/theme.toml"
    sed -i "s/green   = \"#9ece6a\"/green   = \"${C2[$theme]}\"/" "$TDIR/alacritty/theme.toml"
    sed -i "s/yellow  = \"#e0af68\"/yellow  = \"${C3[$theme]}\"/" "$TDIR/alacritty/theme.toml"
    sed -i "s/blue    = \"#7aa2f7\"/blue    = \"${C4[$theme]}\"/" "$TDIR/alacritty/theme.toml"
    sed -i "s/magenta = \"#bb9af7\"/magenta = \"${C5[$theme]}\"/" "$TDIR/alacritty/theme.toml"
    sed -i "s/cyan    = \"#7dcfff\"/cyan    = \"${C6[$theme]}\"/" "$TDIR/alacritty/theme.toml"
    sed -i "s/white   = \"#a9b1d6\"/white   = \"${C7[$theme]}\"/" "$TDIR/alacritty/theme.toml"
    
    # Bright colors use same palette for normal/bright (Omarchy style)
    
    # ====== Replace conky colors ======
    sed -i "s/default_color = '#c0caf5'/default_color = '${FG[$theme]//#/#'}/" "$TDIR/conky/conky.conf"
    sed -i "s/color0 = '#7aa2f7'/color0 = '${PRIMARY[$theme]//#/#'}/" "$TDIR/conky/conky.conf"
    sed -i "s/color1 = '#f7768e'/color1 = '${ALERT[$theme]//#/#'}/" "$TDIR/conky/conky.conf"
    
    # ====== Replace btop theme colors ======
    sed -i "s/main_bg\".*= \"#1a1b26\"/main_bg\"=\"${BG[$theme]}\"/" "$TDIR/btop/theme.theme"
    sed -i "s/main_fg\".*#/main_fg\"=\"${FG[$theme]}\"/" "$TDIR/btop/theme.theme"
    
    echo "Done: $theme"
done

echo "=== All themes generated! ==="
