#!/bin/bash
###################################################
# Created by Roger Nem							  #
# - List details about local accounts		  	  #
# v0004 - Forth version                           #
###################################################

formatDate() {
  date +%d"."%m"."%Y -d " $1 day"
}
padr() {
  string="$1................................................"
  echo "$string" | cut -c1-$2
}
length() {
  length=`echo "$@" | wc -c | cut -c1-8`
  length=$(( $length -1 ))
  echo $length
}
padl() {
  string="................................................$1"
  length=`length "$string"`
  echo "$string" | cut -c`expr $length - $2`-$length
}

host=`hostname`

echo "List of user accounts with password information"
echo "==============================================="
echo "$host - " `date`
echo
echo "Excluding system and Cloud accounts:"
echo "root, mysql, cloud-user, dsuser, centos"
echo
echo "-----------------------------------------------"
echo "Username            |UID  |LastChange|Status   "
echo "--------------------|-----|----------|---------"


for user in `grep 'sftp\|bash' /etc/passwd | sed 's/root//g;s/mysql//g;s/cloud-user//g;s/dsuser//g;s/centos//g' | cut -d: -f1 | sort` ; do 

    uname_all=`cat /etc/shadow | grep $user | awk -F":" '{print}'` 

	user=`echo -e $uname_all | awk -F: '{print$1}'` # Username, up to 8 characters. Case-sensitive, usually all lowercase. A direct match to the username in the /etc/passwd file
	passwd=`echo -e $uname_all | awk -F: '{print$2}'` # Password, 13 character encrypted. A blank entry (eg. ::) indicates a password is not required to log in (usually a bad idea), and a ``*'' entry (eg. :*:) indicates the account has been disabled

        a=`echo -e $uname_all | awk -F: '{print$3}'` # The number of days (since January 1, 1970) since the password was last changed.
        b=`echo -e $uname_all | awk -F: '{print$4}'` # Minumum password age. The number of days before password may be changed (0 indicates it may be changed at any time)
        c=`echo -e $uname_all | awk -F: '{print$5}'` # Maximum password age. The number of days after which password must be changed (99999 indicates user can keep his or her password unchanged for many, many years)
        d=`echo -e $uname_all | awk -F: '{print$6}'` # Password warning age. The number of days to warn user of an expiring password (7 for a full week)
        e=`echo -e $uname_all | awk -F: '{print$7}'` # Acct Exp
        f=`echo -e $uname_all | awk -F: '{print$8}'` # The number of days since January 1, 1970 that an account has been disabled

        now=$(( ($(date +%s) / 86400) ))
        pass=$(( $now - $a ))

        if [ $pass -gt 91 ]; then
                stat=`echo EXPIRED`
        else
                stat=`echo ACTIVE`
        fi

	name=`padr $user 20`

	uid=`id -u $user`
	uid=`padl $uid 4`

	last=`formatDate -$pass`

	echo "$name|$uid|$last|$stat"

done