# 📓 Bitácora de Desarrollo

---

## 21. Contraste de workspaces Polybar: active sin pill, empty-ws contra bubble-ws

### Problema
Los workspaces activos en Polybar usaban `label-active-background = ${colors.primary}`
con `label-active-foreground = ${colors.background}`, creando un "pill" de color
primary. En temas con primary pálido (como el rosa palo `#b59790` de last-horizon),
el texto background (`#0c0b0c`) sobre primary tenía solo 4.2:1 de contraste —
visible pero muy pobre.

Además, el color `empty-ws` (workspace vacío) se calculaba originalmente contra
`background`, pero los módulos `xworkspaces` no tienen fondo propio — heredan el
fondo del segmento de la barra donde están. En layouts con barras segmentadas
(bubble, cynthia, floating), el fondo es `bubble-ws`, no `background`. El empty-ws
quedaba invisible sobre `bubble-ws` en varios temas (contraste < 2:1).

### Solución
1. **Activo sin pill**: Eliminar `label-active-background`. Usar
   `label-active-foreground = ${colors.primary}` con
   `label-active-underline = ${colors.primary}` — texto primary + subrayado en vez
   de fondo sólido. Esto funciona en todos los temas porque el contraste de
   primary contra el fondo de la barra siempre es bueno (primary está diseñado
   para eso).

2. **empty-ws contra bubble-ws**: Recalcular `empty-ws` para cada uno de los 23
   temas, esta vez buscando 5.0:1 de contraste contra `bubble-ws` (en vez de
   `background`). Para temas sin bubble-ws definido previamente, se usó el mismo
   valor que `background-alt`.

3. **Layouts con format-background=primary**: colorblocks, cynthia y dual usaban
   `format-background = ${colors.primary}` en xworkspaces, lo que hacía que el
   contraste de empty-ws contra primary fuera pésimo (1.0-2.7:1). Se eliminó ese
   format-background, dejando los workspaces sobre el fondo natural de la barra.

### Archivos afectados
- 11 layouts: active sin pill
- 3 layouts (colorblocks, cynthia, dual): format-background=primary eliminado
- 23 temas: empty-ws recalculado
- 15 layouts: label-empty-foreground = ${colors.empty-ws}

---

## 22. colorblocks: bloques de color inconsistentes entre temas

### Problema
El layout colorblocks de Polybar usaba colores temáticos como fondos de módulos
individuales: `${colors.green}` para CPU, `${colors.yellow}` para memory,
`${colors.secondary}` para date, `${colors.pink}` para pulseaudio. Estos colores
son semánticos (no visuales) y varían drásticamente entre temas.

En last-horizon, `yellow = #6B5E73` es un púrpura oscuro, no amarillo. El texto
`${colors.background}` (negro) sobre ese fondo tenía solo 2.9:1 de contraste.
El resultado visual era un mosaico de colores sin coherencia, con módulos
ilegibles en varios temas.

### Causa raíz
El original de adi1090x (polybar-themes/simple/colorblocks) usa 8 tonos de
naranja (`shade1`-`shade8`) como fondos de módulos, con texto negro fijo
(`#0a0a0a`). Nuestra adaptación reemplazó los shades por colores semánticos
del tema, que no están diseñados para ser fondos de bloque sino acentos.

### Solución
Eliminar los `format-background` de colores temáticos en CPU, memory, date y
pulseaudio. Reemplazar por `format-background = ${colors.background-alt}` (fondo
consistente como los demás layouts). Los íconos/prefixos conservan su color de
acento (green para CPU, yellow para memory) mediante `format-prefix-foreground`.

El diseño "colorblocks" se conserva en la disposición de módulos con separadores
(`colorblocks-sep`) entre cada bloque, creando el efecto de módulos aislados.
Pero ahora todos los bloques comparten el mismo fondo `background-alt`, con
acentos de color solo en los íconos.

### Archivos afectados
- `config/polybar/layouts/colorblocks.ini`

---

## 23. `inputbar` en Rofi necesitaba `entry` para búsqueda textual

### Problema
Al agregar `inputbar` a los temas de Rofi para tener barra de búsqueda, se
usó `children: [ prompt ]` que solo muestra la etiqueta (ej. "Layout") pero
no el campo de texto. Los usuarios veían el cuadro de búsqueda visualmente pero
no podían tipear — el widget `entry` (el campo de entrada de texto) faltaba.

### Causa
En Rofi, `inputbar` es un contenedor que puede tener varios hijos:
- `prompt`: la etiqueta descriptiva (ej. "🔍 Buscar", "Layout")
- `entry`: el campo de texto donde el usuario escribe
- `case-indicator`: indicador de mayúsculas/minúsculas

Si se redefine `children:` explícitamente sin incluir `entry`, el campo de
texto desaparece. La mayoría de temas de Rofi usan `children: [ prompt, entry ]`
para soportar búsqueda.

### Solución
Cambiar `children: [ prompt ]` a `children: [ prompt, entry ]` en:
1. `rofi-builder.sh` → `ROFI_THEME_MAIN` (tema principal con búsqueda)
2. `rofi-layout-selector.sh` → fallback de `ROFI_THEME_MAIN`
3. `polybar-layout.sh` → fallback de `ROFI_THEME_MAIN`

Además se agregó estilo para `entry { text-color; font; }`.

### Archivos afectados
- `config/themes/scripts/rofi-builder.sh`
- `config/themes/bin/rofi-layout-selector.sh`
- `config/themes/scripts/settings/polybar-layout.sh`

---

## 24. Wrapper `rofi-drun.sh` para themar mod+d con ROFI_THEME_MAIN

### Problema
El lanzador de aplicaciones `mod+d` usaba `rofi -show drun` sin `-theme-str`,
por lo que no heredaba el theme visual del proyecto (colores, bordes, inputbar).
Se veía con el tema por defecto de Rofi, inconsistente con el resto de menús.

