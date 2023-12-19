#!/bin/bash
######################################################################################################
# GENERATE INFORMATION ABOUT LOCAL USER ACCOUNTS                                                     #
# Created by Roger Nem                                                                               #
######################################################################################################

TIME=`date "+%Y_%m_%d"`

if [ -f host_user_url.txt ]; then mv host_user_url.txt host_user_url.txt.$TIME; fi
if [ -f user_list1.txt ]; then mv user_list1.txt user_list1.txt.$TIME; fi
if [ -f user_list.txt ]; then mv user_list.txt user_list.txt.$TIME; fi

## The first step is to create a user list from /etc/passwd
for i in `grep 'sftp\|bash' /etc/passwd | cut -d: -f1` ; do echo $i ;done > user_list1.txt

cat user_list1.txt |grep -v 'root\|cloud\|mysql\|cloudconnect\|centos\|postgres\|synchronize' > user_list.txt

while read user
do

# ----------------------------------------------------------------------------------------------------
##### Define functions
# ----------------------------------------------------------------------------------------------------
###identify groups that user is a member of ###
##To start we are only interested in whether the user is a member of the wheel group or has sudo rights
## This is pretty bad - probably should use an array here an more careful analysis of who is sudoers

userGroups() {
    member=`groups $user`
    wheel_in_sudo=`grep ^%wheel /etc/sudoers`
    if [[ $member =~ "wheel" ]] && [[ $wheel_in_sudo =~ "wheel" ]]; then
        echo IN_WHEEL_SUDOERS
    else
        echo NO_WHEEL
    fi
}
WHEEEL_STATUS=`userGroups`

###Check to see if user is a sudoer
suDoer() {
    sudoer=`grep -w $user /etc/sudoers`
    if [ $? -eq 0 ]; then
        echo SUDOER
    else
        echo NOT_IN_ETCSUDOER
    fi
}
SUDO_STATUS=`suDoer`


# ----------------------------------------------------------------------------------------------------
#### GET user status ####
# ----------------------------------------------------------------------------------------------------
## This simply looks at the last password reset date of the user and if it is over 90 days old (91)
## then it is labeled EXPIRED.

userStatus() {
        
	uname=`cat /etc/shadow | grep $user | awk -F":" '{print}'`
	
	a=`echo -e $uname | awk -F: '{print$3}'`
	b=`echo -e $uname | awk -F: '{print$4}'`
	c=`echo -e $uname | awk -F: '{print$5}'`
	d=`echo -e $uname | awk -F: '{print$6}'`
	e=`echo -e $uname | awk -F: '{print$7}'`
	f=`echo -e $uname | awk -F: '{print$8}'`

	now=$(( ($(date +%s) / 86400) ))
	pass=$(( $now - $a ))

        if [ $pass -gt 91 ]; then
            echo EXPIRED
        else
            echo ACTIVE
        fi
}

# This enters the user's status into a usable variable
USERSTATUS=`userStatus`
####END #### GET user status ####
# ----------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------
#### Get the host user and url list ####
# ----------------------------------------------------------------------------------------------------
### This function happens to use the output of userStatus

host_user_url() {

	if [ ! -d "/home/$user" ]; then
  		# Control will enter here if $DIRECTORY doesn't exist.
		HOME_DIR="/home/$user doesnt exist"		
	fi

        url=`find /home/$user/  -maxdepth 1 -type l -printf "%p\n" 2>>error.log |rev |cut -d/ -f1 |rev |grep -v Agency_`
        result=$?
        if [ -z "$url" ] ; then
            URL_STATUS="NO_ASSOCIATED_URL"
        elif [ "$result" -eq 0 ] && [ -z "$url" ] ; then
            URL_STATUS="NO_ASSOCIATED_URL"
        elif [ "$result" -eq 0 ] && [ ! -z "$url" ] ; then
            URL_STATUS=$url
        elif [ $? -gt 0 ]; then
            URL_STATUS="NO_ASSOCIATED_URL"
        fi

        echo $URL_STATUS $HOME_DIR
}

HOST_USER_URL=`host_user_url`

#### END Get the host ... #####
# ----------------------------------------------------------------------------------------------------

echo $HOSTNAME $user $USERSTATUS $WHEEEL_STATUS $SUDO_STATUS $HOST_USER_URL

done < user_list.txt > host_user_url.txt