# Description

- This is a bash script that installs Arch Linux on a btrfs filesystem in UEFI mode with sway.
- The installation includes printing capabilities, bluetooth, automatic recommended system maintenance, and automatic snapshots of root and home directories.
- The "install.sh" script will ask if you want to include the repo owners custom configurations. For details on what this includes, see the "custom configurations" section in the "config.sh" script
- To scroll up and down during installation, press "Ctrl+b" then "\[", then you can use the arrow or page up/down keys. To exit scrolling mode, press "q"
- Cancel the installation at any time with "Ctrl+c"
	
---

### Details

- Dual booting on the same disk is not supported. The installation will remove all data on the disk selected by the user. Installation includes a 1GB FAT32 efi boot partition, and a btrfs root partition that takes up the rest of the disk. This includes subvolumes @ mounted on /, @snapshots mounted on /.snapshots, @home mounted on /home, and @var_log mounted on /var/log
- The installation comes with a few helpful scripts
	- snaproll.sh
		- gets user input and rolls back to a previous snapshot
	- eject.sh
		- unmounts and powers off any removable storage
	- dotfiles.sh
		- saves necessary dotfiles and pushes them to the online git repo
		- must be run from inside the arch repo

---

# Usage

After booting into arch linux from a live medium in UEFI mode, run the install script with the following commands...
1. `tmux`
2. if you need to connect to wifi, run...
	- `iwctl`
	- `device list`
	- `station [device_name] scan`
	- `station [device_name] get-networks`
	- `station [device_name] conenct [network_name]`
	- verify you are connected with...
		- `station [device_name] show`
3. `pacman -Sy git` 
4. `git clone https://github.com/ksanf3/arch`
5. `cd arch`
6. `chmod +x ./install.sh`
7. `./install.sh`
	- Read the input prompts carefully. This will install arch linux, along with the sway tiling window manager
