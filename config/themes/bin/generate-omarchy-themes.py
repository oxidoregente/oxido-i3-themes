#!/usr/bin/env python3
"""Generate Omarchy theme config files from color definitions."""
import os, shutil, sys

THEMES_DIR = os.path.expanduser("~/.config/themes/themes")
TEMPLATE = "tokyo-night"

themes = {
    "everforest": {
        "bg": "#2d353b", "fg": "#d3c6aa",
        "primary": "#7fbbb3", "secondary": "#83c092",
        "alert": "#e67e80", "disabled": "#475258",
        "green": "#a7c080", "pink": "#d699b6", "yellow": "#dbbc7f",
        "c0": "#475258", "c1": "#e67e80", "c2": "#a7c080",
        "c3": "#dbbc7f", "c4": "#7fbbb3", "c5": "#d699b6",
        "c6": "#83c092", "c7": "#d3c6aa",
        "dunst_frame": "#3a464e",
        "bubble_ws": "#3d4050", "bubble_center": "#3d4848", "bubble_sys": "#3d4858",
    },
    "kanagawa": {
        "bg": "#1f1f28", "fg": "#dcd7ba",
        "primary": "#7e9cd8", "secondary": "#6a9589",
        "alert": "#c34043", "disabled": "#54546d",
        "green": "#76946a", "pink": "#957fb8", "yellow": "#c0a36e",
        "c0": "#090618", "c1": "#c34043", "c2": "#76946a",
        "c3": "#c0a36e", "c4": "#7e9cd8", "c5": "#957fb8",
        "c6": "#6a9589", "c7": "#c8c093",
        "dunst_frame": "#363646",
        "bubble_ws": "#363650", "bubble_center": "#364848", "bubble_sys": "#384858",
    },
    "matte-black": {
        "bg": "#121212", "fg": "#bebebe",
        "primary": "#e68e0d", "secondary": "#bebebe",
        "alert": "#D35F5F", "disabled": "#333333",
        "green": "#FFC107", "pink": "#D35F5F", "yellow": "#FFC107",
        "c0": "#333333", "c1": "#D35F5F", "c2": "#FFC107",
        "c3": "#b91c1c", "c4": "#e68e0d", "c5": "#D35F5F",
        "c6": "#bebebe", "c7": "#bebebe",
        "dunst_frame": "#2a2a2a",
        "bubble_ws": "#2a2a30", "bubble_center": "#2a2a30", "bubble_sys": "#2a2a38",
    },
    "osaka-jade": {
        "bg": "#111c18", "fg": "#C1C497",
        "primary": "#509475", "secondary": "#2DD5B7",
        "alert": "#FF5345", "disabled": "#53685B",
        "green": "#549e6a", "pink": "#D2689C", "yellow": "#459451",
        "c0": "#23372B", "c1": "#FF5345", "c2": "#549e6a",
        "c3": "#459451", "c4": "#509475", "c5": "#D2689C",
        "c6": "#2DD5B7", "c7": "#F6F5DD",
        "dunst_frame": "#1e3028",
        "bubble_ws": "#243830", "bubble_center": "#243840", "bubble_sys": "#243848",
    },
    "ristretto": {
        "bg": "#2c2525", "fg": "#e6d9db",
        "primary": "#f38d70", "secondary": "#85dacc",
        "alert": "#fd6883", "disabled": "#72696a",
        "green": "#adda78", "pink": "#a8a9eb", "yellow": "#f9cc6c",
        "c0": "#72696a", "c1": "#fd6883", "c2": "#adda78",
        "c3": "#f9cc6c", "c4": "#f38d70", "c5": "#a8a9eb",
        "c6": "#85dacc", "c7": "#e6d9db",
        "dunst_frame": "#453838",
        "bubble_ws": "#403848", "bubble_center": "#384848", "bubble_sys": "#403850",
    },
    "rose-pine": {
        "bg": "#232136", "fg": "#e0def4",
        "primary": "#56949f", "secondary": "#d7827e",
        "alert": "#b4637a", "disabled": "#6e6a86",
        "green": "#286983", "pink": "#907aa9", "yellow": "#ea9d34",
        "c0": "#393552", "c1": "#b4637a", "c2": "#286983",
        "c3": "#ea9d34", "c4": "#56949f", "c5": "#907aa9",
        "c6": "#d7827e", "c7": "#e0def4",
        "dunst_frame": "#363050",
        "bubble_ws": "#363050", "bubble_center": "#304848", "bubble_sys": "#304058",
    },
    "catppuccin-latte": {
        "bg": "#1e1e2e", "fg": "#cdd6f4",
        "primary": "#1e66f5", "secondary": "#179299",
        "alert": "#d20f39", "disabled": "#5c5f77",
        "green": "#40a02b", "pink": "#ea76cb", "yellow": "#df8e1d",
        "c0": "#bcc0cc", "c1": "#d20f39", "c2": "#40a02b",
        "c3": "#df8e1d", "c4": "#1e66f5", "c5": "#ea76cb",
        "c6": "#179299", "c7": "#5c5f77",
        "dunst_frame": "#313244",
        "bubble_ws": "#383050", "bubble_center": "#304848", "bubble_sys": "#303858",
    },
    "flexoki-light": {
        "bg": "#1c1c1c", "fg": "#dad8ce",
        "primary": "#205EA6", "secondary": "#3AA99F",
        "alert": "#D14D41", "disabled": "#878580",
        "green": "#879A39", "pink": "#CE5D97", "yellow": "#D0A215",
        "c0": "#DAD8CE", "c1": "#D14D41", "c2": "#879A39",
        "c3": "#D0A215", "c4": "#205EA6", "c5": "#CE5D97",
        "c6": "#3AA99F", "c7": "#B7B5AC",
        "dunst_frame": "#2a2a2a",
        "bubble_ws": "#2e2e3a", "bubble_center": "#2e383a", "bubble_sys": "#2e3040",
    },
}

