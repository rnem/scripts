#!/bin/bash
#################################################################################
# RED HAT SATELLLITE - Create Org Custom Extra Activation Keys(s) - AKs         #
# Created by Roger Nem - 2023                                                   #
#################################################################################

ORG_LABEL="COMP_ORG2"

declare -a all_envs

# 0. AK Name, 1. CV, 2. LCE, 3. Subscriptions, 4. Description

all_envs[0]="extra-ak-0-vms_vdc_only_custom_fedora_vmware;ccv-orgname-standard;Library;Fedora EPEL,VMware;Meant to be used ONLY by VMWARE using VDC subs due to https://access.redhat.com/solutions/3157111"
all_envs[1]="extra-ak_docker;ccv-orgname-standard;Library;Docker;;"
all_envs[2]="extra-ak_gcloud;ccv-orgname-standard;Library;Gcloud;;"
all_envs[3]="extra-ak_influxdb;ccv-orgname-standard;Library;InfluxData;;"
all_envs[4]="extra-ak_jenkins;ccv-orgname-standard;Library;Jenkins EIS;;"
all_envs[5]="extra-ak_rh-ansible-engine_7Server;ccv-orgname-standard;Library;;This AK doesn't have any subscription added by design as it is only to allow Ansible to enable the corresponding repos. The main AK already contains the right subs."
all_envs[6]="extra-ak_rh-ansible-engine_8Server;ccv-orgname-standard;Library;;This AK doesn't have any subscription added by design as it is only to allow Ansible to enable the corresponding repos. The main AK already contains the right subs."
all_envs[7]="extra-ak_rh-els_AWS_NonProd_6Server;ccv-orgname-standard-aws;AWS-NonProd-6;Red Hat Enterprise Linux Extended Life Cycle Support (Physical or Virtual Nodes);Auto-attach must be disabled for it to work"
all_envs[8]="extra-ak_rh-els_AWS_Prod_6Server;ccv-orgname-standard-aws;AWS-Prod-6;Red Hat Enterprise Linux Extended Life Cycle Support (Physical or Virtual Nodes);Auto-attach must be disabled for it to work"
all_envs[9]="extra-ak_rh-els_SOE_NonProd_6Server;ccv-orgname-standard;SOE-NonProduction;Red Hat Enterprise Linux Extended Life Cycle Support (Physical or Virtual Nodes);Auto-attach must be disabled for it to work"
all_envs[10]="extra-ak_rh-els_SOE_Prod_6Server;ccv-orgname-standard;SOE-Production;Red Hat Enterprise Linux Extended Life Cycle Support (Physical or Virtual Nodes);Auto-attach must be disabled for it to work"
all_envs[11]="extra-ak_rh_openstack;ccv-orgname-standard;Library;;This AK doesn't have any subscription added by design as it is only to allow Ansible to enable the corresponding repos. The main AK already contains the right subs."
all_envs[12]="extra-ak_rhscl;ccv-orgname-standard;Library;;This AK doesn't have any subscription added by design as it is only to allow Ansible to enable the corresponding repos. "
all_envs[13]="extra-ak_sap-hana;ccv-orgname-standard;Library;;"
all_envs[14]="extra-ak_signal-sciences;ccv-orgname-standard;Library;Signal Sciences Corp - WAF;"


for envs in "${all_envs[@]}"; do
  IFS=";" read -r -a arr <<< "${envs}"

  hammer activation-key create --organization-label ${ORG_LABEL} --auto-attach "No" --unlimited-hosts --name "${arr[0]}" --content-view "${arr[1]}" --lifecycle-environment "${arr[2]}" --description "${arr[4]}"

  # --subscriptions ( need to be comma separated )
  case ${arr[0]} in
    extra-ak-0-vms_vdc_only_custom_fedora_vmware)
      SUBS="s"
      ;;
    *)
      SUBS=""
      ;;
  esac

  hammer activation-key add-subscription --organization-label ${ORG_LABEL} --name "${arr[0]}" --subscription"$SUBS" "${arr[3]}"

done