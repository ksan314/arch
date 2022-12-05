#!/bin/bash

# check to see if system is ready to run config.sh
##################################################

# check root status
currentUser=$(whoami)
if [ "$currentUser" != root ]
then
    printf "\e[1;31m\nYou must be logged in as root to run this script\n\e[0m"
    exit
fi


# check to see if required packages were installed from packages.txt
paruExists=$(pacman -Qqs paru)
zramdExists=$(pacman -Qqs zramd)
if [ "$paruExists" != paru ] || [ "$zramdExists" != zramd ]
then
    printf "\e[1;31m\nRequired packages not installed from packages.txt\n\e[0m"
    exit
fi










# automatically get system information
######################################

# get username
userName=$(users | grep -Eio '^[[:graph:]]*[^ ]')


# # check if installing on a laptop
laptopInstall=$(neofetch battery)
if [ -z "$laptopInstall" ]
then
	laptopInstall=false
else
	laptopInstall=true
fi


# get root subvolume id
#rootSubvolumeID=$(btrfs subvolume list / | grep -i '@$' | grep -Eio 'id [0-9]*' | grep -Eio '[0-9]*')


# get zram size in MB, equal to half the size of ram, and convert to integer
ramSize=$(free -m | grep -i 'mem' | awk '{print $2}')
swapSize=$(echo -e "$ramSize * 0.5" | bc)
swapsizeInteger=${swapSize%.*}


# get customConfig variable
customConfig=$(ls /usr/share | grep -io 'wallpapers')
if [ "$customConfig" == wallpapers ]
then
    customConfig=true
else
    customConfig=false
fi










# backup boot partition on kernel updates
#########################################

# see "snapshots and /boot parition" section on "system backup" arch wiki page
mkdir /etc/pacman.d/hooks
cp /home/"$userName"/arch/files/95-bootbackup.hook /etc/pacman.d/hooks










# configure snapshots
#####################

printf "\e[1;32m\nConfiguring snapshots\n\e[0m"
sleep 2


# set permissions for /.snapshot directory
chmod -R 700 /.snapshots


# set root subvolume as default subvolume so we can boot from snapshots of root subvolume
#btrfs subvolume set-default "$rootSubvolumeID" /


# create necessary directories
mkdir /.snapshots/root
mkdir /.snapshots/home
mkdir /.snapshots/backups
mkdir /.snapshots/root/hourly
mkdir /.snapshots/home/hourly
mkdir /.snapshots/root/daily
mkdir /.snapshots/home/daily
mkdir /.snapshots/root/weekly
mkdir /.snapshots/home/weekly
mkdir /.snapshots/root/monthly
mkdir /.snapshots/home/monthly
mkdir /.snapshots/root/yearly
mkdir /.snapshots/home/yearly


# configure btrfs scripts
cp /home/"$userName"/arch/files/scripts/btrfs/btrfs-snapshots.sh /usr/local/bin/btrfs-snapshots-hourly.sh
sed -i 's/NUMBEROFSNAPSHOTS/24/' /usr/local/bin/btrfs-snapshots-hourly.sh
sed -i 's/TIMELINE/hourly/' /usr/local/bin/btrfs-snapshots-hourly.sh
chmod +x /usr/local/bin/btrfs-snapshots-hourly.sh

cp /home/"$userName"/arch/files/scripts/btrfs/btrfs-snapshots.sh /usr/local/bin/btrfs-snapshots-daily.sh
sed -i 's/NUMBEROFSNAPSHOTS/7/' /usr/local/bin/btrfs-snapshots-daily.sh
sed -i 's/TIMELINE/daily/' /usr/local/bin/btrfs-snapshots-daily.sh
chmod +x /usr/local/bin/btrfs-snapshots-daily.sh

cp /home/"$userName"/arch/files/scripts/btrfs/btrfs-snapshots.sh /usr/local/bin/btrfs-snapshots-weekly.sh
sed -i 's/NUMBEROFSNAPSHOTS/5/' /usr/local/bin/btrfs-snapshots-weekly.sh
sed -i 's/TIMELINE/weekly/' /usr/local/bin/btrfs-snapshots-weekly.sh
chmod +x /usr/local/bin/btrfs-snapshots-weekly.sh

