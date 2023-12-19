#!/bin/bash
######################################################################################################
# SEND ALERT ABOUT LARGE FILES                                                                       #
# Created by Roger Nem 01.05.2016                                                                    #
# v0.002 - Roger Nem - Delete any existing file and compress it before sending                       #
# v0.003 - Roger Nem - Updated the entire script                                                     #
# v0.004 - Roger Nem - Attachment path updated to avoid cron error                                   #
# v0.005 - Roger Nem - Included date of the file to the output                                       #
# v0.006 - Roger Nem - Ordered results per farm                                                      #
######################################################################################################

# ----------------------------------------------------------------------------------------------------
# Variables
# ----------------------------------------------------------------------------------------------------
today_date=$(date +"%d-%m-%Y")

filename_home="largefiles_home.txt"
filename_html="largefiles_html.txt"

EMAILFROM="noreply@large-files-list.localdomain"
EMAILTO="DL@domain.com"
EMAILCC=""
EMAILSUBJ='[ACTION REQUIRED] - Large files report'
EMAILMSG="***** ATTN: Large files report as of $today_date - PLEASE CLEAN UP *****"

# ----------------------------------------------------------------------------------------------------
# 1 - Clean any existing generated file
# ----------------------------------------------------------------------------------------------------
[ -f "/root/scripts/largefiles/${filename_home}" ] && rm -f /root/scripts/largefiles/${filename_home}
[ -f "/root/scripts/largefiles/${filename_html}" ] && rm -f /root/scripts/largefiles/${filename_html}
[ -f "/root/scripts/largefiles/cron.log" ] && rm -f /root/scripts/largefiles/cron.log

# ----------------------------------------------------------------------------------------------------
# 2 - Generate new list
# ----------------------------------------------------------------------------------------------------
for i in {1..21}
do
    salt "vm-all-php${i}-stag" cmd.run 'find /home -type f -size +100M -printf %TY-%Tm-%Td"  " -exec du -sh {} \;' >> /root/scripts/largefiles/${filename_home}
    salt "vm-all-php${i}-stag" cmd.run 'find /var/www/html -type f -size +100M -printf %TY-%Tm-%Td"  " -exec du -sh {} \;' >> /root/scripts/largefiles/${filename_html}
done

# ----------------------------------------------------------------------------------------------------
# 3 - Send email to the LAMP Team
# ----------------------------------------------------------------------------------------------------
if [ -s "/root/scripts/largefiles/${filename_home}" ];then
    echo "${EMAILMSG}" | mail -s "${EMAILSUBJ}" -r "${EMAILFROM}" -a "/root/scripts/largefiles/${filename_home}" -a "/root/scripts/largefiles/${filename_html}" -c "${EMAILCC}" "${EMAILTO}"
    echo "Report generated and sent to $EMAILTO."
fi