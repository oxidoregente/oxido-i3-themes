# 🎨 oxido-i3-themes

> 23 visual themes · Rofi Control Center · picom v13 Animations · PowerSaver · Default apps

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A complete desktop customization system for **i3wm** that unifies themes, animations, sound, power management, and notifications into a Control Center accessible via a keyboard shortcut.

---

## ✨ Screenshots

| Desktop | Control Center | Theme Selector |
|---|---|---|
| ![desktop](assets/screenshots/desktop.png) | ![settings](assets/screenshots/settings.png) | ![themes](assets/screenshots/themes.png) |

| Animations | Power Menu | Notifications |
|---|---|---|
| ![animations](assets/screenshots/animations.png) | ![power](assets/screenshots/power.png) | ![notifications](assets/screenshots/notifications.png) |

---

## 🚀 Features

### 🎨 23 Visual Themes
| | | | |
|---|---|---|---|
| Catppuccin Latte | Catppuccin Mocha | Dracula | Dracula PowerSaver |
| Ethereal | Everforest | Flexoki Light | Gruvbox |
| Hackerman | Kanagawa | Last Horizon | Lumon |
| Matte Black | Miasma | Nord | Osaka Jade |
| Retro 82 | Ristretto | Rose Pine | Solitude |
| Tokyo Night | Vantablack | White | |

Each theme includes consistent colors across all desktop components: i3 · picom · polybar · dunst · rofi · alacritty · btop · cava · conky · lockscreen · **nemo (Files)**

### ⚙️ Control Center (`$mod+Shift+s`)
Unified panel with Rofi to manage the entire system:

| Category | Functions |
|---|---|
| 🔊 Sound | Volume ±5%, mute, pavucontrol, audio output selector |
| ☀️ Display | Brightness ±5%, wallpaper grid picker, DPMS off |
| 🔔 Notifications | Do Not Disturb, clear, history |
| 🎬 Animations | Hierarchical menu: Global / Per-app / Presets |
| 🎨 Appearance | Theme selector (split panel with preview), Conky toggle, gaps |
| ⚡ Power | PowerSaver, DPMS timeout, autolock, lid behavior |
| 🔧 System | Service status/restart, system information |
| 📋 Utilities | Screenshots, WiFi, Bluetooth, color picker, clipboard |

### 🎬 picom v13 Animations
Per-window animation system with 4 individually configurable triggers:

| Trigger | Effect |
|---|---|
| `Open window` (open) | Animation on open |
| `Close window` (close) | Animation on close |
| `Show` (on workspace switch) | Animation on show |
| `Hide` (on workspace leave) | Animation on hide |

**5 presets:** Classic · GNOME · macOS · Windows 11 · Snap

**Per-application:** Specific animations for Alacritty, Firefox, Rofi, and Dunst.

**No animation:** Option to disable animation per trigger (instant transition).

### 🔋 PowerSaver Mode (`$mod+Shift+p`)
Toggle that disables picom (switches to xrender), conky, and minimal polybar to save battery.

### 🖥️ GTK Theming / Nemo (Files)
When switching themes, **nemo** (Files) and other GTK applications update their accent colors to match the active theme:

| Theme | Nemo accent color |
|------|------------------------|
| Nord | `#81a1c1` (blue) |
| Dracula | `#bd93f9` (purple) |
| Gruvbox | `#d79921` (gold) |
| Everforest | `#7fbbb3` (teal) |

The system applies:
1. **Base GTK theme** — `Orchis-Dark` (modern, dark, nemo-compatible)
2. **Per-theme gtk.css** — Overrides sidebar, toolbar, selection, progress bars, and scrollbar colors to match the active theme's palette
3. **Icons** — `ePapirus-Dark`, consistent across all themes

> 💡 **Note:** nemo must be closed when switching themes for changes to apply. If already open, close and reopen it (`pkill nemo && nemo &`).

### 🎲 Random Theme
Press the "Random" button in the Theme Selector or run:
```bash
~/.config/themes/bin/theme-switch.sh $(ls ~/.config/themes/themes/ | shuf -n1)
```

### ⌨️ Keybinding Viewer
Press `$mod+Shift+/` to view all i3 keyboard shortcuts in a searchable Rofi menu.

---

### 🌍 Multi-language Support (i18n)
The system now supports dynamic language switching (Spanish/English) for all Rofi menus and notifications.
- **Setup**: `Control Center` → `🌍 Language`.

### 📏 Visual Scaling for Rofi
Easily scale all Rofi menus from a single place.
- **File**: `~/.config/themes/rofi/scale.env`
- **Variables**: `ROFI_SCALE` (e.g., 1.25 for +25%), `ROFI_FONT_SIZE`, etc.

### 🔋 Improved Battery Management
- **Fix**: Fixed critical bug that crashed Polybar when clicking the battery icon.
- **Power Profiles**: Integrated selector for energy profiles (Power Save, Balanced, Performance).

---

## 📦 Installation

### Requirements
- Linux with **i3wm** (or i3-gaps)
- Python 3 + GTK3 (for the theme selector)
- **Orchis-Dark** GTK theme (included in Linux Mint; on other distros install from package manager)
- Internet connection

