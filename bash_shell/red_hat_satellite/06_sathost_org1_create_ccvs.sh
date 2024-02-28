#!/bin/bash
#################################################################################
# RED HAT SATELLLITE - Create Org Composite Content View(s) - CCVs              #
# Created by Roger Nem - 2023                                                   #
#################################################################################

#
# Enforce root
#
if [ ! $EUID ]; then
    printf "Error: Must be run as root\n\n"
    exit 1
fi

# Note: CVs must have been published for this to work

ORG_LABEL="COMP_ORG1"

declare -a arr_cvs_of_a

ORG1_CCV="ccv-org1-standard"

# ----------------------
# 1. Getting IDs of CVs
# We need to get the latest published version of the CV
# -----------------------

arr_cvs_of_a[0]='cv-7Server'
arr_cvs_of_a[1]='cv-8Server'
arr_cvs_of_a[2]='cv-AnyPhysicalServer'

echo "This is for $ORG1_CCV: "

for cvs_a in "${arr_cvs_of_a[@]}"; do
  IFS=";" read -r -a arr <<< "${cvs_a}"

  echo "Getting last published version ID of ${arr[0]}" # from arr <<<
  arr_cvs_of_a_ids+=$(hammer --no-headers content-view version list --content-view "${arr[0]}" --organization-label ${ORG_LABEL} | cut -d'|' -f1)','

done

# 1.1 Clear the last comma and white spaces so we have a list of the IDs of the CVs to be added to the corresponding CCV
ids_of_a=$( echo "${arr_cvs_of_a_ids[@]}" | sed 's/,$//' | sed 's/ //g' )

# ----------------------------------------------------
# 2. Now we create the CCVs with the corresponding CVs
# ----------------------------------------------------
declare -a arr_ccvs

arr_ccvs[0]="$ORG1_CCV;$ids_of_a"

for ccvs in "${arr_ccvs[@]}"; do
  IFS=";" read -r -a arr <<< "${ccvs}"

  hammer content-view create --composite --name "${arr[0]}" --component-ids "${arr[1]}" --organization-label ${ORG_LABEL} # from arr <<<

done