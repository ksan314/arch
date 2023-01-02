#!/bin/bash

# scan system and save log file
clamscan -ri --exclude-dir=/.snapshots --log=/clamscan /

# remove permission errors from log file
sed -Ei '/Permission denied$/d' /clamscan

# move log file to home directory for each user in the wheel group
for n in $(groupmems -g wheel -l)
do
	mv /clamscan /home/$n
done
