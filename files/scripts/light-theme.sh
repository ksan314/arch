#!/bin/bash

# set gtk light theme
#####################
echo -e "gtk-icon-theme-name = \"Adwaita\"\ngtk-theme-name = \"Adwaita\"\ngtk-font-name = \"Cantarell 11\"" > /usr/share/gtk-2.0/gtkrc

echo -e "[Settings]\ngtk-icon-theme-name = Adwaita\ngtk-theme-name = Adwaita\ngtk-font-name = Cantarell 11\ngtk-application-prefer-dark-theme = false" > /usr/share/gtk-3.0/settings.ini

echo -e "[Settings]\ngtk-icon-theme-name = Adwaita\ngtk-theme-name = Adwaita\ngtk-font-name = Cantarell 11" > /usr/share/gtk-4.0/settings.ini





# set QT light theme
####################

echo -e "export QT_STYLE_OVERRIDE=Adwaita" > /etc/environment