### Solución
Crear `config/themes/bin/rofi-drun.sh` que:
1. Fuentea `rofi-builder.sh` para obtener colores dinámicos del tema activo
2. Lanza `rofi -show drun` con `-theme-str "$ROFI_THEME_MAIN"`

El `i3/config` se actualiza de `exec "rofi -show drun -show-icons ..."` a
`exec ~/.config/themes/bin/rofi-drun.sh`.

### Archivos afectados
- `config/themes/bin/rofi-drun.sh` (nuevo)
- `config/i3/config`

---

## 25. Barra de búsqueda en el selector visual de temas (GTK3)

### Problema
El selector de temas (`mod+Shift+t`) mostraba una lista plana de 23+ temas sin
forma de filtrarlos. Con tantos temas, encontrar uno específico requería
desplazamiento manual. El selector usa GTK3 Python, no Rofi.

### Solución
Agregar un `Gtk.SearchEntry` en la parte superior del panel izquierdo, con:
- Placeholder "🔍 Temas" (según el locale activo vía `L_CUR_THEME`)
- Filtrado en tiempo real vía `Gtk.TreeModelFilter`
- El filtro busca por nombre de tema (insensible a mayúsculas)
- El botón "Aleatorio" busca en el modelo filtrado

Técnicamente:
1. CSS: se agregó estilo `entry {}` con colores del tema
2. Se creó `self.search_entry` con `Gtk.SearchEntry()`
3. Se conectó `search-changed` a `_on_search_changed` que llama `self.theme_filter.refilter()`
4. `_filter_func` retorna True si el nombre del tema contiene el texto buscado
5. Se usó `hasattr` para evitar refilter antes de que exista `theme_filter`

### Archivos afectados
- `config/themes/bin/rofi-theme-selector.sh`

---

## 26. docky, floating, rounded: width parcial dejaba hueco visual

### Problema
Los layouts docky (96%), floating (90%) y rounded (92%) usaban `width < 100%`
con `offset-x` para centrar la barra. Aunque la intención estética era crear
una barra "flotante" visualmente, en la práctica se veía un espacio vacío en el
extremo derecho del monitor que parecía un error de configuración.

### Solución
Cambiar `width` a `100%` y eliminar `offset-x` en los tres layouts. La barra
ocupa todo el ancho del monitor. El efecto "flotante" se conserva mediante
otros mecanismos:
- docky: `bar-bg = bg-alt` (fondo distinto al escritorio)
- floating: `border-size=2` + `radius=16` (borde redondeado visible)
- rounded: `bar-bg = bg-alt` + `radius=18` (forma de píldora)

### Archivos afectados
- `config/polybar/layouts/docky.ini`
- `config/polybar/layouts/floating.ini`
- `config/polybar/layouts/rounded.ini`

---

## 27. nowplaying: format-background reemplazado por label-background

### Problema
El módulo `nowplaying` en los 15 layouts usaba `format-background` para el
fondo del widget. Polybar no soporta `format-background` en módulos de tipo
`custom/script` con `format = <label>`. La propiedad correcta es
`label-background`. Aunque polybar no daba error explícito, el fondo no se
aplicaba correctamente en ciertas condiciones.

### Solución
Cambiar `format-background = ${colors.background-alt}` por
`label-background = ${colors.background-alt}` en los 15 layouts.

### Archivos afectados
- Todos los 15 layouts `config/polybar/layouts/*.ini`

---

## 28. player-monitor.sh: expandir center bar al iniciar sin player

### Problema
El script `player-monitor.sh` que controla la visibilidad de la barra de
reproducción no expandía la barra center al iniciar si no había un player
activo. Esto dejaba la barra center oculta o parcialmente expandida hasta que
el usuario iniciara manualmente una reproducción.

### Solución
Agregar llamada a `center-bubble.sh expand` al inicio del script, antes del
loop principal de monitoreo. Esto asegura que al arrancar polybar (o al
reiniciar el script), la barra center esté expandida inmediatamente.

### Archivos afectados
- `config/polybar/scripts/player-monitor.sh`

Problemas encontrados durante la creación y refactorización de oxido-i3-themes,
y cómo se resolvieron. Útil para futuras contribuciones y para entender
decisiones técnicas.

---

## 1. Animaciones: triggers combinados vs separados

### Problema
Todos los `picom.conf` usaban triggers combinados en un mismo bloque:
```lua
triggers = ["open", "show"];
```
y
```lua
triggers = ["close", "hide"];
```

El script `animation-picker.sh` buscaba triggers individuales con coincidencia
exacta de cadena (`triggers = ["show"];`), pero esa línea no existía porque
estaban combinados. Esto causaba que `find_trigger_in_section()` retornara
`None` y el menú de animaciones por aplicación no funcionara para show/hide.

### Solución
Script Python (`/tmp/fix_combined_triggers.py`) que separa cada trigger
combinado en su propio bloque:
```lua
triggers = ["open"];
...
}, {
triggers = ["show"];
```

### Detalle técnico
picom v13 sí soporta triggers combinados en una misma lista, pero el script
`animation-picker.sh` fue diseñado con búsqueda exacta, no con parseo
semántico. La separación física en bloques individuales fue más simple y
segura que reescribir el motor de búsqueda.

**Archivos afectados:** 23 picom.conf (todos los temas excepto PowerSaver)
**Commit:** `8352c43f`

---

## 2. `@include` dentro de bloques `animations = ({ })`

### Problema
Se intentó usar `@include` dentro de la estructura de datos de animaciones:
```lua
animations = ({
    @include "../animations/global.conf"
});
```

picom reportaba `syntax error on line 1` — no reconocía la directiva.

