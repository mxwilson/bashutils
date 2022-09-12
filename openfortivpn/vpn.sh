#!/bin/bash
# Openfortivpn wrapper script; <github.com/mxwilson/bashutils>; Sep 2022; ver 0.1 
# GNU General Public License v3.0

PATH=${PATH}:/usr/bin:
SCRIPTNAME=$(basename -- "$0")
CONFIGFILE="/etc/openfortivpn/config"
LOGFILE="/var/log/vpn_log.log"

if [ $# -gt 1 ] ; then
	echo "Not running. Too many arguments."
	echo "How to use: ${SCRIPTNAME} [--kill]"
	exit 1
elif [ $# -eq 0 ] ; then
	RUN_TYPE="actual"
else
	while test $# -gt 0; do
		case "$1" in 
			--kill)
			shift
			RUN_TYPE="shutdown"
			shift
			;;
		*)
			echo "How to use: ${SCRIPTNAME} [--kill]"
			exit 1
			;;
		esac
	done
fi

if [ ${RUN_TYPE} = "actual" ] ; then 
	$(pgrep openfortivpn > /dev/null 2>&1)

	if [ $? -eq 0 ] ; then 
		echo "Error. Openfortivpn already running?"
		exit 1
	fi
	
	echo "Starting Openfortivpn..."
	printf "[$(date)]\n" >> ${LOGFILE}

	$(sudo openfortivpn -c ${CONFIGFILE} >> ${LOGFILE} 2>&1 &)
	
	if [ ! $? -eq 0 ] ; then 
		echo "Error. Unable to connect to VPN".
		exit 1
	fi
fi

if [ ${RUN_TYPE} = "shutdown" ] ; then
	MYPID=$(pgrep openfortivpn)

	if [ ! ${MYPID} ] ; then
		echo "Error. Unable to shutdown Openfortivpn. No longer running?"
	else
		$(sudo kill ${MYPID})
		
		if [ $? -eq 0 ] ; then 
			echo "Shutdown of Openfortivpn."
		else
			echo "Unable to shutdown Openfortivpn."
			exit 1
		fi
	fi
fi

exit 0
