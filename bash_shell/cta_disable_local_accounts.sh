#!/bin/bash
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
##  DSU CTA Control - Local Accounts - DO NOT DELETE/CHANGE                     ##
##  Created by Roger Nem - 2015                                                 ##
##  v0002 - After the review with Ulf - Nov 10, 2015                            ##
##  v0003 - RN: Added critical accounts to the exclusion list - Nov 24, 2015    ##
##  v0004 - RN: Changed code and added one more exeption in the user exclution  ##
##          The output of this script is parsable via RegEx.                    ##
##  Added more Userinformation and Logdate.                                     ##
##  Added feature to only Lock not already locked accounts.                     ##
##  v0005 - RN: Give one line output if no interessting local acconuts could    ##
##  be found, to have an overview which servers are "clean".                    ##
##  v0006 - RN: Fixed the logic to successfull dedect if users were found.      ##
##  Added OS detection, for Ubuntu, no actions done anymore.                    ##
##  v0007 - UB: Fixed empty User -Info, -Home and -Shell, that these values     ##
##  could not be empty. If they are empty the RegEx from the                    ##
##  Analysing script will ignore the line.                                      ##
##  v0008 - RN: Add detection of cPanel Shell detection and ignoring this users ##
##        Add DEBUG mode and set it true, false would disable found users       ##
##  Add ignoring of specified hostnames.                                        ##
##  Add UserID extraction for the local user.                                   ##
##  Add app_syncuser igrnore for Anton Shostak                                  ##
##  v0009 - UB: Add Clear names for the L/LK, P/PS, NP status for the PWStatus  ##
##  Put the FQP to all tools I have used.                                       ##
##  v0010 - RN: Add sectransfer ignore for Security Team on PMA server          ##
##  Make the servername compare more reliable                                   ##
##  v0011 - RN: Add some more servers to the exclusion list to skip these ones. ##
##  v0012 - UB: Agree with Roger to activate the script, so it will disable all ##
##  local users now.                                                            ##
##  v0013 - RN: Added /usr/bin/scponly for a whitelisted user shell.            ##
##  Added also cron_sectransfer as user exclution.                              ##
##  Changed the way of excluding the shells.                                    ##
##  v0014 - RN: Changed behaviour for the handling of excluded servers.         ##
##        Instead of simply ignoring the server, do only display the            ##
##        found users, but not doing anything to them.                          ##
##  v0015 - UB: Changed the Text for Excluded servers from "Excluded" to        ##
##        "No action taken".                                                    ##
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

DEBUG="false"               # DEBUG Mode means not disable any user. false=DEBUG off!
USERARR=()                  # User ArraHallo auch ...y
HOSTNAME=$(/bin/hostname)   # Hostname of the current system
NOLOCALUSERS="true"         # No local users = true otherwise false
CSVHEADER="Hostname,Username,ShadowUser,UserID,UserInfo,UserHome,UserShell,UserPWStatus,LastPWChange,Status,LogDate,OSBrand,DryRun"

