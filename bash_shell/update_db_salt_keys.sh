#!/bin/bash
######################################################################################
#                                                                                    #
# Verifies existing salt-keys against the list of VMs and updates clouddomainapi DB  #
#                                                                                    #
# by Roger Nem - 2016                                                                #
#                                                                                    #
# History:                                                                           #
#               v0.001 - Roger Nem - First version                                   #
#               v0.002 - Roger Nem - added lowercase to VM names                     #
#               v0.003 - Roger Nem - added minion response status                    #
#               v0.004 - Roger Nem - Optimized                                       #
#               v0.005 - Roger Nem - Exact match grep                                #
#               v0.006 - Roger Nem - Removed :lower: to match VM name in RS          #
#               v0.007 - Roger Nem - added lowercase to VM names back                #
#                                    RS: r65-LDEPCOW1.domainrack.local               #
#                                    salt: r65-ldepcow1.domainrack.local             #
#                                                                                    #
######################################################################################

# Variables
dbhost="db-pma"
dbuser="dbuser"
dbpass="dbpass"
database="clouddomainapi"
table="12345678" # domain cloud account

# Connecting to the DB and listing the VMs
mysql -s -u${dbuser} -p${dbpass} -D${database} -h${dbhost} -e "SELECT server_name FROM \`${table}\`;" > VMs.txt

# Clear results
mysql -s -u${dbuser} -p${dbpass} -D${database} -h${dbhost} -e "UPDATE \`${table}\` SET minion_ok='';"

for list in `cat VMs.txt | tr '[:upper:]' '[:lower:]'`; do

    # Does the minion have a key yet?
    key=$(salt-key -L | grep -w "^${list}$")

    # Is the minion responding?
    res=$(salt -t10 ${list} test.ping --out txt | cut -d":" -f2 | tr -d '[:space:]')

    if [[ "$key" == "${list}" ]]; then
        if [[ "$res" == "True" ]]; then
            echo "$key,${list},$res,Y;Y"
            mysql -s -u${dbuser} -p${dbpass} -D${database} -h${dbhost} -e "UPDATE \`${table}\` SET salt_key='Y',minion_ok='Y' WHERE server_name='${list}';"
        else
            echo "$key,${list},$res,Y;N"
            mysql -s -u${dbuser} -p${dbpass} -D${database} -h${dbhost} -e "UPDATE \`${table}\` SET salt_key='Y',minion_ok='N' WHERE server_name='${list}';"
        fi
    else
        echo "$key,${list},$res,N;N"
        mysql -s -u${dbuser} -p${dbpass} -D${database} -h${dbhost} -e "UPDATE \`${table}\` SET salt_key='N',minion_ok='N' WHERE server_name='${list}';"
    fi

done

# Security
rm -f /rsapi/VMs.txt