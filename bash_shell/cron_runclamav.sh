#!/bin/bash
#############################################################################
#                                                                           #
# ClamAV cron scan script                                                   #
# by Roger Nem (2015)                                                       #
#                                                                           #
# History:                                                                  #
# 	v0.001  - First Version                                                 #
#	v0.002  - Added a more precise insert of the infected files list into   #
#             the result mail. Only root can execute now.                   #
#             Added the scanned dirs to mail.                               #
#   v0.003  - Corrected error in Infection detection.                       #
#             Added noscan option to cmdline                                #
#             Enhanced the mail output.                                     #
#  v0.004   - Fixed "not found" sendmail bug. Added syslogging for sending  #
#             emails with some details.                                     #
#  v0.005   - Added [ClamAV-LAMP] to the Subject to ease the search         #
#  v0.006   - Disable eMail sending feature. Global Log collector availabe. #
#  v0.007   - Implemented nice value for Clamscan.                          #
#  v0.008   - Increased the nice value for the ClamScan                     #
#                                                                           #
#############################################################################

# Exit 250 -> Script is not executed with root permissions
# Exit 255 -> No directory given as cmdline option

### Variables
APPPATH=$(dirname $0)                          # Path where this script is started from
CLAMLOG="/var/log/clamav/clamscan.log"         # The Logfile with the current scan results
TMPFILE=$(mktemp /tmp/cron_clamscan.XXXXXXX)   # TMPFile for versionfinder.pl output
DIR2SCAN="${*}"                                # The starting directory that has to be scanned
LOGGERTAG="ClamAV-Cron"                        # The Tag for the logger entries in the syslog
CLAMNICE=15                                    # ClamAV NICE value to run with, to not overuse the CPU

trap 'do_remove_tmpfiles' EXIT SIGTERM SIGINT

### Functions

## Remove temporary files and exit
function do_remove_tmpfiles {
	rm -f ${TMPFILE} >/dev/null 2>&1
	echo
	exit
}

# Scan the last result logfile and send a mail during infection
function clamscanlogfile {
	local SCANDIR="${*}"                            # Value of the starting directory
	local EMAILFROM="noreply@clamscan"              # Mail from
	local EMAILTO="DL@domain.com"                   # Mail to
	local EMAILCC="CC@domain.com, CC2@domain.com"   # CC e-mails
	local SUBJECT=""                                # Subject will be generated below
	local INFECTCOUNT=0                             # Possible Infection Counter
	local LASTBAR=""                                # Last split line to the next file list
	local ALLLINES=""                               # All lines counted
	local LINES2DISP=""                             # Calculated to only display the important lines

	if [ "${SCANDIR}" == "" ]; then
		echo "You have not entered a directory to be scanned, thus aborting the script."
		echo "You can skip to run clamscan entirely with the 'noscanatall' option."
		exit 255
	fi

	# Run the scan
	if [ "${SCANDIR}" != "noscanatall" ]; then
		nice -n ${CLAMNICE} clamscan ${SCANDIR} -r --exclude-dir=/sys/ --exclude-dir=/proc/ --quiet --infected --log=${CLAMLOG} --remove=no
	else
		echo "Skip execution of clamscan."
	fi

	# Calculate the line numbers
	LASTBAR=$(grep -n "\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-" ${CLAMLOG} | tail -n 1 | cut -d: -f1)
	ALLLINES=$(wc -l ${CLAMLOG}|cut -d" " -f1)
	LINES2DISP=$((ALLLINES-LASTBAR))

	# Check the last set of results. If there are any "Infected" counts that aren't zero then there is a problem.
	if [ $(tail -n 12 ${CLAMLOG} | grep -i Infected | grep -v "Infected files: 0" | wc -l) != 0 ]; then
		INFECTCOUNT=$(tail -n 12 ${CLAMLOG} | grep -i Infected | cut -d: -f2 | tr -d " ")
		SUBJECT="[ClamAV-LAMP] POSSIBLE ${INFECTCOUNT} INFECTION(S) DETECTED ON '${HOSTNAME}' !"
		echo "To: ${EMAILTO}" >>  ${TMPFILE}
		echo "From: ${EMAILFROM}" >>  ${TMPFILE}
		echo "Subject: ${SUBJECT}" >>  ${TMPFILE}
		echo "Importance: High" >> ${TMPFILE}
		echo "X-Priority: 1" >> ${TMPFILE}
		echo "" >> ${TMPFILE}
		echo "Information:" >> ${TMPFILE}
		echo "Scanned directories and below them:" >> ${TMPFILE}
		echo "${SCANDIR}" >> ${TMPFILE}
		echo "" >> ${TMPFILE}
		echo "The last ${LINES2DISP} lines of the '${CLAMLOG}' are displayed below:" >> ${TMPFILE}
		echo "$(tail -n ${LINES2DISP} ${CLAMLOG})" >> ${TMPFILE}
		# Disable Mailsendinng feature for now, due to global clamscan.log collector script availability.
		# /usr/sbin/sendmail -t < ${TMPFILE}

		# Send this information also to the syslog
		logger -t ${LOGGERTAG} -f ${TMPFILE}
	fi
}

### Main ################################################################

### Check for root permissions
[[ $EUID -ne 0 ]] && echo "This script has to be excecuted as 'root', aborting script." && exit 250

clamscanlogfile ${DIR2SCAN}