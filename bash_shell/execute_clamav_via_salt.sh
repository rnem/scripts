#!/bin/bash
#################################################################################
#                                                                               #
# Get clamav script to automate the creation process via salt                   #
#                                                                               #
# by Roger Nem 2015                                                             #
# History:                                                                      #
#               v0.001 - Roger Nem  - First version                             #
#                                                                               #
#################################################################################

### Variable definition #########################################################
CURRDATE=$(date +"%Y%m%d-%H:%M")

APPPATH="$(cd $(dirname $0) && pwd && cd - >/dev/null 2>&1)"  # Path where this script is started from
CLAMAVLOG="${APPPATH}/${CURRDATE}_clamav_log"                 # ClamAV Installation from the servers.
EMAILTO="DL1@domain.com"
EMAILCC="CC1@domain.com"
EMAILFROM="noreply@clamav-installation-log"
EMAILSUBJ="ClamAV installation/update in the LAMP Environment - ${CURRDATE}"
read -r -d '' EMAILMSG <<'EOF'
Greetings,

See attached file including the current CTA for the local accounts in the LAMP Environment.

File: '<date>_cta_local_accounts.csv' contains the information about the local accounts in the LAMP Environment.

You can use Excel to open the files and it will automatically split the lines.
You only have to arrange them as you wish.

Best regards,
Service Delivery Team
EOF


### Check for root permissions
[[ $EUID -ne 0 ]] && echo "This script have to be excecuted as 'root', abort script." && exit

### Check for already existing result files and abort
[[ -e "${CLAMAVLOG}.log.gz" ]] && echo "Result file '${CLAMAVLOG}.log.gz' already exists, abort script." && exit

### Get the CMS versions from the servers ##

echo "Doing salt for servers..."
salt -t 90 --no-color --out-file="${CLAMAVLOG}.txt" '*' state.sls clamav

### Second, process the files and convert them to csv files e.g. for Excel

# All the data has to be written to disk
sync

## Convert dedicated_shared file to csv
#echo "Convert servers result file..."
#egrep ".*,.+,.+,.+,.+,.+,.+,.+,.+,.+,.+,.+,.+" "${CLAMAVLOG}.txt" | sed 's/^\s*//' | sort -u | egrep -v #"^echo|^@|^Comment|^File|result=sprintf|^CSVHEADER" > "${CLAMAVLOG}.csv"
#
## Write all data to disk
#sync
#
## Remove all no longer needed files from disk
#echo "Removing no longer needed files..."
#[[ "${CLAMAVLOG}" != "" ]] && [[ -e "${CLAMAVLOG}.txt" ]] && rm -f "${CLAMAVLOG}.txt"
#
#sync

echo "Sending email to the defined recipients..."
echo "${EMAILMSG}" | mail -s "${EMAILSUBJ}" -r "${EMAILFROM}" -a "${CLAMAVLOG}.csv" -c "${EMAILCC}" "${EMAILTO}"

echo "do chmod 660 to the '.txt' files ..."
chmod 660 ${APPPATH}/*.txt

echo "Compress the result files to save disk space"
gzip -9 ${APPPATH}/*.txt

echo "Finished"
