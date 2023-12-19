#!/bin/bash
#################################################################################
# Created by Roger Nem															#
#																				#
# Password Age of accounts in AIX, Linux and Solaris systems					#
# Deployed to servers to generated information									#
#																				#
# v0.001 - Roger Nem -  File created - 2018                                     #
#################################################################################

export LANG=C

case $OSTYPE in
  aix*)
    accounts=$(lsuser -C | cut -d: -f1 | sort)
    ;;
  *)
    accounts=$(getent passwd | cut -d: -f1 | sort | egrep -v "adm|bin|daemon|dbus|ftp|games|gopher|halt|lp|mail|nfsnobody|nobody|ntp|operator|rpc|rpcuser|rtkit|shutdown|sshd|sssd|sync|systemd-bus-proxy|systemd-network|tcpdump|tss|usbmuxd|uucp|uuidd|vcsa|clamav|clam|cron_user|cronjob|solr")
    ;;
esac


function handle_linux
{
  last_date=$(/usr/bin/chage -l $1 | grep Last | cut -d: -f2)
  date --date="${last_date}" +%s
}

function handle_aix
{
  pwdadm -q $1 | grep last | cut -d= -f 2
}

function handle_solaris
{
  last_date=$(passwd -s $1 | awk '{print $3}')
  month=$(echo $last_date |cut -d/ -f1 | sed s/^0//g)
  let month='--month'    # Perl feature, month arrary starts at 0
  day=$(echo $last_date | cut -d/ -f2 | sed s/^0//g)
  year=$(echo $last_date | cut -d/ -f3| sed s/^0//g)
  perl -e "use Time::Local ; print timelocal('0','0','0',$day,$month,$year);"
}

function solaris_today
{
  month=$(date +%m | sed s/^0//g )
  let month='--month'    # Perl feature, month arrary starts at 0
  day=$(date +%d | sed s/^0//g)
  year=$(date +%y | sed s/^0//g)
  perl -e "use Time::Local ; print timelocal('0','0','0',$day,$month,$year);"
}

today=$(/bin/date +%s)
> /tmp/pw_age.txt

for account in ${accounts}
do

  case $OSTYPE in
    linux*)
      last_secs=$(handle_linux $account)
      ;;
    solaris*)
      today=$(solaris_today)
      last_secs=$(handle_solaris $account)
      ;;
    aix*)
      last_secs=$(handle_aix $account)
      ;;
    *) echo "Unkown os $OSTYPE"
       exit 1
      ;;
  esac
  echo $today $last_secs
  let "diff_days=($today-$last_secs)/86400";

  case $OSTYPE in
    solaris*)
      echo $(basename $HOSTNAME .domain.com),$account,$diff_days,$OSTYPE | grep -v "ansible"  >> /tmp/pw_age.txt
      ;;
    *)
      echo $(basename $HOSTNAME .domain.com),$account,$diff_days,$OSTYPE >> /tmp/pw_age.txt
      ;;
  esac

done

chown ansible /tmp/pw_age.txt