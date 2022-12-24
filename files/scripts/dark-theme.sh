#!/bin/bash

# set gtk dark theme
####################
echo -e "gtk-icon-theme-name = \"Adwaita-dark\"\ngtk-theme-name = \"Adwaita-dark\"\ngtk-font-name = \"Cantarell 11\"" > /usr/share/gtk-2.0/gtkrc

echo -e "[Settings]\ngtk-icon-theme-name = Adwaita-dark\ngtk-theme-name = Adwaita-dark\ngtk-font-name = Cantarell 11\ngtk-application-prefer-dark-theme = true" > /usr/share/gtk-3.0/settings.ini

echo -e "[Settings]\ngtk-icon-theme-name = Adwaita-dark\ngtk-theme-name = Adwaita-dark\ngtk-font-name = Cantarell 11\ngsettings set org.gnome.desktop.interface color-scheme prefer-dark" > /usr/share/gtk-4.0/settings.ini





# set QT dark theme
###################

echo -e "export QT_STYLE_OVERRIDE=Adwaita-dark" > /etc/environment
