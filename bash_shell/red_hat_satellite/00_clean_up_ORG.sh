#!/bin/bash
#################################################################################
# RED HAT SATELLLITE - CLEAN-UP                                                 #
# Created by Roger Nem - 2023                                                   #
#################################################################################

## Variables ###########################################################

SAT_ORG_LABEL="COMP_ORG1"
SAT_ORG_ID=3

# 1. Delete custom products
# -------------------------
for prod_id in `hammer --no-headers product list --organization-label $SAT_ORG_LABEL --fields name,id |egrep -v "Red|RHEL|OpenShift" | cut -d'|' -f1`; do 
	echo $prod_id
	hammer product delete --id $prod_id --organization-label $SAT_ORG_LABEL
done

# 2. Delete Activation Keys
# -------------------------
for k in `hammer --no-headers activation-key list --organization-label $SAT_ORG_LABEL --fields id`; do 
	hammer activation-key delete --organization-label $SAT_ORG_LABEL --id $k
done


# 3. Delete Hosts
# ---------------
for h in `hammer --no-headers host list --organization-id $SAT_ORG_ID --fields id`; do 
	hammer host delete --id $h --organization-id $SAT_ORG_ID
done

# 4. Remove CVs from LCEs (Manual Process for now)
# ------------------------------------------------

# 4.1 Lets remove from all LCEs
# --------------------------------

# just to verify the environment IDs
hammer lifecycle-environment list --organization-label $SAT_ORG_LABEL

# Version 133.0 (latest) DMZ-Production
# Version 128.0 (NOT the latest) SOE-ORACLE-EDB-NonProduction & SOE-ORACLE-EDB-Production

hammer content-view remove-from-environment --id 29 --lifecycle-environment DMZ-Production --organization-label $SAT_ORG_LABEL
hammer content-view remove-from-environment --id 29 --lifecycle-environment SOE-ORACLE-EDB-Production --organization-label $SAT_ORG_LABEL

# ID OF THE CCV is hardcoded here: +++ THIS MUST BE DONE FOR EVERY SINGLE CCV AND CV MANUALLY ++++++

# 25              | ccv-orgname-eus                          
# 28              | ccv-orgname-sap-aws-eus                  
# 29              | ccv-orgname-standard                     
# 59              | ccv-orgname-standard-aws                 

for lce_id in `hammer --no-headers lifecycle-environment list --organization-label $SAT_ORG_LABEL --fields id`; do 
	hammer content-view remove-from-environment --id 29 --lifecycle-environment-id $lce_id --organization-label $SAT_ORG_LABEL
done

#[.................................................................................................................................................................] [100%]
#[.................................................................................................................................................................] [100%]
# Could not remove the content view from environment:
#  Content view 'ccv-orgname-standard' is not in lifecycle environment 'AWS-GRC-NonProd-8_1'.
# Could not remove the content view from environment:
#  Content view 'ccv-orgname-standard' is not in lifecycle environment 'AWS-GRC-Prod-8_1'.
# etc

for lce_name in `hammer --no-headers lifecycle-environment list --organization-label $SAT_ORG_LABEL --fields name`; do 
	echo $lce_name; hammer content-view remove-from-environment --id 25 --lifecycle-environment $lce_name --organization-label $SAT_ORG_LABEL
done

# AWS-Prod-7
# Could not remove the content view from environment:
#   Content view 'ccv-orgname-eus' is not in lifecycle environment 'AWS-Prod-7'.
# AWS-Prod-8
# Could not remove the content view from environment:
#   Content view 'ccv-orgname-eus' is not in lifecycle environment 'AWS-Prod-8'.
# BO-NonProduction
#[.................................................................................................................................................................] [100%]
# BO-Production
#[.................................................................................................................................................................] [100%]
# DLP-NonProd
#[.................................................................................................................................................................] [100%]
# Library
#[.................................................................................................................................................................] [100%]
# etc


for lce_name in `hammer --no-headers lifecycle-environment list --organization-label $SAT_ORG_LABEL --fields name`; do echo $lce_name; hammer content-view remove-from-environment --id 28 --lifecycle-environment $lce_name --organization-label $SAT_ORG_LABEL; done
for lce_name in `hammer --no-headers lifecycle-environment list --organization-label $SAT_ORG_LABEL --fields name`; do echo $lce_name; hammer content-view remove-from-environment --id 29 --lifecycle-environment $lce_name --organization-label $SAT_ORG_LABEL; done
for lce_name in `hammer --no-headers lifecycle-environment list --organization-label $SAT_ORG_LABEL --fields name`; do echo $lce_name; hammer content-view remove-from-environment --id 59 --lifecycle-environment $lce_name --organization-label $SAT_ORG_LABEL; done
for lce_name in `hammer --no-headers lifecycle-environment list --organization-label $SAT_ORG_LABEL --fields name`; do echo $lce_name; hammer content-view remove-from-environment --id 55 --lifecycle-environment $lce_name --organization-label $SAT_ORG_LABEL; done
for lce_name in `hammer --no-headers lifecycle-environment list --organization-label $SAT_ORG_LABEL --fields name`; do echo $lce_name; hammer content-view remove-from-environment --id 53 --lifecycle-environment $lce_name --organization-label $SAT_ORG_LABEL; done
# etc

# 4.2) Now we purge old CCV versions that may still contain a cv
# --------------------------------
# "Could not delete the content view: Cannot delete version while it is in use by composite content views: ccv-orgname-standard Version 62.0"

# * https://access.redhat.com/solutions/2760531 - To delete all except for X newest versions, use command

hammer content-view purge --count 2 --id 25 #(ccv-orgname-eus)
hammer content-view purge --count 3 --id 29 #(ccv-orgname-standard)

#[.................................................................................................................................................................] [100%]
# Version '52.0' of content view 'ccv-orgname-standard' deleted.
#[.................................................................................................................................................................] [100%]
# Version '55.0' of content view 'ccv-orgname-standard' deleted.
#[.................................................................................................................................................................] [100%]
# etc

# 4.3) REMOVE THE CCVS first
# --------------------------------
hammer content-view delete --id 59 --organization-label $SAT_ORG_LABEL
#[.................................................................................................................................................................] [100%]

# 4.4) Finally we can remove CVs
# --------------------------------
hammer content-view delete --id 23 --organization-label $SAT_ORG_LABEL
#[.................................................................................................................................................................] [100%]


# 5. Remove CVs
# ---------------

for cv_id in `hammer --no-headers content-view list --organization-label $SAT_ORG_LABEL --fields 'Content View ID'`; do 
	echo $cv_id
	hammer content-view delete --id $cv_id --organization-label $SAT_ORG_LABEL
done

#91
#[..............................................................................................................................................................................] [100%]
#95
#[..............................................................................................................................................................................] [100%]
#etc


# 6. Delete LCEs
# ----------------
for lce_name in `hammer --no-headers lifecycle-environment list --organization-label $SAT_ORG_LABEL --fields name |grep -v Library`; do 
	echo $lce_name
	hammer lifecycle-environment delete --name $lce_name --organization-label $SAT_ORG_LABEL
done

# AWS-DB-NonProd-7
# Environment deleted.
# AWS-DB-NonProd-8
# Environment deleted.
# AWS-DB-Prod-7
# Environment deleted.
# etc