def read_file(path):
    with open(path) as f:
        return f.read()

def write_file(path, content):
    with open(path, 'w') as f:
        f.write(content)

def replace_all(content, replacements):
    for old, new in replacements:
        content = content.replace(old, new)
    return content

def gen_polybar(template_dir, theme_dir, c):
    content = read_file(os.path.join(template_dir, "polybar", "config.ini"))
    content = replace_all(content, [
        ("background = #1a1b26", f"background = {c['bg']}"),
        ("foreground = #c0caf5", f"foreground = {c['fg']}"),
        ("primary = #7aa2f7", f"primary = {c['primary']}"),
        ("secondary = #73daca", f"secondary = {c['secondary']}"),
        ("alert = #f7768e", f"alert = {c['alert']}"),
        ("disabled = #565f89", f"disabled = {c['disabled']}"),
        ("green = #9ece6a", f"green = {c['green']}"),
        ("pink = #bb9af7", f"pink = {c['pink']}"),
        ("yellow = #e0af68", f"yellow = {c['yellow']}"),
        ("bubble-ws = #303858", f"bubble-ws = {c['bubble_ws']}"),
        ("bubble-center = #304848", f"bubble-center = {c['bubble_center']}"),
        ("bubble-sys = #383050", f"bubble-sys = {c['bubble_sys']}"),
    ])
    write_file(os.path.join(theme_dir, "polybar", "config.ini"), content)
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
    write_file(os.path.join(theme_dir, "polybar", "colors.ini"), cols)

def gen_rofi(template_dir, theme_dir, c):
    content = read_file(os.path.join(template_dir, "rofi", "config.rasi"))
    content = replace_all(content, [
        ("background:     #1a1b26", f"background:     {c['bg']}"),
        ("background-alt: #303858", f"background-alt: {c['bubble_ws']}"),
        ("foreground:     #c0caf5", f"foreground:     {c['fg']}"),
        ("selected:       #7aa2f7", f"selected:       {c['primary']}"),
        ("urgent:         #f7768e", f"urgent:         {c['alert']}"),
        ("border-col:     #383050", f"border-col:     {c['bubble_sys']}"),
        ("border-color:   #383050", f"border-color:   {c['bubble_sys']}"),
        ("placeholder-color: #383050", f"placeholder-color: {c['bubble_sys']}"),
        ("lightbg:        #303858", f"lightbg:        {c['bubble_ws']}"),
        ("lightfg:        #7aa2f7", f"lightfg:        {c['primary']}"),
        ("red:            #f7768e", f"red:            {c['alert']}"),
        ("blue:           #7aa2f7", f"blue:           {c['primary']}"),
    ])
    write_file(os.path.join(theme_dir, "rofi", "config.rasi"), content)

def gen_dunst(template_dir, theme_dir, c):
    content = read_file(os.path.join(template_dir, "dunst", "dunstrc"))
    content = replace_all(content, [
        ('background = "#1a1b26', f'background = "{c["bg"]}'),
        ('foreground = "#c0caf5', f'foreground = "{c["fg"]}'),
        ('frame_color = "#73daca"', f'frame_color = "{c["dunst_frame"]}"'),
        ('highlight = "#7aa2f7"', f'highlight = "{c["primary"]}"'),
    ])
    write_file(os.path.join(theme_dir, "dunst", "dunstrc"), content)

