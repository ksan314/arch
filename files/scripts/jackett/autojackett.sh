#!/bin/bash
qBittorrent=$(ps -aux | grep -v 'grep' | grep -io 'qbittorrent')
if [ -z "$qBittorrent" ]
then
	systemctl stop jackett.service
else
	systemctl start jackett.service
fi
