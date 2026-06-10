#!/bin/bash
# 🌐  Wallpaper Downloader — via Pexels API
# oxido-i3-themes — descarga wallpapers de libre acceso con colores acordes a cada tema

REPO_DIR="$(cd "$(dirname "$0")"/../../.. && pwd)"
THEMES_DIR="$REPO_DIR/config/themes/themes"
SYS_DIR="$HOME/.config/themes/themes"
TARGET=5

CONFIG_FILE="$HOME/.config/themes/wallpaper-api.env"
API_KEY="${1:-}"
[ -z "$API_KEY" ] && [ -f "$CONFIG_FILE" ] && API_KEY=$(grep "^PEXELS_API_KEY=" "$CONFIG_FILE" | cut -d= -f2- | tr -d '"' | tr -d "'")
[ -z "$API_KEY" ] && {
    echo "Uso: $0 <pexels-api-key>"
    echo "  O crea $CONFIG_FILE con: PEXELS_API_KEY=\"tu_key\""
    exit 1
}

# Cada entrada: "query|color_hex|alt_query"
# color_hex es el color dominante que queremos (primary/accent del tema)
# Pexels acepta colores por nombre o hex
declare -A QUERIES
QUERIES["catppuccin-latte"]="warm pastel gradient|#1e66f5|soft light abstract"
QUERIES["catppuccin-mocha"]="dark warm moody|#89b4fa|cozy comfortable dark"
QUERIES["dracula-powersaver"]="dark night purple sky|#7a7ab0|deep space stars"
QUERIES["ethereal"]="deep space nebula cosmic|#7d82d9|galaxy purple blue stars"
QUERIES["everforest"]="green forest nature sunlight|#7fbbb3|moss woodland trees"
QUERIES["flexoki-light"]="warm dark moody abstract|#205EA6|atmospheric dark landscape"
QUERIES["hackerman"]="cyberpunk neon dark green|#82FB9C|futuristic tech grid"
QUERIES["kanagawa"]="japan ocean wave night|#7e9cd8|japanese seascape twilight"
QUERIES["last-horizon"]="futuristic dark landscape horizon|#b59790|sci-fi desert dystopian"
QUERIES["lumon"]="minimalist architecture blue|#8bc9eb|modern building clean design"
QUERIES["matte-black"]="dark black texture abstract moody|#e68e0d|night city amber lights"
QUERIES["miasma"]="dark atmospheric fog forest|#78824b|misty moody woodland"
QUERIES["nord"]="arctic mountain snow blue frost|#81a1c1|ice winter landscape"
QUERIES["osaka-jade"]="tokyo neon night green|#509475|japan city rain street"
QUERIES["ristretto"]="dark coffee cozy warm|#f38d70|coffee beans roastery"
QUERIES["rose-pine"]="dark rose pink moody floral|#56949f|roses dark garden vintage"
QUERIES["vantablack"]="black abstract monochrome texture|#8d8d8d|minimal dark grayscale"
QUERIES["white"]="minimal white snow clean bright|#6c9be8|frost ice winter abstract"

# Temas que ya están completos (>5) pero queremos mejorar calidad
# Se procesarán si tienen menos de TARGET imagenes relevantes
SKIP_THEMES="dracula gruvbox retro-82 solitude tokyo-night"

total_downloaded=0