cp /home/"$userName"/arch/files/scripts/btrfs/btrfs-snapshots.sh /usr/local/bin/btrfs-snapshots-monthly.sh
sed -i 's/NUMBEROFSNAPSHOTS/12/' /usr/local/bin/btrfs-snapshots-monthly.sh
sed -i 's/TIMELINE/monthly/' /usr/local/bin/btrfs-snapshots-monthly.sh
chmod +x /usr/local/bin/btrfs-snapshots-monthly.sh

cp /home/"$userName"/arch/files/scripts/btrfs/btrfs-snapshots.sh /usr/local/bin/btrfs-snapshots-yearly.sh
sed -i 's/NUMBEROFSNAPSHOTS/3/' /usr/local/bin/btrfs-snapshots-yearly.sh
sed -i 's/TIMELINE/yearly/' /usr/local/bin/btrfs-snapshots-yearly.sh
chmod +x /usr/local/bin/btrfs-snapshots-yearly.sh


# configure btrfs systemd units
cp /home/"$userName"/arch/files/systemd/btrfs/snapshots/btrfs-snapshots-hourly.service /etc/systemd/system
cp /home/"$userName"/arch/files/systemd/btrfs/snapshots/btrfs-snapshots-hourly.timer /etc/systemd/system
cp /home/"$userName"/arch/files/systemd/btrfs/snapshots/btrfs-snapshots-daily.service /etc/systemd/system
cp /home/"$userName"/arch/files/systemd/btrfs/snapshots/btrfs-snapshots-daily.timer /etc/systemd/system
cp /home/"$userName"/arch/files/systemd/btrfs/snapshots/btrfs-snapshots-weekly.service /etc/systemd/system
cp /home/"$userName"/arch/files/systemd/btrfs/snapshots/btrfs-snapshots-weekly.timer /etc/systemd/system
cp /home/"$userName"/arch/files/systemd/btrfs/snapshots/btrfs-snapshots-monthly.service /etc/systemd/system
cp /home/"$userName"/arch/files/systemd/btrfs/snapshots/btrfs-snapshots-monthly.timer /etc/systemd/system
cp /home/"$userName"/arch/files/systemd/btrfs/snapshots/btrfs-snapshots-yearly.service /etc/systemd/system
cp /home/"$userName"/arch/files/systemd/btrfs/snapshots/btrfs-snapshots-yearly.timer /etc/systemd/system
systemctl daemon-reload
systemctl enable btrfs-snapshots-hourly.timer
systemctl enable btrfs-snapshots-daily.timer
systemctl enable btrfs-snapshots-weekly.timer
systemctl enable btrfs-snapshots-monthly.timer
systemctl enable btrfs-snapshots-yearly.timer


# save snaproll.sh and snapclean.sh and make executable
cp /home/"$userName"/arch/files/scripts/btrfs/snaproll.sh /usr/local/bin
cp /home/"$userName"/arch/files/scripts/btrfs/snapclean.sh /usr/local/bin
chmod +x /usr/local/bin/snaproll.sh
chmod +x /usr/local/bin/snapclean.sh


# take snapshots before config.sh
btrfs subvolume snapshot -r / /.snapshots/root/yearly/before-config.sh
btrfs subvolume snapshot -r /home /.snapshots/home/yearly/before-config.sh










# configure system
##################

printf "\e[1;32m\nConfiguring system\n\e[0m"
sleep 2


# configure grub
grub-mkconfig -o /boot/grub/grub.cfg


# start sway on login
echo -e "\n# start sway on login\nif [ -z \$DISPLAY ] && [ \"\$(tty)\" = \"/dev/tty1\" ]; then\nexec sway\nfi" >> /home/"$userName"/.bash_profile


# configure zram
sed -i 's/# FRACTION=[0-9,\.]*/FRACTION=0.5/' /etc/default/zramd
sed -i "s/# MAX_SIZE=[0-9,\.]*/MAX_SIZE=$swapsizeInteger/" /etc/default/zramd
sed -i 's/# NUM_DEVICES/NUM_DEVICES/' /etc/default/zramd
sed -i 's/# PRIORITY/PRIORITY/' /etc/default/zramd
systemctl enable zramd


# configure clock sync
systemctl enable systemd-timesyncd.service


# configure paccache
systemctl enable paccache.timer


# enable man-db.timer
systemctl start man-db.service
systemctl enable man-db.timer


