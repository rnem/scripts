#!/bin/bash
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
##  Script to verify if AD home dir exists                  ##
##  Created by Roger Nem - 2015                             ##
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

USERARR=()
SRCFILE="users2migrate.csv"
LOGFILE="hdexists.log.txt"
TMPFILE=$(mktemp /tmp/hdexists.XXXXX)

function do_echo {
    local MSG="${1}"
    local LOGDATE=$(date +"%Y-%m-%d %H:%M:%S")

    echo "${LOGDATE} - ${MSG}" | tee -a ${LOGFILE}  #To log the output to migrate2ad.log
}

    if [ -e "${SRCFILE}" ]; then
        #sort -u "${SRCFILE}" | grep -v ^# > ${TMPFILE}
        readarray -t USERARR < ${SRCFILE}
    else
        do_echo "'${SRCFILE}' not found..."
        exit 255
    fi


SRV_MATCH="false"
HOSTNAME="$(hostname)"

for ((i=0;i < ${#USERARR[@]};i++)); do

    SRV_NAME=$(echo ${USERARR[${i}]}|cut -d ";" -f 1)
    USR_AD=$(echo ${USERARR[${i}]}|cut -d ";" -f 3)
    USR_AD=${USR_AD#*\\}

    shopt -s nocasematch
    [[ "${HOSTNAME}" =~ "${SRV_NAME}" ]]

    shopt -u nocasematch # Unset not case sensitive matching

    # Check if it matches
    if [ "${BASH_REMATCH[*]}" != "" ]; then
		echo "servername '${SRV_NAME}' match hostname: '$(hostname)'"
        SRV_MATCH="true"
    else
		echo "servername '${SRV_NAME}' does not match hostname: '$(hostname)'"
        SRV_MATCH="false"
    fi

    if [ "${SRV_MATCH}" == "true" ]; then

        # Check if user is available on current system, go further
        if [ $(id ${USR_LOCAL} >/dev/null 2>&1;echo $?) -eq 0 ]; then
            if [ $(id ${USR_AD} >/dev/null 2>&1;echo $?) -eq 0 ]; then

                if [ -d /home/${USR_AD} ]; then
                    echo "/home/${USR_AD} - AD home dir EXISTS" | tee -a ${LOGFILE}
                else
                    echo "/home/${USR_AD} - AD home dir does NOT exist" | tee -a ${LOGFILE}
                fi

            fi
        fi
    fi

done