### Quick install

```bash
git clone https://github.com/oxidoregente/oxido-i3-themes.git
cd oxido-i3-themes
chmod +x install.sh
./install.sh
```

The installer:
1. ✅ Detects your distro (Debian/Ubuntu, Arch, Fedora)
2. ✅ Installs all dependencies automatically
3. ✅ Backs up your existing configs
4. ✅ Copies themes, scripts, and configurations
5. ✅ Applies the default theme (Nord or Dracula)
6. ✅ Restarts services (picom, polybar, dunst)

### Manual installation

```bash
# 1. Copy configs manually
cp -r config/themes ~/.config/
cp -r config/i3/* ~/.config/i3/
cp -r config/picom/* ~/.config/picom/
cp -r config/polybar/* ~/.config/polybar/
cp -r config/dunst/* ~/.config/dunst/
cp -r config/rofi/* ~/.config/rofi/

# 2. Reload i3
$mod+Shift+r
```

### ⚠️ Important: GTK override in /etc
Some systems have a system-wide GTK config at `/etc/gtk-3.0/settings.ini` with `gtk-theme-name=Yaru` (or other). This can override the per-user GTK theme. If the GTK accent colors don't change after switching themes, check and override it:
```bash
sudo sed -i 's/^gtk-theme-name=.*/gtk-theme-name=Orchis-Dark/' /etc/gtk-3.0/settings.ini
```

---

## ⌨️ Keyboard Shortcuts

| Shortcut | Action |
|---|---|
| `$mod+Shift+s` | Control Center |
| `$mod+Shift+t` | Theme Selector (split panel with preview) |
| `$mod+Shift+p` | PowerSaver Mode |
| `$mod+Shift+n` | Toggle Conky |
| `$mod+Shift+/` | View all shortcuts |
| `$mod+d` | Application launcher (rofi drun) |
| `$mod+Shift+Space` | Toggle floating window |

---

## 📁 Project Structure

```
oxido-i3-themes/
├── config/
│   ├── themes/          → ~/.config/themes/ (complete theme system)
│   │   ├── bin/         → Main scripts (theme-switch, lock, etc.)
│   │   ├── scripts/     → Control Center (settings) + utilities
│   │   ├── applyers/    → Theme applyers per component
│   │   ├── themes/      → 23 themes with palettes, wallpapers, configs and gtk.css
│   │   └── templates/   → Templates for generating new themes
│   ├── i3/              → ~/.config/i3/ (config + scripts)
│   ├── picom/           → ~/.config/picom/picom.conf
│   ├── polybar/         → ~/.config/polybar/
│   ├── dunst/           → ~/.config/dunst/dunstrc
│   ├── rofi/            → ~/.config/rofi/
│   └── nitrogen/        → ~/.config/nitrogen/
├── assets/screenshots/  → Screenshots
├── docs/                → Additional documentation (Spanish)
├── install.sh           → Automatic installer
├── LICENSE              → MIT License
├── README.md            → This guide (Spanish)
└── README.en.md         → This guide (English)
```

---

## 🙏 Credits

This project builds upon the work of the community:

### Omarchy
The **visual themes** foundation, palette generators, and conversion scripts were created by **Omarchy** ([github.com/omarchy](https://github.com/omarchy)). The included themes are based on their theme generation system.

### Wallpapers
Wallpapers come from:
- **Unsplash** — Photos under the Unsplash license (free for commercial use, no attribution required)
- **Pexels** — Photos under the Pexels/CC0 license
- **Pixabay** — Images under the Pixabay license

Specific photographer credits are available in each image's metadata.

### Community & Research
- **r/unixporn** — Inspiration for color schemes and layouts
- **Arch Linux Forums** — Technical solutions for i3 configuration
- **Reddit Communities** — Tutorials and debugging for picom, polybar, and rofi
- **yshui/picom** — Documentation and examples for the v13 animation system
- **i3 Project** — The window manager foundation

### Tools
- **ImageMagick** — Image processing and thumbnail generation
- **Rofi** — Launcher and Control Center menus
- **Python GTK3** — Theme selector with live preview

### opencode

This project was not built by hand. Much of the code, debugging, refactoring, and documentation was generated, reviewed, and corrected by **[opencode](https://opencode.ai)**, an AI-powered software engineering tool that operates directly on the filesystem and terminal.

The idea, direction, conceptual design, and overall supervision belong to **oxidoregente** — the human author behind this repository — who conceived and guided every feature, from the Rofi Control Center to the animation system and PowerSaver mode. opencode acted as a tireless pair programmer, implementing and debugging at the file level, enabling a development pace that would have been impossible manually.

> Inspirations and attributions to the community — including Omarchy, r/unixporn, Arch Linux Forums, yshui/picom, and the i3 project — are detailed in the sections above and remain fully credited.

---

## 📄 License

**MIT License** — Completely free to use, modify, and share.

The software is provided "AS IS", without warranty of any kind. See the [LICENSE](LICENSE) file for details.

Made with ❤️ for the Linux and i3 community.
