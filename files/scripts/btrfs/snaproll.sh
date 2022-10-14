#!/bin/bash

# automatically get information
###############################

# check root status
currentUser=$(whoami)
if [ "$currentUser" != root ]
then
    printf "\e[1;31m\nYou must be logged in as root to run this script\n\e[0m"
    exit
fi


# get root parition
rootPartition=$(df | grep -E '/$' | grep -Eio '/dev/[[:graph:]]*')










# get snapshot to restore
#########################

# get the subvolume you want to restore
mapfile -t subVolumes < <(echo -e "@\n@home")
PS3="Enter the number for the subvolume you want to restore: "
select subVolume in "${subVolumes[@]}"
do
	if (( REPLY > 0 && REPLY <= "${#subVolumes[@]}" ))
    	then
		read -rp $'\n'"Are you sure you want to select the subvolume \"$subVolume\"? [Y/n] " subvolumeConfirm
        	subvolumeConfirm=${subvolumeConfirm:-Y}
            		case $subvolumeConfirm in
				[yY][eE][sS]|[yY]) break;;
                		[nN][oO]|[nN]);;
                		*);;
            		esac
            		REPLY=
	else
		echo -e "\nInvalid option. Try another one\n"
		sleep 2
		REPLY=
	fi
done


# set folder in /.snapshots to get snapshots from
if [ "$subVolume" == @ ]
then
	snapshotFolder=root
elif [ "$subVolume" == @home ]
then
	snapshotFolder=home
fi


# get the snapshot you want to restore
echo -e "\n\n\n"
mapfile -t snapShots < <(btrfs subvolume list -o /.snapshots | grep "$snapshotFolder" | grep -Eo '@[[:print:]]*$')
PS3="Enter the number for the snapshot you want to restore: "
select snapShot in "${snapShots[@]}"
do
	if (( REPLY > 0 && REPLY <= "${#snapShots[@]}" ))
	then
		read -rp $'\n'"Are you sure you want to select the snapshot \"$snapShot\"? [Y/n] " snapshotConfirm
		snapshotConfirm=${snapshotConfirm:-Y}
			case $snapshotConfirm in
				[yY][eE][sS]|[yY]) break;;
				[nN][oO]|[nN]);;
				*);;
			esac
			REPLY=
	else
		echo -e "\nInvalid option. Try another one\n"
		sleep 2
		REPLY=
	fi
done










# if restoring @home and multiple directories exist inside /home, only restore the necessary directories
########################################################################################################

# ask user if they want to restore the entire subvolume
echo -e "\n\n\n"
if [ "$subVolume" == @home ]
then
	directoryNumber=$(ls /home | grep -Eoc '[[:graph:]]')
	if [ "$directoryNumber" -gt 1 ]
	then
		while true
		do
			read -rp $'\n'"Restoring the @home subvolume will restore data for the entire home directory. Instead would you like to only restore data for a particular directory in /home? [Y/n] " partialRestore
			partialRestore=${partialRestore:-Y}
			if [ "$partialRestore" == Y ] || [ "$partialRestore" == y ] || [ "$partialRestore" == yes ] || [ "$partialRestore" == YES ] || [ "$partialRestore" == Yes ]
			then
				partialRestore=true
				read -rp $'\n'"Are you sure you want to restore data for a particular directory in /home instead of the entire home directory? [Y/n] " partialrestoreConfirm
				partialrestoreConfirm=${partialrestoreConfirm:-Y}
					case $partialrestoreConfirm in
						[yY][eE][sS]|[yY]) break;;
						[nN][oO]|[nN]);;
						*);;
					esac
					REPLY=
			else
				partialRestore=false
				read -rp $'\n'"Are you sure you want to restore the entire home directory? [Y/n] " partialrestoreConfirm
				partialrestoreConfirm=${partialrestoreConfirm:-Y}
					case $partialrestoreConfirm in
						[yY][eE][sS]|[yY]) break;;
						[nN][oO]|[nN]);;
						*);;
					esac
					REPLY=
			fi
		done
	fi
fi
		

# if the user wants to perform a partial restore of the /home directory, backup the necessary /home subdirectories
echo -e "\n\n\n"
if [ "$partialRestore" == true ]
then
	# get the directory you want to restore so others can be backed up
	mapfile -t restoreDirectories < <(ls /home)
	PS3="Enter the number for the directory you want to restore so that others can be backed up: "
	select restoreDirectory in "${restoreDirectories[@]}"
	do
		if (( REPLY > 0 && REPLY <= "${#restoreDirectories[@]}" ))
    		then
			read -rp $'\n'"Are you sure you want to restore the directory /home/$restoreDirectory? [Y/n] " restoredirectoryConfirm
        		restoredirectoryConfirm=${restoredirectoryConfirm:-Y}
            			case $restoredirectoryConfirm in
					[yY][eE][sS]|[yY]) break;;
                			[nN][oO]|[nN]);;
                			*);;
            			esac
            			REPLY=
		else
			echo -e "\nInvalid option. Try another one\n"
			sleep 2
			REPLY=
		fi
	done
			
			
	# delete already existing backups
	rm -rf /.snapshots/backups/*
			
			
	# backup necessary directories
	# set number of backups that should exist
	maxbackupNumber=$(echo -e "$directoryNumber - 1" | bc)
	while true
	do
		# check how many directories have been backed up
		backupNumber=$(ls /.snapshots/backups | grep -Eoc '[[:graph:]]')
		if [ "$backupNumber" -lt "$maxbackupNumber" ]
		then
			# set directory to back up
			backupDirectory=$(ls /home | grep -E '[[:graph:]]' | grep -Ev "$restoreDirectory" | head -n 1)
	
			# backup directory
			#btrfs subvolume snapshot -r /home
			mv /home/"$backupDirectory" /.snapshots/backups
		else
			break
		fi
	done
fi










# restore snapshot
##################

# mount the top level subvolume
mount "$rootPartition" -o subvolid=5 /mnt


# move subvolume to be restored to another location (change name of @home to @old)
mv /mnt/"$subVolume" /mnt/@old


# create a read-write snapshot of the read-only snapshot to restore
btrfs subvolume snapshot /mnt/"$snapShot" /mnt/"$subVolume"


# restore backed up home subdirectories if needed
if [ "$partialRestore" == true ]
then
	mv /mnt/@snapshots/backups/* /mnt/@home
fi










# reboot the system
###################

# reboot the system
printf "\e[1;32m\nRollback complete. After rebooting and verifying the rollback, run the \"snapclean.sh\" script to remove no longer needed subvolumes. Enter \"reboot\" to reboot the system\n\e[0m"