# Get the current OS Brand
OSBRAND=$(/bin/egrep -io -m 1 "Ubuntu|CentOS|Red Hat Enterprise Linux" /etc/*-release|/usr/bin/head -n 1 |cut -d":" -f2)
[[ "${OSBRAND}" == "" ]] && OSBRAND="NotKnown"  # If some different OS is detected, also not doing anything with the users!
EXCLUDESRV="false"          # Exclude this server: true=yes, false=no (default)

# Array with servers to be excluded by this script, e.g. cPanel or other reason
SRVEXCLarr=( "vm-all-test"
"vm-all-all-Git-server"
)

# Check if the server is excluded for user analysis
for host in ${SRVEXCLarr[@]}
do
    #if [ "${HOSTNAME}" == "${host}" ]; then
    if [ $( echo "${HOSTNAME}"|/bin/grep -qiw "${host}" >/dev/null 2>&1; echo $? ) -eq 0 ]; then
        EXCLUDESRV="true"
fi
done

# Excluding system and Cloud Accounts
exclusion_user_list="root|cloud|mysql|cloudconnect|centos|clamav|clam|cloud-user|postgres|synchronize|dsuser|svn|git|gitlab|solr|sync|shutdown|halt|monit|apache|cron_user|cronjob|tomcat|speech-dispatcher|app_syncuser|sectransfer|cron_sectransfer"

for i in $( egrep -v "/sbin/nologin|/bin/false|/usr/bin/scponly" /etc/passwd | awk -F: '{print $1}' | sort | /bin/egrep -v "$exclusion_user_list" )
do
    USERARR+=( ${i} );
done

function disable_user {
    local USERNAME="${1}"
    # Only disable the users, if not excluded server

    if [ "${EXCLUDESRV}" == "false" ]; then
        /usr/bin/pkill -u ${USERNAME} # to avoid user is logged in
        /usr/sbin/usermod --lock --expiredate 1970-02-02 ${USERNAME} # Lock the user
    fi
}

# Check for root permissions
[[ $( id -u) -ne 0 ]] && echo "This script needs root privileges, abort." && exit 255

# Starting
echo ${CSVHEADER}

# Collect details about the users found
# If OS not Ubuntu or OS couldn't be detected
if [ "${OSBRAND}" != "Ubuntu" -a "${OSBRAND}" != "NotKnown" ]; then
    for user in "${USERARR[@]}";
    do

        LOGDATE=$(/bin/date +"%Y-%m-%d")                       # Date of analysis
        SHADOWUSER=$( /bin/grep -wo "^${user}" /etc/shadow )   # If existing give the username
        USERID="NotChecked"                                    # Set the UserID     to default value
        USERINFO="NoInfo"                                      # Set the userinfo   to default value
        USERHOME="NoHome"                                      # Set the user home  to default value
        USERSHELL="NoShell"                                    # Set the user shell to default value
        USERLOCKED="NoInfo"                                    # Set the userstate  to default value
        USERLASTPWCHANGE="NoDate"                              # Set the users last pw change to default value
        DEBUGTMP=""                                            # Preserve DEBUG information.

        if [ "${SHADOWUSER}" == "" ]; then
            SHADOWUSER="No"
            STATUS="NotTouched"
        else
            SHADOWUSER="Yes"
            STATUS="AlreadyDisabled"
            USERID=$( id -u ${user} 2>/dev/null )
            USERINFO=$( /bin/grep -w "^${user}" /etc/passwd | cut -d":" -f 5 | tr -d ",")
            USERHOME=$( /bin/grep -w "^${user}" /etc/passwd | cut -d":" -f 6 | tr -d ",")
            USERSHELL=$( /bin/grep -w "^${user}" /etc/passwd | cut -d":" -f 7 | tr -d ",")
            USERLOCKED=$(passwd -S ${user} | cut -d" " -f 2)        # Userstate: L/LK=Locked, NP=No password, P/PS=working password
            USERLASTPWCHANGE=$(passwd -S ${user} | cut -d" " -f 3)  # Users last password change

            [[ "${USERID}" == "" ]] && USERID="NotFound"
            [[ "${USERINFO}" == "" ]] && USERINFO="None"
            [[ "${USERHOME}" == "" ]] && USERHOME="None"
            [[ "${USERSHELL}" == "" ]] && USERSHELL="None"

            case ${USERLOCKED} in
                L|LK)   USERLOCKED="AlreadyLocked";;
                NP)     USERLOCKED="NoPassword";;
                P|PS)   USERLOCKED="WorkingPassword";;
            esac

            if [ "${USERLOCKED}" != "AlreadyLocked" ]; then
                [[ "${DEBUG}" == "false" ]] && STATUS="DisabledDuringRun" || STATUS="WillBeDisabled"
                # Live
                [[ "${DEBUG}" == "false" ]] && disable_user ${user}
            fi
        fi

        if [ "${EXCLUDESRV}" == "true" ]; then
            DEBUGTMP=${DEBUG}
            DEBUG="No action taken"
        fi

        NOLOCALUSERS="false"
        echo "${HOSTNAME},${user},${SHADOWUSER},${USERID},${USERINFO},${USERHOME},${USERSHELL},${USERLOCKED},${USERLASTPWCHANGE},${STATUS},${LOGDATE},${OSBRAND},${DEBUG}"

        # Reset DEBUG to original state
        [[ "${EXCLUDESRV}" == "true" ]] && DEBUG=${DEBUGTMP}
    done

else
    LOGDATE=$(/bin/date +"%Y-%m-%d")# Date of analysis
    STATUS="NotTouched" # Change status
    NOLOCALUSERS="false"# Prevent display "NoUserFound" line.
    echo "${HOSTNAME},NotTouched,NotTouched,NotTouched,Ignored,NotTouched,NotTouched,NotTouched,NotTouched,NotTouched,${LOGDATE},${OSBRAND},${DEBUG}"
fi


# Give a oneliner if no user could be found
if [ "${NOLOCALUSERS}" == "true" ]; then

    LOGDATE=$(/bin/date +"%Y-%m-%d") # Date of analysis

    if [ "${EXCLUDESRV}" == "true" ]; then
        DEBUGTMP=${DEBUG}
        DEBUG="No action taken"
    fi
    echo "${HOSTNAME},NoUserFound,None,None,None,None,None,None,None,None,${LOGDATE},${OSBRAND},${DEBUG}"

    # Reset DEBUG to original state
    [[ "${EXCLUDESRV}" == "true" ]] && DEBUG=${DEBUGTMP}
fi
