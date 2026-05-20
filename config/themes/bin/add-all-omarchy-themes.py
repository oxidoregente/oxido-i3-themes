#!/usr/bin/env python3
"""Generate all missing Omarchy themes from official repo colors."""
import os, shutil, json, glob

THEMES_DIR = os.path.expanduser("~/.config/themes/themes")
OPENCODE_DIR = os.path.expanduser("~/.config/opencode/themes")
OMARCHY_REPO = "/tmp/omarchy-basecamp/themes"
TEMPLATE = os.path.join(THEMES_DIR, "tokyo-night")

def cp(src, dst):
    if os.path.exists(src):
        shutil.copy2(src, dst)

def cpdir(src, dst):
    if os.path.isdir(src):
        os.makedirs(dst, exist_ok=True)
        for f in os.listdir(src):
            shutil.copy2(os.path.join(src, f), os.path.join(dst, f))

def write(path, content):
    with open(path, 'w') as f:
        f.write(content)

def read(path):
    with open(path) as f:
        return f.read()

# ===== THEME DEFINITIONS =====
themes = {}

# 1. ETHEREAL
themes["ethereal"] = {
    "bg": "#060B1E", "fg": "#ffcead",
    "primary": "#7d82d9", "secondary": "#a3bfd1",
    "alert": "#ED5B5A", "disabled": "#3C486D",
    "green": "#92a593", "pink": "#c89dc1", "yellow": "#E9BB4F",
    "c0": "#3C486D", "c1": "#ED5B5A", "c2": "#92a593", "c3": "#E9BB4F",
    "c4": "#7d82d9", "c5": "#c89dc1", "c6": "#a3bfd1", "c7": "#F99957",
    "c8": "#6d7db6", "c9": "#faaaa9", "c10": "#c4cfc4", "c11": "#f7dc9c",
    "c12": "#c2c4f0", "c13": "#ead7e7", "c14": "#dfeaf0", "c15": "#ffcead",
    "bw": "#0D0E2E", "bc": "#0E1038", "bs": "#101242",
    "df": "#1A1C3E",
}

# 2. LUMON (Severance-inspired)
themes["lumon"] = {
    "bg": "#16242d", "fg": "#d6e2ee",
    "primary": "#8bc9eb", "secondary": "#b4e4f6",
    "alert": "#4d86b0", "disabled": "#304860",
    "green": "#5e95bc", "pink": "#8bc9eb", "yellow": "#6fa4c9",
    "c0": "#1b2d40", "c1": "#4d86b0", "c2": "#5e95bc", "c3": "#6fa4c9",
    "c4": "#6fb8e3", "c5": "#8bc9eb", "c6": "#b4e4f6", "c7": "#d6e2ee",
    "c8": "#304860", "c9": "#73a6cb", "c10": "#86b7d8", "c11": "#9dcae5",
    "c12": "#f2fcff", "c13": "#b1d8ee", "c14": "#d1eef8", "c15": "#ffffff",
    "bw": "#1A2A34", "bc": "#1C3038", "bs": "#1E3440",
    "df": "#1E2E38",
}

# 3. MIASMA
themes["miasma"] = {
    "bg": "#222222", "fg": "#c2c2b0",
    "primary": "#78824b", "secondary": "#c9a554",
    "alert": "#685742", "disabled": "#000000",
    "green": "#5f875f", "pink": "#bb7744", "yellow": "#b36d43",
    "c0": "#000000", "c1": "#685742", "c2": "#5f875f", "c3": "#b36d43",
    "c4": "#78824b", "c5": "#bb7744", "c6": "#c9a554", "c7": "#d7c483",
    "c8": "#666666", "c9": "#685742", "c10": "#5f875f", "c11": "#b36d43",
    "c12": "#78824b", "c13": "#bb7744", "c14": "#c9a554", "c15": "#d7c483",
    "bw": "#282828", "bc": "#2A2A2A", "bs": "#2C2C2C",
    "df": "#2E2E2E",
}

