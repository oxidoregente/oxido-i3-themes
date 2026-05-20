#!/usr/bin/env python3
"""Propagate polybar fixes and create cava configs for all themes."""
import os

THEMES_DIR = os.path.expanduser("~/.config/themes/themes")

# Existing themes (7 + 8 new)
all_themes = [
    "dracula", "catppuccin-mocha", "tokyo-night", "nord", "gruvbox",
    "clean-white", "dracula-powersaver",
    "everforest", "kanagawa", "matte-black", "osaka-jade", "ristretto",
    "rose-pine", "catppuccin-latte", "flexoki-light",
]

# Cava gradient colors per theme (8-step gradient using theme palette)
cava_colors = {
    "dracula":         ["#8be9fd","#bd93f9","#ff79c6","#ff5555","#ffb86c","#f1fa8c","#50fa7b","#8be9fd"],
    "catppuccin-mocha":["#89dceb","#89b4fa","#f5c2e7","#f38ba8","#fab387","#f9e2af","#a6e3a1","#89dceb"],
    "tokyo-night":     ["#73daca","#7aa2f7","#bb9af7","#f7768e","#ff9e64","#e0af68","#9ece6a","#73daca"],
    "nord":            ["#88c0d0","#81a1c1","#b48ead","#bf616a","#d08770","#ebcb8b","#a3be8c","#88c0d0"],
    "gruvbox":         ["#83a598","#d79921","#d3869b","#cc241d","#d65d0e","#fabd2f","#b8bb26","#83a598"],
    "clean-white":     ["#a0a0b0","#7c7cf0","#ce93d8","#e53935","#d0a050","#fdd835","#66bb6a","#a0a0b0"],
    "dracula-powersaver":["#88b0d0","#7a7ab0","#cc88cc","#ff6666","#d0a070","#ddd888","#66bb6a","#88b0d0"],
    "everforest":      ["#83c092","#7fbbb3","#d699b6","#e67e80","#dbbc7f","#a7c080","#83c092","#7fbbb3"],
    "kanagawa":        ["#6a9589","#7e9cd8","#957fb8","#c34043","#c0a36e","#76946a","#98bb6c","#6a9589"],
    "matte-black":     ["#bebebe","#e68e0d","#D35F5F","#D35F5F","#FFC107","#FFC107","#b91c1c","#e68e0d"],
    "osaka-jade":      ["#2DD5B7","#509475","#D2689C","#FF5345","#459451","#549e6a","#63b07a","#2DD5B7"],
    "ristretto":       ["#85dacc","#f38d70","#a8a9eb","#fd6883","#f9cc6c","#adda78","#c8e292","#85dacc"],
    "rose-pine":       ["#d7827e","#56949f","#907aa9","#b4637a","#ea9d34","#286983","#56949f","#d7827e"],
    "catppuccin-latte":["#179299","#1e66f5","#ea76cb","#d20f39","#df8e1d","#40a02b","#179299","#1e66f5"],
    "flexoki-light":   ["#3AA99F","#205EA6","#CE5D97","#D14D41","#D0A215","#879A39","#3AA99F","#205EA6"],
}

def fix_polybar_config(filepath, theme_name):
    """Apply all polybar fixes to a config file."""
    with open(filepath) as f:
        content = f.read()
    
    changes = 0
    
    # Fix 1: Remove format-padding from xworkspaces, reduce label-padding
    if "format-padding = 2" in content and "xworkspaces" in content:
        # Check it's the xworkspaces module context
        lines = content.split('\n')
        new_lines = []
        in_xworkspaces = False
        for i, line in enumerate(lines):
            if '[module/xworkspaces]' in line:
                in_xworkspaces = True
            elif line.startswith('[module/'):
                in_xworkspaces = False
            
            if in_xworkspaces:
                if 'format-padding = 2' in line:
                    new_lines.append('#format-padding = 2')
                    changes += 1
                    continue
                # Reduce all label paddings from 2 to 1
                if 'label-' in line and '-padding = 2' in line:
                    new_lines.append(line.replace('-padding = 2', '-padding = 1'))
                    changes += 1
                    continue
            
            new_lines.append(line)
        content = '\n'.join(new_lines)
    
    # Fix 2: Add format-muted to pulseaudio
    if '[module/pulseaudio]' in content and 'format-muted' not in content:
        content = content.replace(
            '[module/pulseaudio]\ntype = internal/pulseaudio\nreverse-scroll = true\nformat-volume = <label-volume>\nformat-volume-background = ${colors.bubble-sys}\nformat-volume-padding = 1\nformat-volume-foreground = ${colors.foreground}',
            '[module/pulseaudio]\ntype = internal/pulseaudio\nreverse-scroll = true\nformat-volume = <label-volume>\nformat-volume-background = ${colors.bubble-sys}\nformat-volume-padding = 1\nformat-volume-foreground = ${colors.foreground}\nformat-muted = <label-muted>\nformat-muted-background = ${colors.bubble-sys}\nformat-muted-padding = 1\nformat-muted-foreground = ${colors.alert}'
        )
        changes += 1
    
    # Fix 3: Change cava format-foreground from green to primary
    if 'format-foreground = ${colors.green}' in content and '[module/cava]' in content:
        content = content.replace(
            'format-foreground = ${colors.green}',
            'format-foreground = ${colors.primary}'
        )
        changes += 1
    
    if changes > 0:
        with open(filepath, 'w') as f:
            f.write(content)
    
    return changes

def create_cava_config(theme_dir, colors_8):
    """Create per-theme terminal cava config."""
    cava_dir = os.path.join(theme_dir, "cava")
    os.makedirs(cava_dir, exist_ok=True)
    
    lines = ["[color]", "gradient = 1", ""]
    for i, col in enumerate(colors_8[:8]):
        lines.append(f"gradient_color_{i+1} = '{col}'")
    
    with open(os.path.join(cava_dir, "config"), 'w') as f:
        f.write('\n'.join(lines) + '\n')

def main():
    for theme in all_themes:
        tdir = os.path.join(THEMES_DIR, theme)
        if not os.path.isdir(tdir):
            print(f"  Skipping {theme} (no dir)")
            continue
        
        # Fix polybar
        polybar_file = os.path.join(tdir, "polybar", "config.ini")
        if os.path.isfile(polybar_file):
            changes = fix_polybar_config(polybar_file, theme)
            print(f"  {theme}: polybar {changes} fix(es)")
        
        # Create cava config
        if theme in cava_colors:
            create_cava_config(tdir, cava_colors[theme])
            print(f"  {theme}: cava config created")

    # Sync opencode themes
    print("\nSyncing opencode themes...")
    os.system(os.path.expanduser("~/.config/themes/bin/update-opencode-themes.py"))

    print("Done!")

if __name__ == "__main__":
    main()
