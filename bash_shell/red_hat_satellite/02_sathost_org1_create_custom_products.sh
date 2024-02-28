#!/bin/bash
#################################################################################
# RED HAT SATELLLITE - Create Org Custom Product(s)                             #
# Created by Roger Nem - 2023                                                   #
#################################################################################

#
# Enforce root
#
if [ ! $EUID ]; then
    printf "Error: Must be run as root\n\n"
    exit 1
fi

# **** Sync plan must exist prior to running this script *****
echo "**** Sync plan must exist prior to running this script *****"
echo ""

ORG_LABEL="COMP_ORG1"

declare -a all_cps

# 1 - CREATE CUSTOM PRODUCTS ( Name, Description, Sync Plan ) 

all_cps[0]="Fedora EPEL;Fedora Extra Packages for Enterprise Linux (EPEL);ORG1 Standard Daily Sync"
all_cps[1]="Hewlett Packard Enterprise;HPE repositories FWPP repos - HPE Firmware Pack for ProLiant SUM repos - HPE Smart Update Manager SPP repos - Service Pack for ProLiant STK repos - HPE Scripting Tools Repository IP Gen8 repo - HPE ProLiant DL360 Gen8 Intelligent Provisioning IP Gen9 repo - HPE ProLiant DL360 Gen9 Intelligent Provisioning;ORG1 Standard Daily Sync"
all_cps[2]="VMware;VMware Tools for RHEL6 - No RHEL7 Available.\n REQUIRED BY VMs\n https://packages.vmware.com/tools/releases/10.3.20/README\n Starting with VMware Tools 10.3.20, Linux OSP packages will only be updated for critical fixes. To get the Windows iso, please refer to https://packages.vmware.com/tools/releases/11.0.0 (or later).\r\n Prior mirror link:\n https://packages.vmware.com/tools/releases/10.3.21/rhel6/x86_64/;ORG1 Standard Daily Sync"

for cps in "${all_cps[@]}"; do
  IFS=";" read -r -a arr <<< "${cps}"

  echo "Creating ${arr[0]}"
  hammer product create --name "${arr[0]}" --description "${arr[1]}" --sync-plan "${arr[2]}" --organization-label ${ORG_LABEL}

done