# enable disk trim
systemctl enable fstrim.timer


# enable bluetooth
systemctl enable bluetooth.service
sed -i 's/#AutoEnable=true/AutoEnable=false/' /etc/bluetooth/main.conf


# configure printing
systemctl enable avahi-daemon.service
sed -i 's/mymachines/mymachines mdns_minimal [NOTFOUND=return]/' /etc/nsswitch.conf
systemctl enable cups.socket


# configure mlocate
sed -i 's/PRUNEPATHS = "/PRUNEPATHS = "\/.snapshots /' /etc/updatedb.conf
updatedb
systemctl enable updatedb.timer


# configure wireplumber
su -c "systemctl --user enable wireplumber.service" "$userName"


# fix framework laptop bug for brightness and airplane mode keys, and make laptop suspend-to-ram (see framework laptop page on the arch wiki)
if [ "$laptopInstall" == true ]
then
	# fix brightness and airplane key bug
	echo -e "blacklist hid_sensor_hub" > /etc/modprobe.d/frameworkbugfix.conf
	# make laptop suspend-to-ram
	echo deep > /sys/power/mem_sleep
	echo "mem_sleep_default=deep" > /etc/modprobe.d/suspend-to-ram.conf
	mkinitcpio -p linux
fi










# set custom configurations
###########################

if [ "$customConfig" == true ]
then

# create .config directory for user
su -c "mkdir /home/$userName/.config" "$userName"


# configure pacman
sed -i 's/#Color/Color/' /etc/pacman.conf


# configure app themes
sed -i 's/Adwaita/Adwaita-dark/' /usr/share/gtk-2.0/gtkrc
sed -i 's/Adwaita/Adwaita-dark/' /usr/share/gtk-3.0/settings.ini
echo -e "gtk-application-prefer-dark-theme = true" >> /usr/share/gtk-3.0/settings.ini
sed -i 's/Adwaita/Adwaita-dark/' /usr/share/gtk-4.0/settings.ini
echo -e "gsettings set org.gnome.desktop.interface color-scheme prefer-dark" >> /usr/share/gtk-4.0/settings.ini


# disable power saving mode for sound card
#sed -i 's/load-module module-suspend-on-idle/#load-module module-suspend-on-idle/' /etc/pulse/default.pa


# configure virtual machine manager (libvirt) if package is installed
libvirtExists=$(pacman -Qqs libvirt)
if [ -z "$libvirtExists" ]
then
    sleep 1
else
systemctl enable libvirtd.service
usermod -aG libvirt "$userName"
fi





# save dotfiles
###############

# alacritty
su -c "cp -r /home/$userName/arch/files/dotfiles/alacritty /home/$userName/.config" "$userName"


# albert
su -c "cp -r /home/$userName/arch/files/dotfiles/albert /home/$userName/.config" "$userName"


# .bashrc
su -c "cp /home/$userName/arch/files/dotfiles/bashrc /home/$userName/.bashrc" "$userName"


# cava
su -c "cp -r /home/$userName/arch/files/dotfiles/cava /home/$userName/.config" "$userName"


# gammastep
su -c "cp -r /home/$userName/arch/files/dotfiles/gammastep /home/$userName/.config" "$userName"


# mako
su -c "cp -r /home/$userName/arch/files/dotfiles/mako /home/$userName/.config" "$userName"


# mimeapps.list
su -c "cp /home/$userName/arch/files/dotfiles/mimeapps.list /home/$userName/.config" "$userName"


# neofetch
su -c "cp -r /home/$userName/arch/files/dotfiles/neofetch /home/$userName/.config" "$userName"


# .pinforc
su -c "cp -r /home/$userName/arch/files/dotfiles/pinforc /home/$userName/.pinforc" "$userName"


# sway
su -c "cp -r /home/$userName/arch/files/dotfiles/sway /home/$userName/.config" "$userName"


# swaylock
su -c "cp -r /home/$userName/arch/files/dotfiles/swaylock /home/$userName/.config" "$userName"


# waybar
su -c "cp -r /home/$userName/arch/files/dotfiles/waybar /home/$userName/.config" "$userName"


# zathura
su -c "cp -r /home/$userName/arch/files/dotfiles/zathura /home/$userName/.config" "$userName"





# save scripts
##############

