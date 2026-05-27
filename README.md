# 🎨 oxido-i3-themes

> 23 temas visuales · Centro de Control en Rofi · Animaciones picom v13 · PowerSaver · Apps predeterminadas

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

### 🧩 7 Layouts de Polybar
| Layout | Estilo | Altura | Señal visual |
|--------|--------|--------|-------------|
| **bubble** | 4 barras independientes | 34px | Dividido en 3+1 segmentos flotantes, cada uno con su color de burbuja |
| **floating** | Barra única con caps | 32px | Wedges en las 3 secciones (float/center/sys), bordes redondeados, offset 1% |
| **blocks** | Módulos bloque | 28px | Cada módulo con fondo `bg-alt`, separados visualmente en grupos |
| **rounded** | Forma de píldora | 24px | Fondo `bg-alt`, radio 18px, apariencia compacta y limpia |
| **hack** | Brackets retro | 24px | Decoración ❰❱, estética terminal/hacker |
| **minimal** | Ultra compacto | 22px | Sin decoraciones, fuente pequeña, máximo espacio para contenido |
| **powerline** | Caps en workspaces | 30px | Wedges / en los bordes de workspaces, fuente Iosevka |

Cada layout tiene **todos los módulos disponibles** definidos (dnd, network, cpu, cpu-temp, memory, pulseaudio, battery, tray, powermenu, nowplaying). Los que no están activos por defecto aparecen como "ocultos" en el **Gestor de Módulos** (`$mod+Shift+m`) y podés activarlos con un clic.

### ⚙️ Centro de Control (`$mod+Shift+s`)
Panel unificado con Rofi para gestionar todo el sistema:

| Categoría | Funciones |
|---|---|
| 🔊 Sonido | Volumen ±5%, mute, pavucontrol, selector de salida de audio |
| ☀️ Pantalla | Brillo ±5%, selector de wallpapers con grid, DPMS off |
| 🔔 Notificaciones | No Molestar, limpiar, historial |
| 🎬 Animaciones | Menú jerárquico: Global / Por app / Preestablecidos |
| 🎨 Apariencia | Selector de temas (split panel con preview), toggle Conky, gaps |
| ⚡ Energía | PowerSaver, Plan de energía, Formato de hora, DPMS timeout, autolock, comportamiento de tapa |
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
También establece el perfil de CPU en `power-saver`; al salir restaura el perfil original.
Incluye lockfile anti-doble-toggle y espera a que los procesos terminen antes de copiar configs.

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

### 🌍 Soporte Multi-idioma (i18n)
Cambio de idioma dinámico (Español/Inglés) para todos los menús de Rofi y notificaciones.
- **Configuración**: `Centro de Control` → `🌍 Idioma`.
- **Persistencia**: El idioma seleccionado persiste entre sesiones (escribe a `~/.config/themes/lang/`).

### 📏 Escalado Visual de Rofi
Puedes agrandar o achicar todos los menús de Rofi de forma centralizada.
- **Archivo**: `~/.config/themes/rofi/scale.env`
- **Variables**: `ROFI_SCALE` (ej: 1.25 para +25%), `ROFI_FONT_SIZE`, etc.

### 🔋 Gestión de Batería Mejorada
- **Fix**: Corregido bug que crasheaba la Polybar al hacer click en la batería.
- **Nuevos Modos**: Selector de perfiles de energía (Ahorro, Equilibrado, Rendimiento) integrado.

### 📦 Gestor de Módulos de Polybar (`$mod+Shift+m`)
Panel visual para reorganizar los módulos de la Polybar sin editar archivos:
- **Intercambio directo**: Seleccionás un módulo, elegís "Intercambiar con..." y seleccionás con cuál trocar posiciones.
- **Ocultar/Mostrar**: Mové módulos a la sección de Ocultos y viceversa.
- **Reordenar**: Reordenamiento visual dentro de cada sección.
- **Restaurar**: Volvé a la disposición original del layout con un clic.
- **Multi-idioma**: Totalmente traducido (Español/Inglés).

