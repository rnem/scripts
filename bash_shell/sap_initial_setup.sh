#!/bin/bash
#################################################################################################
# This script performs the following actions once a SAP EC2 instance is provisioned             #
# It expects the hostname ($1) and IP ($2) to be provided                                       #
# Usage: ./sap_initial_setup.sh <hostname> <IP>                                                 # 
#                                                                                               #
# 1. Hostname                                                                                   #
# 2. Timezone                                                                                   #
# 3. AIDE                                                                                       #
# 4. Disable Transparaent Hugepages (THP) at boot time                                          #
# 5. clocksource = tsc                                                                          #
# 6. Mitigate MDS Vulnerability                                                                 #
# 7. Comment SAP ports in /etc/services                                                         #
#                                                                                               #
# v0.01 - 5/7/2021 - Created by Roger Nem                                                       #
#################################################################################################

#
# Enforce root
#
if [ ! $EUID ]; then
    printf "Error: Must be run as root\n\n"
    exit 1
fi

#
# Enforce correct usage
#
if [ "$#" -ne 2 ]; then
    printf "Usage: $0 <hostname> <IP>\n\n"
    exit 1
fi

###
### SET UP VARIABLES, FUNCTIONS
###
hostname_file="/etc/hostname"
hosts_file="/etc/hosts"
localtime_file="/etc/localtime"
grub_file="/etc/default/grub"
services_file="/etc/services"


# Functions
# -----------------------------------------------------------------------------------------------
function print_headers
{
 echo ""
 echo "----------------------------------------------------------------------------------------"
 echo "$1 "
 echo "----------------------------------------------------------------------------------------"
}

function set_hostname
{
  chattr -i $hostname_file

  echo $1 > $hostname_file
  printf "$hostname_file\n" 
  cat $hostname_file
  printf "\n"

  hostnamectl set-hostname $1

  matches_in_hosts="$(grep -n $1 $hosts_file | cut -f1 -d:)"
  host_entry="$2 $1.aws.domain.com $1"
  if [ ! -z "$matches_in_hosts" ]
  then
    echo "Updating existing hosts entry."
    # iterate over the line numbers on which matches were found
    while read -r line_number; do
      # replace the text of each line with the desired host entry
      sed -i "${line_number}s/.*/${host_entry} /" $hosts_file
    done <<< "$matches_in_hosts"
  else
    echo "Adding new hosts entry."
    echo "" >> $hosts_file
    echo "$host_entry" | sudo tee -a $hosts_file > /dev/null
  fi

  printf "$hosts_file\n"
  cat $hosts_file
  printf "\n"

  systemctl restart systemd-hostnamed
  hostnamectl status

  chattr +i /etc/hostname
}

function set_timezone
{
  check_tmz=$(timedatectl | grep Los_Angeles)
  if [ -z "$check_tmz" ]; then
    rm -f $localtime_file.bkp
    cp $localtime_file $localtime_file.bkp
    rm -f $localtime_file
    ln -s /usr/share/zoneinfo/America/Los_Angeles $localtime_file
    timedatectl set-timezone America/Los_Angeles
    systemctl restart crond.service
    printf "Timezone set:\n"
    echo $TZ `date`
  else
    echo "PST/PDT Timezone already set:"
    timedatectl | grep "Time zone"
    date
  fi
}

function config_aide
{
  # check if the file has been created recently - last 2 minutes
  cmd=$(find "/var/lib/aide/aide.db.new.gz" -mmin +2)
  if [ -z "$cmd" ]; then
    cd /var/lib/aide
    aide --update && rm -f aide.db.gz && mv aide.db.new.gz aide.db.gz && aide --check
  else
    echo "AIDE already setup and run"
    ls -lah /var/lib/aide/aide.db.new.gz
  fi
}

function disable_thp
{
  grep transparent_hugepage $grub_file
  if [ $? -ne 0 ]; then
    cp $grub_file $grub_file.backup
    sed -i '/GRUB_CMDLINE_LINUX/ s|"| transparent_hugepage=never"|2' $grub_file
    grub2-mkconfig -o /boot/grub2/grub.cfg
    cat $grub_file
  else
    echo "Already done."
  fi
}

function set_clocksource
{
  grep clocksource=tsc $grub_file
  if [ $? -ne 0 ]; then
    echo "tsc" > /sys/devices/system/clocksource/*/current_clocksource
    cp $grub_file $grub_file.backup2
    sed -i '/GRUB_CMDLINE_LINUX/ s|"| clocksource=tsc"|2' $grub_file
    grub2-mkconfig -o /boot/grub2/grub.cfg
    cat $grub_file
  else
    echo "Already done."
  fi
}

function mitigate_mds
{
  grep mds=full $grub_file
  if [ $? -ne 0 ]; then
    cp $grub_file $grub_file.backup3
    sed -i '/GRUB_CMDLINE_LINUX/ s|"| mds=full"|2' $grub_file
    grub2-mkconfig -o /boot/grub2/grub.cfg
    cat $grub_file
  else
    echo "Already done."
  fi
}

function edit_etc_services
{
  egrep "#trap-daemon|#visinet-gui|#tick-port|#cpq-tasksmart|#nimsh" $services_file
  if [ $? -ne 0 ]; then
    sed -i 's/trap-daemon/#trap-daemon/g' $services_file
    sed -i 's/visinet-gui/#visinet-gui/g' $services_file
    sed -i 's/tick-port/#tick-port/g' $services_file
    sed -i 's/cpq-tasksmart/#cpq-tasksmart/g' $services_file
    sed -i 's/nimsh/#nimsh/g' $services_file
    egrep "trap-daemon|visinet-gui|tick-port|cpq-tasksmart|nimsh" $services_file
  else
    echo "Already done."
  fi
}

###
### Script
###
printf "Starting the initial configurations\n"

print_headers "1. Hostname"
set_hostname $1 $2

print_headers "2. Timezone"
set_timezone

print_headers "3. AIDE"
config_aide

print_headers "4. Disable Transparaent Hugepages (THP) at boot time"
disable_thp

print_headers "5. clocksource = tsc"
set_clocksource

print_headers "6. Mitigate MDS Vulnerability"
mitigate_mds

print_headers "7. Comment SAP ports in /etc/services"
edit_etc_services
