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










# set git branch to main
########################

git config --global init.defaultbranch main










# get git credentials if needed
###############################

while true
do
git config --global --list
read -rp $'\n'"Is the git username and email correct? [Y/n] " gitCredentials
    gitCredentials=${gitCredentials:-Y}
    if [ "$gitCredentials" == Y ] || [ "$gitCredentials" == y ] || [ "$gitCredentials" == yes ] || [ "$gitCredentials" == YES ] || [ "$gitCredentials" == Yes ]
    then
        gitCredentials=true
        read -rp $'\n'"Are you sure the git credentials are correct? [Y/n] " gitcredentialsConfirm
        gitcredentialsConfirm=${gitcredentialsConfirm:-Y}
        case $gitcredentialsConfirm in
            [yY][eE][sS]|[yY]) break;;
            [nN][oO]|[nN]);;
            *);;
        esac
        REPLY=
    else
        gitCredentials=false
        read -rp $'\n'"Are you sure the git credentials are NOT correct? [Y/n] " gitcredentialsConfirm
        gitcredentialsConfirm=${gitcredentialsConfirm:-Y}
        case $gitcredentialsConfirm in
            [yY][eE][sS]|[yY]) break;;
            [nN][oO]|[nN]);;
            *);;
        esac
        REPLY=
    fi
done










# set git credentials if needed
###############################

if [ "$gitCredentials" == false ]
then

    # get username
    while true
    do
    read -rp $'\n'"Enter git username: " userName
        if [ -z "$userName" ]
        then
            echo -e "\nYou must enter a username\n"
        else
            read -rp $'\n'"Are you sure \"$userName\" is your git username? [Y/n] " usernameConfirm
            usernameConfirm=${usernameConfirm:-Y}
            case $usernameConfirm in
                [yY][eE][sS]|[yY]) break;;
                [nN][oO]|[nN]);;
                *);;
            esac
            REPLY=
        fi
    done


    # get user email
    while true
    do
    read -rp $'\n'"Enter git email for username \"$userName\": " gitEmail
        if [ -z "$gitEmail" ]
        then
            echo -e "\nYou must enter an email\n"
        else
            read -rp $'\n'"Are you sure \"$gitEmail\" is your git email? [Y/n] " gitemailConfirm
            gitemailConfirm=${gitemailConfirm:-Y}
            case $gitemailConfirm in
                [yY][eE][sS]|[yY]) break;;
                [nN][oO]|[nN]);;
                *);;
            esac
            REPLY=
        fi
    done
    
    
    # set git credentials
    git config --global user.name "$userName"
    git config --global user.email "$gitEmail"
    
fi










# automatically get git repo info
#################################

# get repo name
repoName=$(pwd | grep -Eo '[^/]*$')


# get repo url
repoURL=$(grep -i 'url' ~/"$repoName"/.git/config | grep -Eo '[[:graph:]]*$')










# copy all needed dotfiles to the local repo
############################################

# alacritty
cp -r ~/.config/alacritty files/dotfiles


# albert
cp -r ~/.config/albert files/dotfiles


# .bashrc
cp ~/.bashrc files/dotfiles/bashrc


# cava
cp -r ~/.config/cava files/dotfiles


# gammastep
cp -r ~/.config/gammastep files/dotfiles


# mako
cp -r ~/.config/mako files/dotfiles


# mimeapps.list
cp ~/.config/mimeapps.list files/dotfiles


# neofetch
cp -r ~/.config/neofetch files/dotfiles


# .pinforc
cp -r ~/.pinforc files/dotfiles/pinforc


# sway
cp -r ~/.config/sway files/dotfiles


# tealdeer
cp -r ~/.config/tealdeer files/dotfiles


# waybar
cp -r ~/.config/waybar files/dotfiles


# zathura
cp -r ~/.config/zathura files/dotfiles










# push to online git repo
#########################

# re-initialize the repo
git init
git remote add origin "$repoURL"
git remote -v


# add all files to online git repo and commit changes
git add --all
git commit -am "Initial commit"


# force update to master branch of online git repo
printf "\e[1;32m\nEnter PAT instead of password\n\e[0m"
git push -f origin main
