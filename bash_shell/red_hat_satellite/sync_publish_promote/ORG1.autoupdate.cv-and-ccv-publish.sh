#!/bin/bash
#################################################################################
# RED HAT SATELLLITE - Publish new version and Update CVs, CCVs                 #
# Created by Roger Nem - 2023                                                   #
#################################################################################

ORG_LABEL="COMP_ORG1"
TEMP_LOG_FILE="./logs/$(basename $0).log"

# This is to force ruby/hammer to make it's output be line updates instead of progress bars
# that can timeout a session with infrequent output
exec > >(tee -a "$TEMP_LOG_FILE") 2>&1
echo "$(date +"%Y-%m-%d %H:%M:%S") - $(basename $0) START - All output is being appended to $TEMP_LOG_FILE"

# update content views
for cv in $(hammer --csv content-view list --nondefault true --organization-label ${ORG_LABEL}| grep -vi '^Content View ID,' | awk -F',' '{print $2}' | grep '^cv-'); do
        echo "Publishing content view $cv ..."
        hammer content-view publish --name $cv --organization-label ${ORG_LABEL}
done

echo "Updating composite content views..."
for ccv in $(hammer --csv content-view list --organization-label ${ORG_LABEL}| grep -vi '^Content View ID,' | awk -F',' '{print $2}' | grep '^ccv-'); do
        cvids=""
        i=0
        echo "Get embedded CVs for ${ccv}..."
        for cv in $( hammer content-view info --name $ccv --organization-label ${ORG_LABEL} | grep " cv-" | awk -F" " '{print $2}'); do

                echo "Getting newest version of embedded cv ${cv}..."
                newestver=$(hammer --csv content-view version list --content-view $cv --organization-label ${ORG_LABEL} | grep -v Version | sort -rn | awk -F"," 'NR==1{print $3}')

                echo "Getting id of CV $cv version ${newestver}..."
                cvid=$(hammer --csv content-view version list --content-view $cv --organization-label ${ORG_LABEL} | grep ",${newestver},"| awk -F"," '{print $1}')

                # collect all cv ids to add to the ccv
                # TO RESOLVE THE PROBLEM OF BLANK CVIDS
                # Could not update the content view:
                #  Couldn't find Katello::ContentViewVersion with 'id'=

                if [[ $i == 0 ]]
                then
                  cvids="${cvid}"
                else
                  cvids="${cvids},${cvid}"
                fi

                i=$((i+1))
        done

        # remove the leading comma as it causes error in log
        cvids=$(sed -r 's/^,//' <<<"$cvids")

        # set ccv to use newest version of embedded cv
        echo "Updating CV versions (${cvids}) of CCV ${ccv}..."
        hammer content-view update --name $ccv --organization-label ${ORG_LABEL} --component-ids ${cvids}

        echo "Publishing composite content view ${ccv}..."
        hammer content-view publish --name $ccv --organization-label ${ORG_LABEL}
done
echo "$(date +"%Y-%m-%d %H:%M:%S") - $(basename $0) DONE - All output was appended to $TEMP_LOG_FILE"
