#!/bin/bash
#################################################################################
#                                                                               #
# Get CTA local accounts script to automate the creation process via salt       #
#                                                                               #
# by Roger Nem 2015                                                             #
#                                                                               #
# History:                                                                      #
#               v0.001  - Roger Nem  - First version                            #
#               v0.002  - Roger Nem  - Changed salt execution to state.sls.     #
#                                      Added EMAILFROM variable.                #
#               v0.003  - Roger Nem  - Fixed output by removing the extra       #
#                                      line with $result=sprintf... in it.      #
#               v0.004  - Roger Nem  - Increased the execution time from        #
#                                      120 to 240 seconds.                      #
#               v0.005  - Roger Nem  - Adapt the RegEx for userscript v0.6      #
#               v0.006  - Roger Nem  - Adapt the RegEx for the userscript v0.8  #
#               v0.007  - Roger Nem  - Enabled the GLOBE DSU LAMP distlist.     #
#                                      Reduced the EMAILTO recipients.          #
#               v0.008  - Roger Nem  - E-mail message updated                   #
#                                      EMAILTO & EMAILCC updated                #
#               v0.009  - Roger Nem  - Line break removed from signature        #
#                                                                               #
#################################################################################

### Variable definition #########################################################
CURRDATE=$(date +"%m-%d-%Y_%H:%M")

APPPATH="$(cd $(dirname $0) && pwd && cd - >/dev/null 2>&1)"  # Path where this script is started from
CTALOCACC="${APPPATH}/${CURRDATE}_cta_local_accounts"         # CTA local accounts from the servers the script runs on.
EMAILTO="DL1@domain.com"
EMAILCC=""
EMAILFROM="noreply@cta-local-accounts"
EMAILSUBJ="[CTA Report] - Local accounts in the LAMP Shared & Dedicated Environments - ${CURRDATE}"
read -r -d '' EMAILMSG <<'EOF'
Greetings,

Please refer to the attached CSV file (mm-dd-yyyy_H:m) for local user accounts in the LAMP Shared and Dedicated Environments.

Best regards,
Service Delivery Team
EOF


### Check for root permissions
[[ $EUID -ne 0 ]] && echo "This script has to be excecuted as 'root', aborting script." && exit

### Check for already existing result files and abort
[[ -e "${CTALOCACC}.csv.gz" ]] && echo "Result file '${CTALOCACC}.csv.gz' already exits, aborting script." && exit

### Get the CMS versions from the servers ##

echo "Doing salt for servers..."
salt -t 15 --no-color --out-file="${CTALOCACC}.txt" '*' state.sls cta_disable_local_accounts

### Second, process the files and convert them to csv files e.g. for Excel

# All the data has to be written to disk
sync

# Convert dedicated_shared file to csv
echo "Convert servers result file..."
egrep ".*,.+,.+,.+,.+,.+,.+,.+,.+,.+,.+,.+,.+" "${CTALOCACC}.txt" | sed 's/^\s*//' | sort -u | egrep -v "^echo|^@|^Comment|^File|result=sprintf|^CSVHEADER" > "${CTALOCACC}.csv"

# Write all data to disk
sync

# Remove all no longer needed files from disk
echo "Removing no longer needed files..."
[[ "${CTALOCACC}" != "" ]] && [[ -e "${CTALOCACC}.txt" ]] && rm -f "${CTALOCACC}.txt"

sync

echo "Sending email to the defined recipients..."
echo "${EMAILMSG}" | mail -s "${EMAILSUBJ}" -r "${EMAILFROM}" -a "${CTALOCACC}.csv" -c "${EMAILCC}" "${EMAILTO}"

echo "do chmod 660 to the '.csv' files ..."
chmod 660 ${APPPATH}/*.csv

echo "Compress the result files to save disk space"
gzip -9 ${APPPATH}/*.csv

echo "Finished"