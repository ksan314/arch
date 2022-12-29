#!/bin/bash

# dont always require vpn
mullvad always-require-vpn set off

# dont automatically connect to vpn
mullvad auto-connect set off

# disconnect from vpn
mullvad disconnect
