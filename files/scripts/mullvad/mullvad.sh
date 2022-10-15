#!/bin/bash

# configure mullvadvpn if package is installed
mullvadExists=$(pacman -Qqs mullvad)
if [ -z "$mullvadExists" ]
then
	sleep 1
else
	# update server list
	mullvad relay update
	
	# get mullvadvpn account number
	while true
	do
	read -rp $'\n'"Enter your mullvadvpn account number: " mullvadAccount
		if [ -z "$mullvadAccount" ]
		then
			echo -e "\nYou must enter an account number\n"
		else
			read -rp $'\n'"Are you sure you want to use the account number \"$mullvadAccount\"? [Y/n] " mullvadaccountConfirm
			mullvadaccountConfirm=${mullvadaccountConfirm:-Y}
			case $mullvadaccountConfirm in
				[yY][eE][sS]|[yY]) break;;
				[nN][oO]|[nN]);;
				*);;
			esac
			REPLY=
		fi
	done


	# get mullvadvpn server country
	echo -e "\n\n\n"
	mapfile -t serverCountries < <(mullvad relay list | grep -Eo '\([a-z][a-z]\)' | grep -Eo '[a-z][a-z]')
	PS3="Enter the number for the mullvadvpn server country you want to use: "
	select serverCountry in "${serverCountries[@]}"
	do
		if (( REPLY > 0 && REPLY <= "${#serverCountries[@]}" ))
		then
			read -rp $'\n'"Are you sure you want to select the server country \"$serverCountry\"? [Y/n] " servercountryConfirm
			servercountryConfirm=${servercountryConfirm:-Y}
			case $servercountryConfirm in
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


	# get mullvadvpn server city
	echo -e "\n\n\n"
	mapfile -t serverCities < <(mullvad relay list | grep -Eo "$serverCountry-[a-z][a-z][a-z]" | grep -Eo '[a-z][a-z][a-z]$')
	PS3="Enter the number for the mullvadvpn server city you want to use: "
	select serverCity in "${serverCities[@]}"
	do
		if (( REPLY > 0 && REPLY <= "${#serverCities[@]}" ))
		then
			read -rp $'\n'"Are you sure you want to select the server city \"$serverCity\"? [Y/n] " servercityConfirm
			servercityConfirm=${servercityConfirm:-Y}
			case $servercityConfirm in
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


	# login to mullvadvpn
	mullvad account login "$mullvadAccount"


	# if login successful, configure mullvadvpn
	mullvadLogin=$(mullvad account get | grep "$mullvadAccount")
	if [ -n "$mullvadLogin" ]
	then
		# set server location
		mullvad relay set location "$serverCountry" "$serverCity"

		# set the protocol to wireguard
		mullvad relay set tunnel-protocol wireguard

		# enable LAN access
		mullvad lan set allow
    
		# block ads, trackers, and malware
		mullvad dns set default --block-ads --block-malware --block-trackers
    
		# set auto-connect
		mullvad auto-connect set on
    
		# connect to mullvadvpn
		mullvad connect
    
		# always require vpn
		mullvad always-require-vpn set on
		
	else
		printf "\e[1;31m\nLogin to Mullvad not successful\n\e[0m"
		sleep 3
		exit
	fi

fi
