#!/usr/bin/env python3
import os, re, sys

# Detectar si estamos en el repo o en .config
REPO_DIR = "/home/oxido/Documentos/oxido-i3-themes"
if os.path.isdir(REPO_DIR):
    THEMES_DIR = os.path.join(REPO_DIR, "config/themes/themes")
    TEMPLATE = os.path.join(THEMES_DIR, "tokyo-night", "dunst", "dunstrc")
else:
    THEMES_DIR = os.path.expanduser("~/.config/themes/themes")
    TEMPLATE = os.path.join(THEMES_DIR, "tokyo-night", "dunst", "dunstrc")

def load_colors(name):
    tdir = os.path.join(THEMES_DIR, name)
    ci = os.path.join(tdir, "polybar", "colors.ini")
    if os.path.exists(ci):
        c = {}
        with open(ci) as f:
            for line in f:
                if '=' in line:
                    k, v = line.strip().split('=', 1)
                    c[k.strip()] = v.strip()
        return c
    pi = os.path.join(tdir, "polybar", "config.ini")
    if os.path.exists(pi):
        c = {}
        in_colors = False
        with open(pi) as f:
            for line in f:
                s = line.strip()
                if s == '[colors]':
                    in_colors = True; continue
                if in_colors:
                    if s.startswith('['): break
                    if '=' in s:
                        k, v = s.split('=', 1)
                        c[k.strip()] = v.strip()
        return c
    return {}

if not os.path.exists(TEMPLATE):
    print(f"Error: Plantilla no encontrada en {TEMPLATE}")
    sys.exit(1)

themes = {}
for d in sorted(os.listdir(THEMES_DIR)):
    tdir = os.path.join(THEMES_DIR, d)
    if not os.path.isdir(tdir) or d.startswith('.'):
        continue
    colors = load_colors(d)
    if not colors:
        print(f"  ✗ {d}: no colors")
        continue
    themes[d] = {
        'bg': colors.get('background', '#1a1b26'),
        'fg': colors.get('foreground', '#c0caf5'),
        'primary': colors.get('primary', '#7aa2f7'),
        'alert': colors.get('alert', '#f7768e'),
        'disabled': colors.get('disabled', '#565f89'),
        'yellow': colors.get('yellow', '#e0af68'),
    }

print(f"Loaded {len(themes)} themes from {THEMES_DIR}")

with open(TEMPLATE) as f:
    template = f.read()

for name, c in sorted(themes.items()):
    content = template

    # Semi-transparent global bg
    content = content.replace('background = "#1a1b26ee"', f'background = "{c["bg"]}ee"')

    # Opaque bg (urgency low/normal, progress bar bg)
    content = content.replace('background = "#1a1b26"', f'background = "{c["bg"]}"')

    # Global foreground
    content = content.replace('foreground = "#c0caf5"', f'foreground = "{c["fg"]}"')

    # Disabled fg (low urgency)
    content = content.replace('foreground = "#565f89"', f'foreground = "{c["disabled"]}"')

    # All frame_color uses (global→primary, low→disabled, normal→primary, critical→yellow)
    content = content.replace('frame_color = "#7aa2f7"', f'frame_color = "{c["primary"]}"')
    content = content.replace('frame_color = "#565f89"', f'frame_color = "{c["disabled"]}"')
    content = content.replace('frame_color = "#e0af68"', f'frame_color = "{c["yellow"]}"')

    # All highlight uses (global→primary, low→disabled, normal→primary, critical→yellow)
    content = content.replace('highlight = "#7aa2f7"', f'highlight = "{c["primary"]}"')
    content = content.replace('highlight = "#565f89"', f'highlight = "{c["disabled"]}"')
    content = content.replace('highlight = "#e0af68"', f'highlight = "{c["yellow"]}"')

    # Critical urgency bg
    content = content.replace('background = "#f7768e"', f'background = "{c["alert"]}"')

    dst = os.path.join(THEMES_DIR, name, "dunst", "dunstrc")
    with open(dst, 'w') as f:
        f.write(content)
    print(f"  ✓ {name}")

print(f"\nDone: {len(themes)} dunst configs updated.")
