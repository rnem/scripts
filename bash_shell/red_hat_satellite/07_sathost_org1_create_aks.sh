#!/bin/bash
#################################################################################
# RED HAT SATELLLITE - Create Org Activation Keys(s) - AKs                      #
# Created by Roger Nem - 2023                                                   #
#################################################################################

# AKs for physical, virtual machines

ORG_LABEL="COMP_ORG1"
CCV_ORG1_STD="ccv-orgname-standard"

declare -a all_aks

# -----------------------------
# Get IDs of the subscriptions
# -----------------------------

fedora_epel_id=$(hammer --no-headers subscription list --name 'Fedora EPEL' --fields id --organization-label ${ORG_LABEL} | sed 's/ //g' ) # Fedora EPEL
hpe_id=$(hammer --no-headers subscription list --name 'Hewlett Packard Enterprise' --fields id --organization-label ${ORG_LABEL} | sed 's/ //g' ) # Hewlett Packard Enterprise
rhsm_std_id=$(hammer --no-headers subscription list --name 'Red Hat Enterprise Linux Server with Smart Management, Standard (Physical or Virtual Nodes)' --fields id --organization-label ${ORG_LABEL} | sed 's/ //g') # Red Hat Enterprise Linux Server with Smart Management, Standard
vmware_id=$(hammer --no-headers subscription list --name 'VMware' --fields id --organization-label ${ORG_LABEL} | sed 's/ //g') # VMware

# ------------------
# Populate AK Array
# ------------------

all_aks[0]="ak-DELL_RHEL_8Server_x86_External-Production-DMZ_ccv-org1-standard;External-Production-DMZ;8;id=$fedora_epel_id,id=$rhsm_std_id"
all_aks[1]="ak-DELL_RHEL_8Server_x86_Internal-Production_ccv-org1-standard;Internal-Production;8;id=$fedora_epel_id,id=$rhsm_std_id"
all_aks[2]="ak-HPE_RHEL_7Server_x86_Internal-Production_ccv-org1-standard;Internal-Production;7Server;id=$fedora_epel_id,id=$rhsm_std_id,id=$hpe_id"
all_aks[3]="ak-HP_RHEL_7Server_x86_External-Production-DMZ_ccv-org1-standard;External-NonProduction-DMZ;7Server;id=$fedora_epel_id,id=$rhsm_std_id,id=$hpe_id"
all_aks[4]="ak-HP_RHEL_7Server_x86_Internal-Production_ccv-org1-standard;Internal-Production;7Server;id=$fedora_epel_id,id=$rhsm_std_id,id=$hpe_id"
all_aks[5]="ak-VMWARE_RHEL_7Server_x86_Internal-NonProduction_ccv-org1-standard;Internal-NonProduction;7Server;id=$fedora_epel_id,id=$rhsm_std_id,id=$vmware_id"
all_aks[6]="ak-VMWARE_RHEL_7Server_x86_Internal-Production_ccv-org1-standard;Internal-Production;7Server;id=$fedora_epel_id,id=$rhsm_std_id,id=$vmware_id"
all_aks[7]="ak-VMWARE_RHEL_8Server_x86_External-Production-DMZ_ccv-org1-standard;External-Production-DMZ;8;id=$fedora_epel_id,id=$rhsm_std_id"
all_aks[8]="ak-VMWARE_RHEL_8Server_x86_Internal-Production_ccv-org1-standard;Internal-Production;8;id=$fedora_epel_id,id=$rhsm_std_id"

# ---------------------------
# Create AKs and Assign Subs
# ---------------------------

for aks in "${all_aks[@]}"; do
  IFS=";" read -r -a arr <<< "${aks}"

  echo "${arr[0]}"
  hammer activation-key create --organization-label ${ORG_LABEL} --auto-attach "No" --unlimited-hosts --name "${arr[0]}" --lifecycle-environment "${arr[1]}" --release-version "${arr[2]}" --content-view "$CCV_ORG1_STD"

  # --subscriptions ( need to be comma separated )
  hammer activation-key add-subscription --organization-label ${ORG_LABEL} --name "${arr[0]}" --subscriptions "${arr[3]}"

done