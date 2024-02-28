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

ORG_LABEL="COMP_ORG2"

# These are the CCVs
# A. ccv-orgname-eus
# B. ccv-orgname-sap-aws
# C. ccv-orgname-standard
# D. ccv-orgname-standard-aws

declare -a arr_cvs_of_a
declare -a arr_cvs_of_b
declare -a arr_cvs_of_c
declare -a arr_cvs_of_d
declare -a arr_cvs_ids

# ----------------------
# 1. Getting IDs of CVs
# We need to get the latest published version of the CV
# -----------------------

# hammer content-view version list --content-view cv-os-rhel-8Server --organization-label ${ORG_LABEL}
#-----|------------------------|---------|-------------|-----------------------
#ID   | NAME                   | VERSION | DESCRIPTION | LIFECYCLE ENVIRONMENTS
#-----|------------------------|---------|-------------|-----------------------
#4317 | cv-os-rhel-8Server 2.0 | 2.0     |             | Library

# hammer --no-headers content-view version list --content-view cv-os-rhel-8Server --organization-label ${ORG_LABEL}
# 4317

arr_cvs_of_a[0]='cv-os-rhel-6Server-els'
arr_cvs_of_a[1]='cv-os-rhel-7point6-eus'
arr_cvs_of_a[2]='cv-os-rhel-rhscl-7point6-eus'

echo "This is for ccv-orgname-eus: "

for cvs_a in "${arr_cvs_of_a[@]}"; do
  IFS=";" read -r -a arr <<< "${cvs_a}"

  #echo "Getting ID of ${arr[0]}"
  #arr_cvs_of_a_ids+=$(hammer content-view info --name "${arr[0]}" --organization-label ${ORG_LABEL} |egrep "^Id:" | cut -d: -f2 | sed -e 's/^[ \t]*//')','

  echo "Getting last published version ID of ${arr[0]}"
  arr_cvs_of_a_ids+=$(hammer --no-headers content-view version list --content-view "${arr[0]}" --organization-label ${ORG_LABEL} | cut -d'|' -f1)','

done

arr_cvs_of_b[0]='cv-app-sap-hana-aws-rhel-8point2'

echo ""
echo "This is for ccv-orgname-sap-aws: "

for cvs_b in "${arr_cvs_of_b[@]}"; do
  IFS=";" read -r -a arr <<< "${cvs_b}"

  #echo "Getting ID of ${arr[0]}"
  #arr_cvs_of_b_ids+=$(hammer content-view info --name "${arr[0]}" --organization-label ${ORG_LABEL} |egrep "^Id:" | cut -d: -f2 | sed -e 's/^[ \t]*//')','

  echo "Getting last published version ID of ${arr[0]}"
  arr_cvs_of_b_ids+=$(hammer --no-headers content-view version list --content-view "${arr[0]}" --organization-label ${ORG_LABEL} | cut -d'|' -f1)','

done

arr_cvs_of_c[0]='cv-app-docker'
arr_cvs_of_c[1]='cv-app-gcloud'
arr_cvs_of_c[2]='cv-app-influxdb'
arr_cvs_of_c[3]='cv-app-jenkins'
arr_cvs_of_c[4]='cv-app-rh-ansible-engine'
arr_cvs_of_c[5]='cv-app-rhel-rhscl'
arr_cvs_of_c[6]='cv-app-rh-openstack'
arr_cvs_of_c[7]='cv-app-signal-sciences'
arr_cvs_of_c[8]='cv-os-rhel-6Server'
arr_cvs_of_c[9]='cv-os-rhel-6Server-els'
arr_cvs_of_c[10]='cv-os-rhel-7Server'
arr_cvs_of_c[11]='cv-os-rhel-8Server'
arr_cvs_of_c[12]='cv-os-rhel-9Server'

echo ""
echo "This is for ccv-orgname-standard: "

for cvs_c in "${arr_cvs_of_c[@]}"; do
  IFS=";" read -r -a arr <<< "${cvs_c}"

  #echo "Getting ID of ${arr[0]}"
  #arr_cvs_of_c_ids+=$(hammer content-view info --name "${arr[0]}" --organization-label ${ORG_LABEL} |egrep "^Id:" | cut -d: -f2 | sed -e 's/^[ \t]*//')','

  echo "Getting last published version ID of ${arr[0]}"
  arr_cvs_of_c_ids+=$(hammer --no-headers content-view version list --content-view "${arr[0]}" --organization-label ${ORG_LABEL} | cut -d'|' -f1)','

done

arr_cvs_of_d[0]='cv-app-rhel-rhscl'
arr_cvs_of_d[1]='cv-app-rh-openstack'
arr_cvs_of_d[2]='cv-os-rhel-6Server'
arr_cvs_of_d[3]='cv-os-rhel-6Server-els'
arr_cvs_of_d[4]='cv-os-rhel-7Server'
arr_cvs_of_d[5]='cv-os-rhel-8Server'
arr_cvs_of_d[6]='cv-os-rhel-9Server'

echo ""
echo "This is for ccv-orgname-standard-aws: "

for cvs_d in "${arr_cvs_of_d[@]}"; do
  IFS=";" read -r -a arr <<< "${cvs_d}"

  #echo "Getting ID of ${arr[0]}"
  #arr_cvs_of_d_ids+=$(hammer content-view info --name "${arr[0]}" --organization-label ${ORG_LABEL} |egrep "^Id:" | cut -d: -f2 | sed -e 's/^[ \t]*//')','

  echo "Getting last published version ID of ${arr[0]}"
  arr_cvs_of_d_ids+=$(hammer --no-headers content-view version list --content-view "${arr[0]}" --organization-label ${ORG_LABEL} | cut -d'|' -f1)','

done

# 1.1 Clear the last comma and white spaces so we have a list of the IDs of the CVs to be added to the corresponding CCV
ids_of_a=$( echo "${arr_cvs_of_a_ids[@]}" | sed 's/,$//' | sed 's/ //g' )
ids_of_b=$( echo "${arr_cvs_of_b_ids[@]}" | sed 's/,$//' | sed 's/ //g' )
ids_of_c=$( echo "${arr_cvs_of_c_ids[@]}" | sed 's/,$//' | sed 's/ //g' )
ids_of_d=$( echo "${arr_cvs_of_d_ids[@]}" | sed 's/,$//' | sed 's/ //g' )


# ----------------------------------------------------
# 2. Now we create the CCVs with the corresponding CVs
# ----------------------------------------------------
declare -a arr_ccvs

arr_ccvs[0]="ccv-orgname-eus;$ids_of_a"
arr_ccvs[1]="ccv-orgname-sap-aws;$ids_of_b"
arr_ccvs[2]="ccv-orgname-standard;$ids_of_c"
arr_ccvs[3]="ccv-orgname-standard-aws;$ids_of_d"

for ccvs in "${arr_ccvs[@]}"; do
  IFS=";" read -r -a arr <<< "${ccvs}"

  hammer content-view create --composite --name "${arr[0]}" --component-ids "${arr[1]}" --organization-label ${ORG_LABEL}

done