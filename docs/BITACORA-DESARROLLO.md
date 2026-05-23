# 📓 Bitácora de Desarrollo

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
