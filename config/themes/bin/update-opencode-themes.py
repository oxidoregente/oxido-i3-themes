#!/usr/bin/env python3
import os
import json
import configparser

THEMES_DIR = os.path.expanduser("~/.config/themes/themes")
OCODE_THEMES_DIR = os.path.expanduser("~/.config/opencode/themes")

def get_colors(theme_name):
    colors_file = os.path.join(THEMES_DIR, theme_name, "polybar", "colors.ini")
    config_file = os.path.join(THEMES_DIR, theme_name, "polybar", "config.ini")
    
    file_to_read = None
    if os.path.exists(colors_file):
        file_to_read = colors_file
    elif os.path.exists(config_file):
        file_to_read = config_file
    
    if not file_to_read:
        return None
    
    config = configparser.ConfigParser(interpolation=None)
    config.read(file_to_read)
    if 'colors' not in config:
        return None
    
    return dict(config['colors'])

def main():
    if not os.path.exists(OCODE_THEMES_DIR):
        os.makedirs(OCODE_THEMES_DIR)

    for theme_name in os.listdir(THEMES_DIR):
        theme_path = os.path.join(THEMES_DIR, theme_name)
        if not os.path.isdir(theme_path):
            continue
        
        colors = get_colors(theme_name)
        if not colors:
            print(f"Skipping {theme_name}: no colors.ini found")
            continue
        
        print(f"Updating opencode theme: {theme_name}")
        
        # Base colors
        bg = colors.get('background', '#1a1b26')
        bg_alt = colors.get('background-alt', bg)
        fg = colors.get('foreground', '#c0caf5')
        primary = colors.get('primary', '#7aa2f7')
        secondary = colors.get('secondary', '#73daca')
        alert = colors.get('alert', '#f7768e')
        disabled = colors.get('disabled', '#565f89')
        green = colors.get('green', '#9ece6a')
        yellow = colors.get('yellow', '#e0af68')
        pink = colors.get('pink', '#bb9af7')

        theme_json = {
            "$schema": "https://opencode.ai/theme.json",
            "defs": {
                "bg": bg,
                "fg": fg,
                "primary": primary,
                "secondary": secondary,
                "accent": pink,
                "error": alert,
                "warning": yellow,
                "success": green,
                "info": primary
            },
            "theme": {
                "primary": primary,
                "secondary": secondary,
                "accent": pink,
                "error": alert,
                "warning": yellow,
                "success": green,
                "info": primary,
                "text": fg,
                "textMuted": secondary,
                "background": bg,
                "backgroundPanel": bg,
                "backgroundElement": bg_alt,
                "backgroundMenu": bg,
                "border": disabled,
                "borderActive": primary,
                "borderSubtle": bg_alt,
                "selectedListItemText": fg,
                # Syntax (fallbacks to palette)
                "syntaxComment": disabled,
                "syntaxKeyword": pink,
                "syntaxFunction": primary,
                "syntaxVariable": fg,
                "syntaxString": green,
                "syntaxNumber": yellow,
                "syntaxType": secondary,
                "syntaxOperator": secondary,
                "syntaxPunctuation": secondary
            }
        }
        
        with open(os.path.join(OCODE_THEMES_DIR, f"{theme_name}.json"), 'w') as f:
            json.dump(theme_json, f, indent=2)

    print("All opencode themes updated successfully!")

if __name__ == "__main__":
    main()
