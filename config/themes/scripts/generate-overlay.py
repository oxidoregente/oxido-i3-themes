#!/usr/bin/env python3
"""Generate color palette overlay for theme preview screenshots.

Usage: generate-overlay.py WIDTH THEME_NAME BG BG_ALT FG PRIMARY SECONDARY ALERT DISABLED GREEN YELLOW PINK OUTPUT.png
"""
import sys
from PIL import Image, ImageDraw, ImageFont

W = int(sys.argv[1])
THEME = sys.argv[2]
colors = {
    'bg': sys.argv[3],
    'bg_alt': sys.argv[4],
    'fg': sys.argv[5],
    'primary': sys.argv[6],
    'secondary': sys.argv[7],
    'alert': sys.argv[8],
    'disabled': sys.argv[9],
    'green': sys.argv[10],
    'yellow': sys.argv[11],
    'pink': sys.argv[12],
}
OUTPUT = sys.argv[13]

H = 130
img = Image.new('RGBA', (W, H), f"#{colors['bg']}")
draw = ImageDraw.Draw(img)

FONT_BOLD = "/home/oxido/.local/share/fonts/IosevkaTermNerdFontMono-Bold.ttf"
FONT_REG = "/home/oxido/.local/share/fonts/IosevkaTermNerdFontMono-Regular.ttf"
font_name = ImageFont.truetype(FONT_BOLD, 40)
font_hex = ImageFont.truetype(FONT_REG, 12)

# Top accent line (primary)
draw.rectangle([(0, 0), (W, 5)], fill=f"#{colors['primary']}")

# Bottom accent line (disabled)
draw.rectangle([(0, H - 3), (W, H)], fill=f"#{colors['disabled']}")

# Theme name on the left
name_x = 18
name_y = 28
draw.text((name_x, name_y), THEME.upper(), fill=f"#{colors['primary']}", font=font_name)

# "color palette" subtitle
draw.text((name_x, 72), "color palette", fill=f"#{colors['fg']}", font=font_hex)

# Color swatches (1 row of 10)
color_keys = ['bg', 'bg_alt', 'fg', 'primary', 'secondary',
              'alert', 'disabled', 'green', 'yellow', 'pink']
color_labels = ['bg', 'bg-alt', 'fg', 'primary', 'secondary',
                'alert', 'disabled', 'green', 'yellow', 'pink']

# Ensure all colors are non-empty; fill missing with a fallback
fallback = "44475a"
for k in colors:
    if not colors[k]:
        print(f"  ⚠ Color '{k}' vacío, usando fallback #{fallback}", file=sys.stderr)
        colors[k] = fallback

swatch_start_x = 340
swatch_area_w = W - swatch_start_x - 12
num_swatches = len(color_keys)
slot_w = swatch_area_w // num_swatches
swatch_w = min(slot_w - 8, 90)
swatch_h = 30
swatch_y = 40

for i, key in enumerate(color_keys):
    x = swatch_start_x + i * slot_w + (slot_w - swatch_w) // 2
    color_val = colors[key]
    draw.rectangle([(x, swatch_y), (x + swatch_w, swatch_y + swatch_h)],
                   fill=f"#{color_val}")

    label_x = x + swatch_w // 2
    hex_label = f"#{color_val}"
    bbox = draw.textbbox((0, 0), hex_label, font=font_hex)
    label_w = bbox[2] - bbox[0]
    draw.text((label_x - label_w // 2, swatch_y + swatch_h + 4),
              hex_label, fill=f"#{colors['fg']}", font=font_hex)

img.save(OUTPUT)
print(f"Overlay saved: {OUTPUT} ({W}x{H})")
