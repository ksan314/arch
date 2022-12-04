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
cp -r files/dotfiles/alacritty /home/"$userName"/.config


# albert
cp -r files/dotfiles/albert /home/"$userName"/.config


# .bashrc
cp files/dotfiles/bashrc /home/"$userName"/.bashrc


# cava
cp -r files/dotfiles/cava /home/"$userName"/.config


# gammastep
cp -r files/dotfiles/gammastep /home/"$userName"/.config


# mako
cp -r files/dotfiles/mako /home/"$userName"/.config


# mimeapps.list
cp files/dotfiles/mimeapps.list /home/"$userName"/.config


# neofetch
cp -r files/dotfiles/neofetch /home/"$userName"/.config


# .pinforc
cp files/dotfiles/pinforc /home/"$userName"/.pinforc


# sway
cp -r files/dotfiles/sway /home/"$userName"/.config


# swaylock
cp -r files/dotfiles/swaylock /home/"$userName"/.config


# waybar
cp -r files/dotfiles/waybar /home/"$userName"/.config


# zathura
cp -r files/dotfiles/zathura /home/"$userName"/.config
