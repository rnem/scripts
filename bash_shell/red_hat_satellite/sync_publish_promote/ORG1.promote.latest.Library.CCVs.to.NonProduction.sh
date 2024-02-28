#!/bin/bash
##################################################################
# RED HAT SATELLLITE - Promote latest Library CCVs to NonProd    #
# Created by Roger Nem - 2023                                    #
##################################################################

ORG_LABEL="COMP_ORG1"
EXCLUDE_CV_PROMOTION="./ORG1.exclude_from_autoupdate.txt"
TEMP_LOG_FILE="./logs/$(basename $0).log"

# This is to force ruby/hammer to make it's output be line updates instead of progress bars
# that can timeout a session with infrequent output
exec > >(tee -a "$TEMP_LOG_FILE") 2>&1
echo "$(date +"%Y-%m-%d %H:%M:%S") - $(basename $0) START - All output is being appended to $TEMP_LOG_FILE"

declare -a all_envs
all_envs[0]='ccv-org1-standard;External-NonProduction-DMZ'
all_envs[1]='ccv-org1-standard;Internal-NonProduction'

for envs in "${all_envs[@]}"; do
  IFS=";" read -r -a arr <<< "${envs}"

    latest_version=$(hammer --csv content-view version list --content-view "${arr[0]}" --organization-label ${ORG_LABEL} --lifecycle-environment "Library" | grep -v ",Version," | cut -d',' -f3)

    hammer content-view version promote --organization-label ${ORG_LABEL} --content-view "${arr[0]}" --to-lifecycle-environment "${arr[1]}" --version "${latest_version}" --description "promoted latest Library to NonProd LCE"

done

echo "$(date +"%Y-%m-%d %H:%M:%S") - Finished $ORG_LABEL Library to NonProduction promotions see $TEMP_LOG_FILE"