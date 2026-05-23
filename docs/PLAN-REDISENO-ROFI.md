# Plan de Rediseño Rofi: Estética "Next-Gen"

Este plan detalla el rediseño visual de todos los menús Rofi del sistema para lograr una apariencia coherente, moderna y de alta fidelidad.

## 1. Unificación de Estilos (Master RASI)

En lugar de definir estilos en cada script, crearemos un sistema de plantillas RASI que herede los colores del tema activo.

### A. Diseño "Main" (Vertical List con Iconos)
- **Uso**: Centro de Control y la mayoría de submenús.
- **Mejora**: Iconos alineados a la izquierda, fuentes más grandes, bordes extra redondeados (20px+) y espaciado generoso entre elementos.
- **Interactividad**: Efectos de resaltado con el color primario del tema.

### B. Diseño "Grid" (Cuadrícula de Iconos)
- **Uso**: Selector de Wallpapers, Capturas de Pantalla y Powermenu.
- **Mejora**: Celdas cuadradas con iconos/miniaturas gigantes y etiquetas centradas debajo.

## 2. Rediseño del Selector de Temas (GTK3 Moderno)

Aunque usa Python GTK3, se rediseñará para que parezca una aplicación nativa de última generación.

- **Estética Cyberpunk/Glass**:
    - Uso de `backdrop-filter: blur()` (si el compositor lo permite) o transparencias elegantes.
    - Bordes con gradientes que usen el color primario del tema.
    - La lista de temas tendrá iconos de estado (punto verde para el activo).
- **Layout**:
    - Lista a la izquierda con scroll suave.
    - Preview a la derecha con esquinas muy redondeadas y una sombra "glow" del color del tema.
    - Botones de acción flotantes en la parte inferior derecha.

## 3. Revisión de Submenús Específicos

- **Animaciones**: Convertir las opciones en una lista más descriptiva con iconos de movimiento (↑, ↓, ↔).
- **WiFi/Bluetooth**: Mostrar niveles de señal y estado de conexión con colores dinámicos (Verde=Conectado, Rojo=Desconectado).
- **Sonido**: Incluir indicadores visuales del volumen actual en las etiquetas.

## 4. Pasos de Ejecución

1.  **Generador de RASI**: Crear un script interno que genere `~/.cache/rofi-master.rasi` cada vez que se cambia de tema.
2.  **Refactor de Scripts**: Actualizar los ~15 scripts en `scripts/settings/` para que usen el nuevo master RASI.
3.  **Upgrade de ThemeSelector**: Reescribir la sección CSS y la disposición de widgets en el script Python del selector de temas.
4.  **Sincronización**: Aplicar y validar en tiempo real.

---
¿Te parece bien este enfoque de unificación visual o prefieres que cada menú tenga un estilo único y diferente?