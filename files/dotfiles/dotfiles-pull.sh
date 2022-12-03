#!/bin/bash

# check if script is ready to be run
####################################

# check root status
currentUser=$(whoami)
if [ "$currentUser" == root ]
then
    printf "\e[1;31m\nYou should not run this script as the root user\n\e[0m"
    exit
fi


# check if running inside the arch repo
currentDirectory=$(pwd | grep -Eio '[a-z]*$')
if [ "$currentDirectory" != arch ]
then
    printf "\e[1;31m\nThis script must be run from inside the arch repo\n\e[0m"
    exit
fi










# automatically get information
###############################

# get username
userName=$(users | grep -Eio '^[[:graph:]]*[^ ]')










# pull dotfiles from arch repo
##############################

# alacritty
su -c "cp -r files/dotfiles/alacritty /home/$userName/.config" "$userName"


# albert
su -c "cp -r files/dotfiles/albert /home/$userName/.config" "$userName"


# .bashrc
su -c "cp files/dotfiles/bashrc /home/$userName/.bashrc" "$userName"


# cava
su -c "cp -r files/dotfiles/cava /home/$userName/.config" "$userName"


# gammastep
su -c "cp -r files/dotfiles/gammastep /home/$userName/.config" "$userName"


# mako
su -c "cp -r files/dotfiles/mako /home/$userName/.config" "$userName"


# mimeapps.list
su -c "cp files/dotfiles/mimeapps.list /home/$userName/.config" "$userName"


# neofetch
su -c "cp -r files/dotfiles/neofetch /home/$userName/.config" "$userName"


# .pinforc
su -c "cp files/dotfiles/pinforc /home/$userName/.pinforc" "$userName"


# sway
su -c "cp -r files/dotfiles/sway /home/$userName/.config" "$userName"


# swaylock
su -c "cp -r files/dotfiles/swaylock /home/$userName/.config" "$userName"


# waybar
su -c "cp -r files/dotfiles/waybar /home/$userName/.config" "$userName"


# zathura
su -c "cp -r files/dotfiles/zathura /home/$userName/.config" "$userName"
