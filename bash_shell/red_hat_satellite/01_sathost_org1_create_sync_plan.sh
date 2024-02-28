#!/bin/bash
#################################################################################
# RED HAT SATELLLITE - Create Org Sync Plan(s)                                  #
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
SYNC_PLAN_NAME="ORG1 Standard Daily Sync"
SYNC_PLAN_DESC="daily sync plan for ORG1"
SYNC_PLAN_SYNC_ENABLED="true"
SYNC_PLAN_INTERVAL="daily"

date=$(date '+%Y-%m-%d')

echo "Creating ${SYNC_PLAN_NAME}"
hammer sync-plan create --name "${SYNC_PLAN_NAME}" --description "${SYNC_PLAN_DESC}" --enabled "${SYNC_PLAN_SYNC_ENABLED}" --interval "${SYNC_PLAN_INTERVAL}" --sync-date $date --organization-label ${ORG_LABEL}