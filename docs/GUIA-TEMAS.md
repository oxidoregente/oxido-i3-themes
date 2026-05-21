# 🎨 Sistema de Temas para i3wm + Polybar

Guía completa de instalación, configuración y personalización.

---

## 📋 Índice

1. [Introducción](#1-introducción)
2. [Estructura de Directorios](#2-estructura-de-directorios)
3. [Temas Disponibles](#3-temas-disponibles)
4. [Atajos de Teclado](#4-atajos-de-teclado)
5. [Cambiar de Tema](#5-cambiar-de-tema)
6. [Modo PowerSaver](#6-modo-powersaver)
7. [Conky](#7-conky)
8. [Centro de Control](#8-centro-de-control-settings)
9. [Agregar un Tema Nuevo](#9-agregar-un-tema-nuevo)
10. [Personalización por Componente](#10-personalización-por-componente)
11. [Fuentes](#11-fuentes)
12. [Solución de Problemas](#12-solución-de-problemas)
13. [Respaldos](#13-respaldos)
14. [Historial de Cambios](#14-historial-de-cambios)
14. [Apéndice A: Comandos Rápidos](#apéndice-a-comandos-rápidos)
15. [Apéndice B: Referencia de Rutas](#apéndice-b-referencia-de-rutas)
16. [Apéndice C: Gestión de Temperatura](#apéndice-c-gestión-de-temperatura)
17. [Apéndice D: Referencia de Configuración](#apéndice-d-referencia-de-configuración)

---

## 1. Introducción

Este sistema permite cambiar entre múltiples temas visuales completos en i3wm. Cada tema incluye colores para:

- **i3** (ventanas, bordes, fondo)
- **Polybar** (barra de estado con diseño de burbujas segmentadas)
- **Picom** (sombras, desenfoque, animaciones)
- **Dunst** (notificaciones)
- **Rofi** (lanzador y selector)
- **Conky** (información del sistema)
- **Alacritty** (terminal)
- **Btop** (monitor del sistema)
- **Cava** (visualizador de audio)
- **Wallpaper** (fondo de pantalla por tema)

Actualmente hay **24 temas**: 7 originales + 17 inspirados en el repositorio oficial de Omarchy.

El diseño visual usa un estilo de **burbujas segmentadas** en Polybar:

```
┌──────────┐  ┌──────────┐  ┌──────────────────────────────┐
│ 1 2 3 4 5 │  │  10:30  │  │  45%  50°  75%  80% │
└──────────┘  └──────────┘  └──────────────────────────────┘
  Workspaces      Fecha               Sistema
```

Cada burbuja tiene un color de fondo ligeramente distinto para crear profundidad visual.

---

## 2. Estructura de Directorios

```
~/.config/themes/
├── bin/                          # Scripts principales
│   ├── theme-switch.sh           #   Cambia el tema activo
│   ├── rofi-theme-selector.sh    #   Selector visual con Rofi (grid + paginación)
│   ├── rofi-settings.sh          #   ⚙️ Centro de Control (menú principal)
│   ├── toggle-conky.sh           #   Activa/desactiva Conky
│   ├── fix-dnd-module.py         #   Repara módulo DND en 24 temas
│   ├── verify-themes.sh          #   Verifica integridad de los 24 temas
│   ├── add-hackerman-theme.sh    #   Genera el tema Hackerman
│   ├── add-all-omarchy-themes.py #   Genera los 8 temas Omarchy faltantes
│   ├── regenerate-dunst.py       #   Regenera dunst para los 24 temas
│   ├── generate-omarchy-themes.py#   Genera temas nuevos desde colores
│   ├── animation-picker.sh       #   Elige animación de cierre (Rofi/CLI)
│   ├── lock.sh                   #   Bloquea pantalla con fondo del tema
│   └── propagate-fixes.py        #   Propaga cambios a los 24 temas
│
├── applyers/                     # Aplicadores de cada componente
│   ├── apply-polybar.sh          #   Copia y reinicia Polybar
│   ├── apply-i3.sh               #   Copia colores y recarga i3
│   ├── apply-picom.sh            #   Copia y reinicia Picom
│   ├── apply-dunst.sh            #   Copia y reinicia Dunst
│   ├── apply-conky.sh            #   Copia e inicia Conky
│   ├── apply-rofi.sh             #   Copia tema de Rofi
│   ├── apply-alacritty.sh        #   Copia tema de Alacritty
│   ├── apply-wallpaper.sh        #   Aplica wallpaper (cualquier formato)
│   ├── apply-btop.sh             #   Copia tema de Btop
│   ├── apply-cava.sh             #   Copia config de Cava + recarga colores
│   ├── apply-lockscreen.sh       #   Copia unlock.png del tema activo
│   └── apply-opencode.sh         #   Aplica tema de OpenCode
│
├── scripts/                      # Scripts auxiliares
│   ├── batt_status.sh            #   Estado de batería para Polybar
│   ├── cava-polybar.sh           #   Visualizador de audio para Polybar
│   ├── toggle-powersaver.sh      #   Activa/desactiva modo ahorro
│   ├── toggle-dnd.sh             #   Activa/desactiva No Molestar
│   ├── dnd-indicator.sh          #   Indicador de DND para Polybar (colores)
│   ├── notify-send.sh            #   Enviar notis con iconos Nerd Font
│   ├── notify-time.sh            #   Notificación de hora actual
│   ├── notify-battery.sh         #   Notificación de estado de batería
│   ├── notify-weather.sh         #   Notificación del clima
│   ├── power-menu.sh             #   Menú de energía (suspender, tapa, etc.)
│   └── settings/                 #   Centro de Control (8 sub-scripts)
│       ├── .rasi-base            #     Tema RASI compartido
│       ├── sound.sh              #     🔊 Sonido
│       ├── display.sh            #     ☀️ Pantalla
│       ├── notify.sh             #     🔔 Notificaciones + DND
│       ├── animation.sh          #     🎬 Animaciones
│       ├── appearance.sh         #     🎨 Apariencia
│       ├── power.sh              #     ⚡ Energía
│       ├── system.sh             #     🔧 Sistema
│       ├── utils.sh              #     📋 Utilidades
│       ├── wallpaper.sh          #     🖼️ Selector de wallpapers
│       ├── screenshot.sh         #     📸 Capturas de pantalla
│       ├── wifi.sh               #     🌐 Red WiFi
│       ├── bluetooth.sh          #     🔵 Bluetooth
│       ├── colorpicker.sh        #     🎨 Color picker
│       ├── clipboard.sh          #     📋 Portapapeles
│       ├── gaps.sh               #     ▦ Ajuste de gaps
│       ├── dpms.sh               #     💤 DPMS timeout
│       ├── autolock.sh           #     🔒 Bloqueo automático
│       ├── lid.sh                #     󰤁 Comportamiento tapa
│       ├── sysinfo.sh            #     󰍹 Información del sistema
│       ├── sound-sink.sh         #      Selector salida audio
│       └── keybindings.sh        #     ⌨️ Visor de atajos
│
├── current/                      # Enlace al tema activo
│   └── theme -> ../themes/dracula
│
├── conky-enabled                 # Flag: si existe, Conky está activo
│
├── templates/                    # Plantillas (uso futuro)
│
├── themes/                       # 24 temas individuales
│
└── ~/.cache/theme-thumbs/        # Miniaturas para grid preview (autogeneradas)
    ├── dracula/                  #   🟣 Dracula (oscuro, púrpura)
    ├── catppuccin-mocha/         #   🟤 Catppuccin Mocha (cálido oscuro)
    ├── tokyo-night/              #   🔵 Tokyo Night (azul profundo)
    ├── nord/                     #   🌀 Nord (azul grisáceo)
    ├── gruvbox/                  #   🟡 Gruvbox (retro amarillento)
    ├── clean-white/              #   ⚪ Clean White (minimalista oscuro)
    ├── everforest/               #   🌲 Everforest (verde bosque)
    ├── kanagawa/                 #   🌊 Kanagawa (azul ola)
    ├── rose-pine/                #   🌹 Rose Pine (rosa tenue)
    ├── catppuccin-latte/         #   ☕ Catppuccin Latte (cálido)
    ├── flexoki-light/            #   📜 Flexoki Light (sepia)
    ├── matte-black/              #   ⬛ Matte Black (negro absoluto)
    ├── osaka-jade/               #   🟩 Osaka Jade (verde jade)
    ├── ristretto/                #   ☕ Ristretto (marrón café)
    ├── dracula-powersaver/       #   🌙 Dracula PowerSaver (ultra-liviano)
    ├── hackerman/                #   💚 Hackerman (verde neón, matrix)
    ├── ethereal/                 #   🔮 Ethereal (noche azulada, durazno)
    ├── lumon/                    #   🏢 Lumon (azul corporativo, Severance)
    ├── miasma/                   #   🌫️ Miasma (tonos oliva/sepia)
    ├── vantablack/               #   ⬛ Vantablack (negro puro, grises)
    ├── retro-82/                 #   📼 Retro 82 (noche retro, naranja)
    ├── white/                    #   ⬜ White (oscuro adaptado, minimal)
    ├── last-horizon/             #   🌅 Last Horizon (tonos tierra)
    ├── solitude/                 #   ❄️ Solitude (gris frío, minimal)
    └── (cada tema contiene:)
        ├── polybar/config.ini    #     Barra de estado
        ├── i3/colors.conf        #     Colores de ventanas
        ├── picom/picom.conf      #     Compositor (animaciones)
        ├── dunst/dunstrc         #     Notificaciones
        ├── rofi/config.rasi      #     Lanzador
        ├── conky/conky.conf      #     Info del sistema
        ├── alacritty/theme.toml  #     Terminal
        ├── btop/*.theme          #     Tema de Btop
        ├── cava/config           #     Config de Cava (gradiente 8 colores)
        └── backgrounds/          #     Fondos de pantalla (1+ imágenes)
```

### Archivos activos (copiados al hacer "apply")

| Componente | Ruta activa |
|---|---|
| Polybar | `~/.config/polybar/config.ini` |
| i3 colores | `~/.config/i3/colors.conf` |
| Picom | `~/.config/picom/picom.conf` |
| Dunst | `~/.config/dunst/dunstrc` |
| Rofi | `~/.config/rofi/config.rasi` |
| Conky | `~/.config/conky/conky.conf` |
| Alacritty | `~/.config/alacritty/theme.toml` |
| Btop | `~/.config/btop/themes/<tema>.theme` + `btop.conf` |
| Cava | `~/.config/cava/config` |
| Wallpaper | Gestionado por `~/.config/nitrogen/bg-saved.cfg` |

---

## 3. Temas Disponibles

### 3.1 Dracula 🟣
Tema oscuro con acentos púrpura. Clásico, alto contraste.

| Variable | Color | Uso |
|---|---|---|
| Fondo | `#282a36` | Barra, ventanas |
| Fondo alterno | `#3c3e4a` | Elementos secundarios |
| Texto | `#f8f8f2` | Letras, iconos |
| Primario | `#bd93f9` | Púrpura (acento) |
| Secundario | `#8be9fd` | Cian (sub-acento) |
| Alerta | `#ff5555` | Rojo (urgente) |
| Verde | `#50fa7b` | Éxito, batería llena |
| Rosa | `#ff79c6` | RAM, memory |

### 3.2 Catppuccin Mocha 🟤
Tema oscuro cálido. Variante "mocha" de Catppuccin.

| Variable | Color |
|---|---|
| Fondo | `#1e1e2e` |
| Fondo alterno | `#313244` |
| Texto | `#cdd6f4` |
| Primario | `#cba6f7` |
| Secundario | `#89dceb` |
| Alerta | `#f38ba8` |

### 3.3 Tokyo Night 🔵
Tema azul profundo, muy popular en la comunidad.

| Variable | Color |
|---|---|
| Fondo | `#1a1b26` |
| Fondo alterno | `#2f3347` |
| Texto | `#c0caf5` |
| Primario | `#7aa2f7` |
| Secundario | `#73daca` |
| Alerta | `#f7768e` |

### 3.4 Nord 🌀
Tema azul grisáceo inspirado en el Ártico.

| Variable | Color |
|---|---|
| Fondo | `#2e3440` |
| Fondo alterno | `#3b4252` |
| Texto | `#eceff4` |
| Primario | `#88c0d0` |
| Secundario | `#81a1c1` |
| Alerta | `#bf616a` |

### 3.5 Gruvbox 🟡
Tema retro con tonos amarillo/verde tierra.

| Variable | Color |
|---|---|
| Fondo | `#282828` |
| Fondo alterno | `#3c3836` |
| Texto | `#ebdbb2` |
| Primario | `#d79921` |
| Secundario | `#98971a` |
| Alerta | `#cc241d` |

### 3.6 Clean White ⚪
Tema minimalista con fondo oscuro y acentos azul-grisáceo. A pesar del nombre, usa fondo oscuro.

| Variable | Color |
|---|---|
| Fondo | `#1a1a24` |
| Fondo alterno | `#272736` |
| Texto | `#e0e0e0` |
| Primario | `#7c7cf0` |
| Secundario | `#6c8c9c` |
| Alerta | `#e53935` |

### 3.7 Everforest 🌲
Tema verde bosque, inspirado en la naturaleza. Traído de Omarchy.

| Variable | Color |
|---|---|
| Fondo | `#1e2326` |
| Fondo alterno | `#2d3a3f` |
| Texto | `#d3c6aa` |
| Primario | `#7fbbb3` |
| Secundario | `#a7c080` |
| Alerta | `#e67e80` |

### 3.8 Kanagawa 🌊
Tema azul ola, inspirado en la pintura "La gran ola de Kanagawa". Traído de Omarchy.

| Variable | Color |
|---|---|
| Fondo | `#1f1f28` |
| Fondo alterno | `#363646` |
| Texto | `#dcd7ba` |
| Primario | `#7e9cd8` |
| Secundario | `#7fb4ca` |
| Alerta | `#c34043` |

### 3.9 Rose Pine 🌹
Tema rosa tenue, suave y elegante. Traído de Omarchy (adaptado a fondo oscuro).

| Variable | Color |
|---|---|
| Fondo | `#232136` |
| Fondo alterno | `#393552` |
| Texto | `#e0def4` |
| Primario | `#c4a7e7` |
| Secundario | `#9ccfd8` |
| Alerta | `#eb6f92` |

### 3.10 Catppuccin Latte ☕
Tema cálido claro. Originalmente un tema claro, adaptado a fondo oscuro. Traído de Omarchy.

| Variable | Color |
|---|---|
| Fondo | `#1e1e2e` |
| Fondo alterno | `#2f2f40` |
| Texto | `#cdd6f4` |
| Primario | `#89b4fa` |
| Secundario | `#a6e3a1` |
| Alerta | `#f38ba8` |

### 3.11 Flexoki Light 📜
Tema sepia claro, inspirado en papel. Adaptado a fondo oscuro. Traído de Omarchy.

| Variable | Color |
|---|---|
| Fondo | `#1c1c1c` |
| Fondo alterno | `#2a2a2a` |
| Texto | `#c5b18d` |
| Primario | `#879a5f` |
| Secundario | `#8b6f4c` |
| Alerta | `#c95546` |

### 3.12 Matte Black ⬛
Tema negro absoluto, sin saturación. Traído de Omarchy.

| Variable | Color |
|---|---|
| Fondo | `#000000` |
| Fondo alterno | `#1a1a1a` |
| Texto | `#e5e5e5` |
| Primario | `#b3b3b3` |
| Secundario | `#808080` |
| Alerta | `#e53935` |

### 3.13 Osaka Jade 🟩
Tema verde jade, inspirado en Osaka. Traído de Omarchy.

| Variable | Color |
|---|---|
| Fondo | `#0f1a17` |
| Fondo alterno | `#1a2b26` |
| Texto | `#d4e7d7` |
| Primario | `#63cdb5` |
| Secundario | `#48a68f` |
| Alerta | `#e66b5c` |

### 3.14 Ristretto ☕
Tema marrón café, intenso y acogedor. Traído de Omarchy.

| Variable | Color |
|---|---|
| Fondo | `#20111b` |
| Fondo alterno | `#301e28` |
| Texto | `#e1d8d2` |
| Primario | `#b48b6d` |
| Secundario | `#bd6c6c` |
| Alerta | `#c94040` |

### 3.15 Hackerman 💚
Tema verde neón estilo matrix. Traído del repositorio oficial de Omarchy.

| Variable | Color |
|---|---|
| Fondo | `#0B0C16` |
| Texto | `#ddf7ff` |
| Primario | `#82FB9C` (verde neón) |
| Secundario | `#7cf8f7` (cian) |
| Alerta | `#50f872` (verde brillante) |
| Disabled | `#3E4058` |

### 3.16 Ethereal 🔮
Tema noche azulada con texto durazno. Traído del repositorio oficial de Omarchy.

| Variable | Color |
|---|---|
| Fondo | `#060B1E` |
| Texto | `#ffcead` |
| Primario | `#7d82d9` (azul) |
| Secundario | `#a3bfd1` (cian claro) |
| Alerta | `#ED5B5A` (rojo) |
| Disabled | `#3C486D` |

### 3.17 Lumon 🏢
Tema azul corporativo inspirado en la serie Severance. Traído de Omarchy.

| Variable | Color |
|---|---|
| Fondo | `#16242d` |
| Texto | `#d6e2ee` |
| Primario | `#8bc9eb` (celeste) |
| Secundario | `#b4e4f6` (cian muy claro) |
| Alerta | `#4d86b0` (azul medio) |
| Disabled | `#304860` |

### 3.18 Miasma 🌫️
Tema con tonos oliva, sepia y tierra. Traído de Omarchy.

| Variable | Color |
|---|---|
| Fondo | `#222222` |
| Texto | `#c2c2b0` |
| Primario | `#78824b` (verde oliva) |
| Secundario | `#c9a554` (dorado) |
| Alerta | `#685742` (marrón) |
| Disabled | `#000000` |

### 3.19 Vantablack ⬛
Tema negro puro con escala de grises. Traído de Omarchy.

| Variable | Color |
|---|---|
| Fondo | `#000000` |
| Texto | `#ffffff` |
| Primario | `#8d8d8d` (gris medio) |
| Secundario | `#b0b0b0` (gris claro) |
| Alerta | `#a4a4a4` (gris) |
| Disabled | `#404040` |

### 3.20 Retro 82 📼
Tema noche retro con acento naranja. Traído de Omarchy.

| Variable | Color |
|---|---|
| Fondo | `#05182e` |
| Texto | `#f6dcac` |
| Primario | `#faa968` (naranja) |
| Secundario | `#8cbfb8` (verde agua) |
| Alerta | `#f85525` (rojo-naranja) |
| Disabled | `#303442` |

### 3.21 White ⬜
Tema originalmente claro, adaptado a fondo oscuro. Traído de Omarchy.

| Variable | Color |
|---|---|
| Fondo | `#1a1a24` |
| Texto | `#c0c0c0` |
| Primario | `#6e6e6e` (gris) |
| Secundario | `#3e3e3e` (gris oscuro) |
| Alerta | `#2a2a2a` (casi negro) |
| Disabled | `#5c5c5c` |

### 3.22 Last Horizon 🌅
Tema con tonos tierra, beige y azul pálido. Traído de Omarchy.

| Variable | Color |
|---|---|
| Fondo | `#0c0b0c` |
| Texto | `#FAFCFB` |
| Primario | `#b59790` (terracota) |
| Secundario | `#a5a0b6` (lavanda) |
| Alerta | `#c38b7b` (salmón) |
| Disabled | `#584e51` |

### 3.23 Solitude ❄️
Tema gris frío minimalista. Traído de Omarchy.

| Variable | Color |
|---|---|
| Fondo | `#101315` |
| Texto | `#cacccc` |
| Primario | `#798186` (gris azulado) |
| Secundario | `#aeaeae` (gris) |
| Alerta | `#565d60` (gris oscuro) |
| Disabled | `#4b4e55` |

### 3.24 Dracula PowerSaver 🌙
Tema ultra-liviano para ahorrar batería. Basado en Dracula pero:
- **Sin Picom** (0 ahorro ~1-3W)
- **Sin Conky** (0 ahorro ~1-2W)
- **Sin blur ni sombras**
- Polybar con intervalos largos
- Fondo sólido oscuro

Para activarlo: `$mod+Shift+p` (no es un tema normal, es un modo toggle)

---

## 4. Atajos de Teclado

### 4.1 Generales

| Atajo | Acción |
|---|---|
| `$mod+Return` | Abrir terminal (Alacritty) |
| `$mod+d` | Lanzador Rofi (aplicaciones) |
| `$mod+Shift+q` | Cerrar ventana enfocada |
| `$mod+Escape` | Menú de sistema (lock, salir, suspender, reiniciar, apagar) |

### 4.2 Navegación de Ventanas

| Atajo | Acción |
|---|---|
| `$mod+j` / `←` | Enfocar izquierda |
| `$mod+k` / `↓` | Enfocar abajo |
| `$mod+l` / `↑` | Enfocar arriba |
| `$mod+;` / `→` | Enfocar derecha |
| `$mod+Shift+[j/k/l/;]` | Mover ventana |
| `$mod+Space` | Alternar entre tiling y floating |
| `$mod+f` | Pantalla completa |

### 4.3 Workspaces

| Atajo | Acción |
|---|---|
| `$mod+[1-0]` | Ir al workspace N |
| `$mod+Shift+[1-0]` | Mover ventana al workspace N |
| `$mod+s` | Layout stacking |
| `$mod+w` | Layout tabbed |
| `$mod+e` | Layout toggle split |

### 4.4 Temas y Apariencia

| Atajo | Acción |
|---|---|
| **`$mod+Shift+t`** | **Selector de temas (Rofi)** |
| **`$mod+Shift+p`** | **Toggle PowerSaver (ahorro de batería)** |
| **`$mod+Escape → l`** | **Bloquear pantalla (con imagen del tema)** |
| **`$mod+Escape → s`** | **Suspender + bloquear pantalla** |
| **`$mod+Shift+s`** | **⚙️ Centro de Control (configuración visual)** |
| **`$mod+Shift+?`** | **⌨️ Visor de atajos de teclado** |
| **No asignado** | **Animation Picker** (`animation-picker.sh menu`) |
| `$mod+Shift+n` | Toggle Conky (mostrar/ocultar info) |
| `$mod+Shift+c` | Recargar configuración de i3 |
| `$mod+Shift+r` | Reiniciar i3 (conserva sesión) |

### 4.5 Multimedia y Hardware

| Atajo | Acción |
|---|---|
| `XF86AudioRaiseVolume` | Subir volumen |
| `XF86AudioLowerVolume` | Bajar volumen |
| `XF86AudioMute` | Silenciar/activar audio |
| `XF86MonBrightnessUp` | Subir brillo |
| `XF86MonBrightnessDown` | Bajar brillo |
| `$mod+Ctrl+m` | Abrir Pavucontrol (control de audio) |
| `Print` | Captura de pantalla (Flameshot) |
| `XF86PowerOff` | Menú de apagado |

### 4.6 Redimensionar Ventanas

Modo resize (`$mod+r`):

| Tecla | Acción |
|---|---|
| `j` / `←` | Reducir ancho |
| `l` / `→` | Aumentar ancho |
| `k` / `↑` | Aumentar alto |
| `;` / `↓` | Reducir alto |
| `Enter` / `Esc` | Salir del modo resize |

---

## 5. Cambiar de Tema

### 5.1 Método gráfico (Recomendado)
Presiona **`$mod+Shift+t`** para abrir el selector Rofi con **grid de previsualización y paginación**. Cada tema muestra una miniatura de su fondo en un grid de 4 columnas (2 filas = 8 temas visibles a la vez). Usá **Page Up/Page Down o las flechas** para navegar entre páginas. El tema activo se marca con `▶`.

### 5.2 Método CLI
```bash
~/.config/themes/bin/theme-switch.sh <nombre-del-tema>
```
Ejemplo:
```bash
~/.config/themes/bin/theme-switch.sh dracula
~/.config/themes/bin/theme-switch.sh "catppuccin-mocha"
```

### 5.3 ¿Qué hace "theme-switch.sh"?
1. Actualiza el symlink `~/.config/themes/current/theme` al tema elegido
2. Ejecuta cada applyer en orden:
   - Fondo de pantalla → Lock screen → Polybar → Picom → Dunst → Rofi → Conky → i3 → Alacritty → Btop → Cava → OpenCode
3. Muestra una notificación de confirmación

### 5.4 ¿Pasa algo si falla un applyer?
No. El script continúa con los demás. Cada componente se aplica independientemente.

### 5.5 Componentes afectados al cambiar tema

Al ejecutar `theme-switch.sh`, los siguientes componentes se actualizan automáticamente:

| Componente | Archivo/Servicio | Qué cambia |
|---|---|---|
| **i3** | `~/.config/i3/config` | Colores de ventana (focused, unfocused, urgent), bordes, gaps |
| **Polybar** | `~/.config/polybar/` | Fondo, colores de módulos, fuentes, orden de módulos |
| **Picom** | `~/.config/picom/picom.conf` | Color de sombra, blur intensity, corner-radius |
| **Dunst** | `~/.config/dunst/dunstrc` | Fondo, texto, borde, posición, timeout, font |
| **Rofi** | `~/.config/rofi/` | Fondo, texto, selección, border-radius de menús |
| **Conky** | `~/.config/conky/` | Colores, posición, layout, transparencia |
| **Alacritty** | `~/.config/alacritty/alacritty.toml` | Fondo, primer plano, cursor, colores de selección |
| **Wallpaper** | `~/.config/themes/current/theme/backgrounds/` | Imagen de fondo (selección aleatoria del directorio) |
| **i3lock** | `~/.config/themes/current/theme/lock/` | Imagen de unlock, colores del candado |
| **Btop** | `~/.config/btop/btop.conf` | Esquema de colores del monitor del sistema |
| **Cava** | `~/.config/cava/config` | Colores del gradiente del visualizador de audio |
| **OpenCode** | `~/.config/opencode/` | Colores de la TUI del asistente AI |

**No cambian al cambiar de tema:**
- Keybindings de i3
- Layout de monitores (xrandr)
- Animaciones de picom (son preferencia personal, no del tema) — se configuran desde el Centro de Control
- Sonido y volumen
- Configuración de red
- Aplicaciones externas (VS Code, Brave, Eclipse, Neovim) — no tienen applyer implementado actualmente

> **Nota para contributors:** Si querés agregar soporte para una aplicación nueva, creá un applyer en `~/.config/themes/applyers/apply-<app>.sh` y agregalo al array `APPS` en `theme-switch.sh`.

---

## 6. Modo PowerSaver

El **Modo PowerSaver** desactiva componentes que consumen batería:
- **Picom**: ~1-3W de ahorro
- **Conky**: ~1-2W de ahorro
- Polybar mínima (sin animaciones, intervalos largos)
- Fondo de pantalla sólido oscuro

### Activar/Desactivar
Presiona **`$mod+Shift+p`** para alternar entre modo normal y ahorro.

### ¿Qué hace exactamente?
1. Mata picom y conky
2. Aplica la configuración del tema `dracula-powersaver`
3. Establece un fondo oscuro sólido
4. Al desactivar, restaura picom, conky y el tema anterior

### ¿Cómo sé si estoy en modo ahorro?
El script crea el archivo `/tmp/powersaver_active`. Puedes verificarlo con:
```bash
ls /tmp/powersaver_active && echo "🔋 Ahorro activo" || echo "☀ Modo normal"
```

---

## 7. Conky

Conky muestra información del sistema en la esquina superior derecha:
- Reloj grande (hora, fecha)
- Nombre del equipo, uptime, kernel
- CPU (porcentaje, frecuencia, temperatura)
- RAM (uso, gráfico de barras)
- NVMe (uso de disco)

### Activar/Desactivar
Presiona **`$mod+Shift+n`** para alternar.

### ¿Cómo funciona?
- El flag `~/.config/themes/conky-enabled` controla si Conky se inicia
- Si el archivo existe → Conky está activo
- Si no existe → Conky no se inicia
- Al cambiar de tema, Conky se reinicia automáticamente

### Quitar Conky permanentemente
```bash
rm ~/.config/themes/conky-enabled
```
Y eliminar la línea del i3 config:
```
bindsym $mod+Shift+n exec ~/.config/themes/bin/toggle-conky.sh
```

---

---

## 8. Centro de Control (⚙️ Settings)

Unifica toda la configuración del sistema en una interfaz visual con Rofi. Accede con **`$mod+Shift+s`**.

### 8.1 Menú Principal

```
⚙️  Centro de Control
  🔊  Sonido           → volumen, mute, salida de audio
  ☀️  Pantalla         → brillo, wallpaper, apagar pantalla
  🔔  Notificaciones   → No Molestar, limpiar, historial
  🎬  Animaciones      → menú jerárquico: Global, por app, Preestablecidos
  🎨  Apariencia       → tema, Conky, gaps
  ⚡  Energía          → PowerSaver, DPMS, tapa, autolock
  🔧  Sistema          → estado servicios, reiniciar, info
  📋  Utilidades       → capturas, WiFi, Bluetooth, color, clipboard
```

### 8.2 Arquitectura Modular

Cada categoría es un script independiente en `~/.config/themes/scripts/settings/`:

| Script | Función |
|---|---|
| `sound.sh` | Subir/bajar volumen, mute, pavucontrol, selector de salida |
| `display.sh` | Brillo +/-5%, selector de wallpaper con grid, DPMS off |
| `notify.sh` | Toggle No Molestar, limpiar notificaciones, historial |
| `animation.sh` | Menú jerárquico: Global (4 triggers), por app (Alacritty, Firefox, Rofi, Dunst), 5 presets (Clásico, GNOME, macOS, Win11, Snap) + Sin animación |
| `appearance.sh` | Abrir selector de temas, toggle Conky, ajustar gaps |
| `power.sh` | PowerSaver, timeout DPMS, autolock, comportamiento de tapa |
| `system.sh` | Estado/restart de picom, polybar, dunst, conky; información del sistema |
| `utils.sh` | Submenú de utilidades (capturas, WiFi, Bluetooth, color, clipboard) |

### 8.3 Utilidades Incluidas

| Utilidad | Script | Descripción |
|---|---|---|
| 📸 Capturas | `screenshot.sh` | Área, pantalla completa, ventana activa, retardo 5s |
| 🌐 WiFi | `wifi.sh` | Escanear redes, conectarse, mostrar conexión, apagar |
| 🔵 Bluetooth | `bluetooth.sh` | Encender/apagar, escanear, emparejar, conectar |
| 🎨 Color picker | `colorpicker.sh` | Picker de color, copia al portapapeles |
| 📋 Portapapeles | `clipboard.sh` | Historial de clipboard con búsqueda |
| ⌨️ Atajos | `keybindings.sh` | Visor/search de todos los bindings de i3 |

### 8.4 Menú de Animaciones (Jerárquico)

El menú `🎬 Animaciones` usa un sistema de 3 niveles:

**Nivel 1 — Menú principal**
```
🎬 Animaciones
  ▸ Global (todas las ventanas)
  ▸ Por aplicación
  ▸ Preestablecidos
```

**Nivel 2a — Global**: Configura los 4 triggers de picom v13 por separado:
| Trigger | Efecto visual |
|---|---|
| `Abrir ventana` | Animación al abrir (open) |
| `Cerrar ventana` | Animación al cerrar (close) |
| `Show — al cambiar workspace` | Animación al mostrar (show) |
| `Hide — al salir workspace` | Animación al ocultar (hide) |

Cada trigger permite elegir: **preset** → si aplica, **dirección** → **duración**.

**Nivel 2b — Por aplicación**: Idem pero con `--target Alacritty|Firefox|Rofi|Dunst` para animaciones específicas por ventana (open/close).

**Nivel 2c — Preestablecidos**: 5 perfiles completos que configuran los 4 triggers globales de una vez:
| Perfil | open | close | show | hide |
|---|---|---|---|---|
| ◉ Clásico | Aparecer (0.92) | Desaparecer (1.05) | Volar ↑ | Volar ↓ |
| ○ GNOME | Volar ↑ | Volar ↓ | Deslizar ↑ | Deslizar ↓ |
| ○ macOS | Aparecer (0.90) | Volar ← | Volar ↑ | Volar ↓ |
| ○ Windows 11 | Volar ↑ | Volar → | Aparecer (0.95) | Desaparecer (1.05) |
| ○ Snap | Aparecer (0.95) — 0.10s | Desaparecer (1.02) — 0.08s | Aparecer 0.08s | Desaparecer 0.06s |

**Sin animación**: En cualquier trigger, seleccionar `Sin animación` escribe `duration=0.001 scale=1.0`, haciendo la transición instantánea (invisible).

### 8.5 Atajos

| Atajo | Acción |
|---|---|
| `$mod+Shift+s` | Abrir centro de control |
| `$mod+Shift+?` | Visor de atajos de teclado |

### 8.5 Uso Independiente

Cada script settings puede ejecutarse directamente desde la terminal o asignarse a un atajo propio:

```bash
~/.config/themes/scripts/settings/wifi.sh      # Solo WiFi
~/.config/themes/scripts/settings/screenshot.sh # Solo capturas
~/.config/themes/scripts/settings/sound.sh      # Solo sonido
```

---

## 9. Agregar un Tema Nuevo

### Paso 1: Crear la carpeta del tema
```bash
mkdir -p ~/.config/themes/themes/mi-tema/{polybar,i3,picom,dunst,rofi,conky,alacritty,backgrounds}
```

### Paso 2: Definir los colores
Elige una paleta de 10 colores:

| Variable | Descripción | Ejemplo (Dracula) |
|---|---|---|
| `bg` | Fondo general | `#282a36` |
| `bg-alt` | Fondo alterno | `#3c3e4a` |
| `fg` | Texto/iconos | `#f8f8f2` |
| `primary` | Color principal (acento) | `#bd93f9` |
| `secondary` | Secundario | `#8be9fd` |
| `alert` | Urgente/peligro | `#ff5555` |
| `disabled` | Inactivo | `#6272a4` |
| `green` | Éxito/verde | `#50fa7b` |
| `pink` | Rosa/variante | `#ff79c6` |
| `yellow` | Amarillo/variante | `#f1fa8c` |

### Paso 3: Generar los archivos
La forma más fácil es copiar un tema existente y cambiar los colores:

```bash
# Copiar Dracula como base
cp -r ~/.config/themes/themes/dracula/* ~/.config/themes/themes/mi-tema/
```

Luego editar cada archivo reemplazando los colores:

- `polybar/config.ini` - Reemplazar colores en sección `[colors]` y en la configuración
- `i3/colors.conf` - Reemplazar los `set $color #xxxxxx`
- `picom/picom.conf` - No requiere cambios de color (usa valores genéricos)
- `dunst/dunstrc` - Reemplazar colores
- `rofi/config.rasi` - Reemplazar colores en el bloque `* { ... }`
- `conky/conky.conf` - Reemplazar los colores y el fondo
- `alacritty/theme.toml` - Reemplazar colores
- `backgrounds/` - Agregar wallpaper.jpg o wallpaper.png

### Paso 4: Probar el tema
```bash
~/.config/themes/bin/theme-switch.sh mi-tema
```

### Paso 5: (Opcional) Agregar al selector Rofi
El script `rofi-theme-selector.sh` lista automáticamente todas las carpetas en `~/.config/themes/themes/`. Solo con crear la carpeta, el tema aparece.

### Plantilla rápida de colores para nuevo tema
```
bg       = #______  (fondo, más oscuro)
bg-alt   = #______  (ligeramente más claro que bg)
fg       = #______  (texto, alto contraste contra bg)
primary  = #______  (acento principal)
secondary= #______  (segundo acento)
alert    = #______  (rojo o naranja)
disabled = #______  (gris)
green    = #______  (verde)
pink     = #______  (rosa/magenta)
yellow   = #______  (amarillo)

# Colores de burbujas (Polybar) - entre bg y bg-alt
bubble-ws     = #______  (burbuja de workspaces)
bubble-center = #______  (burbuja de fecha)
bubble-sys    = #______  (burbuja de sistema)
```

---

## 10. Personalización por Componente

### 10.1 Polybar (Barra de Estado)
### 10.2 i3 (Gestor de Ventanas)
### 10.3 Picom (Compositor + Animaciones v13)
### 10.4 Dunst (Notificaciones mejoradas)
### 10.5 Rofi (Lanzador)
### 10.6 Conky (Info del Sistema)
### 10.7 Alacritty (Terminal)
### 10.8 Wallpaper (Fondo de Pantalla)
### 10.9 Btop (Monitor del Sistema)
### 10.10 Cava (Visualizador de Audio)
### 10.11 Pantalla de Bloqueo (Lock Screen)
### 10.12 OpenCode (Editor/Terminal AI)
### 10.13 Temas para Navegador (Brave/Chrome) y Editores

### 10.14 GTK / Nemo (Archivos)

El sistema aplica el tema GTK `Orchis-Dark` al cambiar de tema de i3, y sobreescribe los colores de acento de nemo (y otras apps GTK3) mediante `~/.config/gtk-3.0/gtk.css`.

**Qué cambia en nemo al seleccionar un tema de i3:**
- Color de la **sidebar** (panel izquierdo)
- Color de **selección** de archivos y carpetas
- Color de la **toolbar** (barra de herramientas)
- Barras de **progreso** y **scroll**
- Fondos de vista en **icono** y **detalle**

**Archivos involucrados:**
```
tema/gtk/
├── theme.cfg    → nombre del tema GTK base (Orchis-Dark) e iconos (ePapirus-Dark)
└── gtk.css      → sobreescrituras de color para coincidir con la paleta del tema
```

**Flujo al cambiar de tema:**
1. `theme-switch.sh` ejecuta `apply-gtk.sh`
2. `apply-gtk.sh` lee `theme.cfg` y setea el tema e iconos via gsettings
3. `apply-gtk.sh` copia `gtk.css` a `~/.config/gtk-3.0/gtk.css`
4. Al abrir nemo, éste lee primero `gtk.css` del usuario, luego el tema base

**Colores de acento por tema (ejemplos):**

| Tema | Color de acento |
|------|----------------|
| Nord | `#81a1c1` (azul) |
| Dracula | `#bd93f9` (púrpura) |
| Gruvbox | `#d79921` (dorado) |
| Everforest | `#7fbbb3` (verde agua) |
| Tokyo Night | `#7aa2f7` (azul) |
| Catppuccin Mocha | `#89b4fa` (azul) |
| Rose Pine | `#56949f` (teal) |

**Requisitos:**
- Tema GTK `Orchis-Dark` instalado (incluido en Linux Mint, disponible en gnome-look.org o desde el gestor de paquetes)
- nemo debe **reiniciarse** después de cambiar de tema para ver los cambios (`pkill nemo && nemo &`)

**Nota sobre `/etc/gtk-3.0/settings.ini`:** Si el sistema tiene un tema forzado desde esta ruta, puede anular la configuración de usuario. Revisalo con:
```bash
grep gtk-theme-name /etc/gtk-3.0/settings.ini
```
Si muestra un tema diferente a `Orchis-Dark`, ejecutá:
```bash
sudo sed -i 's/gtk-theme-name.*/gtk-theme-name=Orchis-Dark/' /etc/gtk-3.0/settings.ini
```

---

Algunos temas de Omarchy incluyen archivos adicionales:

| Archivo | Propósito | Temas que lo tienen |
|---|---|---|
| `chromium.theme` | Color de fondo para Brave/Chrome (RGB) | lumon, retro-82, last-horizon |
| `vscode.json` | Referencia a extensión de VSCode | Todos los Omarchy |
| `vscode.json` | Nombre de tema + ID de extensión en marketplace | 8 temas Omarchy |

Para aplicar el tema en VSCode:
1. Abrir VSCode
2. Ir a Extensiones (Ctrl+Shift+X)
3. Buscar el nombre del tema indicado en `vscode.json`
4. Instalar y seleccionar

Para Brave/Chrome: el color del `chromium.theme` se usa como acento en la barra de direcciones al usar flags de Chrome.

---

## 11. Fuentes

### Fuentes instaladas
| Fuente | Uso | Tamaño |
|---|---|---|
| JetBrainsMono Nerd Font Mono | Polybar (texto principal, font-0) | 14 |
| JetBrainsMono Nerd Font Mono | Polybar (barra volumen, font-1) | 12 |
| JetBrainsMono Nerd Font Mono | Polybar (iconos grandes: volumen/batería/encendido, font-2) | 24 |
| JetBrainsMono Nerd Font Mono | Conky (reloj gigante) | 46 |
| JetBrainsMono Nerd Font Mono | Conky (fecha) | 16 |
| JetBrainsMono Nerd Font Mono | Conky (cuerpo) | 14 |
| JetBrainsMono Nerd Font Mono | Dunst (notificaciones) | 14 |
| JetBrainsMono Nerd Font Mono | Rofi (lanzador) | 14 |
| JetBrainsMono Nerd Font Mono | i3 (títulos de ventanas) | 14 |
| IosevkaTerm Nerd Font Mono | Alacritty (terminal) | 16 |

### Dónde se almacenan
- Fuentes del sistema: `/usr/share/fonts/`
- Fuentes de usuario: `~/.local/share/fonts/`
- Nerd Fonts instaladas manualmente: `~/.local/share/fonts/`

### Instalar una fuente Nerd Font
```bash
# Descargar de GitHub
curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FontName.tar.xz" -o /tmp/font.tar.xz
# Extraer
tar -xf /tmp/font.tar.xz -C ~/.local/share/fonts/
# Actualizar caché
fc-cache -fv ~/.local/share/fonts/
# Verificar
fc-list | grep -i "FontName.*Nerd"
```

### Cambiar el tamaño de fuente en Polybar
Edita `font-0`, `font-1` y `font-2` en la sección `[bar/top]`:
```ini
font-0 = "JetBrainsMono Nerd Font Mono:size=14;3"   # Texto normal
font-1 = "JetBrainsMono Nerd Font Mono:size=12;4"   # Barras de volumen
font-2 = "JetBrainsMono Nerd Font Mono:size=24;3"   # Iconos grandes (  )
```

El número después del `;` es el "font offset" usado para módulos específicos.

`font-2` se usa con las etiquetas `%{T2}` y `%{T-}` para agrandar solo los iconos de:
- **Volumen** (`%{T2}%{T-}` en `label-volume`)
- **Batería** (`%{T2}${ICON}%{T-}` en `batt_status.sh`)
- **Encendido** (`%{T2}%{T-}` en `format` de powermenu)

---

## 12. Solución de Problemas

### 11.1 Los iconos de Nerd Font no se ven
```
Verificar que la fuente está instalada:
fc-list | grep -i "nerd"

Si no aparece, instalar la fuente:
curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz" -o /tmp/jetbrains.tar.xz
tar -xf /tmp/jetbrains.tar.xz -C ~/.local/share/fonts/
fc-cache -fv ~/.local/share/fonts/
```

### 11.2 Polybar no aparece
```bash
# Ver errores
polybar -c ~/.config/polybar/config.ini top

# Forzar reinicio
~/.config/polybar/launch.sh

# Ver logs del sistema
journalctl -xe | grep polybar
```

### 11.3 Picom no inicia
```bash
# Verificar modo powersaver
ls /tmp/powersaver_active && echo "En powersaver, no inicia" || echo "Modo normal"

# Probar inicio manual
picom --config ~/.config/picom/picom.conf --backend glx

# Si falla, probar con xrender
picom --config ~/.config/picom/picom.conf --backend xrender
```

### 11.4 Conky no se ve
```bash
# Verificar que está habilitado
ls ~/.config/themes/conky-enabled

# Matar y reiniciar
killall conky
conky -c ~/.config/conky/conky.conf
```

### 11.5 El wallpaper no cambia
```bash
# Verificar que el archivo existe
ls ~/.config/themes/themes/<tema>/backgrounds/wallpaper.jpg

# Aplicar manualmente
nitrogen --set-zoom-fill ~/.config/themes/themes/<tema>/backgrounds/wallpaper.jpg --save

# Si Nitrogen no funciona, probar feh
feh --bg-fill ~/.config/themes/themes/<tema>/backgrounds/wallpaper.jpg
```

### 11.6 Rofi no abre o se ve mal
```bash
# Verificar sintaxis del tema
rofi -theme ~/.config/rofi/config.rasi -dump-config

# Probar modo seguro
rofi -dmenu
```

### 11.7 Las animaciones de Picom no funcionan
```bash
# Verificar versión (debe ser v12+)
picom --version

# Verificar que animations=true en el config
grep "animations" ~/.config/picom/picom.conf

# Probar sin animaciones
sed -i 's/animations = true/animations = false/' ~/.config/picom/picom.conf
```

### 11.8 La batería muestra información incorrecta
```bash
# Verificar datos crudos
cat /sys/class/power_supply/BAT0/status
cat /sys/class/power_supply/BAT0/capacity

# Probar el script manualmente
~/.config/themes/scripts/batt_status.sh
```

### 11.9 Las burbujas de Polybar no se ven correctamente
Las burbujas usan los caracteres Unicode `` y `` (Powerline). Si se ven como rectángulos, la fuente Nerd Font no está instalada correctamente. Ver [Sección 11.1](#111-los-iconos-de-nerd-font-no-se-ven).

### 11.10 Cava no se ve en la Polybar
```bash
# Verificar que cava está instalado
which cava

# Probar el script manualmente
~/.config/themes/scripts/cava-polybar.sh

# Verificar permisos de audio
groups | grep audio
sudo usermod -aG audio $USER  # luego cerrar sesión y volver
```

### 11.11 Btop no muestra el tema correcto
```bash
# Verificar que el tema se copió
ls ~/.config/btop/themes/

# Verificar que btop.conf apunta al tema correcto
grep color_theme ~/.config/btop/btop.conf

# Aplicar manualmente
~/.config/themes/applyers/apply-btop.sh ~/.config/themes/themes/<tema>
```

### 11.12 Temperatura del CPU muy alta
Ver [Apéndice C: Gestión de Temperatura](#apéndice-c-gestión-de-temperatura).

---

## 13. Respaldos

### Backup inicial
Se creó un backup completo antes de implementar el sistema de temas en:
```
~/dotfiles-backup-20260519_233940/
```
Contiene: conky, picom (configuraciones originales).

### Restaurar configuración anterior
```bash
# Restaurar conky
cp ~/dotfiles-backup-20260519_233940/conky/conky.conf ~/.config/conky/conky.conf

# Restaurar picom
cp ~/dotfiles-backup-20260519_233940/picom/picom.conf ~/.config/picom/picom.conf
```

### Respaldar el sistema de temas completo
```bash
tar -czf ~/mis-temas-$(date +%Y%m%d_%H%M%S).tar.gz -C ~/.config themes/
```

### Restaurar el sistema de temas desde backup
```bash
tar -xzf ~/mis-temas-*.tar.gz -C ~/.config/
```

---

## Apéndice A: Comandos Rápidos

| Comando | Para qué sirve |
|---|---|---|
| `$mod+Shift+t` | Abrir selector de temas |
| `$mod+Shift+p` | Alternar modo ahorro |
| `$mod+Shift+n` | Alternar Conky |
| `$mod+Escape` | Menú de sistema (bloquear, suspender, reiniciar, apagar) |
| `$mod+Shift+Escape` | Power Menu Rofi completo |
| `$mod+Shift+d` | Alternar Do Not Disturb |
| `$mod+Shift+.` | Mostrar hora actual |
| `$mod+Shift+b` | Mostrar estado de batería |
| `$mod+Shift+w` | Mostrar clima |
| `theme-switch.sh dracula` | Cambiar a Dracula |
| `toggle-powersaver.sh` | Alternar ahorro (CLI) |
| `toggle-conky.sh` | Alternar Conky (CLI) |
| `animation-picker.sh menu` | Elegir animación de cierre |
| `animation-picker.sh up` | Cierre fly-out arriba |
| `lock.sh` | Bloquear pantalla |
| `i3-msg reload` | Recargar i3 sin cerrar ventanas |
| `i3-msg restart` | Reiniciar i3 (conserva sesión) |
| `polybar-msg cmd restart` | Reiniciar Polybar |
| `killall picom && picom &` | Reiniciar Picom |
| `killall dunst && dunst &` | Reiniciar Dunst |
| `kill -USR2 $(pgrep -x cava)` | Recargar colores de Cava en vivo |

## Apéndice B: Referencia de Rutas

```
~/.config/themes/                         → Raíz del sistema de temas
~/.config/themes/bin/theme-switch.sh      → Script principal para cambiar tema
~/.config/themes/bin/rofi-theme-selector.sh → Selector visual
~/.config/themes/bin/animation-picker.sh  → Elegir animación de cierre
~/.config/themes/bin/lock.sh              → Bloquear pantalla
~/.config/themes/bin/toggle-conky.sh      → Toggle Conky
~/.config/themes/scripts/toggle-powersaver.sh → Toggle modo ahorro
~/.config/themes/scripts/batt_status.sh   → Estado de batería
~/.config/themes/scripts/cava-polybar.sh  → Visualizador de audio
~/.config/themes/applyers/apply-lockscreen.sh → Aplica fondo de bloqueo
~/.config/themes/applyers/apply-opencode.sh   → Aplica tema de OpenCode
~/.config/themes/current/theme            → Enlace al tema activo
~/.config/themes/current/lock/lock.png    → Imagen de bloqueo activa
~/.config/themes/conky-enabled            → Flag de Conky
~/.config/themes/themes/<tema>/           → Tema individual
~/.config/themes/themes/<tema>/unlock.png → Fondo de bloqueo del tema
~/.config/themes/themes/<tema>/chromium.theme → Tema para Brave/Chrome
~/.config/themes/themes/<tema>/vscode.json → Referencia a tema VSCode
~/.config/opencode/themes/<tema>.json     → Tema de OpenCode
~/.config/polybar/config.ini              → Polybar activo
~/.config/i3/colors.conf                  → Colores i3 activos
~/.config/i3/config                       → Configuración i3 principal
~/.config/picom/picom.conf                → Picom activo
~/.config/dunst/dunstrc                   → Dunst activo
~/.config/rofi/config.rasi                → Rofi activo
~/.config/conky/conky.conf                → Conky activo
~/.config/alacritty/theme.toml            → Alacritty activo (colores)
~/.config/alacritty/alacritty.toml        → Alacritty (fuente, tamaño)
~/.config/polybar/launch.sh               → Script de inicio de Polybar
~/.config/rofi/powermenu.sh               → Menú de apagado
~/.config/rofi/power_profiles.sh          → Perfiles de energía
~/.config/i3/volume.sh                    → Control de volumen
~/.config/i3/brightness.sh                → Control de brillo
/tmp/powersaver_active                    → Flag de modo ahorro (temporal)
```

---

## Apéndice C: Gestión de Temperatura

Si tu CPU (especialmente en laptops como ThinkPad E480) alcanza 80°C+ con frecuencia:

### Causas comunes
| Causa | Solución |
|---|---|
| **Procesos intensivos** (opencode, compilaciones, Spotify) | Limitar con `cpulimit` o nice |
| **Polvo en el disipador** | Limpieza física con aire comprimido |
| **Pasta térmica seca** | Reaplicar pasta térmica (baja 5-15°C) |
| **Gobernador de CPU** | Ya está en `powersave` |
| **Frecuencia muy alta** | Limitar con `cpupower` |
| **Sin thermald** | Instalar `thermald` |

### Soluciones inmediatas

#### 1. thermald (recomendado)
```bash
sudo apt install thermald      # Debian/Ubuntu/Mint
sudo pacman -S thermald        # Arch
sudo systemctl enable --now thermald
```

#### 2. Limitar frecuencia máxima
```bash
sudo cpupower frequency-set -u 2500MHz
```
Esto reduce temperatura ~10°C con pérdida mínima de rendimiento.

#### 3. Undervolt (avanzado)
Con `intel-undervolt` en CPUs Intel 8va generación (E480):
```bash
# Instalar
git clone https://github.com/kitsunyan/intel-undervolt
cd intel-undervolt && ./configure && make && sudo make install
# Configurar undervolt (ej: -100mV)
sudo nano /etc/intel-undervolt.conf
sudo systemctl enable --now intel-undervolt
```

#### 4. Monitorizar temperatura en Polybar
El módulo `[module/temperature]` cambia a **fondo rojo** cuando el CPU supera los 70°C:
```
┌──────────────┐
│   85°C     │  ← Fondo normal (bubble-sys)
└──────────────┘
┌──────────────┐
│   85°C     │  ← Fondo rojo (alert) si >70°C
└──────────────┘
```

### Referencia de temperaturas
| Rango | Estado | Acción |
|---|---|---|
| < 60°C | Excelente | Normal |
| 60-75°C | Bueno | Normal |
| 75-85°C | Aceptable | Monitorear |
| 85-95°C | Caliente | Revisar ventilación |
| > 95°C | Crítico | Detener procesos pesados |

---

## 14. Historial de Cambios

### v2.5 — Dunst rediseñado + DND + Notificaciones del sistema + Power Menu

- **Dunst mejorado**: iconos redondeados (`icon_corner_radius`), lookup recursivo de iconos, orden por urgencia, `fullscreen = pushback`, `indicate_hidden`, progreso coloreado por urgencia, shortcuts movidos a `[global]`
- **Margen entre notis**: `gap_size = 6` agrega separación entre notificaciones individuales (cada una con su propio borde)
- **Marco usa primary**: `frame_color` ahora usa el color de acento del tema (antes secondary/green)
- **Reglas por app**: Firefox, Chromium, Brave, Chrome, Telegram, Discord, captura de pantalla, volumen y brillo con timeouts y urgencias específicos
- **Sonido crítico**: las notificaciones de urgencia critical reproducen `alarm-clock-elapsed.oga` via `paplay`
- **Do Not Disturb**: `toggle-dnd.sh` + indicador en polybar (``/``). Atajo: `$mod+Shift+d`
- **Notificaciones del sistema**: `notify-time.sh`, `notify-battery.sh`, `notify-weather.sh` con iconos Nerd Font. Atajos: `$mod+.` (hora), `$mod+Shift+b` (batería), `$mod+Shift+w` (clima)
- **Power Menu Rofi**: `power-menu.sh` — menú completo con bloquear, suspender, apagar pantalla, hibernar, reiniciar, apagar, y cambiar comportamiento de la tapa (via `pkexec`). Atajo: `$mod+Shift+Escape`
- **Polybar**: módulo `dnd` agregado a los 24 temas, powermenu apunta al nuevo script
- **Revolución del bloqueo/suspensión**:
  - `lock.sh` ahora lee colores del tema activo (ring=primary, inside=background, time=foreground, etc.)
  - Eliminado `dm-tool lock` (LightDM/Cinnamon) — ahora solo usa `i3lock-color`
  - Eliminado xss-lock duplicado que causaba acumulación de pantallas de login
  - `xss-lock` con `lock.sh` para bloquear antes de suspender (tapa, suspensión manual)
  - `xautolock` bloquea automáticamente tras 8 min de inactividad
  - `xset dpms 300 360 420`: pantalla apagada a los 5 min
- **Fin del problema de inicios de sesión acumulados**: al usar solo i3lock-color, ya no se crean sesiones de lightdm que se apilan

### v2.4 — Selector Rofi con grid + paginación + previews oficiales

- **Grid 4×2 con paginación**: 8 temas visibles a la vez (4 columnas × 2 filas), con imágenes más grandes (5em). Navegación con flechas o Page Up/Page Down
- **Preview oficiales**: 21 temas ahora usan `preview.png` oficial del repo basecamp/omarchy; 3 temas custom tienen preview generado con su paleta de colores
- **Caché de thumbnails**: las miniaturas 320×180 se generan una sola vez en `~/.cache/theme-thumbs/` y se reusan
- **Tema activo**: marcado con `▶` al inicio del nombre

### v2.3 — 24 temas + Animaciones configurables + Lock Screen

- **24 temas** (antes 15): agregados Hackerman, Ethereal, Lumon, Miasma, Vantablack, Retro 82, White, Last Horizon, Solitude — todos del repositorio oficial de Omarchy
- **Wallpapers oficiales**: fondos de pantalla, previews y unlock images copiados del repo basecamp/omarchy
- **Animation Picker**: `animation-picker.sh` — script para elegir animación de cierre vía Rofi o CLI (disappear, fly-out up/down/left/right, slide-out, none)
- **Lock Screen personalizada**: `apply-lockscreen.sh` + `lock.sh` — cada tema tiene su propio fondo de bloqueo (`unlock.png`) usando `i3lock-color`
- **Dunst rediseñado**: notificaciones modernas con iconos, markup, word wrap, barras de progreso redondeadas, historial, atajos de teclado, y colores por nivel de urgencia
- **OpenCode integrado**: 24 temas personalizados en `~/.config/opencode/themes/` aplicados automáticamente al cambiar de tema
- **Temas para VSCode/Chrome**: archivos `vscode.json` y `chromium.theme` copiados para los temas Omarchy que los incluyen
- **Applyers actualizados**: `theme-switch.sh` ahora ejecuta apply-lockscreen.sh y apply-opencode.sh
- **Atajo de bloqueo**: `$mod+Escape → l` bloquea con imagen del tema; `$mod+Escape → s` suspende + bloquea

### v2.2 — Picom v13 + animaciones reales
- **15 temas**: 7 originales + 8 Omarchy (everforest, kanagawa, rose-pine, catppuccin-latte, flexoki-light, matte-black, osaka-jade, ristretto)
- **Btop**: Temas por tema + apply-btop.sh
- **Cava**: Gradientes de 8 colores por tema + apply-cava.sh
- **Omarchy colorimetry**: Acentos azul (color4) como primary, rojo (color1) como alert
- **Polybar burbujas**: 3 segmentos con colores tintados oscuros (bubble-ws, bubble-center, bubble-sys)
- **Rofi**: Variables `lightbg`/`lightfg` para evitar fondo amarillento por defecto
- **Nord**: Foreground corregido a `#d8dee9` (Omarchy spec)

### v2.1 — Correcciones y animaciones v1
- **Temperatura**: Fondo rojo `format-warn-background` cuando CPU >70°C
- **Burbuja derecha**: Eliminado `format-margin` del tray para que el fondo bubble-sys sea contiguo
- **Iconos grandes**: font-2 a tamaño 24 para iconos de volumen, batería y encendido
- **Tray spacing**: Ajustado a 4 entre iconos del sistema
- **Apply-wallpaper.sh**: Ahora detecta cualquier imagen en backgrounds/ (no solo wallpaper.jpg)
- **Theme-switch.sh**: Incluye apply-btop.sh y apply-cava.sh
- **Picom animaciones v1 (v10.2)**: stiffness 280, dampening 18, mass 0.25 — **no funcionales** (v10.2 ignora animaciones)

### v2.2 — Picom v13 + animaciones reales
- **Picom actualizado a v13** (compilado desde fuente yshui/picom v13, Feb 2026)
- **Sistema de animaciones por presets**: `appear`/`disappear` con escala, `fly-in`/`fly-out` con dirección, `geometry-change`
- **Triggers**: `open`, `close`, `show`, `hide`, `geometry`
- **Animaciones por ventana** via `rules:`:
  - `Alacritty`: apertura/cierre rápido (0.15s/0.12s)
  - `Firefox`: slide-in desde abajo (0.25s)
  - `Rofi`: snappy appear/disappear (0.12s/0.08s)
  - `Dunst`: slide-in/slide-out desde la derecha (0.2s/0.15s)
- **Migración completa a `rules:`**: `inactive-opacity`, `shadow-exclude`, `rounded-corners-exclude` movidos a reglas v13
- **Configs limpios**: sin duplicados, sin opciones deprecated (`glx-no-stencil`, `@:c` type specifier)
- **Workspace switch**: `fly-in`/`fly-out` en show/hide — las ventanas se deslizan al cambiar de workspace
- **Geometry smooth**: posición y tamaño con `geometry-change` para layouts que se reorganizan
- **PowerSaver**: picom mínimo — `xrender`, sin vsync, sin animaciones, sin blur, sin shadows, sin fading
- **Floating windows**: actualizaciones (mintupdate), calculadora, bluetooth (blueman-manager), pavucontrol

---

## Apéndice D: Referencia de Configuración

Dónde está configurado cada componente del sistema.

### 🎨 Temas

| Qué | Dónde |
|---|---|
| 24 temas individuales (polybar, rofi, dunst, etc.) | `~/.config/themes/themes/<nombre>/` |
| Tema activo (symlink) | `~/.config/themes/themes/<nombre>/` apuntado por `~/.config/themes/current/theme` |
| Seleccionar tema via Rofi | `$mod+Shift+t` → `~/.config/themes/bin/rofi-theme-selector.sh` |
| Cambiar tema via CLI | `~/.config/themes/bin/theme-switch.sh <nombre>` |
| Verificar integridad | `~/.config/themes/bin/verify-themes.sh` |
| Colores del tema | `~/.config/themes/themes/<nombre>/polybar/colors.ini` |
| Minuaturas para grid selector | Autogeneradas en `~/.cache/theme-thumbs/` |

### 🖱️ Atajos de Teclado (i3)

| Atajo | Acción | Configurado en |
|---|---|---|
| `$mod+Return` | Terminal (Alacritty) | `~/.config/i3/config:56` |
| `$mod+d` | Lanzador Rofi | `~/.config/i3/config:71` |
| `$mod+Shift+t` | Selector de temas (grid) | `~/.config/i3/config:59` |
| `$mod+Shift+n` | Alternar Conky | `~/.config/i3/config:62` |
| `$mod+Shift+p` | Alternar PowerSaver | `~/.config/i3/config:65` |
| `$mod+Shift+q` | Cerrar ventana | `~/.config/i3/config:68` |
| `$mod+Shift+d` | Alternar No Molestar | `~/.config/i3/config:314` |
| `$mod+Shift+.` | Notificación de hora | `~/.config/i3/config:317` |
| `$mod+Shift+b` | Notificación de batería | `~/.config/i3/config:318` |
| `$mod+Shift+w` | Notificación de clima | `~/.config/i3/config:319` |
| `$mod+Escape` → `l` | Bloquear pantalla | `~/.config/i3/config:292` |
| `$mod+Escape` → `s` | Suspender + bloquear | `~/.config/i3/config:294` |
| `$mod+Escape` → `e` | Salir de i3 | `~/.config/i3/config:293` |
| `$mod+Escape` → `r` | Reiniciar | `~/.config/i3/config:295` |
| `$mod+Escape` → `S` | Apagar | `~/.config/i3/config:297` |
| `$mod+Shift+Escape` | Power Menu Rofi completo | `~/.config/i3/config:308` |

### 🔒 Bloqueo y Suspensión

| Qué | Dónde | Detalle |
|---|---|---|
| Script de bloqueo | `~/.config/themes/bin/lock.sh` | i3lock-color con colores del tema activo |
| Bloquear antes de suspender | `~/.config/i3/config:34` | `xss-lock --transfer-sleep-lock -- lock.sh` |
| Bloqueo automático (8 min) | `~/.config/i3/config:350` | `xautolock -time 8 -locker "lock.sh" -detectsleep` |
| DPMS (apagar pantalla) | `~/.config/i3/config:348` | `xset dpms 300 360 420` (5/6/7 min) |
| Comportamiento de tapa | `/etc/systemd/logind.conf` | `HandleLidSwitch=suspend` |
| Menú de tapa vía Rofi | `~/.config/themes/scripts/power-menu.sh` | Cambia logind via pkexec |
| Imagen de bloqueo por tema | `~/.config/themes/themes/<nombre>/unlock.png` | Leída directamente por lock.sh |

### 🎬 Animaciones (Picom v13)

| Qué | Dónde | Detalle |
|---|---|---|
| Config picom del tema activo | `~/.config/themes/current/theme/picom/picom.conf` | Animaciones vía presets + rules |
| Elegir animación de cierre | `$mod+...` → `~/.config/themes/bin/animation-picker.sh` | Rofi o CLI |
| Presets disponibles | En el script | `disappear`, `fly-out` (up/down/left/right), `slide-out`, `none` |
| Trigger `open` | `picom.conf` | `appear` (zoom 0.92, 0.25s) |
| Trigger `close` | `picom.conf` | Configurable via animation-picker (default: fly-out down 0.25s) |
| Trigger `show` | `picom.conf` | `fly-in` up (0.2s) |
| Trigger `hide` | `picom.conf` | `fly-out` down (0.15s) |
| Trigger `geometry` | `picom.conf` | `geometry-change` (0.25s) |
| Reglas por ventana | `picom.conf` → `rules:` | Alacritty rápido, Firefox slide, Rofi snappy, Dunst slide-right |
| PowerSaver picom | `dracula-powersaver/picom/picom.conf` | xrender, sin animaciones, sin blur |

### 📬 Notificaciones (Dunst)

| Qué | Dónde | Detalle |
|---|---|---|
| Config activa | `~/.config/dunst/dunstrc` | Copiada desde el tema actual |
| Template base | `~/.config/themes/themes/tokyo-night/dunst/dunstrc` | Usado por regenerate-dunst.py |
| Regenerar para 24 temas | `~/.config/themes/bin/regenerate-dunst.py` | Python, reemplaza colores |
| Applyer | `~/.config/themes/applyers/apply-dunst.sh` | Copia + restart dunst |
| Atajos de teclado en notis | `~/.config/dunst/dunstrc` → `[global]` | `Ctrl+Space` cerrar, `Ctrl+Shift+Space` cerrar todo, `Ctrl+.` historial |
| Reglas por app | `~/.config/dunst/dunstrc` → secciones por app | Firefox (critical 10s), Telegram (critical 8s), volumen (low 2s), etc. |
| Sonido crítico | `[urgency_critical]` → `script = paplay alarm-clock-elapsed.oga` | Solo alertas critical |

### 🔇 No Molestar (DND)

| Qué | Dónde | Detalle |
|---|---|---|
| Script toggle | `~/.config/themes/scripts/toggle-dnd.sh` | Usa `dunstctl set-paused` |
| Indicador polybar | `~/.config/themes/scripts/dnd-indicator.sh` | Muestra / con colores |
| Módulo polybar | `~/.config/themes/themes/*/polybar/config.ini` → `[module/dnd]` | Agregado a los 24 temas |
| Atajo | `$mod+Shift+d` | `~/.config/i3/config:314` |

### 📊 Polybar

| Qué | Dónde | Detalle |
|---|---|---|
| Config del tema activo | `~/.config/themes/current/theme/polybar/config.ini` | Copiado a `~/.config/polybar/config.ini` |
| Módulos izquierda | `modules-left` | Burbujas de workspaces |
| Módulos centro | `modules-center` | Fecha/hora |
| Módulos derecha | `modules-right` | DND, CPU, temp, mem, cava, audio, batt, tray, power |
| Burbujas con colores tintados | `bubble-ws`, `bubble-center`, `bubble-sys` | 3 segmentos con fondos oscuros distintos |
| Iconos grandes | `font-2 = 24` | Solo para    |
| DND indicator | `[module/dnd]` | Ejecuta dnd-indicator.sh cada 5s |

### ⚡ PowerSaver

| Qué | Dónde | Detalle |
|---|---|---|
| Script toggle | `~/.config/themes/scripts/toggle-powersaver.sh` | Mata picom/conky, polybar mínima |
| Tema especial | `dracula-powersaver` | Sin animaciones, fondo sólido |
| Atajo | `$mod+Shift+p` | `~/.config/i3/config:65` |

### 🖼️ Conky

| Qué | Dónde | Detalle |
|---|---|---|
| Toggle on/off | `$mod+Shift+n` → `~/.config/themes/bin/toggle-conky.sh` | Crea/elimina flag `conky-enabled` |
| Config activa | `~/.config/themes/current/theme/conky/conky.conf` | Reloj grande + fecha |

### 🔧 Scripts del Sistema

| Script | Ruta | Qué hace |
|---|---|---|
| `theme-switch.sh` | `~/.config/themes/bin/` | Cambia tema + ejecuta applyers |
| `lock.sh` | `~/.config/themes/bin/` | i3lock-color con colores del tema |
| `animation-picker.sh` | `~/.config/themes/bin/` | Cambia animación de cierre |
| `rofi-theme-selector.sh` | `~/.config/themes/bin/` | Grid con previews |
| `toggle-dnd.sh` | `~/.config/themes/scripts/` | No Molestar on/off |
| `power-menu.sh` | `~/.config/themes/scripts/` | Menú de energía Rofi |
| `notify-time.sh` | `~/.config/themes/scripts/` | Hora actual vía dunst |
| `notify-battery.sh` | `~/.config/themes/scripts/` | Batería vía dunst |
| `notify-weather.sh` | `~/.config/themes/scripts/` | Clima vía wttr.in |
| `notify-send.sh` | `~/.config/themes/scripts/` | Wrapper con iconos Nerd Font |
| `dnd-indicator.sh` | `~/.config/themes/scripts/` | Icono polybar para DND |
| `batt_status.sh` | `~/.config/themes/scripts/` | Estado batería polybar |
| `rofi-settings.sh` | `~/.config/themes/bin/` | ⚙️ Centro de Control (menú principal) |
| `settings/sound.sh` | `~/.config/themes/scripts/` | 🔊 Sonido (volumen, mute, salida) |
| `settings/display.sh` | `~/.config/themes/scripts/` | ☀️ Pantalla (brillo, wallpaper, DPMS) |
| `settings/notify.sh` | `~/.config/themes/scripts/` | 🔔 Notificaciones (DND, limpiar, historial) |
| `settings/animation.sh` | `~/.config/themes/scripts/` | 🎬 Animaciones (selector de cierre) |
| `settings/appearance.sh` | `~/.config/themes/scripts/` | 🎨 Apariencia (tema, gaps, conky) |
| `settings/power.sh` | `~/.config/themes/scripts/` | ⚡ Energía (PowerSaver, DPMS, tapa, autolock) |
| `settings/system.sh` | `~/.config/themes/scripts/` | 🔧 Sistema (servicios, restart, info) |
| `settings/utils.sh` | `~/.config/themes/scripts/` | 📋 Utilidades (capturas, WiFi, BT) |
| `settings/wallpaper.sh` | `~/.config/themes/scripts/` | 🖼️ Selector de wallpapers con grid |
| `settings/screenshot.sh` | `~/.config/themes/scripts/` | 📸 Capturas (área, completa, ventana, retardo) |
| `settings/wifi.sh` | `~/.config/themes/scripts/` | 🌐 WiFi manager (nmcli) |
| `settings/bluetooth.sh` | `~/.config/themes/scripts/` | 🔵 Bluetooth manager |
| `settings/colorpicker.sh` | `~/.config/themes/scripts/` | 🎨 Color picker (copia al clipboard) |
| `settings/clipboard.sh` | `~/.config/themes/scripts/` | 📋 Historial de portapapeles |
| `settings/gaps.sh` | `~/.config/themes/scripts/` | ▦ Ajuste de gaps interiores/exteriores |
| `settings/dpms.sh` | `~/.config/themes/scripts/` | 💤 Timeout de apagado de pantalla |
| `settings/autolock.sh` | `~/.config/themes/scripts/` | 🔒 Timeout de bloqueo automático |
| `settings/lid.sh` | `~/.config/themes/scripts/` | 󰤁 Comportamiento al cerrar tapa |
| `settings/sysinfo.sh` | `~/.config/themes/scripts/` | 󰍹 Información del sistema |
| `settings/sound-sink.sh` | `~/.config/themes/scripts/` |  Selector de salida de audio |
| `settings/keybindings.sh` | `~/.config/themes/scripts/` | ⌨️ Visor de atajos de i3 |

### 🧩 Componentes por Tema

Cada tema en `~/.config/themes/themes/<nombre>/` tiene:

| Subdirectorio/Archivo | Propósito |
|---|---|
| `polybar/config.ini` | Barra + colores |
| `polybar/colors.ini` | Paleta de colores (opcional) |
| `rofi/config.rasi` | Tema de Rofi |
| `dunst/dunstrc` | Config de notificaciones |
| `i3/config` | Colores de i3 (ventana, bordes) |
| `picom/picom.conf` | Animaciones + sombras |
| `alacritty/alacritty.toml` | Tema de terminal |
| `conky/conky.conf` | Widget de escritorio |
| `btop/btop.conf` | Monitor del sistema |
| `cava/config` | Visualizador de audio |
| `backgrounds/` | Fondos de pantalla (múltiples) |
| `unlock.png` | Imagen de bloqueo |
| `preview.png` | Preview para selector Rofi |
| `chromium.theme` | Tema para Brave/Chrome (en algunos) |
| `vscode.json` | Ref. a extensión VSCode (en Omarchy) |
| `opencode.json` | Tema para OpenCode |

### 🌐 OpenCode

| Qué | Dónde |
|---|---|
| Tema activo | `~/.config/opencode/tui.json` (escrito por apply-opencode.sh) |
| 24 temas guardados | `~/.config/opencode/themes/<nombre>.json` |
| Applyer | `~/.config/themes/applyers/apply-opencode.sh` |

### 🚀 Procesos Inicio Automático (i3)

| Proceso | Línea en i3/config | Propósito |
|---|---|---|
| `picom` | (via applyer en theme-switch) | Compositor con animaciones |
| `dunst` | (via applyer en theme-switch) | Notificaciones |
| `polybar` | (via applyer en theme-switch) | Barra |
| `nm-applet` | `:39` | Red WiFi |
| `xss-lock lock.sh` | `:34` | Bloquear antes de suspender |
| `xautolock` | `:350` | Bloqueo por inactividad (8 min) |
| `xset dpms` | `:348` | Apagar pantalla (5 min) |
| `polkit-gnome` | `:311` | Autenticación gráfica |

---

> **Nota final:** Este sistema está diseñado para ser modular. Cada componente
> es independiente y puede modificarse sin afectar a los demás. Si algo falla,
> siempre puedes recargar i3 con `$mod+Shift+c` o reiniciar la sesión.
