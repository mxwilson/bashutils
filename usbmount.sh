#!/bin/bash

#usbmount.sh - Bash script to enable use of USB storage devices on workstations. Then disable it. 

#E-mails admins when script is used, warns user with a Zenity pop-up window. Window re-appears at
#specified time as a reminder to unmount. Tested on CentOS 7 and Ubuntu 17. 
#Requires Zenity <https://help.gnome.org/users/zenity/stable/>.

#(c)2017 MWILSON <http://www.github.com/mxwilson>

#License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.

#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.

#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.

#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.

SLEEPYTIME=3600 #reminder period with popup window

UNLOADERFUNC() {
while true; do
        sleep $SLEEPYTIME #seconds between attempt to unload module

        MOD_USE=$(lsmod | grep usb_storage | tr -s ' ' | cut -d ' ' -f 3 | head -n 1)

        if [ "$MOD_USE" -eq 0 ]; then
                #if module not in use unload and exit.
                modprobe -r usb_storage >/dev/null 2>&1
                exit 0;
        else
                #if module still in use, popup reminder and restart loop using sleepytime value
                zenity --info --text "Reminder: Eject/unmount USB storage device when finished."
                continue;
        fi
done
}

#First send e-mail notification to admin

EMAILADDR="ADMINTEAM@MAIL.COM"
THEHOST=$(uname -n)
THEDATE=$(date)
THEUSER=$(whoami)
MAILTEXT="user: ${THEUSER}
host: ${THEHOST}
date: ${THEDATE}"

mail -s "Alert: USB Storage has been enabled" $EMAILADDR <<< "$MAILTEXT"

#insert the kernel module enabling USB storage devices

insmod /lib/modules/$(uname -r)/kernel/drivers/usb/storage/usb-storage.ko &

zenity --warning --text "Notice: USB storage temporarily enabled.\nThis incident has been logged."

#Go to Unload function

UNLOADERFUNC &
disown

exit 0