for theme in "${!QUERIES[@]}"; do
    # Saltar temas que no necesitan más wallpapers
    echo "$SKIP_THEMES" | grep -qw "$theme" && {
        echo "=== $theme: saltado (ya completo) ==="
        continue
    }

    bg_dir="$THEMES_DIR/$theme/backgrounds"
    sys_bg_dir="$SYS_DIR/$theme/backgrounds"
    mkdir -p "$bg_dir"

    existing=0
    for f in "$bg_dir"/*.{jpg,png,jpeg,webp,bmp}; do
        [ -f "$f" ] && existing=$((existing + 1))
    done 2>/dev/null

    need=$((TARGET - existing))
    [ "$need" -le 0 ] && continue

    echo "=== $theme: $existing existentes, necesito $need más ==="

    IFS='|' read -r query color alt_query <<< "${QUERIES[$theme]}"
    per_page=$need
    [ "$per_page" -gt 80 ] && per_page=80

    # Construir URL con color filter
    url="https://api.pexels.com/v1/search?query=$(echo "$query" | sed 's/ /+/g')&per_page=$per_page&orientation=landscape&color=$(echo "$color" | sed 's/#/%23/g')"

    response=$(curl -s -H "Authorization: $API_KEY" "$url")

    total_results=$(echo "$response" | python3 -c "import sys,json; print(json.load(sys.stdin).get('total_results',0))" 2>/dev/null)

    # Si no hay resultados con color, reintentar sin color
    if [ "$total_results" -eq 0 ]; then
        echo "  Sin resultados con color $color, reintentando sin filtro..."
        url="https://api.pexels.com/v1/search?query=$(echo "$query" | sed 's/ /+/g')&per_page=$per_page&orientation=landscape"
        response=$(curl -s -H "Authorization: $API_KEY" "$url")
        total_results=$(echo "$response" | python3 -c "import sys,json; print(json.load(sys.stdin).get('total_results',0))" 2>/dev/null)
    fi

    # Si aún no hay resultados, probar alt_query
    if [ "$total_results" -eq 0 ] && [ -n "$alt_query" ]; then
        echo "  Sin resultados para '$query', probando '$alt_query'..."
        url="https://api.pexels.com/v1/search?query=$(echo "$alt_query" | sed 's/ /+/g')&per_page=$per_page&orientation=landscape"
        response=$(curl -s -H "Authorization: $API_KEY" "$url")
        total_results=$(echo "$response" | python3 -c "import sys,json; print(json.load(sys.stdin).get('total_results',0))" 2>/dev/null)
    fi

    [ "$total_results" -eq 0 ] && {
        echo "  Sin resultados para '$theme'"
        sleep 1
        continue
    }

    next_num=0
    while ls "$bg_dir/$next_num-"*.* &>/dev/null 2>/dev/null; do
        next_num=$((next_num + 1))
    done

    for i in $(seq 0 $((per_page - 1))); do
        downloaded=$((existing + i))
        [ "$downloaded" -ge "$TARGET" ] && break

        photo_data=$(echo "$response" | python3 -c "
import sys, json
d = json.load(sys.stdin)
photos = d.get('photos', [])
if $i < len(photos):
    p = photos[$i]
    print(p['id'], p['src']['original'])
" 2>/dev/null)

        [ -z "$photo_data" ] && continue

        read -r pid url <<< "$photo_data"

        ext="${url##*.}"
        ext=$(echo "$ext" | cut -d? -f1 | tr -d ' ')
        [ -z "$ext" ] && ext="jpg"

        filename="${next_num}-${pid}.${ext}"
        filename=$(echo "$filename" | tr -d '[:space:]')

        [ -f "$bg_dir/$filename" ] && {
            echo "  Ya existe: $filename"
            next_num=$((next_num + 1))
            continue
        }

        echo "  [$theme] Descargando: $filename"
        curl -sL -o "$bg_dir/$filename" "$url" && {
            [ -d "$sys_bg_dir" ] && cp "$bg_dir/$filename" "$sys_bg_dir/"
            total_downloaded=$((total_downloaded + 1))
            next_num=$((next_num + 1))
            sleep 0.3
        } || {
            echo "  Error descargando $url"
            rm -f "$bg_dir/$filename"
        }
    done

    sleep 0.5
done

echo ""
echo "✅ Descarga completa: $total_downloaded wallpapers nuevos"

rm -rf ~/.cache/wallpaper-thumbs 2>/dev/null || true
echo "✅ Caché de thumbnails regenerada"
