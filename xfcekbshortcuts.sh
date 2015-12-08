#!/bin/bash

# xfcekbshortcuts.sh (0.1) 
# This script adds new keyboard shortcuts for volume and screen brightness under XFCE
# (c) 2015 Matthew Wilson
# License GPLv3+: GNU GPL version 3 or later: http://gnu.org/licenses/gpl.html
# No warranty. Software provided as is.

vol0="F1"
volm10="F2"
volp10="F3"
brilow="F5"
brimed1="F6"
brimed2="F7"
brimax="F8"

echo "Installing custom keyboard shortcuts for XFCE"
echo "Volume 0: $vol0. Volume -10%: $volm10. Volume +10%: $volp10."
echo "Bright 0.3: $brilow. Bright 0.5: $brimed1. Bright 0.7: $brimed2. Bright 1: $brimax."

# get currently connected display
con_scr=$(xrandr | grep -w "connected" | cut -d " " -f 1)
echo "Use output: $con_scr"

read -p "Continue? (y/n)" somevar

case "$somevar" in
	y|Y ) 
		;;
	* ) 
		echo "Bye"; exit;;
esac

xfconf-query -c xfce4-keyboard-shortcuts --property "/commands/custom/$vol0" --create --type string --set "amixer -q set -D pulse Master 0%"
xfconf-query -c xfce4-keyboard-shortcuts --property "/commands/custom/$volm10" --create --type string --set "amixer -q set -D pulse Master 10%-"
xfconf-query -c xfce4-keyboard-shortcuts --property "/commands/custom/$volp10" --create --type string --set "amixer -q set -D pulse Master 10%+"
xfconf-query -c xfce4-keyboard-shortcuts --property "/commands/custom/$brilow" --create --type string --set "xrandr --output $con_scr --brightness 0.3"
xfconf-query -c xfce4-keyboard-shortcuts --property "/commands/custom/$brimed1" --create --type string --set "xrandr --output $con_scr --brightness 0.5"
xfconf-query -c xfce4-keyboard-shortcuts --property "/commands/custom/$brimed2" --create --type string --set "xrandr --output $con_scr --brightness 0.7"
xfconf-query -c xfce4-keyboard-shortcuts --property "/commands/custom/$brimax" --create --type string --set "xrandr --output $con_scr --brightness 1.0"

echo "Done"
