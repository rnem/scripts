#!/bin/bash
#################################################################################
# SEND ALERT ABOUT THE MINIONS NOT RESPONDING - DO NOT DELETE/CHANGE            #
# Created by Roger Nem - 2016                                                   #
# v0.002 - Roger Nem -  Updated SQL query to exclude certain VMs                #
# v0.003 - Roger Nem -  Updated SQL query and added more VMs to be excluded     #
#                       If file is empty do not send message                    #
#################################################################################

### Variables
dbhost="dbhost"
dbuser="dbuser"
dbpass="dbpass"
database="database"
table="12345678" # cloud account

file="minions_not_ok.txt"
EMAILFROM="noreply@minions-not-responding.localdomain"
EMAILTO="DL1@domain.com"
EMAILCC=""
EMAILSUBJ="** CRITICAL: Minions NOT responding **"
read -r -d '' EMAILMSG <<'EOF'
Dear team,

The attached file contains the list of minions not responding today.

Please investigate to ensure the 'salt-minion' service is running on these VMs and that everything is ok.

IMPORTANT: vm-master and Windows machines should be ignored.

Thanks,
Service Delivery Team
EOF


### Connecting to the DB and listing the minions with issues
query="SELECT server_name FROM \`${table}\` WHERE minion_ok='N' AND server_name!='vm-master' AND (server_name NOT REGEXP 'VM-REGION-*');"

mysql -s -u${dbuser} -p${dbpass} -D${database} -h${dbhost} -e "${query}" > ${file}

### If the file is not empty then send the alert
if [ -s "${file}" ]; then
        echo "Sending email..."
        echo "${EMAILMSG}" | mail -s "${EMAILSUBJ}" -r "${EMAILFROM}" -a "${file}" -c "${EMAILCC}" "${EMAILTO}"
else
        echo "No alert email to send..."
fi

### Security
rm -f /folder/${file}