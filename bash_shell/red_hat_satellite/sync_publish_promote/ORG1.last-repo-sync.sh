#!/bin/bash
#################################################################################
# RED HAT SATELLLITE - Confirm repos have synched (Good, Warning, Bad)          #
# Created by Roger Nem - 2023                                                   #
#################################################################################

ORG_LABEL="COMP_ORG1"
TEMP_LOG_FILE="./logs/$(basename $0).log"

# This is to force ruby/hammer to make it's output be line updates instead of progress bars
# that can timeout a session with infrequent output
exec > >(tee -a "$TEMP_LOG_FILE") 2>&1
echo "$(date +"%Y-%m-%d %H:%M:%S") - All output is being appended to $TEMP_LOG_FILE"

#REPO_ATTRIBUTES='started_at|ended_at|state|result|progress'
REPO_ATTRIBUTES='Status|Last Sync Date'

ORG_REPO_IDS=""

GOOD_REPOS_IDS=""
WARN_REPOS_IDS=""
BAD_REPOS_IDS=""

GOOD_REPOS_COUNT=0
WARN_REPOS_COUNT=0
BAD_REPOS_COUNT=0

#GOOD_REPO_MATCH="\s+hour\s+"
#Match Good if hour(s) or minute(s)
GOOD_REPO_MATCH="(\s+hour\w?\s+)|(\s+minute\w?\s+)"
#WARN_REPO_MATCH="\s+days\s+"
WARN_REPO_MATCH="\s+1 day\s+"

# get last repo sync info for all org repos

OLDIFS="$IFS"
echo "Last sync status for $ORG_LABEL repositories..."
IFS=$'\n'
for repo in $(hammer --output csv repository list --organization-label ${ORG_LABEL} | cut --output-delimiter="|" -f1,2,3 -d, | sed -n '1!p'); do
#       echo $repo
        CURRENT_REPO_ID="$(echo $repo | cut -f1 -d"|")"
        CURRENT_REPO_NAME="$(echo $repo | cut -f2 -d"|")"
        CURRENT_REPO_PRODUCT="$(echo $repo | cut -f3 -d"|")"
        CURRENT_REPO_INFO="$(hammer --output yaml repository info --id ${CURRENT_REPO_ID} | egrep -e ${REPO_ATTRIBUTES} | tr -d '\n' | sed -e 's/  / /g')"
        if [[ " $CURRENT_REPO_INFO " =~ $GOOD_REPO_MATCH ]]
        then
                CURRENT_STATUS=""
                GOOD_REPOS_IDS="$repo,$GOOD_REPO_IDS"
                GOOD_REPOS_COUNT=$((GOOD_REPOS_COUNT+1))
        elif [[ " $CURRENT_REPO_INFO " =~ $WARN_REPO_MATCH ]]
        then
                CURRENT_STATUS="WARNING"
                WARN_REPOS_IDS="$repo,$WARN_REPO_IDS"
                WARN_REPOS_COUNT=$((WARN_REPOS_COUNT+1))
        else
                CURRENT_STATUS="BAD"
                BAD_REPOS_IDS="$repo,$BAD_REPO_IDS"
                BAD_REPOS_COUNT=$((BAD_REPOS_COUNT+1))
        fi
        #echo "Repository $CURRENT_REPO_NAME of Product $CURRENT_REPO_PRODUCT last sync status (Repo ID: $CURRENT_REPO_ID):"
        echo "$CURRENT_STATUS + Repository \"$CURRENT_REPO_NAME (ID: $CURRENT_REPO_ID)\" last sync status:"
        echo "$CURRENT_STATUS \\___ $CURRENT_REPO_INFO"

done
IFS="$OLDIFS"
echo

echo "GOOD REPOS COUNT: $GOOD_REPOS_COUNT"
echo "WARNING REPOS COUNT: $WARN_REPOS_COUNT"
echo "BAD REPOS COUNT: $BAD_REPOS_COUNT"

echo "$(date +"%Y-%m-%d %H:%M:%S") - done reporting last repo sync status appended to $TEMP_LOG_FILE"
