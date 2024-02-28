#!/bin/bash
#################################################################################
# RED HAT SATELLLITE - Publish new version of CVs only                          #
# Created by Roger Nem - 2023                                                   #
#################################################################################

ORG_LABEL="COMP_ORG1"
TEMP_LOG_FILE="./logs/$(basename $0).log"

# This is to force ruby/hammer to make it's output be line updates instead of progress bars
# that can timeout a session with infrequent output
exec > >(tee -a "$TEMP_LOG_FILE") 2>&1
echo "All output is being appended to $TEMP_LOG_FILE"

# update content views
echo "Updating Content Views (Not Composite Content Views)..."
for cv in $(hammer --csv content-view list --organization-label ${ORG_LABEL}| grep -vi '^Content View ID,' | awk -F',' '{print $2}' | grep '^cv-'); do
        echo "Publishing content view $cv ..."
        hammer content-view publish --async --name $cv --organization-label ${ORG_LABEL}
done