# 🎨 oxido-i3-themes

> 23 temas visuales · Centro de Control en Rofi · Animaciones picom v13 · PowerSaver

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Un sistema completo de personalización visual para **i3wm** que unifica temas, animaciones, sonido, energía y notificaciones en un Centro de Control accesible con un atajo de teclado.

---

## ✨ Capturas

| Escritorio | Centro de Control | Selector de Temas |
|---|---|---|
| ![desktop](assets/screenshots/desktop.png) | ![settings](assets/screenshots/settings.png) | ![themes](assets/screenshots/themes.png) |

| Animaciones | Menú de Energía | Notificaciones |
|---|---|---|
| ![animations](assets/screenshots/animations.png) | ![power](assets/screenshots/power.png) | ![notifications](assets/screenshots/notifications.png) |

---

## 🚀 Características

### 🎨 23 Temas Visuales
| | | | |
|---|---|---|---|
| Catppuccin Latte | Catppuccin Mocha | Dracula | Dracula PowerSaver |
| Ethereal | Everforest | Flexoki Light | Gruvbox |
| Hackerman | Kanagawa | Last Horizon | Lumon |
| Matte Black | Miasma | Nord | Osaka Jade |
| Retro 82 | Ristretto | Rose Pine | Solitude |
| Tokyo Night | Vantablack | White | |

Cada tema incluye colores coherentes para todos los componentes del escritorio: i3 · picom · polybar · dunst · rofi · alacritty · btop · cava · conky · lockscreen · **nemo (Archivos)**

### ⚙️ Centro de Control (`$mod+Shift+s`)
Panel unificado con Rofi para gestionar todo el sistema:

| Categoría | Funciones |
|---|---|
| 🔊 Sonido | Volumen ±5%, mute, pavucontrol, selector de salida de audio |
| ☀️ Pantalla | Brillo ±5%, selector de wallpapers con grid, DPMS off |
| 🔔 Notificaciones | No Molestar, limpiar, historial |
| 🎬 Animaciones | Menú jerárquico: Global / Por app / Preestablecidos |
| 🎨 Apariencia | Selector de temas (split panel con preview), toggle Conky, gaps |
| ⚡ Energía | PowerSaver, DPMS timeout, autolock, comportamiento de tapa |
| 🔧 Sistema | Estado/restart de servicios, información del sistema |
| 📋 Utilidades | Capturas, WiFi, Bluetooth, color picker, clipboard |

### 🎬 Animaciones con picom v13
Sistema de animaciones por ventana con 4 triggers configurables individualmente:

| Trigger | Efecto |
|---|---|
| `Abrir ventana` (open) | Animación al abrir |
| `Cerrar ventana` (close) | Animación al cerrar |
| `Show` (al cambiar workspace) | Animación al mostrar |
| `Hide` (al salir workspace) | Animación al ocultar |

**5 presets preconfigurados:** Clásico · GNOME · macOS · Windows 11 · Snap

**Por aplicación:** Animaciones específicas para Alacritty, Firefox, Rofi y Dunst.

**Sin animación:** Opción para desactivar la animación por trigger (transición instantánea).

### 🔋 PowerSaver Mode (`$mod+Shift+p`)
Toggle que desactiva picom (cambia a xrender), conky y polybar mínima para ahorrar batería.

### 🖥️ Tema GTK / Nemo (Archivos)
Al cambiar de tema, el Gestor de Archivos **nemo** (Archivos) y otras aplicaciones GTK actualizan sus colores de acento para coincidir con el tema activo:

| Tema | Color de acento en nemo |
|------|------------------------|
| Nord | `#81a1c1` (azul) |
| Dracula | `#bd93f9` (púrpura) |
| Gruvbox | `#d79921` (dorado) |
| Everforest | `#7fbbb3` (verde agua) |

El sistema aplica:
1. **Tema GTK base** — `Orchis-Dark` (moderno, oscuro, compatible con nemo)
2. **gtk.css por tema** — Sobreescribe colores de sidebar, toolbar, selección, barras de progreso y scrollbars para que coincidan con la paleta del tema activo
3. **Iconos** — `ePapirus-Dark` consistente con todos los temas

> 💡 **Nota:** nemo debe estar cerrado al cambiar de tema para que los cambios se apliquen. Si ya está abierto, cerrarlo y abrirlo de nuevo (`pkill nemo && nemo &`).

---

## 📦 Instalación