### 🧩 Split-Bar Layout (`bubble`)
El layout **bubble** divide la Polybar en 4 barras independientes (left, center, player, right) que flotan sobre el escritorio con 80% de transparencia:

| Barra | Ancho | Posición | Función |
|---|---|---|---|
| left | 22% | x=0% | Espacio reservado (consistencia visual, sin strut) |
| center | 12% | x=27% | Burbuja con fecha centrada, se expande a 39% cuando player está oculto |
| player | 16% | x=48% | Módulo nowplaying, aparece/desaparece con `polybar-msg cmd hide/show` |
| right | 100% | x=0% | Módulos del sistema (batería, red, sonido, etc.), ocupa el resto del espacio |

**Características clave:**
- **Detección inteligente de reproductor** (`playerctl-wrapper.sh`): Prioriza Spotify (Playing > Paused) sobre Brave/Chrome (MPRIS). Solo una fuente activa por vez.
- **Ocultamiento dinámico**: Cuando no hay reproductor activo, la barra player se oculta y la barra center se expande (`polybar-msg cmd hide`) recuperando el espacio visual sin strut residual.
- **Ajuste adaptativo de anchos** (`calc-adaptive-widths.sh`): Calcula automáticamente offset-x, width y right_pct según la resolución del monitor, manteniendo un gap de 10px entre barras.
- **Offset dinámico del center**: Al aparecer el reproductor, el center se desplaza de x=27% a x=29% para equilibrar la composición visual. Al ocultarse, vuelve a su posición original.
- **Fullscreen automático**: Todas las barras se ocultan al detectar una ventana en pantalla completa (`fullscreen-monitor.sh` con `i3-msg -t subscribe`), ignorando falsos positivos de `fullscreen_mode=1` en workspaces vacíos.
- **Compatibilidad multi-layout**: `polybar-modules.sh` muestra un mensaje graceful si se selecciona un layout que no sea bubble.
- **Transparencia forzada**: `apply-polybar.sh` inyecta alpha `CC` (80% opaco) para que la barra se vea sólida y contrastada contra cualquier wallpaper.
- **Sin strut**: Todas las barras usan `override-redirect = true`; la i3bar reserva 34px en modo dock para mantener el gap visual superior.

**Scripts del sistema:**
| Script | Función |
|---|---|
| `launch.sh` | Lanzador dinámico con limpieza de lockfiles y `pkill` preciso |
| `player-monitor.sh` | Monitoreo continuo de player + fullscreen, IPC hide/show y reflow del center |
| `fullscreen-monitor.sh` | Suscripción a eventos i3 para ocultar/mostrar todas las barras |
| `calc-adaptive-widths.sh` | Cálculo de anchos y offsets proporcionales al monitor |
| `center-bubble.sh` | Módulo custom que renderiza borde+wedges+fecha con colores del tema activo |
| `playerctl-wrapper.sh` | Wrapper con detección prioritaria de reproductor activo |
| `nowplaying.sh` | Módulo nowplaying sourced desde el wrapper |

### 🕐 Reloj configurable (12h / 24h)
La fecha en la Polybar se puede alternar entre formato de 12 y 24 horas desde el Centro de Control (`$mod+Shift+s` → Energía).
- **Formato por defecto**: `%I:%M %p` (12h, ej: 02:30 PM)
- **Formato alternativo**: `%H:%M` (24h, ej: 14:30)
- **Persistencia**: La selección se guarda en `~/.config/themes/date-format`
- **Afecta todos los layouts**: Los layouts con `internal/date` se actualizan via `apply-polybar.sh`. Los layouts que usan scripts custom (`bubble` con `date-wrapper.sh` y `center-bubble.sh`) leen el archivo de estado directamente.
- **Fecha extendida**: Al hacer clic en el reloj, muestra `%A, %d %B %Y` en el idioma activo (ej: sábado, 23 mayo 2026)

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
| `$mod+Shift+m` | Gestor de Módulos de Polybar |
| `$mod+Shift+l` | Gestor de Layouts de Polybar |
| `$mod+Shift+p` | PowerSaver Mode |
| `$mod+Shift+n` | Toggle Conky |
| `$mod+Shift+/` | Ver todos los atajos |
| `$mod+d` | Lanzador de aplicaciones (rofi drun) |
| `$mod+Shift+Space` | Ventana flotante |
| `Print` / `PrtSc` | Captura de pantalla (área seleccionable) |

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

