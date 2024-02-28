#!/bin/bash
#################################################################################
# RED HAT SATELLLITE - Create Org Reg DB Activation Keys(s) - AKs               #
# Created by Roger Nem - 2023                                                   #
#################################################################################

ORG_LABEL="COMP_ORG2"
CCV_ORG1_STD="ccv-orgname-standard"

declare -a all_envs

# Fedora EPEL subscription id=10
# VMware id=29
# noVDC - Red Hat Enterprise Linux Server with Smart Management, Standard id=37
# VDC - Red Hat Enterprise Linux for Virtual Datacenters with Smart Management, Standard id=45

all_envs[0]="primary-ak_VMWAREnoVDC_RHEL_7Server_x86_SOE-DB-NonProduction_ccv-orgname-standard;SOE-DB-NonProduction;7Server;id=10,id=29,id=37"
all_envs[1]="primary-ak_VMWAREnoVDC_RHEL_7Server_x86_SOE-DB-Production_ccv-orgname-standard;SOE-DB-Production;7Server;id=10,id=29,id=37"
all_envs[2]="primary-ak_VMWAREnoVDC_RHEL_8Server_x86_SOE-DB-NonProduction_ccv-orgname-standard;SOE-DB-NonProduction;8;id=10,id=29,id=37"
all_envs[3]="primary-ak_VMWAREnoVDC_RHEL_8Server_x86_SOE-DB-Production_ccv-orgname-standard;SOE-DB-Production;8;id=10,id=29,id=37"
all_envs[4]="primary-ak_VMWARE_RHEL_7Server_x86_SOE-DB-NonProduction_ccv-orgname-standard;SOE-DB-NonProduction;7Server;" #id=10,id=29,id=45 These VMWARE AKs using VDC subs CANNOT have any sub attached - https://access.redhat.com/solutions/3157111
all_envs[5]="primary-ak_VMWARE_RHEL_7Server_x86_SOE-DB-Production_ccv-orgname-standard;SOE-DB-Production;7Server;" #id=10,id=29,id=45 These VMWARE AKs using VDC subs CANNOT have any sub attached - https://access.redhat.com/solutions/3157111
all_envs[6]="primary-ak_VMWARE_RHEL_8Server_x86_SOE-DB-NonProduction_ccv-orgname-standard;SOE-DB-Production;8;" #no association id=10,id=29,id=45 These VMWARE AKs using VDC subs CANNOT have any sub attached - https://access.redhat.com/solutions/3157111
all_envs[7]="primary-ak_VMWARE_RHEL_8Server_x86_SOE-DB-Production_ccv-orgname-standard;SOE-DB-Production;8;" #no association id=10,id=29,id=45 These VMWARE AKs using VDC subs CANNOT have any sub attached - https://access.redhat.com/solutions/3157111

for envs in "${all_envs[@]}"; do
  IFS=";" read -r -a arr <<< "${envs}"

  echo "${arr[0]}"
  hammer activation-key create --organization-label ${ORG_LABEL} --auto-attach "No" --unlimited-hosts --name "${arr[0]}" --lifecycle-environment "${arr[1]}" --release-version "${arr[2]}" --content-view ${CCV_ORG1_STD}

  # --subscriptions ( need to be comma separated )
  hammer activation-key add-subscription --organization-label ${ORG_LABEL} --name "${arr[0]}" --subscriptions "${arr[3]}"

done