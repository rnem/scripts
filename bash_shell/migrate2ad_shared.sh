#!/bin/bash
##########################################################################
# Script: Migration of local users accounts setup to AD setup (Shared)   #
# - by Roger Nem (2015)                                                  #
#                                                                        #
# History:                                                               #
# v0.001  - Roger Nem - First Version                                    #
# v0.002  - Roger Nem - Moved ACLs to a function to avoid the loop       #
#                                                                        #
##########################################################################

### Variables ###########################################################
USERARR=()
SRV_NAME=""
USR_LOCAL=""
USR_AD=""
SRCFILE="/folder_CTA/users2migrate_shared.csv"
LOGFILE="/folder_CTA/migrate2ad_shared.log"


### Functions ###########################################################

## Give response to screen and logfile
function do_echo {
    local MSG="${1}"
    local LOGDATE=$(date +"%Y-%m-%d %H:%M:%S")
    echo "${LOGDATE} - ${MSG}" | tee -a ${LOGFILE}
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
function do_shared_migration {

    local SRV_MATCH="false"         # false=no servername / hostname match
    local HOSTNAME="$(hostname)"    # For the hostname

    do_echo "======================================================================================"
    do_echo "STARTING THE MIGRATION OF LOCAL ACCOUNTS"
    do_echo "======================================================================================"

    for ((i=0;i < ${#USERARR[@]};i++)); do

        SRV_NAME=$(echo ${USERARR[${i}]}|cut -d ";" -f 1)
        USR_LOCAL=$(echo ${USERARR[${i}]}|cut -d ";" -f 2)
        USR_AD=$(echo ${USERARR[${i}]}|cut -d ";" -f 3)
        USR_AD=${USR_AD#*\\}        # Remove existing domain in front - domainrack - not needed
        GROUP_AD=$(echo ${USERARR[${i}]}|cut -d ";" -f 4 | tr '[:upper:]' '[:lower:]')
        WEB_CONTAINER=$(echo ${USERARR[${i}]}|cut -d ";" -f 5 | tr '[:upper:]' '[:lower:]')

        shopt -s nocasematch        # Make it not case sensitive
        [[ "${HOSTNAME}" =~ "${SRV_NAME}" ]] # Check if the servername is the expected one.
        shopt -u nocasematch        # Unset not case sensitive matching

        # Check if it matches
        if [ "${BASH_REMATCH[*]}" != "" ]; then
            SRV_MATCH="true"
        else
            SRV_MATCH="false"
        fi

        if [ "${SRV_MATCH}" == "true" ]; then

            do_echo ""
            do_echo "Server: $SRV_NAME / Local User: $USR_LOCAL / AD User: $USR_AD"
            do_echo "-------------------------------------------------------------"
            do_echo ""

            # Check if user is available on current system, go further
            if [ $(id ${USR_LOCAL} >/dev/null 2>&1;echo $?) -eq 0 ]; then

                if [ $(id ${USR_AD} >/dev/null 2>&1;echo $?) -eq 0 ]; then

                    do_echo "Both users '${USR_LOCAL}' and '${USR_AD}' exist."

                    #####################################################
                    # START: Local account migration to AD
                    #####################################################

                    # 1 - verify if AD home dir exists
                    if [ -d /home/${USR_AD} ]; then
                        do_echo "$USR_AD AD homedir exists"
                    else
                        do_echo "$USR_AD AD homedir doesn't exist"
                        do_echo "mkdir /home/${USR_AD}"

                        mkdir /home/${USR_AD}
                    fi

                    # 2 - copy all from local homedir to AD home dir

                    if [ -d /home/${USR_LOCAL} ]; then

                        do_echo "$USR_LOCAL local homedir exists"
						do_echo "cp -R /home/${USR_LOCAL}/* /home/${USR_AD} - copy all from local homedir to AD home dir"
						cp -R /home/${USR_LOCAL}/* /home/${USR_AD}

                    else
                        do_echo "$USR_LOCAL local homedir doesn't exist. Nothing to copy"
                    fi

                    # 3 - Assign proper permissions

                    do_echo "Assign proper permissions"
                    do_echo "chown -R ${USR_AD}:\"domain users\" /home/${USR_AD}"
                    do_echo "chmod -R 700 /home/${USR_AD}/"

                    chown -R ${USR_AD}:"domain users" /home/${USR_AD}
                    chmod -R 700 /home/${USR_AD}/

                    # Rest moved to a function to avoid the loop

                    #####################################################
                    # END: Local account migration to AD
                    #####################################################

                else
                    do_echo "AD user '${USR_AD}' doesn't exist."
                fi
            else
                do_echo "Local user '${USR_LOCAL}' doesn't exist."
            fi
        fi
    done

    do_echo "======================================================================================"
    do_echo "END OF THE MIGRATION OF LOCAL ACCOUNTS"
    do_echo "======================================================================================"
}


function do_set_acls {

	do_echo ""
    do_echo "======================================================================================"
    do_echo "STARTING SETTING THE PROPER ACLS"
    do_echo "======================================================================================"

	for WEB_CONTAINER in `cat ${SRCFILE} | cut -d ";" -f 5 | tr '[:upper:]' '[:lower:]' | sort | uniq`; do

		GROUP_AD=$(echo ${WEB_CONTAINER//_/\.})

        # 3 - Assign proper permissions

        if [ -d /var/www/html/${WEB_CONTAINER} ]; then

            # 4 - ACLs
						
            do_echo ""
            do_echo "/var/www/html/${WEB_CONTAINER}/ exists"
            do_echo "Set ACLs"
            do_echo "setfacl -Rm g:${GROUP_AD}:rwx /var/www/html/${WEB_CONTAINER}/"
            do_echo "setfacl -Rm g:apache:rx /var/www/html/${WEB_CONTAINER}/"
            do_echo "setfacl -Rm u:dsuser:rwx /var/www/html/${WEB_CONTAINER}/"

            setfacl -Rm g:${GROUP_AD}:rwx /var/www/html/${WEB_CONTAINER}/
            setfacl -Rm g:apache:rx /var/www/html/${WEB_CONTAINER}/
            setfacl -Rm u:dsuser:rwx /var/www/html/${WEB_CONTAINER}/

            # 5 - Web Container

            do_echo "Assign proper permissions to the Web Container"
            do_echo "chown -R root:${GROUP_AD} /var/www/html/${WEB_CONTAINER}/"
            do_echo "chmod -R 2775 /var/www/html/${WEB_CONTAINER}/"

            chown -R root:${GROUP_AD} /var/www/html/${WEB_CONTAINER}/
            chmod -R 2775 /var/www/html/${WEB_CONTAINER}/

            getfacl -p /var/www/html/${WEB_CONTAINER}

        else
            do_echo "/var/www/html/${WEB_CONTAINER}/ doesn't exist"
        fi

	done

    do_echo "======================================================================================"
    do_echo "END OF SETTING THE PROPER ACLS"
    do_echo "======================================================================================"
}

## Initiate the complete process this script is intended for
function do_process {
    do_read_users
    do_shared_migration
    do_set_acls
}

### Main program ########################################################
do_process "${1}"