# 4. VANTABLACK (grayscale)
themes["vantablack"] = {
    "bg": "#000000", "fg": "#ffffff",
    "primary": "#8d8d8d", "secondary": "#b0b0b0",
    "alert": "#a4a4a4", "disabled": "#404040",
    "green": "#b6b6b6", "pink": "#9b9b9b", "yellow": "#cecece",
    "c0": "#404040", "c1": "#a4a4a4", "c2": "#b6b6b6", "c3": "#cecece",
    "c4": "#8d8d8d", "c5": "#9b9b9b", "c6": "#b0b0b0", "c7": "#ececec",
    "c8": "#5c5c5c", "c9": "#a4a4a4", "c10": "#b6b6b6", "c11": "#cecece",
    "c12": "#8d8d8d", "c13": "#9b9b9b", "c14": "#b0b0b0", "c15": "#ffffff",
    "bw": "#0A0A0A", "bc": "#0C0C0C", "bs": "#0E0E0E",
    "df": "#1A1A1A",
}

# 5. RETRO 82
themes["retro-82"] = {
    "bg": "#05182e", "fg": "#f6dcac",
    "primary": "#faa968", "secondary": "#8cbfb8",
    "alert": "#f85525", "disabled": "#303442",
    "green": "#028391", "pink": "#3f8f8a", "yellow": "#e97b3c",
    "c0": "#303442", "c1": "#f85525", "c2": "#028391", "c3": "#e97b3c",
    "c4": "#faa968", "c5": "#3f8f8a", "c6": "#8cbfb8", "c7": "#a7c9c6",
    "c8": "#134e5a", "c9": "#f85525", "c10": "#028391", "c11": "#e97b3c",
    "c12": "#faa968", "c13": "#3f8f8a", "c14": "#8cbfb8", "c15": "#f6dcac",
    "bw": "#0A1C34", "bc": "#0C2038", "bs": "#0E2440",
    "df": "#142838",
}

# 6. WHITE (dark-adapted - original was light bg #ffffff)
themes["white"] = {
    "bg": "#1a1a24", "fg": "#c0c0c0",
    "primary": "#6e6e6e", "secondary": "#3e3e3e",
    "alert": "#2a2a2a", "disabled": "#5c5c5c",
    "green": "#3a3a3a", "pink": "#2e2e2e", "yellow": "#4a4a4a",
    "c0": "#c0c0c0", "c1": "#2a2a2a", "c2": "#3a3a3a", "c3": "#4a4a4a",
    "c4": "#1a1a1a", "c5": "#2e2e2e", "c6": "#3e3e3e", "c7": "#000000",
    "c8": "#c0c0c0", "c9": "#2a2a2a", "c10": "#3a3a3a", "c11": "#4a4a4a",
    "c12": "#1a1a1a", "c13": "#2e2e2e", "c14": "#3e3e3e", "c15": "#000000",
    "bw": "#222230", "bc": "#242434", "bs": "#262638",
    "df": "#2a2a38",
}

# 7. LAST HORIZON
themes["last-horizon"] = {
    "bg": "#0c0b0c", "fg": "#FAFCFB",
    "primary": "#b59790", "secondary": "#a5a0b6",
    "alert": "#c38b7b", "disabled": "#584e51",
    "green": "#87a9b0", "pink": "#c4d8e2", "yellow": "#6B5E73",
    "c0": "#0c0b0c", "c1": "#c38b7b", "c2": "#87a9b0", "c3": "#6B5E73",
    "c4": "#b59790", "c5": "#c4d8e2", "c6": "#a5a0b6", "c7": "#cfd3cd",
    "c8": "#584e51", "c9": "#c38b7b", "c10": "#87a9b0", "c11": "#6B5E73",
    "c12": "#b59790", "c13": "#c4d8e2", "c14": "#a5a0b6", "c15": "#e2dddc",
    "bw": "#121112", "bc": "#141314", "bs": "#161516",
    "df": "#1c1b1c",
}

