#!/bin/bash
#########################################################################
#                                                                       #
# Disable local accounts that were not re-certified                     #
# by Roger Nem (2015)                                                   #
#                                                                       #
# History:                                                              #
#  v0.001  - Roger Nem - First Version                                  #
#                                                                       #
#########################################################################

## Variables ###########################################################
USERARR=()
SRV_NAME=""
USR_LOCAL=""
SRCFILE="/folder_CTA/users2disable.csv"
LOGFILE="/folder_CTA/users2disable.log"

### Functions ###########################################################

## Give response to screen and logfile
function do_echo {
	local MSG="${1}"
	local LOGDATE=$(date +"%Y-%m-%d %H:%M:%S")
	echo "${LOGDATE} - ${MSG}" >> ${LOGFILE} #To log the output
	echo "${LOGDATE} - ${MSG}" | tee -a ${LOGFILE}
}

## Read the users file into an array
function read_users {

	if [ -e "${SRCFILE}" ]; then
		readarray -t USERARR < ${SRCFILE}
	else
		do_echo "'${SRCFILE}' not found..."
		exit 255
	fi
}

## Do the migration for the user
function disable_users {

	local SRV_MATCH="false"         # false=no servername / hostname match
	local HOSTNAME="$(hostname)"    # For the hostname

	for ((i=0;i < ${#USERARR[@]};i++)); do

		SRV_NAME=$(echo ${USERARR[${i}]}|cut -d ";" -f 1)
		USR_LOCAL=$(echo ${USERARR[${i}]}|cut -d ";" -f 2)

		shopt -s nocasematch    # Make it not case sensitive
		[[ "${HOSTNAME}" =~ "${SRV_NAME}" ]]    # Check if the servername is the expected one.
		shopt -u nocasematch    # Unset not case sensitive matching

		# Check if it matches
		if [ "${BASH_REMATCH[*]}" != "" ]; then
			SRV_MATCH="true"
		else
			SRV_MATCH="false"
		fi

		if [ "${SRV_MATCH}" == "true" ]; then

			#do_echo ""
			#do_echo "Server: $SRV_NAME / Local User: $USR_LOCAL"
			#do_echo "----------------------------------------------------"
			#do_echo ""

			# Check if user is available on current system, go further
			if [ $(id ${USR_LOCAL} >/dev/null 2>&1;echo $?) -eq 0 ]; then

				#####################################################
				# START: Disable Local account
				#####################################################

				usermod --lock --expiredate 1970-02-02 ${USR_LOCAL}
				do_echo "Local user '${USR_LOCAL}' exists on $SRV_NAME and was disabled."

				#####################################################
				# END: Disable Local account
				#####################################################

			else
				do_echo "Local user '${USR_LOCAL}' doesn't exist anymore on $SRV_NAME."
			fi
		fi
	done
}

## Initiate the complete process this script is intended for
function do_process {
    read_users
    disable_users
}

### Main program ########################################################

do_process "${1}"