#!/bin/bash
#########################################################################
#                                                                       #
# Delete L2, L3 local user accounts                                     #
# by Roger Nem (2015)                                                   #
#                                                                       #
# History:                                                              #
#   v0.001  - Roger Nem - First Version                                 #
#                                                                       #
#########################################################################

today=$(date +%Y-%m-%d-%H:%M:%S)

SRCFILE="/folder_CTA/l2l3localaccounts.csv"
LOGFILE="/folder_CTA/l2l3localaccountsdeletion.$today.log"
HOSTNAME="$(hostname)"

array=( user1 user2 user3 user4 )

function do_echo {
	local MSG="${1}"
	local LOGDATE=$(date +"%Y-%m-%d %H:%M:%S")
	echo "${LOGDATE} - ${MSG}"
	echo "${LOGDATE} - ${MSG}" >> ${LOGFILE}
}

function delete_local_accounts {

	#for USR_LOCAL in `cat $SRCFILE`; do
	for USR_LOCAL in "${array[@]}"

		# Check if user is available on current system, go further
		if [ $(id ${USR_LOCAL} >/dev/null 2>&1;echo $?) -eq 0 ]; then

			do_echo "$HOSTNAME - Local Account $USR_LOCAL exists."

			for I in $(pgrep -u ${USR_LOCAL});do kill $I; done #start with this one

			sleep 5 # give time for the process to finish

			for I in $(pgrep -u ${USR_LOCAL});do kill -9 $I; done #kill indeed

		userdel $USR_LOCAL
		do_echo "$HOSTNAME - Local Account $USR_LOCAL DELETED"

		if [ -d /home/${USR_LOCAL} ]; then
			#rm -rf /home/$USR_LOCAL
			do_echo "$HOSTNAME - $USR_LOCAL homedir DELETED"
		else
			do_echo "$HOSTNAME - $USR_LOCAL doesn't have a homedir"
		fi;

		else
			do_echo "$HOSTNAME - Local Account $USR_LOCAL doesn't exist."
		fi;

	done
}

### Main program ########################################################

delete_local_accounts "${1}"