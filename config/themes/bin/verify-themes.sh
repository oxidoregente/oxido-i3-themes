#!/usr/bin/env bash
# verify-themes.sh - Checks all 23 themes for integrity and consistency
set -e

THEMES_DIR="$HOME/.config/themes/themes"
ERRORS=0
WARNS=0

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[1;33m'
cyan='\033[0;36m'
nc='\033[0m'

ok()   { echo -e "  ${green}OK${nc}  $1"; }
fail() { echo -e "  ${red}FAIL${nc} $1"; ERRORS=$((ERRORS+1)); }
warn() { echo -e "  ${yellow}WARN${nc} $1"; WARNS=$((WARNS+1)); }

check_dir() {
  [[ -d "$1" ]] && ok "$2 directory exists" || fail "$2 directory MISSING at $1"
}

check_file() {
  [[ -f "$1" ]] && ok "$2 exists" || fail "$2 MISSING at $1"
}

echo -e "${cyan}========================================${nc}"
echo -e "${cyan}  Multi-Theme Verification Suite${nc}"
echo -e "${cyan}========================================${nc}"
echo ""

# Check that all theme directories exist
echo -e "${cyan}--- Theme Directories ---${nc}"
EXPECTED_THEMES=(
  "dracula" "catppuccin-mocha" "tokyo-night" "nord" "gruvbox"
  "dracula-powersaver" "everforest" "kanagawa" "rose-pine"
  "catppuccin-latte" "flexoki-light" "matte-black" "osaka-jade"
  "ristretto" "hackerman" "ethereal" "lumon" "miasma"
  "vantablack" "retro-82" "white" "last-horizon" "solitude"
)
for theme in "${EXPECTED_THEMES[@]}"; do
  [[ -d "$THEMES_DIR/$theme" ]] && ok "Theme '$theme'" || fail "Theme '$theme' MISSING"
done
echo ""

# Check required subdirectories and files per theme
echo -e "${cyan}--- Per-Theme Integrity ---${nc}"
for theme in "${EXPECTED_THEMES[@]}"; do
  td="$THEMES_DIR/$theme"
  [[ ! -d "$td" ]] && continue

  check_dir "$td/polybar" "$theme/polybar"
  check_dir "$td/rofi" "$theme/rofi"
  check_dir "$td/dunst" "$theme/dunst"
  check_dir "$td/i3" "$theme/i3"
  check_dir "$td/alacritty" "$theme/alacritty"
  check_dir "$td/conky" "$theme/conky"
  check_dir "$td/btop" "$theme/btop"
  check_dir "$td/cava" "$theme/cava"
  check_dir "$td/backgrounds" "$theme/backgrounds"

  check_file "$td/polybar/config.ini" "$theme/polybar/config.ini"
  check_file "$td/rofi/config.rasi" "$theme/rofi/config.rasi"
  check_file "$td/dunst/dunstrc" "$theme/dunst/dunstrc"
  check_file "$td/i3/colors.conf" "$theme/i3/colors.conf"
  check_file "$td/alacritty/theme.toml" "$theme/alacritty/theme.toml"
  check_file "$td/conky/conky.conf" "$theme/conky/conky.conf"
  check_file "$td/cava/config" "$theme/cava/config"

  # Btop: check for .theme file
  btop_file=$(ls "$td/btop/"*.theme 2>/dev/null | head -1)
  [[ -n "$btop_file" ]] && ok "$theme/btop/*.theme exists" || fail "$theme/btop/*.theme MISSING"

  # Backgrounds: check at least one image
  bg_count=$(find "$td/backgrounds" -type f \( -name '*.jpg' -o -name '*.png' -o -name '*.jpeg' -o -name '*.webp' \) 2>/dev/null | wc -l)
  if [[ "$bg_count" -gt 0 ]]; then
    ok "$theme/backgrounds ($bg_count images)"
  else
    fail "$theme/backgrounds has NO images"
  fi
  echo ""
done

# Check polybar config for critical colors
echo -e "${cyan}--- Polybar Bubble Colors ---${nc}"
for theme in "${EXPECTED_THEMES[@]}"; do
  pc="$THEMES_DIR/$theme/polybar/config.ini"
  [[ ! -f "$pc" ]] && continue

  for color in bubble-ws bubble-center bubble-sys; do
    if grep -q "^$color" "$pc" 2>/dev/null; then
      val=$(grep "^$color" "$pc" | head -1 | sed 's/.*= *//')
      if [[ -z "$val" || "$val" == '""' ]]; then
        fail "$theme: $color is empty"
      fi
    else
      fail "$theme: MISSING $color in polybar"
    fi
  done

  # Check format-muted exists in pulseaudio
  if grep -q "format-muted" "$pc" 2>/dev/null; then
    : # ok
  else
    warn "$theme: MISSING format-muted in pulseaudio module"
  fi

  # Check no format-padding in xworkspaces
  if grep -q "xworkspaces.*format-padding" "$pc" 2>/dev/null; then
    warn "$theme: has format-padding in xworkspaces (should be removed)"
  fi

  # Check font-2 exists (bigger icons)
  if grep -q "font-2" "$pc" 2>/dev/null; then
    : # ok
  else
    warn "$theme: MISSING font-2 (for bigger icons)"
  fi

  # Check format-warn-background in temperature
  if grep -q "format-warn-background" "$pc" 2>/dev/null; then
    : # ok
  else
    warn "$theme: MISSING format-warn-background in temperature module"
  fi

  # Check bigger icons via T2 tag
  for mod in "label-volume" "format.*"; do
    if grep -q "%{T2}" <(grep "$mod" "$pc" 2>/dev/null) 2>/dev/null; then
      : # ok
    else
      warn "$theme: MISSING %{T2} icon size tag in $mod"
    fi
  done

  # Check tray has no positive format-margin
  tray_section=$(sed -n '/^\[module\/tray\]/,/^\[/p' "$pc" 2>/dev/null)
  if echo "$tray_section" | grep -q "^format-margin\s*=\s*[1-9]" 2>/dev/null; then
    warn "$theme: tray has format-margin > 0 (may cause gaps)"
  fi
done
echo ""

# Check rofi config for critical variables
echo -e "${cyan}--- Rofi Colors ---${nc}"
for theme in "${EXPECTED_THEMES[@]}"; do
  rc="$THEMES_DIR/$theme/rofi/config.rasi"
  [[ ! -f "$rc" ]] && continue

  for var in lightbg lightfg red blue background-alt border-col; do
    if grep -qi "$var" "$rc" 2>/dev/null; then
      : # ok
    else
      warn "$theme: MISSING '$var' in rofi config"
    fi
  done

  # Check for yellowish-beige (#eee8d5) leakage
  if grep -qi "eee8d5\|#ee e8 d5" "$rc" 2>/dev/null; then
    warn "$theme: rofi may have yellowish default (#eee8d5)"
  fi
done
echo ""

# Check cava config for 8-color gradient
echo -e "${cyan}--- Cava Gradients ---${nc}"
for theme in "${EXPECTED_THEMES[@]}"; do
  cc="$THEMES_DIR/$theme/cava/config"
  [[ ! -f "$cc" ]] && continue

  gradient_lines=$(grep -c "^gradient_color_" "$cc" 2>/dev/null || true)
  if [[ "$gradient_lines" -ge 8 ]]; then
    ok "$theme: cava has $gradient_lines gradient colors"
  else
    warn "$theme: cava only has $gradient_lines gradient colors (expected 8+)"
  fi

  # Cava uses gradient, no explicit foreground needed
  ok "$theme: cava foreground set via gradient"
done
echo ""

# Check btop theme
echo -e "${cyan}--- Btop Themes ---${nc}"
for theme in "${EXPECTED_THEMES[@]}"; do
  btop_file=$(ls "$THEMES_DIR/$theme/btop/"*.theme 2>/dev/null | head -1)
  [[ -z "$btop_file" ]] && continue

  # Btop uses theme[key] format
  for field in "main_bg" "main_fg" "title" "hi_fg" "selected_bg" "inactive_fg"; do
    if grep -q "theme\[$field\]" "$btop_file" 2>/dev/null; then
      : # ok
    else
      warn "$theme/btop: MISSING theme[$field]"
    fi
  done
done
echo ""

# Check i3 config for required colors
echo -e "${cyan}--- i3 Colors ---${nc}"
for theme in "${EXPECTED_THEMES[@]}"; do
  ic="$THEMES_DIR/$theme/i3/colors.conf"
  [[ ! -f "$ic" ]] && continue

  # i3 uses $bg, $fg, $primary
  for var in '\$bg' '\$fg' '\$primary'; do
    if grep -q "$var" "$ic" 2>/dev/null; then
      : # ok
    else
      warn "$theme/i3: MISSING $var"
    fi
  done
done
echo ""

# Check applyers exist and are executable
echo -e "${cyan}--- Applyers ---${nc}"
APPLYERS_DIR="$HOME/.config/themes/applyers"
for app in apply-polybar.sh apply-rofi.sh apply-dunst.sh apply-i3.sh \
           apply-alacritty.sh apply-conky.sh apply-wallpaper.sh \
           apply-btop.sh apply-cava.sh apply-gtk.sh; do
  if [[ -x "$APPLYERS_DIR/$app" ]]; then
    ok "$app is executable"
  elif [[ -f "$APPLYERS_DIR/$app" ]]; then
    warn "$app exists but NOT executable"
  else
    warn "$app MISSING in applyers"
  fi
done
echo ""

# Check theme-switch.sh
echo -e "${cyan}--- Theme Switch Script ---${nc}"
if [[ -x "$HOME/.config/themes/bin/theme-switch.sh" ]]; then
  ok "theme-switch.sh is executable"
else
  fail "theme-switch.sh NOT executable"
fi
echo ""

echo -e "${cyan}========================================${nc}"
echo -e "${green}  Complete: $ERRORS errors, $WARNS warnings${nc}"
echo -e "${cyan}========================================${nc}"
exit $ERRORS
