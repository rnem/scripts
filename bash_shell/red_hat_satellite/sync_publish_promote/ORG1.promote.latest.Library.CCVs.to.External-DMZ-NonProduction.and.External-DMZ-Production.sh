#!/bin/bash
#####################################################################################
# RED HAT SATELLLITE - Promote latest Library CCVs to DMZ NonProd and Prod - CVEs   #
# Created by Roger Nem - 2023                                                       #
#####################################################################################

ORG_LABEL="COMP_ORG1"
ORG_CCV="ccv-org1-standard"

EXCLUDE_CV_PROMOTION="./ORG1.exclude_from_autoupdate.txt"
TEMP_LOG_FILE="./logs/$(basename $0).log"

# This is to force ruby/hammer to make it's output be line updates instead of progress bars
# that can timeout a session with infrequent output
exec > >(tee -a "$TEMP_LOG_FILE") 2>&1
echo "$(date +"%Y-%m-%d %H:%M:%S") - $(basename $0) START - All output is being appended to $TEMP_LOG_FILE"

{% if facter_puppetversion >= "5.5.17" %}
latest_version=$(hammer --csv content-view version list --content-view ${ORG_CCV} --organization-label ${ORG_LABEL} --lifecycle-environment "Library" | grep -v ",Version," | cut -d',' -f3)
{% else %}
latest_version=$(hammer --csv content-view version list --content-view ${ORG_CCV} --organization-label ${ORG_LABEL} --environment "Library" | grep -v ",Version," | cut -d',' -f3)
{% endif %}

declare -a all_plces

all_plces[0]="External-NonProduction-DMZ,promoted Library CCVs to External-NonProduction-DMZ"
all_plces[1]="External-Production-DMZ,promoted Library CCVs to External-Production-DMZ"

for plces in "${all_plces[@]}"; do
  IFS=";" read -r -a arr <<< "${plces}"

  hammer content-view version promote --organization-label ${ORG_LABEL} --content-view ${ORG_CCV} --to-lifecycle-environment "${arr[0]}" --version "${latest_version}" --description "${arr[1]}"

done

echo "$(date +"%Y-%m-%d %H:%M:%S") - $(basename $0) DONE - All output is being appended to $TEMP_LOG_FILE"