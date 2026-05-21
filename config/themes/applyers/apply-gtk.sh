#!/bin/bash
THEME_DIR="$1"
GTK_CFG="$THEME_DIR/gtk/theme.cfg"
GTK_CSS="$THEME_DIR/gtk/gtk.css"

DEFAULT_GTK_THEME="Orchis-Dark"
DEFAULT_ICON_THEME="ePapirus-Dark"

if [ -f "$GTK_CFG" ]; then
    source "$GTK_CFG"
fi

GTK_THEME="${gtk_theme:-$DEFAULT_GTK_THEME}"
ICON_THEME="${icon_theme:-$DEFAULT_ICON_THEME}"

gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME" 2>/dev/null
gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME" 2>/dev/null

mkdir -p ~/.config/gtk-3.0

cat > ~/.config/gtk-3.0/settings.ini << CFGEOF
[Settings]
gtk-theme-name=$GTK_THEME
gtk-icon-theme-name=$ICON_THEME
gtk-font-name=Sans 10
gtk-cursor-theme-name=Bibata-Modern-Classic
gtk-cursor-theme-size=0
gtk-toolbar-style=GTK_TOOLBAR_BOTH_HORIZ
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=0
gtk-menu-images=0
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=1
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintmedium
CFGEOF

if [ -f "$GTK_CSS" ]; then
    cp "$GTK_CSS" ~/.config/gtk-3.0/gtk.css
    if [ -f ~/.config/gtk-3.0/gtk.css ]; then
        gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME" 2>/dev/null
    fi
elif [ -f ~/.config/gtk-3.0/gtk.css ]; then
    rm -f ~/.config/gtk-3.0/gtk.css
fi
