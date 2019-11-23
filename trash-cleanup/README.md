**trash-cleanup.sh**

This script forcibly empties the trash cans inside Linux users home directories (located on a network). Ideally run by a cron job on a host that exposes a r/w mount of the /userhomedirs/<user1> ... <user2>. 
It will delete files and directories older than an X number of days as specified by a the fileage variable. It supports local logging and sends e-mail notifications in the event of success or failure.

How to run:

trash-cleanup.sh      :: DRY RUN

trash-cleanup.sh -f   :: ACTUAL RUN


GNU General Public License v3.0