# 8. SOLITUDE
themes["solitude"] = {
    "bg": "#101315", "fg": "#cacccc",
    "primary": "#798186", "secondary": "#aeaeae",
    "alert": "#565d60", "disabled": "#4b4e55",
    "green": "#9fa5a9", "pink": "#aeaeae", "yellow": "#d9dbdc",
    "c0": "#101315", "c1": "#565d60", "c2": "#9fa5a9", "c3": "#d9dbdc",
    "c4": "#798186", "c5": "#aeaeae", "c6": "#707070", "c7": "#cbc2be",
    "c8": "#4b4e55", "c9": "#de6145", "c10": "#343d41", "c11": "#c9c2b4",
    "c12": "#5d6367", "c13": "#9a9a9a", "c14": "#707070", "c15": "#a5aeb4",
    "bw": "#16191b", "bc": "#181b1d", "bs": "#1a1d1f",
    "df": "#1e2123",
}

# ===== TEMPLATE READER =====
tmpl_polybar = read(os.path.join(TEMPLATE, "polybar", "config.ini"))
tmpl_rofi = read(os.path.join(TEMPLATE, "rofi", "config.rasi"))
tmpl_dunst = read(os.path.join(TEMPLATE, "dunst", "dunstrc"))
tmpl_i3 = read(os.path.join(TEMPLATE, "i3", "colors.conf"))
tmpl_alacritty = read(os.path.join(TEMPLATE, "alacritty", "theme.toml"))
tmpl_conky = read(os.path.join(TEMPLATE, "conky", "conky.conf"))
tmpl_btop = read(os.path.join(TEMPLATE, "btop", "theme.theme"))
tmpl_picom = read(os.path.join(TEMPLATE, "picom", "picom.conf"))
tmpl_cava = read(os.path.join(TEMPLATE, "cava", "config"))

