# 🎨 Theme System for i3wm + Polybar

Complete guide to installation, configuration, and customization of the oxido-i3-themes system.

---

## Index

1. [Introduction](#1-introduction)
2. [Directory Structure](#2-directory-structure)
3. [Available Themes](#3-available-themes)
4. [Keyboard Shortcuts](#4-keyboard-shortcuts)
5. [Changing Themes](#5-changing-themes)
6. [PowerSaver Mode](#6-powersaver-mode)
7. [Conky](#7-conky)
8. [Control Center (Settings)](#8-control-center-settings)
9. [Default Applications](#9-default-applications)
10. [Adding a New Theme](#10-adding-a-new-theme)
11. [Component Customization](#11-component-customization)
12. [Animation System](#12-animation-system)
13. [Fonts](#13-fonts)
14. [EWW Widgets](#14-eww-widgets)
15. [Troubleshooting](#15-troubleshooting)
16. [Backups](#16-backups)
17. [Change History](#17-change-history)

---

## 1. Introduction

This system enables switching between multiple complete visual themes in i3wm. Each theme includes colors for:

- **i3** (windows, borders, background)
- **Polybar** (segmented bubble-style status bar)
- **Picom** (shadows, blur, compositor, animations)
- **Dunst** (notifications)
- **Rofi** (launcher and theme selector)
- **Conky** (system information overlay)
- **Alacritty** (terminal emulator)
- **Btop** (system monitor)
- **Cava** (audio visualizer)
- **Wallpaper** (per-theme background)

There are currently **23 themes**: 7 originals + 16 inspired by the Omarchy repository, plus a PowerSaver variant.

The visual design uses a **segmented bubble** style in Polybar:

```
┌──────────┐  ┌──────────┐  ┌──────────────────────────────┐
│ 1  2  3  │  │  Mon 24  │  │ 🔊  ██  🔋 98%         │
│  ws-pad  │  │mid-pad   │  │        sys-pad                │
└──────────┘  └──────────┘  └──────────────────────────────┘
```

Each segment (workspaces, date, system info) has its own color bubble.

---

## 2. Directory Structure

```
~/.config/themes/                         # Runtime configuration
├── themes/                               # Theme definitions
│   ├── dracula/
│   │   ├── alacritty/theme.toml          # Terminal colors
│   │   ├── backgrounds/                  # Wallpapers
│   │   ├── btop/btop.theme               # System monitor theme
│   │   ├── cava/config                   # Audio visualizer
│   │   ├── conky/conky.conf              # Desktop overlay
│   │   ├── dunst/dunstrc                 # Notifications
│   │   ├── gtk/gtk.css                   # GTK overrides for Nemo
│   │   ├── i3/colors.conf                # i3 window colors
│   │   ├── picom/picom.conf              # Compositor config
│   │   ├── polybar/
│   │   │   ├── config.ini                # Full bar definition
│   │   │   └── colors.ini                # Color palette only
│   │   ├── rofi/theme.rasi               # Launcher theme
│   │   ├── preview.png                   # Theme preview image
│   │   └── unlock.png                    # Lock screen preview
│   ├── tokyo-night/                      # (same structure)
│   └── ...                               # Total: 23 themes
├── bin/
│   ├── rofi-settings.sh                  # Main settings center
│   ├── rofi-theme-selector.sh            # Visual theme picker
│   ├── theme-switch.sh                   # Core theme switching
│   ├── animation-picker.sh               # Animation control
│   └── verify-themes.sh                  # Integrity checker
├── applyers/
│   ├── apply-i3.sh                       # Apply i3 colors
│   ├── apply-polybar.sh                  # Apply polybar config
│   ├── apply-picom.sh                    # Apply compositor
│   ├── apply-dunst.sh                    # Apply notifications
│   ├── apply-conky.sh                    # Apply desktop overlay
│   ├── apply-alacritty.sh                # Apply terminal colors
│   └── ...                               # (13 applyers total)
├── scripts/
│   ├── launch-terminal.sh                # Default terminal wrapper
│   ├── launch-browser.sh                 # Default browser wrapper
│   ├── launch-fm.sh                      # Default file manager
│   ├── settings/                         # Rofi settings menus
│   │   ├── default-apps.sh               # App profile selector
│   │   ├── sound.sh                      # Audio controls
│   │   ├── animation.sh                  # Animation menu
│   │   ├── appearance.sh                 # Theme/conky/gaps
│   │   └── ...                           # (21 menus total)
│   ├── power-menu.sh                     # Power options (legacy Rofi, replaced by EWW)
│   ├── toggle-powersaver.sh              # PowerSaver mode
│   ├── toggle-dnd.sh                     # Do Not Disturb
│   └── ...
├── eww/                                  # EWW widgets (floating UI)
│   ├── eww.yuck                          # Widget definitions (powermenu, control-center)
│   ├── eww.scss                          # GTK CSS styles with SCSS preprocessing
│   └── scripts/
│       ├── toggle-powermenu.sh           # Toggle EWW powermenu
│       └── toggle-control-center.sh      # Toggle EWW control center
├── animations/
│   ├── global.picom                      # Global animation triggers
│   └── rules.picom                       # Per-app animation rules
└── defaults.conf                         # Default applications
```

### Development Repository

The source of truth lives at `~/Documentos/oxido-i3-themes/` with the same structure under `config/`. Changes are made in the repo and deployed to `~/.config/themes/` via applyer scripts or `install.sh`.

---

## 3. Available Themes

| Theme | Type | Description |
|-------|------|-------------|
| catppuccin-mocha | Dark | Catppuccin Mocha — warm, muted purples and blues |
| catppuccin-latte | Dark | Catppuccin-inspired dark variant |
| dracula | Dark | Classic Dracula — purple accent, dark background |
| dracula-powersaver | Dark min | Minimal Dracula, no animations, no conky |
| ethereal | Dark | Deep blue, aurora-inspired |
| everforest | Dark | Earthy green tones |
| flexoki-light | Dark | High-contrast dark, named "light" historically |
| gruvbox | Dark | Retro warm — orange/green accents |
| hackerman | Dark | Neon cyan on very dark blue |
| kanagawa | Dark | Wave-inspired, deep ocean colors |
| last-horizon | Dark | Desaturated dark, cosmic theme |
| lumon | Dark | Corporate dark blue, Severance-inspired |
| matte-black | Dark | Pure matte black with muted accents |
| miasma | Dark | Dark and moody, low saturation |
| nord | Dark | Arctic blue theme |
| osaka-jade | Dark | Deep green/jade tones |
| retro-82 | Dark | Cyan/amber retro-futuristic |
| ristretto | Dark | Warm brown, coffee-inspired |
| rose-pine | Dark | Rosé Pine — soft pine cone palette |
| solitude | Dark | Muted monochrome, ultra-calm |
| tokyo-night | Dark | Vibrant night city — blues, purples |
| vantablack | Dark | True black background, grayscale accents |
| white | Dark | Desaturated dark (name is historical) |

---

## 4. Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `$mod+Return` | Open terminal (default: alacritty) |
| `$mod+Shift+f` | Open browser (default: firefox) |
| `$mod+Shift+t` | Theme selector (Rofi visual) |
| `$mod+Shift+s` | Control Center (all settings) |
| `$mod+d` | Application launcher (Rofi) |
| `$mod+Shift+d` | Toggle Do Not Disturb |
| `$mod+Shift+period` | Show time notification |
| `$mod+Shift+comma` | Open calendar (gnome-calendar) |
| `$mod+Shift+b` | Show battery notification |
| `$mod+Shift+w` | Show weather notification |
| `$mod+Shift+Escape` | Power menu (EWW floating widget) |
| `$mod+Shift+c` | Control Center (EWW floating: WiFi, BT, volume, brightness, power) |
| `$mod+Shift+Slash` | Show keybindings help |
| `$mod+Escape` | System mode (lock, exit, suspend) |

### Navigation

| Key | Action |
|-----|--------|
| `$mod+h/j/k/l` | Focus left/down/up/right |
| `$mod+Shift+h/j/k/l` | Move window left/down/up/right |
| `$mod+f` | Toggle fullscreen |
| `$mod+v` | Toggle split orientation |
| `$mod+Shift+Space` | Toggle floating/tiling |
| `$mod+Space` | Toggle focus between tiling/floating |

---

## 5. Changing Themes

### Via Rofi (Recommended)

Press `$mod+Shift+t` to open the visual theme selector. It displays:
- A grid of theme preview thumbnails
- The current theme is highlighted
- Clicking a theme applies it immediately (i3, polybar, terminal, notifications, wallpaper, conky all update live)

The selector uses a Python GTK3 window with a CSS grid layout.

### Via Control Center

`$mod+Shift+s` → Appearance → Theme Selector → choose from list

### Via Command Line

```bash
# Switch to a specific theme
~/.config/themes/bin/theme-switch.sh dracula

# Switch to PowerSaver mode
~/.config/themes/scripts/toggle-powersaver.sh
```

### What Happens When You Switch

The `theme-switch.sh` script:
1. Updates `~/.config/themes/current/theme` symlink
2. Calls each applyer sequentially (i3, polybar, picom, dunst, conky, alacritty, wallpapers, rofi, btop, cava, gtk, lock screen)
3. Refreshes all running instances via IPC/SIGUSR1

---

## 6. PowerSaver Mode

PowerSaver (`dracula-powersaver`) is a minimal theme variant designed for battery conservation:

- **No animations** — picom animations disabled
- **No compositor blur** — uses `xrender` backend instead of `glx`
- **No conky** — desktop overlay disabled
- **Minimal polybar** — fewer modules updating
- **Darker colors** — reduces pixel brightness on OLED screens

Activate via: `$mod+Shift+s` → Power → PowerSaver mode

---

## 7. Conky

Conky displays a semi-transparent overlay on your desktop with:
- System info (hostname, kernel, uptime)
- CPU usage per core + temperature
- Memory usage (RAM + swap)
- Disk usage (root + NVMe)
- Network IP addresses
- Top processes by CPU/memory

Toggle via: Control Center → Appearance → Toggle Conky

Conky uses `~/.config/conky/conky.conf` which is theme-specific.

---

## 8. Control Center (Settings)

Press `$mod+Shift+s` to open the Rofi-based Control Center:

```
⚙️ Control Center
├── 📱 Default Apps      → Choose terminal, browser, file manager
├── 🔊 Sound             → Volume, mute, output device
├── ☀️ Display           → Brightness, wallpaper, DPMS
├── 🔔 Notifications     → DND, history, clear
├── 🎬 Animations        → Per-app animation settings, presets
├── 🎨 Appearance        → Theme, conky, gaps
├── ⚡ Power             → PowerSaver, autolock, lid behavior
└── 🔧 System            → Service status, system info
└── 📋 Utilities         → Screenshot, WiFi, Bluetooth, clipboard
```

Each submenu is a standalone Rofi script that can also be bound to a key directly.

---

## 9. Default Applications

The system now supports configurable default applications via `~/.config/themes/defaults.conf`:

```bash
TERMINAL="alacritty"
BROWSER="firefox"
FILE_MANAGER="nemo"
TERMINAL_FILE_MANAGER="ranger"
```

### Setting Defaults

1. Open Control Center → 📱 Default Apps
2. Choose a role (Terminal, Browser, File Manager, CLI File Manager)
3. Select from a list of common apps or choose "Other..." to enter a custom command
4. Changes take effect immediately

### Wrapper Scripts

These scripts are used by keybindings and other system components:

| Script | Purpose | Default | Keybinding |
|--------|---------|---------|------------|
| `launch-terminal.sh` | Opens `$TERMINAL` | alacritty | `$mod+Return` |
| `launch-browser.sh` | Opens `$BROWSER` | firefox | `$mod+Shift+f` |
| `launch-fm.sh` | Opens `$FILE_MANAGER` | nemo | — |

Each wrapper sources `defaults.conf` with a safe fallback if the file is missing.

### Profiles

You can save and load application profiles:

1. Set your apps via the Default Apps menu
2. Select **Save profile**, enter a name
3. Later, select **Load profile** to instantly restore all four apps

Profiles are stored as individual `.conf` files in `~/.config/themes/profiles/`.

---

## 10. Adding a New Theme

To create a new theme, copy an existing theme directory and customize its files:

```bash
cp -r config/themes/themes/dracula config/themes/themes/my-theme
```

Each theme needs these 11 directories:

```
my-theme/
├── alacritty/theme.toml    # Terminal 16-color palette
├── backgrounds/             # Wallpaper images
├── btop/btop.theme          # System monitor colors
├── cava/config              # Audio visualizer colors
├── conky/conky.conf         # Desktop overlay colors
├── dunst/dunstrc            # Notification colors
├── gtk/gtk.css              # GTK file manager colors
├── i3/colors.conf           # i3 window colors
├── picom/picom.conf         # Compositor settings (+ @include)
├── polybar/
│   ├── config.ini           # Bar layout + colors
│   └── colors.ini           # Color palette only (for scripts)
├── rofi/theme.rasi          # Launcher theme
├── preview.png              # 480×360 theme preview
└── unlock.png               # Lock screen preview
```

**Note**: Since Fase 2, `picom/picom.conf` only contains theme-specific settings (backend, blur, radius). The `animations` and `rules` blocks are centralized in `config/themes/animations/global.picom` and `rules.picom` and included via `@include` at the root level.

Run `verify-themes.sh` to validate your new theme:

```bash
~/.config/themes/bin/verify-themes.sh
```

---

## 11. Component Customization

### Colors

Each theme's `i3/colors.conf` defines:

```
$bg         # Window background / unfocused border
$bg-alt     # Inactive title bar background
$fg         # Text color
$primary    # Active window border / focused accent
$secondary  # Secondary accent
$alert      # Urgent window border
$disabled   # Inactive window elements
$green      # Success indicators
$pink       # Special accents
$yellow     # Warning indicators
```

### Polybar — Layout System

The bar uses a **composable layout system**: each theme provides only colors (`colors.ini`), and the bar structure comes from a **layout file** (`.ini`). The applyer concatenates them at apply time.

```
colors.ini (theme)  +  layout.ini (design)  →  config.ini (runtime)
```

#### 15 Available Layouts

| # | Layout | Identidad | Font | Height | Radius | Modules |
|---|--------|-----------|------|--------|--------|---------|
| 1 | **bubble** | 3 burbujas segmentadas, full features (original) | JetBrainsMono NF | 34 | 0 | ws + dnd+cpu+temp+mem+cava+audio+bat+tray+power |
| 2 | **minimal** | Super slim (22px), solo texto plano, sin iconos ni decoración | IosevkaTerm NF | 22 | 0 | ws + date + mem+audio+bat+tray |
| 3 | **blocks** | Bloques shade con format-background en todos los módulos | IosevkaTerm NF | 28 | 0 | ws + date + dnd+cpu+mem+audio+bat+tray+power |
| 4 | **colorblocks** | Cada módulo con fondo de color distinto (green, yellow, pink...) + powerline separators | JetBrainsMono NF | 28 | 0 | ws(c) + cpu(g)+mem(y)+date(sec)+audio(pk)+bat(c)+power(alert) |
| 5 | **floating** | Flotante 90% + border frame 3px primary (técnica Material) | JetBrainsMono NF | 30 | 12 | ws + date + dnd+cpu+audio+bat+tray |
| 6 | **default** | Acento primario con line-size, separador `\|`, limpio | JetBrainsMono NF | 28 | 0 | ws + date + cpu+mem+audio+bat+tray |
| 7 | **powerline** | Glyphs / rodeando workspaces + format-prefix | IosevkaTerm NF | 30 | 0 | ws + date + cpu+mem+audio+bat+tray |
| 8 | **sharp** | Pestañas / sobre primary, workspaces sólidos | IosevkaTerm NF | 30 | 0 | ws + date + dnd+cpu+audio+bat+tray |
| 9 | **material** | Material Design con border frame + line accent, label-radius | JetBrainsMono NF | 36 | 14 | ws + date + dnd+cpu+audio+bat+tray |
| 10 | **rounded** | Barra flotante background-alt + radius 18, Maple Mono NF, compacto | Maple Mono NF | 24 | 18 | ws + date + audio+bat+tray |
| 11 | **panel** | Estilo Win11/GNOME con separadores `\|` entre módulos | JetBrainsMono NF | 28 | 0 | ws + date + dnd\|cpu\|mem\|audio\|bat\|tray\|power |
| 12 | **dual** | Dos zonas divididas por barra primaria (dual-divider) | IosevkaTerm NF | 30 | 0 | ws(p)+date + cpu+mem+audio+bat+tray(separados) |
| 13 | **hack** | Terminal aesthetic: ❰❱ brackets, color-coded (green, yellow), Terminus font | JetBrainsMono NF + Terminus | 24 | 0 | ws ❰...❱ + date + cpu+mem+audio+bat+tray |
| 14 | **docky** | macOS-style floating dock, background-alt, launcher icon, centered ws | JetBrainsMono NF | 32 | 16 | launcher + ws + date + audio+bat+tray |
| 15 | **cynthia** | Two-tone con powerline /, ws con fondo primary, Maple Mono NF | Maple Mono NF | 28 | 0 | ws + date + dnd+cpu+audio+bat+tray |

Cada layout incluye `format-prefix` con iconos ( CPU,  memoria,  audio,  batería,  fecha,  DND) para identificar visualmente cada módulo.

Switch via: Centro de Control → Apariencia → Diseño Polybar, or directly:
```bash
echo "bubble" > ~/.config/themes/current-layout
~/.config/themes/applyers/apply-polybar.sh ~/.config/themes/current/theme
```

#### Position (Top / Bottom)

The polybar can be positioned at the **top** or **bottom** of the screen. Default is `top`.

Set via Centro de Control → Apariencia → Diseño Polybar → `📍 Posición`, or directly:
```bash
echo "bottom" > ~/.config/themes/polybar-position
~/.config/themes/applyers/apply-polybar.sh ~/.config/themes/current/theme
```

When switching to bottom, the bar's accent decoration swaps automatically (e.g., `border-bottom-size` for top → `border-top-size` for bottom). All 15 layouts support both positions.

#### Color Variables

Each theme's `polybar/colors.ini` defines 14 variables:

| Variable | Purpose | Contrast rule |
|----------|---------|--------------|
| `background` | Bar background | — |
| `background-alt` | Module backgrounds (blocks, minimal, powerline, rounded) | Must differ from `background` by ≥15 per RGB channel (~1.5 CR) |
| `bubble-ws` | Left bubble segment (workspaces) | Must differ from `background` by ≥20 per channel |
| `bubble-center` | Center bubble segment (date) | Must contrast with `primary` (CR ≥ 3.0) |
| `bubble-sys` | Right bubble segment (system info) | Must differ from `background` by ≥20 per channel |
| `foreground` | Default text | CR ≥ 7.0 against all backgrounds it sits on |
| `primary` | Active workspace, date accent, icon highlights | CR ≥ 3.0 against `bubble-center` and `bubble-ws` |
| `secondary` | Volume bars, secondary accents | — |
| `alert` | Urgent workspace, temperature warning, low battery | — |
| `disabled` | Empty workspaces, volume empty segments | — |
| `green` | Battery full, success indicators | — |
| `pink` | Special accents | — |
| `yellow` | Charging indicator, warnings | — |

#### Colorimetry Guidelines

The **bubble-*** colors create subtle section divisions. They must be visibly distinct from `background`:

- **Minimum RGB difference**: ≥20 per channel (or ≥40 weighted)
- **Hue consistency**: stay in the same color family as background
- **Primary contrast**: ensure primary text/icons are readable on bubble backgrounds (CR ≥ 3.0)

If bubble sections appear invisible (common in very dark themes), increase the bubble-* lightness by 15-25 per RGB channel relative to background.

The `background-alt` serves as module backgrounds in non-bubble layouts (blocks, minimal, powerline, default, etc.). It requires:
- **Minimum RGB difference from background**: ≥15 per channel
- **Target CR**: ≥ 1.5 (below this, module backgrounds blend into the bar)

### Picom

Since Fase 2, the compositor configuration is split:

- **Per-theme** (in `picom/picom.conf`): backend, blur method, corner radius, shadows, fading
- **Shared** (in `animations/`): animation triggers and per-app rules via `@include`

To customize animations globally:
```bash
~/.config/themes/bin/animation-picker.sh preset gnome
# or for a specific trigger:
~/.config/themes/bin/animation-picker.sh close disappear duration=0.3
# or per-application:
~/.config/themes/bin/animation-picker.sh open slide-in direction=up --target Firefox
```

---

## 12. Animation System

Picom v13+ supports per-window animations. The system manages five trigger types:

| Trigger | When It Fires |
|---------|--------------|
| `open` | Window opens |
| `close` | Window closes |
| `show` | Window becomes visible (e.g., tab switch) |
| `hide` | Window becomes hidden |
| `geometry` | Window resize/move |

### Available Presets

| Preset | Effect | Parameters |
|--------|--------|------------|
| `appear` | Zoom in from center | `scale` (0.0-1.0) |
| `disappear` | Zoom out to center | `scale` (1.0+) |
| `fly-in` | Fly in from edge | `direction` (up/down/left/right) |
| `fly-out` | Fly out to edge | `direction` |
| `slide-in` | Slide in from edge | `direction` |
| `slide-out` | Slide out to edge | `direction` |
| `geometry-change` | Smooth resize | — |

### Quick Presets

| Preset Name | Style |
|-------------|-------|
| `clasico` | Subtle appear/disappear |
| `gnome` | GNOME-style fly animations |
| `macos` | macOS-style scale + fly |
| `win11` | Windows 11-style reposition |
| `snap` | Ultra-fast (<100ms) |

### Per-Application Rules

The following apps have dedicated animation rules:

| App | Purpose |
|-----|---------|
| **Alacritty** | Terminal — fast appear/close |
| **Firefox** | Browser — slide from bottom |
| **Rofi** | Launcher — snappy appear |
| **Dunst** | Notifications — slide from right |

These are configured in `config/themes/animations/rules.picom`.

---

## 13. Fonts

The system requires Nerd Fonts for icon support:

| Font | Usage | Size |
|------|-------|------|
| JetBrainsMono Nerd Font | Terminal (Alacritty), system default | 11 |
| JetBrainsMono Nerd Font | Polybar icons and text | 12 |
| JetBrainsMono Nerd Font | Rofi menus | 10 |
| FiraCode Nerd Font | Conky | 9 |
| Iosevka Nerd Font | Cava labels, alternative terminal | 10 |

Install via:
```bash
# Arch Linux
sudo pacman -S nerd-fonts-jetbrains-mono ttf-nerd-fonts-symbols
# Or manual install from https://www.nerdfonts.com/
```

---

## 14. EWW Widgets

EWW (ElKowar's Wacky Widgets) provides floating GTK widgets complementing the Polybar. Currently includes:

- **Powermenu**: 5 action buttons (Shutdown, Reboot, Lock, Suspend, Logout) with color-coded backgrounds
- **Control Center**: Quick toggles for WiFi, Bluetooth, Volume slider, Brightness slider + link to powermenu

### Dependencies

- `eww 0.6.0+` compiled with `--features x11` (installed in `/usr/local/bin/eww`)
- Rust toolchain (rustup) for compilation
- GTK3, cairo, pango, gdk-pixbuf, libdbusmenu-gtk3 development packages
- `pamixer` for volume control
- `brightnessctl` for backlight control

### Usage

| Action | Command |
|--------|---------|
| Toggle powermenu | `eww open/close powermenu` |
| Toggle control-center | `eww open/close control-center` |
| Close all | `eww close-all` |
| Debug | `eww logs` (blocking, use `timeout`) |
| Inspector | `eww inspector` (GTK inspector) |

### Architecture

- **`eww.yuck`**: Widget definitions using Yuck (Lisp-like DSL). Variables (`defpoll`) for volume and brightness.
- **`eww.scss`**: GTK CSS with SCSS preprocessing. Colors are defined as CSS classes, not inline styles.
- **Toggle scripts**: `toggle-powermenu.sh` and `toggle-control-center.sh` toggle between open/close.

The EWW daemon starts automatically via `exec_always` in the i3 config.

## 15. Troubleshooting

### Picom won't start

```bash
# Check for syntax errors
picom --config ~/.config/picom/picom.conf

# The config uses @include for animations and rules.
# Ensure the included files exist at the absolute paths
# specified in the config. The applyer transforms relative
# paths to absolute during deployment.
```

### Polybar won't load

```bash
# Test the config
polybar --config=~/.config/polybar/config.ini top

# Check launch script output
~/.config/polybar/launch.sh

# Common issues: missing fonts, invalid color values,
# script dependencies not installed
```

### Theme switch doesn't update everything

```bash
# Run applyers manually
~/.config/themes/bin/theme-switch.sh <theme-name>

# Or check each component:
~/.config/themes/applyers/apply-i3.sh <theme-dir>
~/.config/themes/applyers/apply-polybar.sh <theme-dir>
```

### Calendar doesn't float

The `for_window` rule for gnome-calendar is in `config/i3/config`:
```
for_window [class="Gnome-calendar"] floating enable, resize set 900 700, move position center
for_window [class="org.gnome.Calendar"] floating enable, resize set 900 700, move position center
```

If your calendar app has a different WM_CLASS, add a matching rule.

### Rofi menus look wrong

The settings menus use a shared base theme from `~/.config/themes/scripts/settings/.rasi-base`. If missing, an inline fallback is used. To regenerate:

```bash
# The base theme is auto-generated; delete and reopen a menu
rm ~/.config/themes/scripts/settings/.rasi-base
```

### "module cava not found"

Install cava: `sudo pacman -S cava` or `brew install cava`

---

## 16. Backups

The system includes automatic backup before major changes:

```bash
# Manual backup
tar -czf ~/Backups/themes-backup-$(date +%Y%m%d-%H%M%S).tar.gz ~/.config/themes/

# Backups are also created by install.sh before applying updates
```

Backup location: `~/Backups/oxido-i3-themes-backup-*.tar.gz`

### Restore from backup

```bash
tar -xzf ~/Backups/oxido-i3-themes-backup-20250521-*.tar.gz -C ~/
```

---

## 17. Change History

| Date | Version | Changes |
|------|---------|---------|
| 2026-05 | Fase 4C | Colorimetry fix: 9 themes with invisible bubble colors, 7 themes with low bg-alt contrast, primary visibility ensured |
| 2026-05 | Fase 4B | 7 new polybar layouts (12 total): default, sharp, colorblocks, material, rounded, panel, dual |
| 2026-05 | Fase 4A | Polybar layout fixes: wm-restack, bubble-center → bg-alt, powerline separators, floating radius, applyer sync |
| 2026-05 | Fase 3 | Default applications system, calendar floating, profile support |
| 2026-05 | Fase 2 | Animation centralization, @include structure, -83% picom.conf size |
| 2026-05 | Fase 1 | Bug fixes: triggers, presets, SSIDs, picom timeout, keybinding search |
| 2026-05 | Fase 0 | Initial theme system with 23 themes, Rofi selector, PowerSaver mode |
