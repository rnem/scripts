#!/bin/bash
#################################################################################
# Created by Roger Nem															#
#																				#
# Password Age of accounts in AIX, Linux and Solaris systems					#
# Generate corresponding files for each type of system							#
#																				#
# v0.001 - Roger Nem -  File created - 2018                                     #
#################################################################################

# -------------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------------
ex_accts = "adm|bin|daemon|dbus|ftp|games|gopher|halt|lp|mail|nfsnobody|nobody|ntp|operator|rpc|rpcuser|rtkit|shutdown|sshd|sssd|sync|systemd-bus-proxy|systemd-network|tcpdump|tss|usbmuxd|uucp|uuidd|vcsa|clamav|clam|cron_user|cronjob|solr|noaccess|panopta|gdm|svctag|sys|unknown|webservd|xcom62"

# -------------------------------------------------------------------------------
# Functions
# -------------------------------------------------------------------------------
function clean_up_files
{
 rm ansible.cfg
 rm -rf /tmp/pw_age
}

function clean_up_reports
{
 rm /tmp/pw_age_aix.csv
 rm /tmp/pw_age_linux.csv
 rm /tmp/pw_age_solaris.csv
}

# -------------------------------------------------------------------------------
# 1 - Validate folder and files do not exist
# -------------------------------------------------------------------------------
if [ -d /tmp/pw_age ];
then
 echo "/tmp/pw_age exists"
 exit 1
fi

if [ -e /tmp/pw_age_aix.csv ];
then
  echo "/tmp/pw_age_aix.csv exists"
  exit 1
fi

if [ -e /tmp/pw_age_linux.csv ];
then
  echo "/tmp/pw_age_linux.csv exists"
  exit 1
fi

if [ -e /tmp/pw_age_solaris.csv ];
then
  echo "/tmp/pw_age_solaris.csv exists"
  exit 1
fi

# -------------------------------------------------------------------------------
# 2 - Run Ansible Playbook to get results
# -------------------------------------------------------------------------------
# 2.1 - AIX
cp ../ansible-aix/ansible.cfg .
ansible-playbook -u ansible -i ../ansible-aix/maintenance/allhosts -s check_pw_age_all.yml

echo "Host,Account,Days,OSType" > /tmp/pw_age_aix.csv
cat /tmp/pw_age/*/tmp/pw_age.txt >> /tmp/pw_age_aix.csv

clean_up_files

# 2.2 - LINUX
cp ../ansible-linux/ansible.cfg .
ansible-playbook -u ansible -i ../ansible-linux/development -s check_pw_age_all.yml
ansible-playbook -u ansible -i ../ansible-linux/production -s check_pw_age_all.yml

echo "Host,Account,Days,OSType" > /tmp/pw_age_linux.csv
cat /tmp/pw_age/*/tmp/pw_age.txt >> /tmp/pw_age_linux.csv

clean_up_files

# 2.3 - SOLARIS
cp ../ansible-solaris/ansible.cfg .
ansible-playbook -u ansible -i ../ansible-solaris/hosts -s check_pw_age_all.yml

echo "Host,Account,Days,OSType" > /tmp/pw_age_solaris.csv
cat /tmp/pw_age/*/tmp/pw_age.txt >> /tmp/pw_age_solaris.csv

clean_up_files

#rm ansible.cfg

#echo "Host,Account,Days,OSType" > /tmp/pw_age.csv
#cat /tmp/pw_age/*/tmp/pw_age.txt >> /tmp/pw_age.csv

# -------------------------------------------------------------------------------
# 3 - Send results to e-mail
# -------------------------------------------------------------------------------
echo "The following accounts are being excluded from this report: $ex_accts" | mailx -r "audit-report@domain.com" -s "Password aging report for `date`" -a /tmp/pw_age_linux.csv -a /tmp/pw_age_solaris.csv recipient@domain.com #< /dev/null

clean_up_reports

#rm -rf /tmp/pw_age
#rm /tmp/pw_age.csv