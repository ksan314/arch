#!/bin/bash

maxVolume=100
defaultSink=$(pactl get-default-sink)
currentVolume=$(pactl get-sink-volume "$defaultSink" | grep -Eio '[0-9]*%' | head -n 1 | grep -Eio '[0-9]*')

if [[ $currentVolume -le $maxVolume ]]
then
	pactl set-sink-volume "$defaultSink" +5%
fi
