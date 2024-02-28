#!/bin/bash
#################################################################################
# RED HAT SATELLLITE - Create Org Lifecycle Environments(s) - LCEs              #
# Created by Roger Nem - 2023                                                   #
#################################################################################

#
# Enforce root
#
if [ ! $EUID ]; then
    printf "Error: Must be run as root\n\n"
    exit 1
fi

ORG_LABEL="COMP_ORG1"

declare -a all_lces

all_lces[0]="Internal-NonProduction;Library"
all_lces[1]="Internal-Production;Internal-NonProduction"
all_lces[2]="External-NonProduction-DMZ;Library"
all_lces[3]="External-Production-DMZ;External-NonProduction-DMZ"

for lces in "${all_lces[@]}"; do
  IFS=";" read -r -a arr <<< "${lces}"

  echo "Creating ${arr[0]} LCE"
  hammer lifecycle-environment create --name "${arr[0]}" --description "ORG1 ${arr[0]} Environment" --prior "${arr[1]}" --organization-label ${ORG_LABEL}

done

#hammer lifecycle-environment create --name "Internal-NonProduction" --description "ORG1 Internal-NonProduction Environment" --prior "Library" --organization-label ${ORG_LABEL}
#hammer lifecycle-environment create --name "Internal-Production" --description "ORG1 Internal-Production Environment" --prior "External-Production" --organization-label ${ORG_LABEL}
#hammer lifecycle-environment create --name "External-NonProduction-DMZ" --description "ORG1 External-NonProduction-DMZ Environment" --prior "Library" --organization-label ${ORG_LABEL}
#hammer lifecycle-environment create --name "External-Production-DMZ" --description "ORG1 External-Production-DMZ Environment" --prior "External-NonProduction-DMZ" --organization-label ${ORG_LABEL}