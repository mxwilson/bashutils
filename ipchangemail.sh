#!/bin/bash

#ipchangemail.sh - Bash script to send e-mail alerts when IP address changes. Ideally run periodically with a cron job. 

#(c)2018 MWILSON <http://www.github.com/mxwilson>

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

DATFILE="./current_ip.dat" # saved ip address
DLFILE="./dl.html" # downloaded html file of ip address
EMAILADDR="myemail@mail.ru" #email address of recipient

#download ip address and save it

wget -q http://whatismyip.host/my-ip-address-details -O $DLFILE

if [ ! $? = 0 ] ; then
	echo "download failed"
	exit 1
fi

#parse ip out of the downloaded file

REZ=$(cat $DLFILE | grep "<p class=\"ipaddress\">" | head -n 1 | xargs | cut -d '>' -f 2 | cut -d '<' -f 1)

#save dat file of current ip if not exist

if [ ! -e $DATFILE ] ; then  
	echo $REZ > $DATFILE
	echo "creating dat file, exiting."
	exit 0 #exit now, will compare next run
fi

#otherwise compare dl'd ip vs saved one

COMPAREIP=$(cat $DATFILE)

if [ ! "$REZ" == "$COMPAREIP" ] ; then
	#now e-mail to alert
	echo "Your new IP address is: $REZ" | mail -s "Your IP address has changed" $EMAILADDR
fi

#now update the data file with new ip address

echo $REZ > $DATFILE

if [ ! $? = 0 ] ; then
	echo "unable to save dat file."
	exit 1
fi

exit 0
