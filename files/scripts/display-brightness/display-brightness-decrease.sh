#!/bin/bash

# get current display
#currentDisplay=$(swaymsg -pt get_outputs | grep -i focused | awk '{print $2}'


# get max display brightness
maxBrightness=$(less /sys/class/backlight/*/max_brightness)


# get current brightness
currentBrightness=$(less /sys/class/backlight/*/brightness)


adjustAmount=$(( $currentBrightness / 10 ))
if [[ $adjustAmount -lt 1 ]]
then
	adjustAmount=1
fi
#echo -e "adjust amount $adjustAmount"


# get new brightness level
newBrightness=$(echo -e "$currentBrightness - $adjustAmount" | bc)
if [[ $newBrightness == 0 ]]
then
	newBrightness=1
fi
#echo -e "new brightness $newBrightness"


# set new brightness level
echo -e "$newBrightness" >> /sys/class/backlight/*/brightness