### 🌐 Comunidad e Inspiración (Polybar)

Estos proyectos de la comunidad inspiraron directamente el sistema de layouts y colorimetría:

| Proyecto | ★ | Aporte a oxido-i3-themes |
|----------|---|--------------------------|
| [adi1090x/polybar-themes](https://github.com/adi1090x/polybar-themes) | 6.2k | 12 familias de layouts, dark/light variants por archivo separado, pywal, `random.sh`, preview de módulos, rofi integrado |
| [gh0stzk/dotfiles](https://github.com/gh0stzk/dotfiles) | 4.6k | Theme switching instantáneo sin reinicio, auto-detección multi-monitor, RiceEditor, <500MB RAM |
| [polybar/polybar-scripts](https://github.com/polybar/polybar-scripts) | 2.6k | 50+ scripts: weather (MPRIS), battery (udev), bluetooth, IMAP, crypto, hackspeed |
| [Murzchnvok/polybar-collection](https://github.com/Murzchnvok/polybar-collection) | 923 | `include-directory` para módulos, variables env (`POLYBAR_COLLECTION`), separadores decorativos con glyphs, detección automática de hardware |
| [Yucklys/polybar-nord-theme](https://github.com/Yucklys/polybar-nord-theme) | 247 | `inherit` chain para bar definitions, dual-bar con config compartida |
| [kiddae/polybar-themes](https://github.com/kiddae/polybar-themes) | 433 | xrdb-based colors (`${xrdb:color0}`), themes que se adaptan al sistema |
| [r/unixporn](https://reddit.com/r/unixporn) | — | Tendencias: dark (80% de posts), slim bars 24-32px, Nerd Fonts, ARGB `#00` transparency, pywal, spotify/mpris module |

**Lo que adoptamos:**
- De **adi1090x**: separación colors.ini ↔ layouts.ini, layouts intercambiables (12 diseños)
- De **gh0stzk**: theme switching instantáneo, selector Rofi unificado
- De **Murzchnvok**: separadores powerline glyphs, estructura modular de includes
- De **polybar-scripts**: patrones de battery status, dnd indicator, cava, power menu

### Comunidad e Investigación (General)
- **r/unixporn** — Inspiración para combinaciones de colores y layouts
- **Arch Linux Forums** — Soluciones técnicas para configuración de i3
- **yshui/picom** — Documentación y ejemplos del sistema de animaciones v13
- **Proyecto i3** — Window manager base de todo el sistema

### Herramientas
- **ImageMagick** — Procesamiento de imágenes y generación de thumbnails
- **Rofi** — Lanzador y menús del Centro de Control
- **Python GTK3** — Selector de temas con vista previa

### opencode

Este proyecto no se hizo a mano. Gran parte del código, debugging, refactorización y documentación fue generada, revisada y corregida por **[opencode](https://opencode.ai)**, una herramienta de IA para ingeniería de software que opera directamente sobre el sistema de archivos y el terminal.

La idea, dirección, diseño conceptual y supervisión general del proyecto son de **oxidoregente** — el autor humano detrás del repositorio — quien concibió y guió cada funcionalidad, desde el Centro de Control en Rofi hasta el sistema de animaciones y PowerSaver. opencode actuó como un par de programación incansable, implementando y depurando a nivel de archivo, permitiendo un ritmo de desarrollo que habría sido imposible manualmente.

> Inspiraciones y atribuciones a la comunidad — incluyendo Omarchy, r/unixporn, Arch Linux Forums, yshui/picom y el proyecto i3 — se detallan en las secciones anteriores y se mantienen con todo el crédito que merecen.

---

## 📄 Licencia

**MIT License** — Totalmente libre de usar, modificar y compartir.

El software se proporciona "COMO ESTÁ", sin garantía de ningún tipo. Ver el archivo [LICENSE](LICENSE) para más detalles.

Hecho con ❤️ para la comunidad de Linux y i3.
