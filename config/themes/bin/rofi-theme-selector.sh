#!/bin/bash
# 🎨  Theme Selector — split panel: lista + preview grande
# Usa Python GTK3 (no requiere yad ni otras dependencias)

THEMES_DIR=~/.config/themes/themes
CURRENT_THEME=$(basename "$(readlink ~/.config/themes/current/theme)" 2>/dev/null)
CACHE_DIR=~/.cache/theme-thumbs
PREVIEW_SIZE="480x270"

mkdir -p "$CACHE_DIR"

read_wallpaper() {
    local wall_file="$1/backgrounds/wallpaper"
    [ -f "$wall_file" ] && cat "$wall_file" && return
    ls "$1/backgrounds/"*.* 2>/dev/null | head -1
}

# Regenerate thumbnails if needed (larger for the new UI)
for theme in "$THEMES_DIR"/*/; do
    name=$(basename "$theme")
    thumb="$CACHE_DIR/$name.png"
    src=""
    if [ -f "$theme/preview.png" ]; then
        src="$theme/preview.png"
    elif [ -f "$theme/preview-unlock.png" ]; then
        src="$theme/preview-unlock.png"
    elif [ -f "$theme/unlock.png" ]; then
        src="$theme/unlock.png"
    else
        wp=$(read_wallpaper "$theme")
        [ -n "$wp" ] && src="$wp"
    fi
    if [ -f "$thumb" ] && [ "$src" -nt "$thumb" ] 2>/dev/null; then
        rm -f "$thumb"
    fi
    if [ ! -f "$thumb" ] && [ -n "$src" ]; then
        convert "$src" -resize "${PREVIEW_SIZE}^" -gravity center -extent "$PREVIEW_SIZE" -quality 92 "$thumb" 2>/dev/null
    fi
    if [ ! -f "$thumb" ]; then
        bg=$(grep "^bg_color=" "$theme/polybar/colors.ini" 2>/dev/null | cut -d= -f2 | tr -d ' "')
        fg=$(grep "^fg_color=" "$theme/polybar/colors.ini" 2>/dev/null | cut -d= -f2 | tr -d ' "')
        [ -z "$bg" ] && bg="#1e1e2e"
        [ -z "$fg" ] && fg="#cdd6f4"
        convert -size "$PREVIEW_SIZE" "xc:$bg" -fill "$fg" -gravity center -pointsize 28 -annotate 0 "$name" "$thumb" 2>/dev/null
    fi
done

export THEMES_DIR CACHE_DIR CURRENT_THEME

python3 << 'PYEOF'
import os, sys, json

THEMES_DIR = os.path.expanduser(os.environ['THEMES_DIR'])
CACHE_DIR = os.path.expanduser(os.environ['CACHE_DIR'])
CURRENT_THEME = os.environ.get('CURRENT_THEME', '')

try:
    import gi
    gi.require_version('Gtk', '3.0')
    gi.require_version('GdkPixbuf', '2.0')
    from gi.repository import Gtk, GdkPixbuf, Gdk, GLib, Pango
except ImportError as e:
    print(f"Error: Python GTK3 no disponible ({e})", file=sys.stderr)
    sys.exit(1)

theme_dirs = sorted([d for d in os.listdir(THEMES_DIR)
    if os.path.isdir(os.path.join(THEMES_DIR, d))])

class ThemeSelector(Gtk.Window):
    def __init__(self):
        super().__init__(title="🎨  Theme Selector")
        self.set_default_size(920, 540)
        self.set_border_width(12)
        self.set_position(Gtk.WindowPosition.CENTER)
        self.set_wmclass("theme-selector", "ThemeSelector")
        self.connect("destroy", Gtk.main_quit)
        self.connect("key-press-event", self.on_key_press)

        css = b"""
        window { background-color: #1e1e2e; }
        list { background-color: #181825; }
        list row { padding: 6px 10px; background-color: #181825; color: #cdd6f4; }
        list row:selected { background-color: #89b4fa; color: #1e1e2e; }
        list row:hover { background-color: #313244; }
        button { background-color: #313244; color: #cdd6f4; border-radius: 8px; padding: 8px 20px; border: none; font-size: 11pt; }
        button:hover { background-color: #89b4fa; color: #1e1e2e; }
        label { color: #cdd6f4; }
        """
        provider = Gtk.CssProvider()
        provider.load_from_data(css)
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(), provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)

        # Main box: horizontal split
        hbox = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=12)

        # ─── Left: theme list ───
        left_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        left_box.set_size_request(260, -1)

        lbl_list = Gtk.Label(label="<b>Temas</b>")
        lbl_list.set_use_markup(True)
        lbl_list.set_xalign(0)
        left_box.pack_start(lbl_list, False, False, 0)

        sw = Gtk.ScrolledWindow()
        sw.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        sw.set_min_content_height(400)

        self.liststore = Gtk.ListStore(str, str)  # display_name, theme_name
        self.liststore.set_sort_column_id(0, Gtk.SortType.ASCENDING)

        for t in theme_dirs:
            display = t
            if t == CURRENT_THEME:
                display = f"▶ {t}"
            self.liststore.append([display, t])

        self.treeview = Gtk.TreeView(model=self.liststore)
        self.treeview.set_headers_visible(False)

        renderer = Gtk.CellRendererText()
        renderer.set_property("font", "FiraCode Nerd Font 10")
        col = Gtk.TreeViewColumn("Theme", renderer, text=0)
        col.set_expand(True)
        self.treeview.append_column(col)

        self.treeview.connect("cursor-changed", self.on_selection_changed)
        self.treeview.connect("row-activated", self.on_row_activated)

        sw.add(self.treeview)
        left_box.pack_start(sw, True, True, 0)

        # Select current theme in list
        for i, row in enumerate(self.liststore):
            if row[1] == CURRENT_THEME:
                self.treeview.set_cursor(Gtk.TreePath(i))
                break

        hbox.pack_start(left_box, False, False, 0)

        # ─── Right: preview ───
        right_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)

        lbl_preview = Gtk.Label(label="<b>Vista previa</b>")
        lbl_preview.set_use_markup(True)
        lbl_preview.set_xalign(0)
        right_box.pack_start(lbl_preview, False, False, 0)

        preview_holder = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        preview_holder.set_size_request(600, -1)

        self.preview_image = Gtk.Image()
        self.preview_image.set_size_request(600, 338)
        self.preview_image.set_halign(Gtk.Align.CENTER)
        self.preview_image.set_valign(Gtk.Align.CENTER)
        preview_holder.pack_start(self.preview_image, True, True, 0)

        self.lbl_theme_name = Gtk.Label(label="")
        self.lbl_theme_name.set_use_markup(True)
        preview_holder.pack_start(self.lbl_theme_name, False, False, 4)

        right_box.pack_start(preview_holder, True, True, 0)

        # Buttons
        btn_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        btn_box.set_halign(Gtk.Align.END)

        cancel_btn = Gtk.Button(label="Cancelar")
        cancel_btn.connect("clicked", lambda w: self.destroy())
        btn_box.pack_end(cancel_btn, False, False, 0)

        apply_btn = Gtk.Button(label="Aplicar tema")
        apply_btn.get_style_context().add_class("suggested-action")
        apply_btn.connect("clicked", self.on_apply)
        btn_box.pack_end(apply_btn, False, False, 0)

        right_box.pack_end(btn_box, False, False, 0)
        hbox.pack_start(right_box, True, True, 0)

        self.add(hbox)
        self.selected_theme = CURRENT_THEME

        # Show initial preview
        self.update_preview()

    def get_selected_theme(self):
        selection = self.treeview.get_selection()
        model, treeiter = selection.get_selected()
        if treeiter is not None:
            return model[treeiter][1]
        return None

    def on_selection_changed(self, treeview):
        self.update_preview()

    def update_preview(self):
        theme = self.get_selected_theme()
        if not theme:
            return
        self.selected_theme = theme

        thumb_path = os.path.join(CACHE_DIR, f"{theme}.png")
        if os.path.exists(thumb_path):
            try:
                pixbuf = GdkPixbuf.Pixbuf.new_from_file_at_scale(
                    thumb_path, 600, 338, True)
                self.preview_image.set_from_pixbuf(pixbuf)
            except Exception:
                self.preview_image.set_from_icon_name(
                    "image-x-generic", Gtk.IconSize.DIALOG)
        else:
            self.preview_image.set_from_icon_name(
                "image-x-generic", Gtk.IconSize.DIALOG)

        is_current = theme == CURRENT_THEME
        status = " <span foreground='#a6e3a1'>● Activo</span>" if is_current else ""
        self.lbl_theme_name.set_markup(
            f"<b>{theme}</b>{status}")

    def on_row_activated(self, treeview, path, column):
        self.apply_theme()

    def on_apply(self, button):
        self.apply_theme()

    def apply_theme(self):
        theme = self.selected_theme
        if theme and theme != CURRENT_THEME:
            os.system(f"~/.config/themes/bin/theme-switch.sh '{theme}' &")
        self.destroy()

    def on_key_press(self, widget, event):
        if event.keyval == Gdk.KEY_Escape:
            self.destroy()
        return False

win = ThemeSelector()
win.show_all()
Gtk.main()
PYEOF
