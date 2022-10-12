#!/bin/bash

# variables
###########

currentTime=$(date)
maxsnapshotCount=NUMBEROFSNAPSHOTS





# clean up old snapshots
########################

# get number of existing snapshots
rootsnapshotCount=$(btrfs subvolume list -o /.snapshots | grep 'root' | grep -c 'TIMELINE')
homesnapshotCount=$(btrfs subvolume list -o /.snapshots | grep 'home' | grep -c 'TIMELINE')


# delete oldest root snapshot
if [ "$rootsnapshotCount" -ge "$maxsnapshotCount" ]
then
	# get name of oldest root snapshot
	oldestrootSnapshot=$(btrfs subvolume list -o /.snapshots | grep 'root/TIMELINE' | head -n 1 | grep -Eo 'snapshots[[:print:]]*$')
	
	# delete oldest root snapshot
	btrfs subvolume delete "/.$oldestrootSnapshot"
fi


# delete oldest home snapshot
if [ "$homesnapshotCount" -ge "$maxsnapshotCount" ]
then
	# get name of oldest home snapshot
	oldesthomeSnapshot=$(btrfs subvolume list -o /.snapshots | grep 'home/TIMELINE' | head -n 1 | grep -Eo 'snapshots[[:print:]]*$')
	
	# delete oldest home snapshot
	btrfs subvolume delete "/.$oldesthomeSnapshot"
fi





# create read-only btrfs snapshots
##################################

btrfs subvolume snapshot -r / /.snapshots/root/TIMELINE/"$currentTime"
btrfs subvolume snapshot -r /home /.snapshots/home/TIMELINE/"$currentTime"