def gen_i3(template_dir, theme_dir, c):
    content = read_file(os.path.join(template_dir, "i3", "colors.conf"))
    content = replace_all(content, [
        ("set $bg        #1a1b26", f"set $bg        {c['bg']}"),
        ("set $fg        #c0caf5", f"set $fg        {c['fg']}"),
        ("set $primary   #7aa2f7", f"set $primary   {c['primary']}"),
        ("set $secondary #73daca", f"set $secondary {c['secondary']}"),
        ("set $alert     #f7768e", f"set $alert     {c['alert']}"),
        ("set $disabled  #565f89", f"set $disabled  {c['disabled']}"),
        ("set $green     #9ece6a", f"set $green     {c['green']}"),
        ("set $pink      #bb9af7", f"set $pink      {c['pink']}"),
        ("set $yellow    #e0af68", f"set $yellow    {c['yellow']}"),
    ])
    write_file(os.path.join(theme_dir, "i3", "colors.conf"), content)

def gen_alacritty(template_dir, theme_dir, c):
    content = read_file(os.path.join(template_dir, "alacritty", "theme.toml"))
    content = replace_all(content, [
        ('background = "#1a1b26"', f'background = "{c["bg"]}"'),
        ('foreground = "#c0caf5"', f'foreground = "{c["fg"]}"'),
        ('black   = "#2f3347"', f'black   = "{c["c0"]}"'),
        ('red     = "#f7768e"', f'red     = "{c["c1"]}"'),
        ('green   = "#9ece6a"', f'green   = "{c["c2"]}"'),
        ('yellow  = "#e0af68"', f'yellow  = "{c["c3"]}"'),
        ('blue    = "#7aa2f7"', f'blue    = "{c["c4"]}"'),
        ('magenta = "#bb9af7"', f'magenta = "{c["c5"]}"'),
        ('cyan    = "#73daca"', f'cyan    = "{c["c6"]}"'),
        ('white   = "#c0caf5"', f'white   = "{c["c7"]}"'),
        # Bright section (same as normal for Omarchy)
        ('black   = "#565f89"', f'black   = "{c["c8"]}"' if 'c8' in c else f'black   = "{c["disabled"]}"'),
        ('white   = "#ffffff"', f'white   = "{c["c15"]}"' if 'c15' in c else f'white   = "{c["fg"]}"'),
    ])
    write_file(os.path.join(theme_dir, "alacritty", "theme.toml"), content)

def gen_conky(template_dir, theme_dir, c):
    content = read_file(os.path.join(template_dir, "conky", "conky.conf"))
    content = replace_all(content, [
        ("default_color = '#c0caf5'", f"default_color = '{c['fg']}'"),
        ("color0 = '#7aa2f7'", f"color0 = '{c['primary']}'"),
        ("color1 = '#bb9af7'", f"color1 = '{c['pink']}'"),
        ("#7aa2f7", f"{c['primary']}"),
    ])
    write_file(os.path.join(theme_dir, "conky", "conky.conf"), content)

def gen_btop(template_dir, theme_dir, c):
    content = read_file(os.path.join(template_dir, "btop", "theme.theme"))
    content = replace_all(content, [
        ('"#1a1b26"', f'"{c["bg"]}"'),
        ('"#c0caf5"', f'"{c["fg"]}"'),
        ('"#7aa2f7"', f'"{c["primary"]}"'),
        ('"#f7768e"', f'"{c["alert"]}"'),
        ('"#73daca"', f'"{c["secondary"]}"'),
        ('"#9ece6a"', f'"{c["green"]}"'),
        ('"#bb9af7"', f'"{c["pink"]}"'),
        ('"#e0af68"', f'"{c["yellow"]}"'),
        ('"#565f89"', f'"{c["disabled"]}"'),
        ('"#24283b"', f'"{c["dunst_frame"]}"'),
        ('"#364049"', f'"{c["dunst_frame"]}"'),
    ])
    write_file(os.path.join(theme_dir, "btop", "theme.theme"), content)

def main():
    template_dir = os.path.join(THEMES_DIR, TEMPLATE)
    for name, c in sorted(themes.items()):
        tdir = os.path.join(THEMES_DIR, name)
        print(f"Generating {name}...")
        gen_polybar(template_dir, tdir, c)
        gen_rofi(template_dir, tdir, c)
        gen_dunst(template_dir, tdir, c)
        gen_i3(template_dir, tdir, c)
        gen_alacritty(template_dir, tdir, c)
        gen_conky(template_dir, tdir, c)
        gen_btop(template_dir, tdir, c)
        print(f"  ✓ {name}")
    print("Done!")

if __name__ == "__main__":
    main()
