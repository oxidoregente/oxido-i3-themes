#!/usr/bin/env python3
import os
import re

THEMES_DIR = os.path.expanduser("~/Documentos/oxido-i3-themes/config/themes/themes")

def get_brightness(hex_color):
    hex_color = hex_color.lstrip('#')
    if len(hex_color) == 3:
        hex_color = ''.join([c*2 for c in hex_color])
    if len(hex_color) >= 6:
        r = int(hex_color[0:2], 16)
        g = int(hex_color[2:4], 16)
        b = int(hex_color[4:6], 16)
        return (r * 0.299 + g * 0.587 + b * 0.114)
    return 128

def fix_dunstrc(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # 1. Fix urgency_low foreground contrast
    match = re.search(r'\[urgency_low\].*?foreground\s*=\s*"([^"]+)"', content, re.DOTALL)
    if match:
        fg = match.group(1)
        bg_match = re.search(r'\[urgency_low\].*?background\s*=\s*"([^"]+)"', content, re.DOTALL)
        bg = bg_match.group(1) if bg_match else "#000000"
        
        fg_b = get_brightness(fg)
        bg_b = get_brightness(bg)
        
        if abs(fg_b - bg_b) < 60:
            print(f"  Fixing contrast in {filepath}: {fg} on {bg}")
            # Use a more readable foreground (at least 50% brightness or much brighter than bg)
            new_fg = "#8a91a1" if bg_b < 128 else "#4a4a4a"
            content = content.replace(f'foreground = "{fg}"', f'foreground = "{new_fg}"', 1)

    # 2. Modernize: simplify icon_path
    if 'icon_path =' in content:
        content = re.sub(r'icon_path\s*=\s*[^\n]+', '', content)
        if 'enable_recursive_icon_lookup' not in content:
            content = content.replace('[global]', '[global]\n    enable_recursive_icon_lookup = true')

    # 3. Modernize: ensure layer = top (for i3/polybar visibility)
    if 'layer =' not in content:
        content = content.replace('[global]', '[global]\n    layer = top')

    with open(filepath, 'w') as f:
        f.write(content)
    return True

def main():
    for theme in os.listdir(THEMES_DIR):
        dunst_file = os.path.join(THEMES_DIR, theme, "dunst", "dunstrc")
        if os.path.isfile(dunst_file):
            fix_dunstrc(dunst_file)
            print(f"Processed {theme}")

if __name__ == "__main__":
    main()
