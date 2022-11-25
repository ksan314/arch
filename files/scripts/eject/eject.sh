#!/bin/bash

# get partition name
####################

partitionName=$(df | grep '/run/media/' | grep -Eo '^[[:graph:]]*')





# get disk name
###############

shortdiskName=$(lsblk -no PKNAME "$partitionName")
diskName=/dev/"$shortdiskName"





# unmount and power off removable disk
######################################

udisksctl unmount -b "$partitionName"
udisksctl power-off -b "$diskName"
