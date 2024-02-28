#!/bin/bash
#################################################################################
# RED HAT SATELLLITE - Create Org Custom Repos(s)                               #
# Created by Roger Nem - 2023                                                   #
#################################################################################

#
# Enforce root
#
if [ ! $EUID ]; then
    printf "Error: Must be run as root\n\n"
    exit 1
fi

# **** Custom Products must exist prior to running this script *****
echo "**** Custom Products must exist prior to running this script *****"
echo ""

ORG_LABEL="COMP_ORG1"

declare -a all_crps

# 1 - CREATE CUSTOM REPOS ( Product, Repo Name, Description, Type, url, verify SSL, Download Policy ) 

# Fedora EPEL
all_crps[0]="Fedora EPEL;EPEL6 x86_64;;yum;https://archives.fedoraproject.org/pub/archive/epel/6/x86_64/;true;immediate;additive"
all_crps[1]="Fedora EPEL;EPEL7 x86_64;;yum;https://dl.fedoraproject.org/pub/epel/7/x86_64/;true;immediate;additive"
all_crps[2]="Fedora EPEL;EPEL8 x86_64;;yum;https://dl.fedoraproject.org/pub/epel/8/Everything/x86_64/;true;immediate;additive"
all_crps[3]="Fedora EPEL;EPEL9 x86_64;;yum;https://dl.fedoraproject.org/pub/epel/9/Everything/x86_64/;true;immediate;additive"

# Hewlett Packard Enterprise

	# This one requires authentication
	# FWPP Current 7Server x86_64
	# Satellite 6.7: hammer repository create --product "Hewlett Packard Enterprise" --name "FWPP Current 7Server x86_64" --content-type "yum" --url "https://downloads.linux.hpe.com/SDR/repo/fwpp/rhel/7/x86_64/current/" --upstream-username "***************" --upstream-password "null" --verify-ssl-on-sync "true" --download-policy "immediate" --organization-label ${ORG_LABEL}

	# Satellite 6.12
	echo "Creating FWPP Current 7Server x86_64"
	hammer repository create --product "Hewlett Packard Enterprise" --name "FWPP Current 7Server x86_64" --description "HPE Firmware Pack for ProLiant (FWPP)" --content-type "yum" --url "https://downloads.linux.hpe.com/SDR/repo/fwpp/rhel/7/x86_64/current/" --upstream-username "***************" --upstream-password "null" --verify-ssl-on-sync "true" --download-policy "immediate" --mirroring-policy "mirror_content_only" --organization-label ${ORG_LABEL}

all_crps[4]="Hewlett Packard Enterprise;HPSUM Current 7Server x86_64;HPE Smart Update Manager (SUM);yum;https://downloads.linux.hpe.com/SDR/repo/hpsum/rhel/7Server/x86_64/current/;true;immediate;mirror_content_only"
all_crps[5]="Hewlett Packard Enterprise;IP Gen8 Current;HPE ProLiant DL360 Gen8 Intelligent Provisioning (IP);yum;https://downloads.linux.hpe.com/repo/ip/rhel/current/x86_64/gen8/;true;immediate;mirror_content_only"
all_crps[6]="Hewlett Packard Enterprise;IP Gen9 Current;HPE ProLiant DL360 Gen9 Intelligent Provisioning (IP);yum;https://downloads.linux.hpe.com/repo/ip/rhel/current/x86_64/gen9/;true;immediate;mirror_content_only"
all_crps[7]="Hewlett Packard Enterprise;SPP Current 7Server x86_64;Service Pack for ProLiant (SPP);yum;https://downloads.linux.hpe.com/repo/spp/rhel/7Server/x86_64/current/;true;immediate;mirror_content_only"
all_crps[8]="Hewlett Packard Enterprise;STK Current 7Server x86_64;HPE Scripting Tools Repository (STK);yum;https://downloads.linux.hpe.com/SDR/repo/stk/rhel/7Server/x86_64/current/;true;immediate;mirror_content_only"

# VMware
all_crps[9]="VMware;VMware Tools Latest RHEL6 x86_64;VMware Tools;yum;https://packages.vmware.com/tools/releases/latest/rhel6/x86_64;true;immediate;mirror_content_only"

for crps in "${all_crps[@]}"; do
  IFS=";" read -r -a arr <<< "${crps}"

  echo "Creating ${arr[1]}"
  hammer repository create --product "${arr[0]}" --name "${arr[1]}" --description "${arr[2]}" --content-type "${arr[3]}" --url "${arr[4]}" --verify-ssl-on-sync "${arr[5]}" --download-policy "${arr[6]}" --mirroring-policy "${arr[7]}" --organization-label ${ORG_LABEL}

done