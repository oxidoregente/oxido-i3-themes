#!/usr/bin/env python3
"""Fix DND polybar module in all themes.
Moves orphaned sys-pad properties into their proper section."""
import os
from pathlib import Path

themes_dir = Path.home() / '.config/themes/themes'
config_files = sorted(themes_dir.glob('*/polybar/config.ini'))

SYS_PAD_BODY = """type = custom/text
format = <label>
label = " "
label-background = ${colors.bubble-sys}
label-foreground = ${colors.bubble-sys}

"""

fixed = 0
for filepath in config_files:
    with open(filepath, 'r') as f:
        content = f.read()
        lines = content.split('\n')

    result = []
    i = 0
    changed = False
    while i < len(lines):
        line = lines[i]
        stripped = line.strip()

        if stripped == '[module/sys-pad]' and i+1 < len(lines) and lines[i+1].strip() == '[module/dnd]':
            result.append(line)
            result.append(SYS_PAD_BODY.rstrip())
            i += 1  # [module/dnd]

            dnd_start = i
            while i < len(lines) and 'click-left' not in lines[i]:
                i += 1
            if i < len(lines):
                i += 1  # skip click-left line

            orphan_count = 0
            for _ in range(6):
                if i < len(lines):
                    candidate = lines[i].strip()
                    if candidate in ('type = custom/text', 'format = <label>',
                                     'label = " "',
                                     'label-background = ${colors.bubble-sys}',
                                     'label-foreground = ${colors.bubble-sys}',
                                     ''):
                        orphan_count += 1
                        i += 1
                    else:
                        break
                else:
                    break

            # output clean dnd block
            dnd_lines = lines[dnd_start:i - orphan_count]
            for dl in dnd_lines:
                result.append(dl)
            changed = True
        else:
            result.append(line)
            i += 1

    if changed:
        with open(filepath, 'w') as f:
            f.write('\n'.join(result) + '\n')
        fixed += 1
        tname = filepath.parent.parent.name
        print(f'  ✓ {tname}')

print(f'\nFixed {fixed}/{len(config_files)} themes')
