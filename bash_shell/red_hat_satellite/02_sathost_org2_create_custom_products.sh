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

ORG_LABEL="COMP_ORG2"

declare -a all_cps

# 1 - CREATE CUSTOM PRODUCTS

all_cps[0]='Docker;Docker;Docker CentOS Products (Custom)'
all_cps[1]='Fedora EPEL;Fedora_EPEL;Fedora Extra Packages for Enterprise Linux (EPEL) (Custom)'
all_cps[2]='Gcloud;Gcloud;Google cloud related Products (Custom)'
all_cps[3]='Hewlett Packard Enterprise;Hewlett_Packard_Enterprise;HPE repositories FWPP repos - HPE Firmware Pack for ProLiant SUM repos - HPE Smart Update Manager SPP repos - Service Pack for ProLiant STK repos - HPE Scripting Tools Repository IP Gen8 repo - HPE ProLiant DL360 Gen8 Intelligent Provisioning IP Gen9 repo - HPE ProLiant DL360 Gen9 Intelligent Provisioning'
all_cps[4]='InfluxData;InfluxData;InfluxDB Time-Series Database Products (Custom)'
all_cps[5]='Jenkins EIS;Jenkins_EIS;EIS Jenkins CI/CD (Custom)'
all_cps[6]='Katello;Katello;Katello Products (Custom)'
all_cps[7]='Signal Sciences Corp - WAF;Signal_Sciences_Corp_-_WAF;Signal Sciences Corp WAF Products (Custom)'
all_cps[8]='VMware;VMware;(Custom) https://packages.vmware.com/tools/releases/10.3.20/README Starting with VMware Tools 10.3.20, Linux OSP packages will only be updated for critical fixes. https://packages.vmware.com/tools/releases/10.3.21/rhel6/x86_64/'

for cps in "${all_cps[@]}"; do
  IFS=";" read -r -a arr <<< "${cps}"

  case ${arr[0]} in
    Katello)
      SYNC_PLAN_NAME="All-repo-sync"
      ;;
    *)
      SYNC_PLAN_NAME="Standard Daily Sync"
      ;;
  esac

  echo "Creating ${arr[0]}"
  hammer product create --name "${arr[0]}" --label "${arr[1]}" --description "${arr[2]}" --sync-plan "$SYNC_PLAN_NAME" --organization-label ${ORG_LABEL}

done