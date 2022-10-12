#!/bin/bash

# chroot confirmation
#####################

printf "\e[1;32m\nChrooted into new environment and running chroot script\n\e[0m"
sleep 2










# import user inputs and system information
###########################################

read -r hostName userName userPassword rootPassword timeZone reflectorCode diskName dualBoot customConfig archURL virtualMachine nvme processorVendor graphicsVendor < /confidentials
# needs to be the exact same list of variables as in the install script










# configure pacman, and install all needed packages
###################################################

# configure pacman
printf "\e[1;32m\nConfiguring pacman\n\e[0m"
sleep 2
sed -i 's/#\[multilib\]/\[multilib\]/;/\[multilib\]/{n;s/#Include /Include /}' /etc/pacman.conf
pacman -Syu
pacman -S --needed --asdeps --noconfirm pacman-contrib pacutils


# enable microcode updates
if [ "$processorVendor" != null ]
then
    printf "\e[1;32m\nEnabling microcode updates\n\e[0m"
    sleep 2
    pacman -S --needed --noconfirm "$processorVendor"-ucode
fi


# install graphics drivers
if [ "$graphicsVendor" != null ]
then
    printf "\e[1;32m\nInstalling graphics drivers\n\e[0m"
    sleep 2
fi
if [ "$graphicsVendor" == amd ]
then
    pacman -S --needed --noconfirm mesa lib32-mesa lib32-vulkan-radeon libva-mesa-driver lib32-libva-mesa-driver mesa-vdpau lib32-mesa-vdpau vulkan-radeon xf86-video-amdgpu
fi
if [ "$graphicsVendor" == intel ]
then
    pacman -S --needed xf86-video-intel mesa lib32-mesa vulkan-intel
fi
if [ "$graphicsVendor" == nvidia ]
then
    pacman -S --needed nvidia nvidia-settings nvidia-utils lib32-nvidia-utils
fi


# install essential packages
printf "\e[1;32m\nInstalling essential packages\n\e[0m"
sleep 2
pacman -S --needed --noconfirm arch-wiki-docs arch-wiki-lite base base-devel bash btrfs-progs coreutils exfat-utils grub ifuse libimobiledevice man-db man-pages mlocate networkmanager npm ntfs-3g pinfo python-pip reflector rsync tldr trash-cli ufw unzip zip


# install tools
printf "\e[1;32m\nInstalling tools\n\e[0m"
sleep 2
pacman -S --needed --noconfirm bat fzf git gnupg hwinfo inotify-tools libqalculate lshw nano neofetch neovim zoxide


# install necessary packages
printf "\e[1;32m\nInstalling necessary packages\n\e[0m"
sleep 2
pacman -S --needed --noconfirm archlinux-wallpaper adwaita-qt5 adwaita-qt6 gnome-themes-extra gtk2 gtk3 gtk4 noto-fonts noto-fonts-emoji otf-font-awesome qt5-base qt5-wayland qt6-base qt6-wayland ttf-hack


# install desktop packages
printf "\e[1;32m\nInstalling desktop packages\n\e[0m"
sleep 2
pacman -S --needed --noconfirm alacritty foot mako seatd sway swaybg swaylock swayidle waybar wayland wayland-docs wayland-utils wlc wl-clipboard xorg-xwayland


# install audio packages
printf "\e[1;32m\nInstalling audio packages\n\e[0m"
sleep 2
pacman -S --needed --noconfirm pavucontrol pipewire pipewire-alsa pipewire-docs pipewire-jack pipewire-pulse wireplumber wireplumber-docs


# install bluetooth packages
printf "\e[1;32m\nInstalling bluetooth packages\n\e[0m"
sleep 2
pacman -S --needed --noconfirm blueman bluez bluez-utils


# install printing packages
printf "\e[1;32m\nInstalling printing packages\n\e[0m"
sleep 2
pacman -S --needed --noconfirm system-config-printer





# install optional dependencies
###############################

# grub
printf "\e[1;32m\nInstalling optional dependencies for grub\n\e[0m"
sleep 2
pacman -S --needed --asdeps --noconfirm efibootmgr os-prober
# set as dependencies
package=grub
dependsOn=("efibootmgr" "os-prober")
package=$(ls /var/lib/pacman/local | grep -Ei "$package-[0-9]")
for n in "${dependsOn[@]}";
do
    needed=$(grep -io "$n" /var/lib/pacman/local/"$package"/desc)
    if [ -z "$needed" ]
    then
        sudo sed -i "s/%DEPENDS%/%DEPENDS%\n$n/g" /var/lib/pacman/local/"$package"/desc
    fi
