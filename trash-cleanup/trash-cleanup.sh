#!/bin/bash

# trash-cleanup.sh : Script to be run by cron job to empty trash cans of users. 
# Copyright Matthew W, 2019 <http://github.com/mxwilson>
# GNU General Public License v3.0

readonly FILEAGE="+7" # delete all files and dirs older than 7 days
readonly MYFULLPATH="/blahmount/userhomedirs"
readonly REL_TRASHDIR=".local/share/Trash"
readonly TRASHFOLDER1="expunged"
readonly TRASHFOLDER2="files"
readonly TRASHFOLDER3="info"
readonly LOGFILE="/var/log/trash-cleanup.log"
readonly LOCKFILE="/run/lock/trash-cleanup.lock"
readonly MAILTO="myemail@yandex.ru"

function MAILER () {
if [ ${1} == "fail_lock" ] || [ ${1} == "fail_mount" ] ; then
	mail_subject="[FAILURE] [TRASH CLEANUP]" 
	if [ ${1} == "fail_lock" ] ; then	
		mail_body="Lock file exists. Is the script still running?"
	else
		mail_body="${MYFULLPATH} doesn't appear to be mounted."
	fi
fi

if [ ${1} == "success_run" ] ; then
	mail_subject="[SUCCESS] [TRASH CLEANUP]"
	mail_body="Trash cleanup completed. Run type: ${RUN_TYPE}"
fi

/usr/sbin/sendmail -i -- ${MAILTO} <<EOF
Subject: ${mail_subject}
From: donotreply@myhost.ru
${mail_body}
EOF
}

# Check for argument flags to determine if dry run or not. No flags = dry run. -f = actual run.

if [ $# -gt 1 ] ; then
        echo "Not running. Too many arguments."
        exit 1
elif [ $# -eq 0 ] ; then
        RUN_TYPE="dry"
else
	while test $# -gt 0; do
		case "$1" in
	  	    -f)
                       shift
            	       RUN_TYPE="actual"
            	       shift
            	       ;;
	  	     *)
	    	       echo "Not running. $1 is not a flag."
            	       exit 1
            	       ;;
		esac
	done
fi

if [ $RUN_TYPE == "actual" ] ; then
	readonly FINDCMD="rm -rfv"
else
	readonly FINDCMD="echo"
fi

# Check for lock file first

if [ -e "$LOCKFILE" ] ; then
        echo "[$(date)]: [FAILURE] - Lock file exists. Is the script still running?" >> $LOGFILE
	MAILER "fail_lock"
        exit 1
else
        touch $LOCKFILE
fi

# Check if mount point of home dirs is available

if [ ! -e "$MYFULLPATH" ] ; then
 	echo "[$(date)]: [FAILURE] - Homedir path not available: ${MYFULLPATH} " >> $LOGFILE
	MAILER "fail_mount"
	rm $LOCKFILE
	exit 1
fi

echo "[$(date)]: [START] [RUN TYPE: ${RUN_TYPE^^}] - Successful script launch." >> $LOGFILE

# Get array of home dirs (ie usernames) first
mapfile -t HOMEDIRLISTARR < <(ls -1 $MYFULLPATH)

exec 2>>$LOGFILE

for i in ${!HOMEDIRLISTARR[@]}; do
        #move to next user if no trash folder, or symlink is encountered
        if [ ! -e ${MYFULLPATH}/${HOMEDIRLISTARR[i]}/${REL_TRASHDIR} ] ; then
                echo "No trash folder for ${HOMEDIRLISTARR[i]} - skipping." >> $LOGFILE
                continue;
        elif [[ -L ${MYFULLPATH}/${HOMEDIRLISTARR[i]} && -d ${MYFULLPATH}/${HOMEDIRLISTARR[i]} ]] ; then
                echo "Symlink encountered at ${HOMEDIRLISTARR[i]} - skipping." >> $LOGFILE
                continue;
        else
                FULLDIR1="${MYFULLPATH}/${HOMEDIRLISTARR[i]}/${REL_TRASHDIR}/${TRASHFOLDER1}"
                FULLDIR2="${MYFULLPATH}/${HOMEDIRLISTARR[i]}/${REL_TRASHDIR}/${TRASHFOLDER2}"
                FULLDIR3="${MYFULLPATH}/${HOMEDIRLISTARR[i]}/${REL_TRASHDIR}/${TRASHFOLDER3}"

                $(find ${FULLDIR1} ${FULLDIR2} ${FULLDIR3} -mindepth 1 -type d -mtime ${FILEAGE} -prune -exec ${FINDCMD} {} \; 1>>$LOGFILE)
                $(find ${FULLDIR1} ${FULLDIR2} ${FULLDIR3} -type f -mtime ${FILEAGE} -exec ${FINDCMD} {} \; 1>>$LOGFILE)
        fi
done

echo "[$(date)]: [END] [RUN TYPE: ${RUN_TYPE^^}] - Successful script run." >> $LOGFILE
MAILER "success_run"
rm $LOCKFILE
exit 0