# ===== GENERATE THEMES =====
for name, c in sorted(themes.items()):
    print(f"\n=== Generando {name} ===")
    tdir = os.path.join(THEMES_DIR, name)
    omarchy_src = os.path.join(OMARCHY_REPO, name)

    # Create directories
    os.makedirs(os.path.join(tdir, "alacritty"), exist_ok=True)
    os.makedirs(os.path.join(tdir, "backgrounds"), exist_ok=True)
    os.makedirs(os.path.join(tdir, "btop"), exist_ok=True)
    os.makedirs(os.path.join(tdir, "cava"), exist_ok=True)
    os.makedirs(os.path.join(tdir, "conky"), exist_ok=True)
    os.makedirs(os.path.join(tdir, "dunst"), exist_ok=True)
    os.makedirs(os.path.join(tdir, "i3"), exist_ok=True)
    os.makedirs(os.path.join(tdir, "picom"), exist_ok=True)
    os.makedirs(os.path.join(tdir, "polybar"), exist_ok=True)
    os.makedirs(os.path.join(tdir, "rofi"), exist_ok=True)

    # ----- Polybar -----
    content = tmpl_polybar.replace("background = #1a1b26", f"background = {c['bg']}")
    content = content.replace("foreground = #c0caf5", f"foreground = {c['fg']}")
    content = content.replace("bubble-ws = #303858", f"bubble-ws = {c['bw']}")
    content = content.replace("bubble-center = #304848", f"bubble-center = {c['bc']}")
    content = content.replace("bubble-sys = #383050", f"bubble-sys = {c['bs']}")
    content = content.replace("primary = #7aa2f7", f"primary = {c['primary']}")
    content = content.replace("secondary = #73daca", f"secondary = {c['secondary']}")
    content = content.replace("alert = #f7768e", f"alert = {c['alert']}")
    content = content.replace("disabled = #565f89", f"disabled = {c['disabled']}")
    content = content.replace("green = #9ece6a", f"green = {c['green']}")
    content = content.replace("pink = #bb9af7", f"pink = {c['pink']}")
    content = content.replace("yellow = #e0af68", f"yellow = {c['yellow']}")
    write(os.path.join(tdir, "polybar", "config.ini"), content)

    # colors.ini
    cols = f"""[colors]
background = {c['bg']}
foreground = {c['fg']}
primary = {c['primary']}
secondary = {c['secondary']}
alert = {c['alert']}
disabled = {c['disabled']}
green = {c['green']}
pink = {c['pink']}
yellow = {c['yellow']}
"""
    write(os.path.join(tdir, "polybar", "colors.ini"), cols)
    print("  Polybar ✓")

    # ----- Rofi -----
    content = tmpl_rofi
    content = content.replace("background:     #1a1b26", f"background:     {c['bg']}")
    content = content.replace("background-alt: #303858", f"background-alt: {c['bw']}")
    content = content.replace("foreground:     #c0caf5", f"foreground:     {c['fg']}")
    content = content.replace("selected:       #7aa2f7", f"selected:       {c['primary']}")
    content = content.replace("urgent:         #f7768e", f"urgent:         {c['alert']}")
    content = content.replace("border-col:     #383050", f"border-col:     {c['bs']}")
    content = content.replace("border-color:   #383050", f"border-color:   {c['bs']}")
    content = content.replace("placeholder-color: #383050", f"placeholder-color: {c['bs']}")
    content = content.replace("lightbg:        #303858", f"lightbg:        {c['bw']}")
    content = content.replace("lightfg:        #7aa2f7", f"lightfg:        {c['primary']}")
    content = content.replace("red:            #f7768e", f"red:            {c['alert']}")
    content = content.replace("blue:           #7aa2f7", f"blue:           {c['primary']}")
    write(os.path.join(tdir, "rofi", "config.rasi"), content)
    print("  Rofi ✓")

    # ----- Dunst -----
    content = tmpl_dunst
    content = content.replace('background = "#1a1b26"', f'background = "{c["bg"]}"')
    content = content.replace('foreground = "#c0caf5"', f'foreground = "{c["fg"]}"')
    content = content.replace('frame_color = "#73daca"', f'frame_color = "{c["df"]}"')
    content = content.replace('highlight = "#7aa2f7"', f'highlight = "{c["primary"]}"')
    write(os.path.join(tdir, "dunst", "dunstrc"), content)
    print("  Dunst ✓")

    # ----- i3 colors -----
    content = tmpl_i3
    content = content.replace("set $bg        #1a1b26", f"set $bg        {c['bg']}")
    content = content.replace("set $bg-alt    #2f3347", f"set $bg-alt    {c['c0']}")
    content = content.replace("set $fg        #c0caf5", f"set $fg        {c['fg']}")
    content = content.replace("set $primary   #7aa2f7", f"set $primary   {c['primary']}")
    content = content.replace("set $secondary #73daca", f"set $secondary {c['secondary']}")
    content = content.replace("set $alert     #f7768e", f"set $alert     {c['alert']}")
    content = content.replace("set $disabled  #565f89", f"set $disabled  {c['disabled']}")
    content = content.replace("set $green     #9ece6a", f"set $green     {c['green']}")
    content = content.replace("set $pink      #bb9af7", f"set $pink      {c['pink']}")
    content = content.replace("set $yellow    #e0af68", f"set $yellow    {c['yellow']}")
    write(os.path.join(tdir, "i3", "colors.conf"), content)
    print("  i3 ✓")

    # ----- Alacritty -----
    content = tmpl_alacritty
    content = content.replace('background = "#1a1b26"', f'background = "{c["bg"]}"')
    content = content.replace('foreground = "#c0caf5"', f'foreground = "{c["fg"]}"')
    content = content.replace('black   = "#2f3347"', f'black   = "{c["c0"]}"')
    content = content.replace('red     = "#f7768e"', f'red     = "{c["c1"]}"')
    content = content.replace('green   = "#9ece6a"', f'green   = "{c["c2"]}"')
    content = content.replace('yellow  = "#e0af68"', f'yellow  = "{c["c3"]}"')
    content = content.replace('blue    = "#7aa2f7"', f'blue    = "{c["c4"]}"')
    content = content.replace('magenta = "#bb9af7"', f'magenta = "{c["c5"]}"')
    content = content.replace('cyan    = "#73daca"', f'cyan    = "{c["c6"]}"')
    content = content.replace('white   = "#c0caf5"', f'white   = "{c["c7"]}"')
    content = content.replace('black   = "#565f89"', f'black   = "{c["c8"]}"')
    content = content.replace('red     = "#f7768e"', f'red     = "{c["c9"]}"')
    content = content.replace('green   = "#9ece6a"', f'green   = "{c["c10"]}"')
    content = content.replace('yellow  = "#e0af68"', f'yellow  = "{c["c11"]}"')
    content = content.replace('blue    = "#7aa2f7"', f'blue    = "{c["c12"]}"')
    content = content.replace('magenta = "#bb9af7"', f'magenta = "{c["c13"]}"')
    content = content.replace('cyan    = "#73daca"', f'cyan    = "{c["c14"]}"')
    content = content.replace('white   = "#ffffff"', f'white   = "{c["c15"]}"')
    write(os.path.join(tdir, "alacritty", "theme.toml"), content)
    print("  Alacritty ✓")

    # ----- Conky -----
    content = tmpl_conky
    content = content.replace("default_color = '#c0caf5'", f"default_color = '{c['fg']}'")
    content = content.replace("color0 = '#7aa2f7'", f"color0 = '{c['primary']}'")
    content = content.replace("color1 = '#bb9af7'", f"color1 = '{c['pink']}'")
    content = content.replace("color2 = '#73daca'", f"color2 = '{c['secondary']}'")
    content = content.replace("color3 = '#9ece6a'", f"color3 = '{c['green']}'")
    content = content.replace("color4 = '#e0af68'", f"color4 = '{c['yellow']}'")
    content = content.replace("#7aa2f7", f"{c['primary']}")
    write(os.path.join(tdir, "conky", "conky.conf"), content)
    print("  Conky ✓")

    # ----- Btop -----
    content = tmpl_btop
    btop_repl = {
        'main_bg': c['bg'], 'main_fg': c['fg'], 'title': c['fg'],
        'hi_fg': c['primary'], 'selected_bg': c['primary'], 'selected_fg': c['bg'],
        'inactive_fg': c['disabled'], 'graph_text': c['fg'],
        'meter_bg': c['c0'], 'proc_misc': c['primary'],
        'cpu_box': c['primary'], 'mem_box': c['green'],
        'net_box': c['alert'], 'proc_box': c['secondary'],
        'div_line': c['df'],
        'temp_start': c['primary'], 'temp_mid': c['pink'], 'temp_end': c['alert'],
        'cpu_start': c['primary'], 'cpu_mid': c['secondary'], 'cpu_end': c['green'],
        'free_start': c['green'], 'free_mid': c['secondary'], 'free_end': c['primary'],
        'cached_start': c['secondary'], 'cached_mid': c['primary'], 'cached_end': c['pink'],
        'available_start': c['yellow'], 'available_mid': c['alert'], 'available_end': c['yellow'],
        'used_start': c['primary'], 'used_mid': c['pink'], 'used_end': c['alert'],
        'download_start': c['primary'], 'download_mid': c['green'], 'download_end': c['secondary'],
        'upload_start': c['alert'], 'upload_mid': c['pink'], 'upload_end': c['primary'],
        'process_start': c['green'], 'process_mid': c['primary'], 'process_end': c['disabled'],
    }
    for key, val in btop_repl.items():
        content = content.replace(f'theme[{key}]="#', f'theme[{key}]="{val[:-1]}')
    # Fix: the above might not work cleanly. Let's do it properly.
    # Actually re-do btop content from scratch using template
    lines = tmpl_btop.strip().split('\n')
    new_lines = []
    for line in lines:
        line = line.strip()
        if line.startswith('theme['):
            key = line.split(']')[0].split('[')[1]
            if key in btop_repl:
                new_lines.append(f'theme[{key}]="{btop_repl[key]}"')
                continue
        new_lines.append(line)
    write(os.path.join(tdir, "btop", "theme.theme"), '\n'.join(new_lines) + '\n')
    print("  Btop ✓")

    # ----- Cava -----
    content = f"""[color]
gradient = 1
gradient_color_1 = '{c['c6']}'
gradient_color_2 = '{c['c4']}'
gradient_color_3 = '{c['c5']}'
gradient_color_4 = '{c['c1']}'
gradient_color_5 = '{c['primary']}'
gradient_color_6 = '{c['secondary']}'
gradient_color_7 = '{c['green']}'
gradient_color_8 = '{c['c6']}'
"""
    write(os.path.join(tdir, "cava", "config"), content)
    print("  Cava ✓")

    # ----- Picom (copy template - same animations for all) -----
    write(os.path.join(tdir, "picom", "picom.conf"), tmpl_picom)
    print("  Picom ✓")

    # ----- Wallpapers from Omarchy repo -----
    bg_src = os.path.join(omarchy_src, "backgrounds")
    bg_dst = os.path.join(tdir, "backgrounds")
    if os.path.isdir(bg_src):
        for f in os.listdir(bg_src):
            cp(os.path.join(bg_src, f), os.path.join(bg_dst, f))
        print(f"  Wallpapers ({len(os.listdir(bg_src))}) ✓")
    else:
        # Fallback: copy from template
        for f in os.listdir(os.path.join(TEMPLATE, "backgrounds")):
            cp(os.path.join(TEMPLATE, "backgrounds", f), os.path.join(bg_dst, f))
        print("  Wallpapers (template fallback) ✓")

    # ----- Unlock / Preview images -----
    for img in ["unlock.png", "preview.png", "preview-unlock.png"]:
        cp(os.path.join(omarchy_src, img), os.path.join(tdir, img))
    print("  Images ✓")

    # ----- Chromium / Brave theme -----
    cp(os.path.join(omarchy_src, "chromium.theme"), os.path.join(tdir, "chromium.theme"))
    print("  Chromium/Brave ✓" if os.path.exists(os.path.join(omarchy_src, "chromium.theme")) else "  Chromium/Brave ✗")

    # ----- VSCode JSON -----
    cp(os.path.join(omarchy_src, "vscode.json"), os.path.join(tdir, "vscode.json"))
    print("  VSCode ✓" if os.path.exists(os.path.join(omarchy_src, "vscode.json")) else "  VSCode ✗")

    # ----- OpenCode Theme -----
    ocode = {
        "$schema": "https://opencode.ai/theme.json",
        "defs": {
            "bg": c['bg'], "fg": c['fg'],
            "primary": c['primary'], "secondary": c['secondary'],
            "accent": c['pink'], "error": c['alert'],
            "warning": c['yellow'], "success": c['green'],
            "info": c['primary'],
        },
        "theme": {
            "primary": c['primary'], "secondary": c['secondary'],
            "accent": c['pink'], "error": c['alert'],
            "warning": c['yellow'], "success": c['green'],
            "info": c['primary'],
            "text": c['fg'], "textMuted": c['secondary'],
            "background": c['bg'],
        },
    }
    write(os.path.join(OPENCODE_DIR, f"{name}.json"), json.dumps(ocode, indent=2))
    print("  OpenCode ✓")

    print(f"  → {name} COMPLETADO")

print("\n=== TODOS LOS TEMAS GENERADOS ===")