### Causa raíz
picom usa **libconfig** para parsear su configuración. `@include` es una
directiva de **preprocesador** de libconfig que opera a nivel de archivo,
antes del parseo. No puede anidarse dentro de estructuras de datos como
listas (`(...)`) o grupos (`{...}`). Solo funciona al nivel raíz del archivo.

La documentación oficial de picom.confirma:
> When `@include` directive is used in the config file, picom will first
> search for the included file in the parent directory of picom.conf,
> then in `$XDG_CONFIG_HOME/picom/include/`.

No hay mención de uso dentro de estructuras anidadas.

### Solución
Extraer el **bloque completo** de animaciones a un archivo separado e
incluirlo a nivel raíz:

`animations/global.picom`:
```lua
animations = ({
    triggers = ["open"];
    ...
});
```

`picom.conf`:
```lua
@include "../../animations/global.picom"
```

Esto funciona porque libconfig pega el contenido textualmente antes de
parsear. El bloque `animations = ({ ... });` completo es sintácticamente
válido a nivel raíz.

**Referencias:**
- https://github.com/yshui/picom/issues/931 — discusión sobre rutas relativas en @include
- https://www.hyperrealm.com/libconfig/libconfig_manual.html — documentación de libconfig
- https://github.com/yshui/picom/issues/510 — feature request de include directive
- https://github.com/yshui/picom/pull/1253 — implementación de animaciones en picom v13

---

## 3. Indentación en f-strings de Python

### Problema
Al generar bloques de animación con Python f-strings, las llaves `{` y `}`
requieren escaping (`{{` y `}}`). Se generó accidentalmente `animations = ({})`
en vez de `animations = ({` por un error de escaping.

### Solución
Usar variable intermedia para la llave de apertura y concatenación para
la de cierre:
```python
lb = '{'
result.append(f'{indent}animations = ({lb}\n')
result.append(f'{indent}}});\n')
```

---

## 4. Picom no arranca con config nueva

### Problema
Después de reemplazar `~/.config/picom/picom.conf`, picom no arrancaba
sin mostrar errores. `picom --config file 2>&1 &` se ejecutaba en foreground
y el timeout del shell lo mataba, dando la impresión de fallo.

### Causa
picom sí arrancaba correctamente, pero al ejecutarse con `&` en el script
el shell reportaba timeout. No era un error de configuración.

### Solución
Verificar con `pgrep` tras dormir 1 segundo, no confiar en que el shell
background reporte correctamente.

---

## 5. Icono de disco en Conky no se renderiza

### Problema
El icono `` (U+F7C9) en la línea de NVMe del conky se mostraba como un
cuadrado vacío.

### Causa
El caracter U+F7C9 no está presente en ninguna Nerd Font instalada en el
sistema, ni en JetBrainsMono Nerd Font ni en IosevkaTerm Nerd Font. Es
un glifo que pudo haber estado en versiones anteriores de Nerd Fonts pero
fue eliminado o movido en versiones recientes.

### Solución
Reemplazar por `` (U+F0A0 — `nf-fa-hdd_o`), que es el icono estándar de
disco duro en Nerd Fonts y está disponible en todas las variantes instaladas.

**Archivos afectados:** 23 conky.conf
**Commit:** `af007dbf`

---

## 6. SSIDs con espacios en wifi.sh

### Problema
El script `wifi.sh` usaba `echo "$sel" | awk '{print $1}'` para extraer el
SSID de la red WiFi seleccionada, lo cual solo tomaba la primera palabra.
SSIDs como "Mi Casa WiFi" se truncaban a "Mi".

### Solución
Usar awk con detección de la columna SIGNAL (siempre un número 0-100) para
identificar el límite derecho del SSID:
```awk
for(i=NF; i>=1; i--)
    if($i ~ /^[0-9]+$/) { sig=i; break }
for(j=1; j<sig-1; j++) printf "%s%s", (j>1?" ":""), $j
```

**Limitación:** SSIDs con campo de seguridad multi-palabra (ej. "WPA1 WPA2")
pueden incluir parte de la seguridad en el SSID extraído. Es un caso raro.

---

## 7. Búsqueda de keybindings en modo `mode {}` de i3

### Problema
`keybindings.sh` usaba `grep "^bindsym"` que solo capturaba binds al
inicio de línea. Los binds dentro de bloques `mode { ... }` de i3 están
indentados y no se mostraban.

### Solución
Cambiar a `grep "^\s*bindsym"` que captura binds con cualquier indentación.

---

## 8. Loop infinito en apply-picom.sh

### Problema
El bucle `while pgrep -u $UID -x picom >/dev/null; do sleep 0.3; done`
esperaba indefinidamente a que picom terminara. Si picom se colgaba,
el script se quedaba trabado para siempre.

### Solución
Reemplazar con bucle `for` con límite de 10 iteraciones (3 segundos máximo):
```bash
for _ in $(seq 1 10); do
    pgrep -u $UID -x picom >/dev/null || break
    sleep 0.3
done
```

---

## 9. Presets de animaciones no afectan reglas per-app

### Problema
`apply_preset_to_file()` solo aplicaba el preset a los triggers globales.
Las reglas per-app (Alacritty, Firefox, Rofi, Dunst) tienen prioridad
sobre las globales según la documentación de picom v13, por lo que el
usuario no veía el cambio en esas aplicaciones.

### Solución
Agregar `find_all_app_rules()` que escanea el archivo en busca de reglas
con bloques `animations = ({`, y aplica el preset también a cada una.
Parámetro `quiet=True` para suprimir errores cuando un trigger no existe
en una app específica (ej. "show" no existe en Alacritty).

**Archivos:** `animation-picker.sh`
**Commit:** `8352c43f`

---

## 11. Corrupción estructural en los 23 temas polybar (sección powermenu)

