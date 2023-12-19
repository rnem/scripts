#!/bin/bash
#############################################
# Script: Test Connection                   #
# - by Roger Nem (2015)                     #
#############################################

timestorun=10
host=$(hostname)

J=0; I=0; 

for (( t=1; t<=$timestorun; t++ )); do

    sshpass -p ****** ssh -o ConnectTimeout=5 -o ConnectionAttempts=1 -oStrictHostKeyChecking=no dsutestad@$host 'date' > /dev/null 2>/dev/null; 

    #echo "J:$J - I:$I";

    if [ $? -ne 0 ]; then 
        echo -n "+"; 
    else 
        echo -n "."; 
        let J=$J+1; 
    fi; 

    let I=$I+1; 

    if [ $(( $I % $timestorun )) -eq 0 ]; then 
        echo "Succesffuly logged in $J out of $I times"; 
    fi; 

done