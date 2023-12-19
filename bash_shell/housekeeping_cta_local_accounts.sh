#!/bin/bash
##########################################################################
#                                                                        #
# Housekeeping Script for File Cleanup for CTA Localaccounts Saltformula #
#                                                                        #
#       v0.1    - Roger Nem - First version                              #
#       v0.2    - Roger Nem - Fixed issue with date calculation          #
#                                 Problem with calculation over year     #
#                                 borders now fixed.                     #
#                                                                        #
##########################################################################

trap "echo;echo 'Script Abort';exit" INT TERM

## Definition of Variables ############################################
APPVER="v0.2"                   # Application verison
APPNAME=$(basename $0)          # Application name, without path
APPPATH=${0%/*}                 # Application path, without name
LOGTAG="${APPNAME} ${APPVER}"   # Tag for logger
ENTRY=""                        # Variable for the single ENTRY in list

### Functions #########################################################
function getfilenames {
    local TPATH="$1"            # Target Path to search
    local TDATE=$2              # Target date (-7 days)
    local TFNAME="$3"           # Target filename

    local TMPFILE=$(mktemp /tmp/${APPNAME}.XXXXXXXXXX)
    local TMPDATE=$(date -d "${TDATE}" +%Y%m%d%H%M)

    touch -t ${TMPDATE} ${TMPFILE}

    echo $(find ${TPATH} -type f ! -newer ${TMPFILE} -iname "${TFNAME}"|sort)

    rm ${TMPFILE}
}
     
function doremove {
    local LIST=$*               # List with filenames

    for ENTRY in ${LIST}; do
#----------------------------------------------------------------------------------
# For production use, comment the following line, to have no duplicate displays
        echo $(ls -al $ENTRY)
# For production use, enable the next two lines to have the files removed for real!
#        logger -t ${LOGTAG} "Removed: $(ls -al ${ENTRY})"
#        rm  "${ENTRY}"
#----------------------------------------------------------------------------------
    done
}

### Main program ########################################################

### --- Insert doremove line here, if you want to remove the files regardless of diskusage --- ###
doremove $(getfilenames "/cta_local_accounts" "-30 days" "*.csv.gz")
### --- Insert doremove line here, if you want to remove the files regardless of diskusage --- ###