### Problema
En **los 23 temas** (`config/themes/themes/*/polybar/config.ini`) se detectó que
la cabecera `[module/powermenu]` **no existía**. Las propiedades del powermenu
estaban filtradas dentro del bloque `[module/battery]`, sobrescribiendo su
`type = internal/battery` por `type = custom/text` y mostrando el icono de
power () en lugar del indicador de batería.

Adicionalmente, el `[module/tray]` era una cabecera huérfana sin contenido,
y `[module/network]` estaba definido dentro de la sección tray. La línea
`type = internal/tray` aparecía al final del archivo como última línea, como
si fuera parte del bloque network.

### Estructura corrupta (antes de la reparación)
```ini
[module/battery]
type = internal/battery
... (config correcta hasta línea 201)
type = custom/text           # ← ¡Sobrescribe battery!
format = " %{T2}%{T-}"     # ← Muestra power icon en vez de batería
...
click-left = /home/oxido/.config/eww/scripts/toggle-powermenu.sh

[module/tray]               # ← Cabecera huérfana (sin body)
[module/network]
type = internal/network
...
type = internal/tray         # ← Última línea del archivo
```

### Causa raíz
La cabecera `[module/powermenu]` se omitió durante una fase de refactorización
o generación masiva de los 23 temas. Como polybar no mostraba errores
explícitos (el parser de INI simplemente acumulaba propiedades en la sección
actual), el error pasó desapercibido. Al concatenar los temas con los layouts
(vía `apply-polybar.sh`), las definiciones correctas del layout sobrescribían
las corruptas, ocultando el problema en el runtime pero dejando los archivos
fuente inservibles por sí solos.

### Solución
Script Python que:
1. Detecta la línea `type = custom/text` inmediatamente después de
   `animation-charging-framerate = 750` dentro de `[module/battery]`
2. Inserta `[module/powermenu]` antes de esa línea
3. Reemplaza la ruta EWW (`eww/scripts/toggle-powermenu.sh`) por la ruta Rofi
   (`rofi-powermenu.sh`)
4. Reestructura la sección tray/network eliminando la cabecera huérfana
   `[module/tray]`, dejando `[module/network]` como sección independiente,
   y creando un nuevo `[module/tray]` con su `type = internal/tray`

**Archivos afectados:** 23 theme configs + 11 layouts
**Commit:** próximo

---

## 12. EWW config inexistente pero referenciada en todo el proyecto

