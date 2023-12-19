#!/bin/bash
#########################################################
# Created by Roger Nem                                  #
# - Quick fix for /etc/sudoers and /etc/ssh/sshd_config #
# v0001 - First version                                 #
#########################################################

# -------------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------------
today=$(date +%Y-%m-%d);
host=`hostname`
file_sudoers="/etc/sudoers"
file_sshd="/etc/ssh/sshd_config"
# -------------------------------------------------------------------------------

#================================================================================
# /etc/sudoers
#================================================================================

# Remove entries
sed -i".$today.bak" '/#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@/d' $file_sudoers
sed -i".$today.bak" '/## Active Directory Project - DO NOT DELETE - START ##/d' $file_sudoers
sed -i".$today.bak" '/%domain_lamp_sudoers/d' $file_sudoers
sed -i".$today.bak" '/%domainfulladmin/d' $file_sudoers
sed -i".$today.bak" '/%gc support/d' $file_sudoers
sed -i".$today.bak" "/%$host/d" $file_sudoers
sed -i".$today.bak" '/#%wheel      ALL=(ALL)       ALL/d' $file_sudoers
sed -i".$today.bak" '/%wheel      ALL=(ALL)       ALL/d' $file_sudoers
sed -i".$today.bak" '/%wheel      ALL=(ALL)       NOPASSWD: ALL/d' $file_sudoers

# Add new lines to the beginning of the file
# This works the opposite way - bottom to top
sed -i -e '1i\\' $file_sudoers
sed -i '1i#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@' $file_sudoers
sed -i "1i%$host        ALL=(ALL)       ALL" $file_sudoers
sed -i '1i%wheel      ALL=(ALL)       ALL' $file_sudoers
sed -i '1i\"%gc support\"        ALL=(ALL)       ALL' $file_sudoers
sed -i '1i%domainfulladmin        ALL=(ALL)       ALL' $file_sudoers
sed -i '1i%domain_lamp_sudoers        ALL=(ALL)       ALL' $file_sudoers
sed -i '1i#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@' $file_sudoers
sed -i '1i## Active Directory Project - DO NOT DELETE - START ##' $file_sudoers
sed -i '1i#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@' $file_sudoers

#================================================================================
# /etc/ssh/sshd_config
#================================================================================

# Remove entries
sed -i".$today.bak" '/#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@/d' $file_sshd
sed -i".$today.bak" '/## Active Directory Project - DO NOT DELETE - START ##/d' $file_sshd
sed -i".$today.bak" '/AllowGroups domain_lamp_sudoers domainfulladmin cloudconnect wheel cloud/d' $file_sshd
sed -i".$today.bak" "/AllowGroups $host/d" $file_sshd

# Add new lines to the beginning of the file
# This works the opposite way - bottom to top
sed -i -e '1i\\' $file_sshd
sed -i '1i#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@' $file_sshd
sed -i "1iAllowGroups $host" $file_sshd
sed -i '1iAllowGroups domain_lamp_sudoers domainfulladmin cloudconnect wheel cloud' $file_sshd
sed -i '1i#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@' $file_sshd
sed -i '1i## Active Directory Project - DO NOT DELETE - START ##' $file_sshd
sed -i '1i#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@' $file_sshd

# Restart for changes to take effect
service sshd restart