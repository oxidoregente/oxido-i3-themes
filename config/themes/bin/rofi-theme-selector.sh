#!/bin/bash
# 🎨  Theme Selector — split panel: lista + preview grande
# Usa Python GTK3 (no requiere yad ni otras dependencias)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$SCRIPT_DIR/../scripts/core.sh" ] && source "$SCRIPT_DIR/../scripts/core.sh"
[ -f "$SCRIPT_DIR/core.sh" ] && source "$SCRIPT_DIR/core.sh"

CURRENT_THEME=$(basename "$(readlink $THEMES_ROOT/current/theme)" 2>/dev/null)
CACHE_DIR=~/.cache/theme-thumbs
PREVIEW_SIZE="640x360"

mkdir -p "$CACHE_DIR"

# Cargar builder para colores e idioma
[ -f "$SCRIPT_DIR/../scripts/rofi-builder.sh" ] && source "$SCRIPT_DIR/../scripts/rofi-builder.sh"

THEMES_DIR="$THEMES_ROOT/themes"

read_wallpaper() {
    local wall_file="$1/backgrounds/wallpaper"
    [ -f "$wall_file" ] && cat "$wall_file" && return
    ls "$1/backgrounds/"*.* 2>/dev/null | head -1
}

# Regenerate thumbnails if needed
for theme in "$THEMES_DIR"/*/; do
    [ ! -d "$theme" ] && continue
    name=$(basename "$theme")
    thumb="$CACHE_DIR/$name.png"
    src=""
    if [ -f "$theme/preview.png" ]; then
        src="$theme/preview.png"
    elif [ -f "$theme/unlock.png" ]; then
        src="$theme/unlock.png"
    else
        wp=$(read_wallpaper "$theme")
        [ -n "$wp" ] && src="$wp"
    fi
    if [ ! -f "$thumb" ] && [ -n "$src" ]; then
        convert "$src" -resize "${PREVIEW_SIZE}^" -gravity center -extent "$PREVIEW_SIZE" -quality 92 "$thumb" 2>/dev/null
    fi
done

export THEMES_DIR CACHE_DIR CURRENT_THEME SEL BG BGA FG
export L_SELECT L_CANCEL L_RANDOM L_ACT_THEME L_CUR_THEME

python3 << 'PYEOF'
import os, sys, json
try:
    import gi
    gi.require_version('Gtk', '3.0')
    from gi.repository import Gtk, GdkPixbuf, Gdk
except Exception as e:
    print(f"Error loading GTK: {e}")
    sys.exit(1)

THEMES_DIR = os.path.expanduser(os.environ.get('THEMES_DIR', '~/.config/themes/themes'))
CACHE_DIR = os.path.expanduser(os.environ.get('CACHE_DIR', '~/.cache/theme-thumbs'))
CURRENT_THEME = os.environ.get('CURRENT_THEME', '')
SEL = os.environ.get('SEL', '#89b4fa')
BG = os.environ.get('BG', '#1e1e2e')
BGA = os.environ.get('BGA', '#313244')
FG = os.environ.get('FG', '#cdd6f4')

L_SELECT = os.environ.get('L_SELECT', 'Select')
L_CANCEL = os.environ.get('L_CANCEL', 'Cancel')
L_RANDOM = os.environ.get('L_RANDOM', 'Random')
L_ACT_THEME = os.environ.get('L_ACT_THEME', 'Active')
L_CUR_THEME = os.environ.get('L_CUR_THEME', 'Themes')

theme_dirs = sorted([d for d in os.listdir(THEMES_DIR) if os.path.isdir(os.path.join(THEMES_DIR, d))]) if os.path.exists(THEMES_DIR) else []

class ThemeSelector(Gtk.Window):
    def __init__(self):
        super().__init__(title="🎨 " + L_CUR_THEME)
        self.set_wmclass("ThemeSelector", "ThemeSelector")
        self.set_default_size(1024, 640)
        self.set_border_width(15)
        self.set_position(Gtk.WindowPosition.CENTER)
        self.connect("destroy", Gtk.main_quit)
        self.connect("key-press-event", self.on_key_press)
        self._current_preview_theme = None
        self._preview_width = 0
        self._preview_height = 0

        css = f"""
        window {{ background-color: {BG}; border: 2px solid {SEL}; border-radius: 20px; }}
        list {{ background-color: {BGA}; border-radius: 12px; }}
        list row {{ padding: 10px 15px; color: {FG}; font-size: 12pt; }}
        list row:selected {{ background-color: {SEL}; color: {BG}; border-radius: 10px; }}
        button {{ background-color: {BGA}; color: {FG}; border-radius: 12px; padding: 10px 25px; border: 0; font-size: 12pt; font-weight: bold; }}
        button:hover {{ background-color: {SEL}; color: {BG}; }}
        label {{ color: {FG}; font-size: 14pt; }}
        scrolledwindow {{ border-radius: 12px; }}
        """.encode()
        
        provider = Gtk.CssProvider()
        provider.load_from_data(css)
        Gtk.StyleContext.add_provider_for_screen(Gdk.Screen.get_default(), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)

        hbox = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=20)
        
        # Left Panel
        left_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        left_box.set_size_request(300, -1)
        lbl_list = Gtk.Label(label=f"<b>{L_CUR_THEME}</b>", use_markup=True, xalign=0)
        left_box.pack_start(lbl_list, False, False, 0)

        self.liststore = Gtk.ListStore(str, str)
        self.liststore.append(["🎲 " + L_RANDOM, "__random__"])
        for t in theme_dirs:
            display = "▶ " + t if t == CURRENT_THEME else t
            self.liststore.append([display, t])

        self.treeview = Gtk.TreeView(model=self.liststore, headers_visible=False)
        self.treeview.append_column(Gtk.TreeViewColumn("", Gtk.CellRendererText(font="JetBrainsMono NF 11"), text=0))
        self.treeview.connect("cursor-changed", lambda w: self.update_preview())
        
        sw = Gtk.ScrolledWindow()
        sw.add(self.treeview)
        left_box.pack_start(sw, True, True, 0)
        hbox.pack_start(left_box, False, False, 0)

        # Right Panel
        right_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=15)
        self.preview_image = Gtk.Image()
        right_box.pack_start(self.preview_image, True, True, 0)
        right_box.connect("size-allocate", self.on_right_resize)

        self.lbl_info = Gtk.Label(label="", use_markup=True)
        right_box.pack_start(self.lbl_info, False, False, 0)

        btn_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        btn_box.set_halign(Gtk.Align.END)
        for label, callback in [(L_CANCEL, lambda w: self.destroy()), (L_RANDOM, self.on_random), (L_SELECT, self.on_apply)]:
            btn = Gtk.Button(label=label)
            btn.connect("clicked", callback if callable(callback) else lambda w: callback())
            btn_box.pack_start(btn, False, False, 0)
        
        right_box.pack_end(btn_box, False, False, 0)
        hbox.pack_start(right_box, True, True, 0)

        self.add(hbox)
        self.show_all()
        self.update_preview()

    def on_right_resize(self, widget, allocation):
        new_w = max(200, allocation.width - 20)
        new_h = max(112, int(new_w * 9 / 16))
        if new_w != self._preview_width or new_h != self._preview_height:
            self._preview_width = new_w
            self._preview_height = new_h
            self._current_preview_theme = None  # force refresh
            self.update_preview()

    def update_preview(self):
        selection = self.treeview.get_selection()
        model, treeiter = selection.get_selected()
        if treeiter:
            theme = model[treeiter][1]
            if theme == "__random__":
                self.preview_image.set_from_icon_name("media-playlist-shuffle", Gtk.IconSize.DIALOG)
                self.lbl_info.set_markup(f"<b>{L_RANDOM}</b>")
            elif theme != self._current_preview_theme or self._preview_width == 0:
                thumb = os.path.join(CACHE_DIR, f"{theme}.png")
                if os.path.exists(thumb) and self._preview_width > 0:
                    w = self._preview_width
                    h = self._preview_height or int(w * 9 / 16)
                    self.preview_image.set_from_pixbuf(
                        GdkPixbuf.Pixbuf.new_from_file_at_scale(thumb, w, h, True)
                    )
                status = f" <span foreground='#a6e3a1'>● {L_ACT_THEME}</span>" if theme == CURRENT_THEME else ""
                self.lbl_info.set_markup(f"<b>{theme}</b>{status}")
                self._current_preview_theme = theme

    def on_key_press(self, widget, event):
        if event.keyval == 65293:  # Enter/Return
            self.on_apply(None)
            return True
        elif event.keyval == 65307:  # Escape
            self.destroy()
            return True
        return False

    def on_apply(self, btn):
        model, treeiter = self.treeview.get_selection().get_selected()
        if treeiter:
            theme = model[treeiter][1]
            if theme == "__random__":
                import random
                theme = random.choice([t for t in theme_dirs])
            os.system(f"~/.config/themes/bin/theme-switch.sh '{theme}' &")
            self.destroy()

    def on_random(self, btn):
        import random
        if not theme_dirs: return
        theme = random.choice(theme_dirs)
        for i, row in enumerate(self.liststore):
            if row[1] == theme:
                self.treeview.set_cursor(Gtk.TreePath(i))
                self.treeview.scroll_to_cell(Gtk.TreePath(i), None, True, 0.5, 0.5)
                break

ThemeSelector()
Gtk.main()
PYEOF