### Problema
El proyecto dependía de EWW (Elkowar's Wacky Widgets) para los menús de
powermenu y control-center, pero:
- `~/.config/eww/` no existía (sin `eww.yuck`, `eww.scss`, ni scripts)
- El binario `eww` estaba instalado (v0.6.0) pero sin configuración
- `i3 config` ejecutaba `exec_always eww daemon` en cada arranque (fallaba)
- 49 referencias a `eww/scripts/toggle-powermenu.sh` en layouts y temas
- La documentación describía directorios EWW que no existían

### Causa raíz
EWW fue el primer mecanismo implementado para widgets flotantes, pero
posteriormente se migró a Rofi (más estable, menos dependencias). La migración
quedó incompleta: se cambiaron algunos layouts pero no todos, y los archivos
de configuración EWW nunca se subieron al repositorio ni se copiaron al
sistema.

### Solución
1. Eliminada línea `exec_always eww daemon` del i3 config
2. Reemplazadas las 49 referencias a `eww/scripts/toggle-powermenu.sh` por
   `rofi-powermenu.sh` en layouts y temas
3. Powermenu ahora usa exclusivamente `rofi-powermenu.sh` (Rofi grid moderno)
4. Control Center usa `rofi-settings.sh` vía `$mod+Shift+s`

**Archivos afectados:** 23 temas, 15 layouts, i3/config
**Commit:** próximo

---

## 13. Battery click handlers inconsistentes y propensos a errores

### Problema
Existían dos sistemas diferentes de click en batería:
- 11 layouts estándar: usaban `notify-battery-detail.sh` (notificación Dunst),
  sin señales a polybar.
- 4 layouts premium (bubble, floating, cynthia, material): usaban
  `toggle-battery-info.sh` que enviaba `SIGRTMIN+10` (signal 44) a polybar
  para forzar actualización, y `rofi-battery-mode.sh` para menú de perfiles.

El segundo sistema causaba:
- Múltiples instancias de Rofi al hacer clic rápido
- Posibles crashes de polybar si la señal llegaba en momento incorrecto
- Condición de carrera con el archivo flag `/tmp/polybar_batt_extended`

### Causa raíz
El sistema de señal SIGRTMIN+10 se implementó para dar actualización
"instantánea" del widget, pero polybar puede manejar la actualización por sí
mismo con `interval = 10`. La señal era una optimización prematura.

### Solución
Unificar todos los layouts al sistema simple de notificación:
- `click-left`: `notify-battery-detail.sh`
- `click-right`: `cycle-power-profile.sh`
- Ninguno envía señales a polybar
- `batt-widget.sh` se actualiza por intervalos normales

**Archivos afectados:** 4 layouts premium (bubble, floating, cynthia, material)
**Commit:** próximo

---

## 10. `@include` no funciona dentro de estructuras de datos (v2 — confirmación)

### Problema (revisitado)
Se intentó usar `@include` dentro del bloque `animations = ({ })` para
externalizar solo el contenido interior. picom v13 reportaba error de
sintaxis.

### Causa raíz (confirmada experimentalmente)
`@include` es una directiva del preprocesador de **libconfig** que opera
a nivel de archivo, antes del parseo sintáctico. No puede aparecer dentro
de ninguna estructura de datos: ni listas `()`, ni grupos `{}`, ni arrays `[]`.

Funciona exclusivamente a nivel raíz del archivo de configuración.

### Solución final (Fase 2)
Externalizar bloques **completos** a archivos separados e incluirlos a
nivel raíz:

```
config/themes/animations/
  global.picom   → animations = ({ ... });  (bloque completo)
  rules.picom    → rules: ({ ... });        (bloque completo)
```

Cada `picom.conf` de tema queda:
```
backend = "glx"; vsync = true; ...
@include "../../../animations/global.picom"
@include "../../../animations/rules.picom"
```

Esto sí funciona porque el bloque entero es sintácticamente válido a
nivel raíz de un archivo libconfig.

### Beneficios colaterales
- 121 líneas → ~20 líneas por picom.conf (-83%)
- Las animaciones se modifican en un solo lugar (no 24 archivos)
- El `animation-picker.sh` modifica solo `global.picom` y `rules.picom`
- El `apply-picom.sh` transforma paths relativos a absolutos al copiar
- PowerSaver no tiene `@include` (no usa animaciones)

### Archivos afectados
- **Creados:** `config/themes/animations/global.picom` (25 líneas),
  `config/themes/animations/rules.picom` (93 líneas)
- **Modificados:** 23 picom.conf (22 temas + central), `apply-picom.sh`,
  `animation-picker.sh`
- **No modificado:** PowerSaver (no tiene animaciones)

---

## Convenciones y decisiones técnicas

### ¿Por qué no usar `@include` para reglas per-app?
Las reglas per-app están dentro del bloque `rules: ({ ... })`, que es una
estructura de datos de libconfig. `@include` no funciona dentro de
estructuras anidadas. La única alternativa viable es externalizar el
bloque `rules:` completo a un archivo separado e incluirlo a nivel raíz.

### ¿Por qué todos los temas comparten las mismas animaciones?
Se decidió estandarizar las animaciones (globales y per-app) en todos los
temas porque:
1. Reduce la complejidad de mantenimiento de 24 archivos a 1-2 archivos
2. El usuario puede personalizar las animaciones independientemente del tema
3. El `animation-picker.sh` puede operar sobre un único archivo fuente
4. Las diferencias visuales entre temas están en las paletas de colores,
   wallpapers y configs de picom/polybar, no en las animaciones

### ¿Por qué se usa `sed` en `apply-picom.sh` para transformar paths?
Los archivos de tema tienen `@include` con rutas relativas a su ubicación
(`../../../animations/...`). Al copiarse a `~/.config/picom/picom.conf`,
la ruta relativa cambia. `sed` transforma la ruta durante la copia para
que apunte a `../themes/animations/...` desde la ubicación de destino.

---

## 13. Variable Shadowing en polybar-modules.sh: `MODS_L` vs `MODS_LEFT`

### Problema
El Gestor de Módulos (`$mod+Shift+m`) mostraba **0 módulos en cada sección**
y las listas aparecían vacías, aunque el archivo de layout tuviera los módulos
correctamente definidos.

### Causa
Las variables que almacenan los módulos se llaman `MODS_LEFT`, `MODS_CENTER`
y `MODS_RIGHT`, pero todas las funciones internas (`count_sec`, `seccion_menu`,
`reordenar_seccion`, `ocultar_todos`, `move_mod`) usaban la notación indirecta
`mods_var="MODS_$sec"` donde `$sec` es el código corto `L`/`C`/`R` — produciendo
`MODS_L`, `MODS_C`, `MODS_R` que **no existen**.

Al expandir `${!mods_var}` se obtenía una cadena vacía, resultando en conteo 0
y listas de opciones vacías.

### Solución
Se introdujo la función `_mods_of()` que mapea el código corto a la variable
real mediante un `case`:

```bash
_mods_of() {
    case "$1" in L) echo "$MODS_LEFT" ;; C) echo "$MODS_CENTER" ;; R) echo "$MODS_RIGHT" ;; esac
}
```

Y se reemplazaron todas las referencias `mods_var="MODS_$sec"` + `${!mods_var}`
por `$(_mods_of "$sec")`.

### Archivos afectados
- `config/themes/bin/polybar-modules.sh` (5 funciones corregidas)

---

## 14. Reloj Polybar en Inglés con Locale Español

### Problema
La fecha en la Polybar mostraba los días y meses en inglés a pesar de que
el sistema tenía `LANG=es_VE.UTF-8` y `LC_TIME=es_VE.utf8`.

### Causa
El módulo `internal/date` de Polybar no respeta consistentemente el locale
del entorno, posiblemente porque Polybar reinicia el locale interno a `"C"`
durante su inicialización o usa `std::put_time` con el locale por defecto
del proceso.

### Solución
Se reemplazó `internal/date` por `custom/script` que usa un wrapper
con archivo de estado, evitando la dependencia del IPC de Polybar:

```ini
[module/date]
type = custom/script
exec = ~/.config/polybar/scripts/date-wrapper.sh
interval = 1
click-left = ~/.config/polybar/scripts/date-toggle.sh
```

El wrapper `date-wrapper.sh` lee `/tmp/polybar-date-alt`. Si el archivo
existe, muestra la fecha en español con `LC_TIME=es_VE.utf8`; si no,
muestra la hora. El toggle `date-toggle.sh` crea/elimina ese archivo y
envía `polybar-msg action` con un pequeño retardo para forzar la
actualización inmediata del módulo.

Esta arquitectura es robusta porque no depende del IPC interno de
Polybar, que falla cuando `click-left` intenta enviar mensajes a su
propio proceso.

### Archivos afectados
- `config/polybar/layouts/bubble.ini` (y por herencia `config.ini`)
- `config/polybar/scripts/date-wrapper.sh` (nuevo)
- `config/polybar/scripts/date-toggle.sh` (nuevo)

---

## 15. Idioma no Persistía entre Sesiones

### Problema
Al seleccionar un idioma en `Centro de Control → 🌍 Idioma`, el cambio se
reflejaba inmediatamente pero se perdía al cerrar y reabrir el menú.

### Causa
El script `language.sh` escribía el archivo `active_lang.env` en la ruta del
repositorio (`$REPO_DIR/config/themes/lang/`), pero los menús se abren desde
`~/.config/themes/bin/` que lee el archivo desde `~/.config/themes/lang/`
— rutas completamente distintas. El cambio nunca persistía al runtime.

### Solución
Se modificó `language.sh` para:
1. Escribir `active_lang.env` a `~/.config/themes/lang/` (ruta de runtime)
2. Ejecutar el menú principal desde la misma ruta de runtime (`~/.config/themes/bin/`)
3. (Opcional) También escribir al repo para mantener sincronización en desarrollo

### Archivos afectados
- `config/themes/scripts/settings/language.sh`

---

## 16. Intercambio de Módulos: UX Mejorado

### Problema
Para mover un módulo al final de su sección, el usuario debía presionar
"Intercambiar con siguiente" múltiples veces, lo cual era tedioso.

### Solución
Se reemplazaron las dos opciones `⬆  Intercambiar con anterior` y
`⬇  Intercambiar con siguiente` por una única opción `↔  Intercambiar con...`.
Al seleccionarla, aparece un submenú con todos los otros módulos de la misma
sección. El usuario elige con cuál intercambiar y las posiciones se
invierten al instante.

### Cambios en el código
- Nueva función `swap_with_seleccion()`: muestra el submenú de módulos
- Nueva función `swap_positions()`: intercambia dos módulos en la lista
- Se eliminó la función `move_mod()` (obsoleta)
- Se añadió la variable `L_MOD_SWAP` a los archivos de idioma

### Archivos afectados
- `config/themes/bin/polybar-modules.sh`
- `config/themes/lang/es.sh`
- `config/themes/lang/en.sh`

---

## 17. Theme Selector: Botón Cancelar no Funcionaba

### Problema
El botón "Cancelar" en el Selector de Temas (rofi-theme-selector.sh) no
cerraba la ventana GTK.

### Causa
En Python GTK3, al conectar `self.destroy` directamente como callback:
```python
btn.connect("clicked", self.destroy)
```
GTK pasa el widget (el botón) como primer argumento, efectivamente llamando
a `Gtk.Window.destroy(self, button)` que falla por argumento extra.

### Solución
Envolver `self.destroy` en un lambda que ignore el argumento:
```python
btn.connect("clicked", lambda w: self.destroy())
```

### Archivos afectados
- `config/themes/bin/rofi-theme-selector.sh`

---

## 18. i3/colors.conf: 9 temas con paleta incorrecta (Tokyo Night placeholder)

### Problema
Nueve temas tenían el archivo `i3/colors.conf` con los colores de **Tokyo Night**
en lugar de su propia paleta cromática. Esto ocurría porque al crear los temas
se copió la plantilla de Tokyo Night como base y nunca se actualizaron los
valores hexadecimales. El resultado era una **inconsistencia visual**: los
bordes de ventanas de i3 mostraban Tokyo Night mientras polybar, dunst y
alacritty sí tenían los colores correctos del tema.

### Temas afectados (colores incorrectos)
| Tema | Color i3 (erróneo) | Color polybar (correcto) |
|------|-------------------|-------------------------|
| catppuccin-latte | `#1a1b26` `#c0caf5` (Tokyo) | `#1e1e2e` `#cdd6f4` (Latte) |
| everforest | `#1a1b26` (Tokyo) | `#2d353b` `#d3c6aa` (Everforest) |
| flexoki-light | `#1a1b26` (Tokyo) | `#1c1c1c` `#dad8ce` (Flexoki) |
| rose-pine | `#1a1b26` (Tokyo) | `#232136` `#e0def4` (Rosé Pine) |
| osaka-jade | `#1a1b26` (Tokyo) | `#111c18` `#C1C497` (Osaka Jade) |
| kanagawa | `#1a1b26` (Tokyo) | `#1f1f28` `#dcd7ba` (Kanagawa) |
| matte-black | `#1a1b26` (Tokyo) | `#121212` `#bebebe` (Matte Black) |
| ristretto | `#1a1b26` (Tokyo) | `#2c2525` `#e6d9db` (Ristretto) |
| white | `#c0c0c0` (gris repetido) | `#1a1a24` `#cdd6e8` (White) |

### Temas con comentario incorrecto (colores correctos)
8 temas adicionales tenían los colores correctos pero el comentario `# Tokyo Night`
no se había actualizado al nombre real del tema: solitude, vantablack, retro-82,
hackerman, ethereal, last-horizon, lumon, miasma.

### Solución
Se regeneró `i3/colors.conf` para los 9 temas con colores incorrectos
extrayendo los valores desde `polybar/colors.ini` (que sí tenía la paleta
correcta) y mapeándolos a las variables de i3 (`$bg`, `$fg`, `$primary`, etc.).
Para los 8 temas con solo comentario erróneo, se corrigió únicamente la
primera línea.

La regla de mapeo es: cada valor de i3 debe coincidir con su equivalente en
polybar (bg↔background, fg↔foreground, primary↔primary, alert↔alert, etc.)
para garantizar coherencia visual entre bordes de ventana y barra.

### Verificación
Se añadieron tres nuevas comprobaciones a `verify-themes.sh`:
1. Verificación de cabecera: detecta comentarios "Tokyo Night" en temas que no lo son
2. Validación cruzada i3↔polybar: compara bg, fg, primary, alert entre ambos archivos
3. Sanidad de contraste: alerta si `$fg` == `$bg-alt` (texto invisible)

### Archivos afectados
- 17 archivos `config/themes/themes/*/i3/colors.conf`
- `config/themes/bin/verify-themes.sh`

---

## 19. apply-polybar.sh: rutas absolutas hardcodeadas

### Problema
El script `apply-polybar.sh` contenía rutas absolutas al directorio del repo:
```bash
REPO_LAYOUTS="/home/oxido/Documentos/oxido-i3-themes/config/polybar/layouts"
```
Si el repositorio se movía de ubicación, el script dejaba de sincronizar
layouts y scripts de polybar.

### Solución
Se reemplazaron las rutas absolutas por detección dinámica desde la ubicación
del script:
```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
```
Esto permite que el script funcione sin importar dónde esté clonado el repo.

### Fallback seguro para polybar sin barras
Además, se detectó que cuando no existía ni layout guardado ni `config.ini`
en el tema, se copiaba `colors.ini` (solo sección `[colors]`) como único
contenido — dejando a polybar sin definiciones de barras y provocando que
no arrancara.

Se añadió un bloque que inyecta una barra `[bar/top]` mínima funcional con
módulos esenciales si el archivo resultante no contiene ninguna sección `[bar/`.

### Archivos afectados
- `config/themes/applyers/apply-polybar.sh`

---

## 20. Transparencia del fondo de polybar (alpha 33 → 99)

### Problema
El script `apply-polybar.sh` forzaba `alpha=33` (20% opacidad = 80% transparente)
en el color `background` de la sección `[colors]` de polybar. Esto hacía que el
fondo de la barra (los espacios entre burbujas y las cuñas `ws-start/end`)
fuera casi invisible contra el escritorio.

Las burbujas en sí no se veían afectadas porque usan colores propios
(`bubble-ws`, `bubble-center`, `bubble-sys`) sin canal alpha.

### Solución
Se cambió el alpha de `33` a `99` (~60% opacidad = 40% transparente). Esto
permite que el fondo de la barra sea visible y mantenga coherencia cromática
con el tema, mientras las burbujas conservan su color sólido original.

El cambio está en la línea que inyecta el alpha en `apply-polybar.sh`:
```bash
sed -i "s/^background *=.*/background = ${base_color}99/"
```

### Archivos afectados
- `config/themes/applyers/apply-polybar.sh`
- `~/.config/polybar/config.ini` (configuración activa del sistema)

---

## 29. rofi-layout-selector: faltaba botón Volver

### Problema
El selector de layouts (`rofi-layout-selector.sh`) no tenía opción de retroceder.
Al abrirlo desde Apariencia → Diseño Polybar, el usuario no podía volver al menú
anterior — solo quedaba seleccionar un layout o presionar Escape.

### Causa
El script construía la lista de items solo con los nombres de layouts, sin
incluir `$L_BACK`. No había manejo de "Volver".

### Solución
Agregar `items+="$L_BACK\n"` después de enumerar los layouts, y detectar la
selección con `[[ "$chosen" == *"$L_BACK"* ]] && exit 0`. Como `appearance.sh`
lo llama sin `exec` (línea 44: `~/.config/themes/bin/rofi-layout-selector.sh`),
al salir retorna naturalmente al menú de Apariencia.

### Archivos afectados
- `config/themes/bin/rofi-layout-selector.sh`

---

## 30. default-apps: listas hardcodeadas → detección dinámica

### Problema
El submenú de Aplicaciones Predeterminadas (`default-apps.sh`) mostraba listas
fijas de aplicaciones para cada rol: terminal, navegador, gestor de archivos.
Firefox aparecía aunque el usuario usara Brave, Alacritty aunque usara Kitty.

El proyecto es multi-distribución, así que una lista fija no podía cubrir
todas las variantes de nombres de paquetes (ej. `firefox-esr` en Debian,
`google-chrome-stable` en Fedora, `brave-browser` en algunos repos).

### Solución
Reemplazar las listas hardcodeadas por detección dinámica con `command -v`:
- Se define un array amplio de `known_apps` para cada rol (terminal, browser,
  file_manager, terminal_fm) con TODAS las variantes de nombres conocidas
  a través de distintas distribuciones.
- Para cada app conocida, se verifica `command -v <app>` — si está instalada,
  se agrega a las opciones del menú.
- La app actual (guardada en `defaults.conf`) aparece primero con `(actual)`.
- Si no hay apps detectadas, se muestra directamente "✏️  Otra...".
- El sufijo `(actual)` se elimina con `sed` antes de guardar.

Esto funciona en cualquier distro: Debian, Arch, Fedora, NixOS, etc. porque
`command -v` verifica el PATH del usuario, que es donde residen los binarios
instalados por el gestor de paquetes nativo.

### Listas de detección
| Rol | Apps buscadas |
|-----|--------------|
| terminal | alacritty, kitty, wezterm, foot, gnome-terminal, konsole, xterm, urxvt, st, termite, blackbox, tilix, sakura, lxterminal, qterminal, ptyxis, kgx, deepin-terminal, warp-terminal |
| browser | firefox, firefox-esr, brave, brave-browser, google-chrome, google-chrome-stable, chromium, chromium-browser, vivaldi, vivaldi-stable, microsoft-edge, microsoft-edge-stable, librewolf, zen-browser, tor-browser, tor-browser-en, opera, waterfox, waterfox-classic, palemoon, falkon, epiphany, midori, nyxt |
| file_manager | nemo, thunar, nautilus, pcmanfm, pcmanfm-qt, dolphin, caja, doublecmd, doublecmd-qt, krusader, spacefm, xfe |
| terminal_fm | ranger, lf, nnn, vifm, mc, yazi, xplr, broot, joshuto, fm, clifm |

### Archivos afectados
- `config/themes/scripts/settings/default-apps.sh`

---

## 31. toggle-powersaver: desactivación no restauraba el tema original

### Problema
Al activar el modo ahorro (`mod+Shift+p`), el script:
1. Cambiaba el symlink `current/theme` a `dracula-powersaver`
2. Copiaba configs de polybar, i3, dunst, rofi
3. Mataba picom y conky

Al desactivar, solo:
1. Borraba el flag `/tmp/powersaver_active`
2. Reiniciaba picom, conky y polybar

Pero **no restauraba el symlink ni las configs originales**. El polybar seguía
usando los colores de dracula-powersaver, i3 y dunst también. El único cambio
visible era que picom volvía a funcionar.

### Solución
1. **Al activar**: antes de cambiar el symlink, guardar el nombre del tema
   original en `/tmp/powersaver_prev_theme`:
   ```bash
   ORIG_THEME_DIR=$(readlink -f "$CURRENT_LINK")
   basename "$ORIG_THEME_DIR" > /tmp/powersaver_prev_theme
   ```

2. **Al desactivar**: si existe el archivo de tema previo, ejecutar
   `theme-switch.sh <nombre>` que restaura el symlink, corre todos los
   applyers (polybar, i3, dunst, rofi, picom, conky, wallpaper, etc.) y
   notifica el cambio:
   ```bash
   bash "$HOME/.config/themes/bin/theme-switch.sh" "$ORIG_THEME"
   ```

### Archivos afectados
- `config/themes/scripts/toggle-powersaver.sh`

---

## 32. polybar-modules: opciones en blanco que actuaban como "volver"

### Problema
El gestor de módulos (`polybar-modules.sh`) y sus submenús tenían líneas en
blanco seleccionables. En rofi, los `\n\n` consecutivos en la cadena de items
crean una entrada vacía en el menú que el usuario puede seleccionar. Al
pincharla, el script la interpretaba como selección vacía y ejecutaba `exit 0`
o `return`, lo que se sentía como un "volver" fantasma.

Causas puntuales:
- Menú principal (línea 412): `\n\n` entre `$s_hidden` y `$s_restore` creaba
  línea en blanco → seleccionable → `exit 0`
- `seccion_menu` (línea 180): `\n` al inicio de `items+="\n${L_MOD_REORDER}..."`
  después de que items ya terminaba en `\n`, creando `\n\n` → `return`
- `mostrar_ocultos` (línea 158): mismo patrón con `\n${L_MOD_BACK}`
- `swap_with_seleccion` (línea 329): mismo patrón con `\n${L_MOD_BACK}`
- `restaurar_default` (línea 127): `\n\n` entre pregunta y opciones

### Solución
Reemplazar todos los `\n\n` y `\n` duplicados por `───\n` (separador visual
con línea de em dash). Rofi renderiza `───` como un elemento visible, no
seleccionable como opción de menú (aunque se puede seleccionar, no coincide
con ningún case, por lo que el script lo ignora y continúa).

### Archivos afectados
- `config/themes/bin/polybar-modules.sh`

---

## 33. default-apps: saltos de línea literales en lugar de reales

### Problema
El menú de aplicaciones predeterminadas (`default-apps.sh`) mostraba los items
con `\n` literal en vez de separarlos en líneas distintas. Ej: se veía
"alacritty\nkitty\n..." en lugar de cada app en su propia línea.

### Causa
En la función `pick_app()`, las opciones se construían con:
```bash
choices+="$app\n"
```
Dentro de comillas dobles en bash, `\n` es literal (backslash + n), no un
salto de línea real. Al pasar `choices` a `printf "%s"` para el menú rofi,
se mostraba el texto literal.

### Solución
Reemplazar `choices+="$app\n"` por `choices+="$app"$'\n'` en las 5 ocurrencias
de `pick_app()`. El `$'\n'` de bash genera un salto de línea real (LF, 0x0A).

### Archivos afectados
- `config/themes/scripts/settings/default-apps.sh`

---

## 34. rofi-drun: prompt "drun" no logra cambiarse (investigación)

### Problema
El lanzador `mod+d` (`rofi-drun.sh`) muestra "drun" en el prompt en vez de
"🔍  Apps". El archivo actual tiene:
```bash
rofi -show drun -show-icons -p "🔍  Apps" -location 0 -monitor -1 -theme-str "$ROFI_THEME_MAIN"
```

Pero el prompt sigue mostrando "drun:" porque `$ROFI_THEME_MAIN` define
`inputbar { children: [ prompt, entry ]; }` y el widget `prompt` de rofi
muestra el prompt interno del modo drun ("drun:"), ignorando el flag `-p`.

### Intentos fallidos
1. **`-p "🔍  Apps"`**: ignorado — el widget `prompt` en `$ROFI_THEME_MAIN`
   muestra el prompt interno del modo, no el del flag
2. **`textbox-prompt-colon { text: "🔍  Apps" }`**: ignorado — drun mode
   re-aplica su prompt después de aplicar el theme de `-theme-str`
3. **`-modi "drun:🔗  Apps"`**: rompe — rofi interpreta el espacio como
   comando personalizado: "Failed to execute: ' Apps'"
4. **`-no-config` + tema standalone**: funcionaba técnicamente pero cambiaba
   drásticamente el diseño visual (perdía el merge con `config.rasi`) y el
   usuario reportó truncamiento "Br..." y diseño incorrecto

### Estado actual
Revertido al estado anterior (`-p "🔍  Apps"` removido, usa `$ROFI_THEME_MAIN`
directamente). El prompt muestra "drun:" y NO se logró cambiar.

### Conclusión técnica
Rofi (v1.7.5) no permite cambiar el prompt del modo drun vía `-p` ni
`textbox-prompt-colon` cuando el theme define `inputbar { children: [ prompt, entry ] }`. La única forma viable (`-no-config` + tema standalone) requiere
reescribir completamente el `config.rasi` del usuario para conservar el
diseño visual.

**Pendiente:** Decidir si se reescribe `config.rasi` para integrar el tema
standalone de drun, o se acepta que el prompt muestre "drun:".

### Archivos afectados
- `config/themes/bin/rofi-drun.sh` (sin cambios funcionales netos)
