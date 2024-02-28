#!/bin/bash
#################################################################################
# RED HAT SATELLLITE - Create Org Reg SOE Activation Keys(s) - AKs              #
# Created by Roger Nem - 2023                                                   #
#################################################################################

# AKs for regular instances ONLY - Not DB, SAP

ORG_LABEL="COMP_ORG2"
CCV_ORG1_STD="ccv-orgname-standard"
CCV_ORG1_EUS="ccv-orgname-eus"

declare -a all_envs

# Fedora EPEL subscription id=10
# VMware id=29
# Hewlett Packard Enterprise id=43
# VMWAREnoVDC - "Use for VMs on hypervisors without VDC"
# noVDC - Red Hat Enterprise Linux Server with Smart Management, Standard id=37
# VDC - Red Hat Enterprise Linux for Virtual Datacenters with Smart Management, Standard id=45
# VDC - Red Hat Enterprise Linux for Virtual Datacenters with Smart Management, Premium id=44

# ******* SAP VM Key missing - needs to be created *******

all_envs[0]="primary-ak_VMWARE_RHEL_7point6_x86_BO-Production_ccv-orgname-eus;BO-Production;7.6;;$CCV_ORG1_EUS" #These VMWARE AKs using VDC subs CANNOT have any sub attached - https://access.redhat.com/solutions/3157111
all_envs[1]="primary-ak_HP_RHEL_6Server_x86_SOE-Production_ccv-orgname-standard;SOE-Production;6Server;id=10,id=43;$CCV_ORG1_STD"
all_envs[2]="primary-ak_HP_RHEL_7Server_x86_SOE-Production_ccv-orgname-standard;SOE-Production;7Server;id=10,id=43;$CCV_ORG1_STD"
all_envs[3]="primary-ak_VMWAREnoVDC_RHEL_7Server_x86_SOE-Production_ccv-orgname-standard;SOE-Production;7Server;id=10,id=29,id=37;$CCV_ORG1_STD"
all_envs[4]="primary-ak_VMWAREnoVDC_RHEL_8Server_x86_SOE-NonProduction_ccv-orgname-standard;SOE-NonProduction;8;id=10,id=29,id=37;$CCV_ORG1_STD"
all_envs[5]="primary-ak_VMWAREnoVDC_RHEL_8Server_x86_SOE-Production_ccv-orgname-standard;SOE-Production;8;id=10,id=29,id=37;$CCV_ORG1_STD"
all_envs[6]="primary-ak_VMWARE_RHEL_6Server_x86_SOE-NonProduction_ccv-orgname-standard;SOE-NonProduction;6Server;;$CCV_ORG1_STD" #no association These VMWARE AKs using VDC subs CANNOT have any sub attached - https://access.redhat.com/solutions/3157111
all_envs[7]="primary-ak_VMWARE_RHEL_7Server_x86_SOE-NonProduction_ccv-orgname-standard;SOE-NonProduction;7Server;;$CCV_ORG1_STD" #id=10,id=29,id=45 These VMWARE AKs using VDC subs CANNOT have any sub attached - https://access.redhat.com/solutions/3157111
all_envs[8]="primary-ak_VMWARE_RHEL_7Server_x86_SOE-Production_ccv-orgname-standard;SOE-Production;7Server;;$CCV_ORG1_STD" #id=10,id=29,id=45 These VMWARE AKs using VDC subs CANNOT have any sub attached - https://access.redhat.com/solutions/3157111
all_envs[9]="primary-ak_VMWARE_RHEL_8Server_x86_SOE-NonProduction_ccv-orgname-standard;SOE-NonProduction;8;;$CCV_ORG1_STD" #id=10,id=29,id=45 These VMWARE AKs using VDC subs CANNOT have any sub attached - https://access.redhat.com/solutions/3157111
all_envs[10]="primary-ak_VMWARE_RHEL_8Server_x86_SOE-Production_ccv-orgname-standard;SOE-Production;8;;$CCV_ORG1_STD" #id=10,id=29,id=45 These VMWARE AKs using VDC subs CANNOT have any sub attached - https://access.redhat.com/solutions/3157111
all_envs[11]="primary-ak_VMWARE_RHEL_6Server_x86_SOE-Production_ccv-orgname-standard;SOE-Production;6Server;;$CCV_ORG1_STD" #These VMWARE AKs using VDC subs CANNOT have any sub attached - https://access.redhat.com/solutions/3157111

for envs in "${all_envs[@]}"; do
  IFS=";" read -r -a arr <<< "${envs}"

  echo "${arr[0]}"
  hammer activation-key create --organization-label ${ORG_LABEL} --auto-attach "No" --unlimited-hosts --name "${arr[0]}" --lifecycle-environment "${arr[1]}" --release-version "${arr[2]}" --content-view "${arr[4]}"

  # --subscriptions ( need to be comma separated )
  hammer activation-key add-subscription --organization-label ${ORG_LABEL} --name "${arr[0]}" --subscriptions "${arr[3]}"

done