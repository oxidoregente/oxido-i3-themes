# Plan de Mejora UI/UX: Polybar & Rofi

Este plan detalla las mejoras para los 4 layouts seleccionados de Polybar y la transición de los menús de Eww a Rofi con un diseño moderno.

## 1. Refactorización de Polybar (layouts "Premium")

Se estandarizarán las fuentes, espaciados y se corregirán errores visuales en los siguientes diseños:

### A. Bubble (Burbujas Segmentadas)
- **Mejora**: Sustituir los espacios planos (`ws-pad`, etc.) por glifos reales `` y `` para lograr un redondeado perfecto en cada segmento.
- **Detalle**: Ajustar el `tray` para que se integre sin cortes en la burbuja de sistema.

### B. Floating (Flotante)
- **Mejora**: Optimizar el centrado vertical de los iconos.
- **Estética**: Refinar el `border-color` para que use el acento primario de forma más elegante y asegurar que `wm-restack` funcione sin parpadeos.

### C. Cynthia (Modern Two-Tone)
- **Mejora**: Unificar la paleta de colores. Actualmente usa `background-alt` para el centro, se probará una variante de contraste dinámico.
- **Tipografía**: Asegurar que `Maple Mono NF` esté disponible o usar un fallback elegante como `JetBrainsMono NF` si falla.

### D. Material (Material Design)
- **Mejora**: Implementar sombras reales (vía Picom) y bordes definidos.
- **Interactividad**: Mejorar los estados `hover` y `active` de los módulos.

## 2. Nuevos Menús en Rofi

Se crearán dos nuevos archivos de estilo `.rasi` y se actualizarán los scripts de lanzamiento.

### A. Powermenu (Menú de Apagado)
- **Diseño**: Cuadrícula (grid) de 5 iconos gigantes (Apagar, Reiniciar, Suspender, Bloquear, Salir).
- **Estética**: Fondo semi-transparente, bordes redondeados (16px+), iconos Nerd Font en tamaño extra grande.
- **Script**: `config/themes/scripts/rofi-powermenu.sh` reemplazará la lógica de Eww.

### B. Control Center (Centro de Control)
- **Diseño**: Menú lateral o central con iconos a la izquierda y etiquetas descriptivas.
- **Secciones**: Sonido, Pantalla, Red, Bluetooth, Animaciones, etc.
- **Mejora**: El script `rofi-settings.sh` se actualizará para usar este nuevo diseño de alta densidad.

### E. Gestión de Batería (simplificada)
- **Widget**: `batt-widget.sh` muestra icono + porcentaje con iconos Nerd Font v3.
- **Click izquierdo**: `notify-battery-detail.sh` — notificación Dunst con estado
  detallado (porcentaje, tiempo restante, perfil de energía activo).
- **Click derecho**: `cycle-power-profile.sh` — cicla entre Ahorro/Equilibrado/
  Rendimiento usando `powerprofilesctl`.
- **Nota**: El sistema anterior de expansión vía flag `/tmp/` y señales SIGRTMIN+10
  se eliminó por causar crashes y múltiples instancias de Rofi.

## 3. Estado Actual (post-Fase 5)

1.  **Backup**: Punto de restauración creado.
2.  **Rofi Themes**: Powermenu (grid 5 iconos) y Control Center operativos.
3.  **Scripts**: Todos los scripts de batería y menús migrados de EWW a Rofi.
4.  **Polybar Refactor**: 15 layouts reparados — EWW reemplazado por Rofi,
    23 temas con estructura de secciones corregida.
5.  **Sincronización**: Cambios aplicados en `~/.config/` y repositorio.
6.  **i3 config**: Eliminada dependencia de EWW daemon.

---
¿Deseas que proceda con este plan o te gustaría ajustar algún detalle de los diseños?