done


# printing
printf "\e[1;32m\nInstalling optional dependencies for printing\n\e[0m"
sleep 2
pacman -S --needed --asdeps --noconfirm avahi cups cups-pdf foomatic-db-ppds foomatic-db-nonfree-ppds nss-mdns usbutils
# set as dependencies
package=system-config-printer
dependsOn=("avahi" "cups" "cups-pdf" "nss-mdns" "usbutils")
package=$(ls /var/lib/pacman/local | grep -Ei "$package-[0-9]")
for n in "${dependsOn[@]}";
do
    needed=$(grep -io "$n" /var/lib/pacman/local/"$package"/desc)
    if [ -z "$needed" ]
    then
        sudo sed -i "s/%DEPENDS%/%DEPENDS%\n$n/g" /var/lib/pacman/local/"$package"/desc
    fi
done










# configure the system
######################

printf "\e[1;32m\nConfiguring the system\n\e[0m"
sleep 2


# set the time and language
ln -sf /usr/share/zoneinfo/"$timeZone" /etc/localtime
hwclock --systohc
sed -i 's/#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf


# set the hostname
echo -e "$hostName" >> /etc/hostname


# configure the network
echo -e "127.0.0.1   localhost" >> /etc/hosts
echo -e "::1         localhost" >> /etc/hosts
echo -e "127.0.1.1   $hostName" >> /etc/hosts


# configure root user
echo -e "$rootPassword\n$rootPassword" | passwd root
echo -e "root ALL=(ALL:ALL) ALL" >> /etc/sudoers


# configure user
useradd -m -g users -G wheel -s /bin/bash "$userName"
echo -e "$userPassword\n$userPassword" | passwd "$userName"
echo -e "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers


# configure fstab
# remove subvolid's
sed -i 's/,subvolid=[0-9]*//' /etc/fstab


# configure mkinitcpio.conf
sed -i 's/MODULES=()/MODULES=(btrfs)/' /etc/mkinitcpio.conf
# put btrfs into modules instead of hooks due to a bug that is documented on the arch wiki btrfs page. Also see the mkinitcpio arch wiki page for configuring mkinitcpio file
mkinitcpio -p linux


# configure grub
sed -i 's/GRUB_TIMEOUT=[0-9]*/GRUB_TIMEOUT=3/' /etc/default/grub
if [ "$dualBoot" == true ]
then
  sed -i 's/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
fi
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg


# enable and speed up package builds
if [ "$cpuThreads" != null ]
then
    sed -i 's/#MAKEFLAGS=\"-j[0-9]*\"/MAKEFLAGS=\"-j$(nproc)\"/g' /etc/makepkg.conf
fi


# configure reflector
echo -e "--country $reflectorCode" >> /etc/xdg/reflector/reflector.conf
sed -Ei 's/--latest [0-9]*/--latest 15/' /etc/xdg/reflector/reflector.conf
sed -Ei 's/--sort [a-z,A-Z]*/--sort rate/' /etc/xdg/reflector/reflector.conf
systemctl enable reflector.timer
systemctl start reflector.service


# enable network manager
systemctl enable NetworkManager


# configure shadow
systemctl enable shadow.timer


# enable sway 
# add user to seat group
usermod -aG seat kaleb
# enable seatd daemon
systemctl enable seatd.service


# set global environment variables
if [ "$virtualMachine" == true ]
then
    echo -e "\n# enables mouse cursor on virtual machines"    >>  /etc/environment
    echo -e "WLR_NO_HARDWARE_CURSORS=1"                       >>  /etc/environment
fi










# import files
##############

printf "\e[1;32m\nImporting files\n\e[0m"
sleep 2


# save arch repo
su -c "git clone $archURL /home/$userName/arch" "$userName"


# save packages.txt
su -c "cp /home/$userName/arch/files/packages.txt /home/$userName" "$userName"


# save config.sh
su -c "cp /home/$userName/arch/config.sh /home/$userName" "$userName"
chmod +x /home/"$userName"/config.sh


# save custom config files
if [ "$customConfig" == true ]
then
    cp -r /home/"$userName"/arch/files/wallpapers /usr/share
fi










# exit the chroot environment (does this automatically when script ends)
########################################################################

printf "\e[1;32m\nExiting the chroot environment\n\e[0m"
sleep 2
