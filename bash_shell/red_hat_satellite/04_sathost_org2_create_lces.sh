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

ORG_LABEL="COMP_ORG2"

declare -a all_lces

all_lces[0]="BO-NonProduction;Library"
all_lces[1]="BO-Production;BO-NonProduction"
all_lces[2]="DMZ-NonProduction;Library"
all_lces[3]="DMZ-Production;DMZ-NonProduction"
all_lces[4]="SAP-NonAppliance-NonProd;Library"
all_lces[5]="SAP-NonAppliance-Prod;SAP-NonAppliance-NonProd"
all_lces[6]="SOE-DB-NonProduction;Library"
all_lces[7]="SOE-DB-Production;SOE-DB-NonProduction"
all_lces[8]="SOE-NonProduction;Library"
all_lces[9]="SOE-Production;SOE-NonProduction"

for lces in "${all_lces[@]}"; do
  IFS=";" read -r -a arr <<< "${lces}"

  echo "Creating ${arr[0]} LCE"
  hammer lifecycle-environment create --name "${arr[0]}" --description "ORG2 ${arr[0]} Environment" --prior "${arr[1]}" --organization-label ${ORG_LABEL}

done