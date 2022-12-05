#!/bin/bash

# set the protocol to wireguard
mullvad relay set tunnel-protocol wireguard

# enable LAN access
mullvad lan set allow
    
# block ads, trackers, and malware
mullvad dns set default --block-ads --block-malware --block-trackers
    
# set auto-connect
mullvad auto-connect set on
    
# connect to vpn
mullvad connect
    
# always require vpn
mullvad always-require-vpn set on