# display-brightness
cp /home/"$userName"/arch/files/scripts/display-brightness/display-brightness-decrease.sh /usr/local/bin
cp /home/"$userName"/arch/files/scripts/display-brightness/display-brightness-increase.sh /usr/local/bin
chmod +x /usr/local/bin/display-brightness-decrease.sh
chmod +x /usr/local/bin/display-brightness-increase.sh


# eject
cp /home/"$userName"/arch/files/scripts/eject/eject.sh /usr/local/bin
chmod +x /usr/local/bin/eject.sh


# jackett
cp /home/"$userName"/arch/files/scripts/jackett/autojackett.sh /usr/local/bin
chmod +x /usr/local/bin/autojackett.sh


# pipewire
cp /home/"$userName"/arch/files/scripts/pipewire/pipewire-max-volume.sh /usr/local/bin
chmod +x /usr/local/bin/pipewire-max-volume.sh


# mullvad vpn
cp /home/"$userName"/arch/files/scripts/vpn/vpn-connect.sh /usr/local/bin
cp /home/"$userName"/arch/files/scripts/vpn/vpn-disconnect.sh /usr/local/bin
chmod +x /usr/local/bin/vpn-connect.sh
chmod +x /usr/local/bin/vpn-disconnect.sh





# save and enable custom systemd units
######################################

# configure backlight permissions
cp /home/"$userName"/arch/files/systemd/backlight-permission/backlight-permission.service /etc/systemd/system
cp /home/"$userName"/arch/files/systemd/backlight-permission/backlight-permission.timer /etc/systemd/system
systemctl daemon-reload
systemctl enable backlight-permission.timer


# configure clamav (antivirus)
cp /home/"$userName"/arch/files/systemd/clamav/freshclam.service /etc/systemd/system
cp /home/"$userName"/arch/files/systemd/clamav/clamscan.service /etc/systemd/system
cp /home/"$userName"/arch/files/systemd/clamav/clamscan.timer /etc/systemd/system
sed -i "s/USERNAME/$userName/" /etc/systemd/system/clamscan.service
systemctl daemon-reload
systemctl enable clamscan.timer


# configure jackett
cp /home/"$userName"/arch/files/systemd/jackett/autojackett.service /etc/systemd/system
cp /home/"$userName"/arch/files/systemd/jackett/autojackett.timer /etc/systemd/system
systemctl daemon-reload
systemctl enable autojackett.timer


# configure nnn plugins
cp /home/"$userName"/arch/files/systemd/nnnplugins/nnnplugins.service /etc/systemd/system
cp /home/"$userName"/arch/files/systemd/nnnplugins/nnnplugins.timer /etc/systemd/system
sed -i "s/USERNAME/$userName/" /etc/systemd/system/nnnplugins.service
systemctl daemon-reload
systemctl start nnnplugins.service
systemctl enable nnnplugins.timer


# configure suspend-to-ram
cp /home/"$userName"/arch/files/systemd/suspend-to-ram/suspend-to-ram.service /etc/systemd/system
cp /home/"$userName"/arch/files/systemd/suspend-to-ram/suspend-to-ram.timer /etc/systemd/system
systemctl daemon-reload
systemctl enable suspend-to-ram.timer


# configure tealdeer
cp /home/"$userName"/arch/files/systemd/tealdeer/tealdeer.service /etc/systemd/system
cp /home/"$userName"/arch/files/systemd/tealdeer/tealdeer.timer /etc/systemd/system
systemctl daemon-reload
systemctl start tealdeer.service
systemctl enable tealdeer.timer


# configure trash
cp /home/"$userName"/arch/files/systemd/trash/trash.service /etc/systemd/system
cp /home/"$userName"/arch/files/systemd/trash/trash.timer /etc/systemd/system
systemctl daemon-reload
systemctl enable trash.timer

fi










# remove files, and reboot
##########################

# remove no longer needed files
rm -rf /home/"$userName"/arch
rm -rf /home/"$userName"/packages.txt
rm -rf /home/"$userName"/config.sh


# take after config.sh snapshots
btrfs subvolume snapshot -r / /.snapshots/root/yearly/after-config.sh
btrfs subvolume snapshot -r /home /.snapshots/home/yearly/after-config.sh


# reboot
printf "\e[1;32m\nConfig complete. Enter \"reboot\" to reboot the system\n\e[0m"
