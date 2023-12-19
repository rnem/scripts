#!/bin/bash
#########################################################################
#                                                                       #
# Migrate local user to AD-user on LAMP                                 #
# by Roger Nem (2015)                                                   #
#                                                                       #
# History:                                                              #
# v0.001  - Roger Nem - First Version                                   #
# v0.002  - Roger Nem - Clean up / Updates / Fixes                      #
# v0.003  - Roger Nem - Updates to Dedicated Environment                #
#                                                                       #
#########################################################################


### Variables ###########################################################
USERARR=()
SRV_NAME=""
USR_LOCAL=""
USR_AD=""
TMPFILE=$(mktemp /tmp/AD_stuff_CTA/migrate2ad.XXXXX)
SRCFILE="/tmp/AD_stuff_CTA/users2migrate_final.csv"
LOGFILE="/tmp/AD_stuff_CTA/users2migrate_final.log"


trap 'do_remove_tmpfiles' EXIT SIGTERM SIGINT

### Functions ###########################################################

## Remove temporary files and exit
function do_remove_tmpfiles {
    rm ${TMPFILE} >/dev/null 2>&1
    echo
    exit
}

## Give response to screen and logfile
function do_echo {
    local MSG="${1}"
    local LOGDATE=$(date +"%Y-%m-%d %H:%M:%S")
	echo "${LOGDATE} - ${MSG}"
    echo "${LOGDATE} - ${MSG}" >> ${LOGFILE} #To log the output to migrate2ad.log
}

## Read the users file into an array
function do_read_users {

    if [ -e "${SRCFILE}" ]; then
        readarray -t USERARR < ${SRCFILE}
    else
        do_echo "'${SRCFILE}' not found..."
        exit 255
    fi
}

## Do the migration for the user
function do_migrate_user {

    local SRV_MATCH="false"        # false=no servername / hostname match
    local HOSTNAME="$(hostname)"   # For the hostname

    for ((i=0;i < ${#USERARR[@]};i++)); do

        SRV_NAME=$(echo ${USERARR[${i}]}|cut -d ";" -f 1)
        USR_LOCAL=$(echo ${USERARR[${i}]}|cut -d ";" -f 2)
        USR_AD=$(echo ${USERARR[${i}]}|cut -d ";" -f 3)
        USR_AD=${USR_AD#*\\}       # Remove existing domain in front - domainrack - not needed
                
        shopt -s nocasematch       # Make it not case sensitive
        [[ "${HOSTNAME}" =~ "${SRV_NAME}" ]]  # Check if the servername is the expected one.   
        shopt -u nocasematch       # Unset not case sensitive matching

        # Check if it matches
        if [ "${BASH_REMATCH[*]}" != "" ]; then
            SRV_MATCH="true"
        else
            SRV_MATCH="false"
        fi

        if [ "${SRV_MATCH}" == "true" ]; then

            do_echo "Server: $SRV_NAME / Local User: $USR_LOCAL / AD User: $USR_AD"

            #####################################################
			# START: Local account migration to AD - Dedicated
			#####################################################

			# SUDOERS
			#echo "" >> /etc/sudoers
			#echo "## Active Directory Project - DO NOT DELETE" >> /etc/sudoers

			#do_echo "%domain_lamp_sudoers        ALL=(ALL)       ALL"
			#echo "%domain_lamp_sudoers        ALL=(ALL)       ALL" >> /etc/sudoers

			#do_echo "%domainfulladmin        ALL=(ALL)       ALL"
			#echo "%domainfulladmin        ALL=(ALL)       ALL" >> /etc/sudoers

			do_echo "%${SRV_NAME}        ALL=(ALL)       ALL"
			echo "%${SRV_NAME}        ALL=(ALL)       ALL" >> /etc/sudoers


			# Allowed Groups - Default - DSU
			echo "" >> /etc/ssh/sshd_config
			echo "## Active Directory Project - DO NOT DELETE" >> /etc/ssh/sshd_config

			do_echo "AllowGroups domain_lamp_sudoers domainfulladmin cloudconnect wheel cloud"
			echo "AllowGroups domain_lamp_sudoers domainfulladmin cloudconnect wheel cloud" >> /etc/ssh/sshd_config

			# Allowed Groups - Agency
			do_echo "AllowGroups ${SRV_NAME}"
			echo "AllowGroups ${SRV_NAME}" >> /etc/ssh/sshd_config

			# Apply changes					
			service sshd restart

			# Clean-up to not expose user accounts
			rm -rf ${SRCFILE}

			#####################################################
			# END: Local account migration to AD - Dedicated
			#####################################################

        fi
    done

}

## Initiate the complete process this script is intended for
function do_process {
    do_read_users
    do_migrate_user
}

### Main program ########################################################

do_process "${1}"