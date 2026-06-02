# 💎 Guía de Arquitectura y Convenciones - oxido-i3-themes

Este archivo documenta las decisiones técnicas, estándares de código y flujos de trabajo específicos para este repositorio.

## 🏗️ Arquitectura de Componentes

### 1. Polybar "Organic Bubble"
Se utiliza una arquitectura de **barra única nativa** (`override-redirect = false`) con fondo transparente (`#00000000`).
- **Razón:** Permite que i3wm gestione los "struts" (espacios reservados) de forma automática sin necesidad de scripts de cálculo de gaps.
- **Módulos:** Los módulos simulan burbujas independientes mediante el uso de glyphs decorativos (``, ``) y fondos de color específicos (`%{B...}`).
- **Resizing:** El redimensionado es orgánico (nativo de Polybar) y no requiere reiniciar el proceso al cambiar de estado (ej: al ocultar el reproductor).

### 2. Sistema de Temas e i18n
- **Portabilidad:** Está terminantemente **prohibido** usar rutas hardcodeadas como `/home/usuario`. Se debe usar siempre `${HOME}` o `~`.
- **Localización:** Todos los scripts que interactúan con el usuario deben soportar multi-idioma mediante la carga de `~/.config/themes/lang/active_lang.env`.
- **Persistencia de Wallpaper:** Cada tema gestiona su propio fondo en un archivo `last-wallpaper` dentro de su carpeta. Evitar archivos de estado globales para elementos visuales que dependen del tema.

## 🎨 Estándares Visuales

### 1. Notificaciones (Dunst)
- **Contraste:** El texto de baja urgencia (`urgency_low`) debe mantener un ratio de contraste legible contra el fondo oscuro. Se recomienda `#8a91a1` para fondos cercanos al negro.
- **Iconos:** Se prefiere `enable_recursive_icon_lookup = true` sobre rutas estáticas.

### 2. Animaciones (Picom)
- **Compatibilidad:** Para garantizar la estabilidad en hardware Intel UHD, se debe mantener `vsync = true` y `unredir-if-possible = false`.
- **Triggers:** Usar solo disparadores estables: `open`, `close`, `show`, `hide`. Evitar disparadores experimentales que generen errores en el log.

## 🛠️ Flujo de Trabajo y Mantenimiento

### 1. Gestión de Ventanas
- **Flotantes:** Las aplicaciones de sistema, diálogos y herramientas de configuración (actualizaciones, redes, calculadora) deben definirse como flotantes y centradas en la configuración de i3.
- **Startup ID:** Todos los `exec` en la configuración de i3 que lancen scripts o aplicaciones sin ventana persistente deben incluir `--no-startup-id` para evitar el bloqueo del cursor en modo carga.

### 2. Scripts de Mantenimiento
- Los scripts de generación de temas o propagación de cambios masivos se encuentran en `config/themes/maintenance/`. No deben mezclarse con los binarios de ejecución diaria en `bin/`.

## 📂 Estructura de Persistencia Local
- `~/.config/themes/current/theme`: Link simbólico al tema activo.
- `~/.config/themes/lang/active_lang.env`: Estado del idioma global.
- `~/.config/themes/date-format`: Estado del formato de reloj (12h/24h).