### Requisitos
- Linux con **i3wm** (o i3-gaps)
- Python 3 + GTK3 (para el selector de temas)
- Tema GTK **Orchis-Dark** (viene incluido en Linux Mint; en otras distros se instala desde el gestor de paquetes)
- Conexión a internet

### Un solo comando

```bash
git clone https://github.com/oxidoregente/oxido-i3-themes.git
cd oxido-i3-themes
chmod +x install.sh
./install.sh
```

El instalador:
1. ✅ Detecta tu distro (Debian/Ubuntu, Arch, Fedora)
2. ✅ Instala todas las dependencias automáticamente
3. ✅ Hace backup de tus configuraciones existentes
4. ✅ Copia los temas, scripts y configuraciones
5. ✅ Aplica el tema por defecto (Nord o Dracula)
6. ✅ Reinicia los servicios (picom, polybar, dunst)

### Instalación manual

```bash
# 1. Copiar configuraciones manualmente
cp -r config/themes ~/.config/
cp -r config/i3/* ~/.config/i3/
cp -r config/picom/* ~/.config/picom/
cp -r config/polybar/* ~/.config/polybar/
cp -r config/dunst/* ~/.config/dunst/
cp -r config/rofi/* ~/.config/rofi/

# 2. Recargar i3
$mod+Shift+r
```

---

## ⌨️ Atajos de Teclado

| Atajo | Acción |
|---|---|
| `$mod+Shift+s` | Centro de Control |
| `$mod+Shift+t` | Selector de Temas (split panel con preview) |
| `$mod+Shift+p` | PowerSaver Mode |
| `$mod+Shift+n` | Toggle Conky |
| `$mod+Shift+/` | Ver todos los atajos |
| `$mod+d` | Lanzador de aplicaciones (rofi drun) |
| `$mod+Shift+Space` | Ventana flotante |

---

## 📁 Estructura del Proyecto

```
oxido-i3-themes/
├── config/
│   ├── themes/          → ~/.config/themes/ (sistema de temas completo)
│   │   ├── bin/         → Scripts principales (theme-switch, lock, etc.)
│   │   ├── scripts/     → Centro de Control (settings) + utilidades
│   │   ├── applyers/    → Aplicadores de tema por componente
│   │   ├── themes/      → 23 temas con paletas, wallpapers, configs y gtk.css
│   │   └── templates/   → Plantillas para generar nuevos temas
│   ├── i3/              → ~/.config/i3/ (config + scripts)
│   ├── picom/           → ~/.config/picom/picom.conf
│   ├── polybar/         → ~/.config/polybar/
│   ├── dunst/           → ~/.config/dunst/dunstrc
│   ├── rofi/            → ~/.config/rofi/
│   └── nitrogen/        → ~/.config/nitrogen/
├── assets/screenshots/  → Capturas de pantalla
├── docs/                → Documentación adicional
├── install.sh           → Instalador automático
├── LICENSE              → MIT License
└── README.md            → Esta guía
```

---

## 🙏 Créditos y Atribuciones

Este proyecto no sería posible sin el trabajo de la comunidad:

### Omarchy
La base de los **temas visuales**, generadores de paletas y scripts de conversión fueron creados por **Omarchy** ([github.com/omarchy](https://github.com/omarchy)). Los 24 temas incluidos están basados en su sistema de generación de temas.

### Wallpapers
Los fondos de pantalla provienen de:
- **Unsplash** — Fotos bajo licencia Unsplash (libres para uso comercial sin atribución)
- **Pexels** — Fotos bajo licencia Pexels/CC0
- **Pixabay** — Imágenes bajo licencia Pixabay

Créditos específicos de fotógrafos disponibles en los metadatos de cada imagen.

### Comunidad e Investigación
- **r/unixporn** — Inspiración para combinaciones de colores y layouts
- **Arch Linux Forums** — Soluciones técnicas para configuración de i3
- **Reddit Communities** — Tutoriales y debugging de picom, polybar y rofi
- **yshui/picom** — Documentación y ejemplos del sistema de animaciones v13
- **Proyecto i3** — Window manager base de todo el sistema

### Herramientas
- **ImageMagick** — Procesamiento de imágenes y generación de thumbnails
- **Rofi** — Lanzador y menús del Centro de Control
- **Python GTK3** — Selector de temas con vista previa

---

## 📄 Licencia

**MIT License** — Totalmente libre de usar, modificar y compartir.

El software se proporciona "COMO ESTÁ", sin garantía de ningún tipo. Ver el archivo [LICENSE](LICENSE) para más detalles.

Hecho con ❤️ para la comunidad de Linux y i3.
