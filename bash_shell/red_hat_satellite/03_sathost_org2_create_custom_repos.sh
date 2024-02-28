#!/bin/bash
#################################################################################
# RED HAT SATELLLITE - Create Org Custom Repos(s)                               #
# Created by Roger Nem - 2023                                                   #
#################################################################################

#
# Enforce root
#
if [ ! $EUID ]; then
    printf "Error: Must be run as root\n\n"
    exit 1
fi

# **** Custom Products must exist prior to running this script *****
echo "**** Custom Products must exist prior to running this script *****"
echo ""

ORG_LABEL="COMP_ORG2"

declare -a all_crps

# 1 - CREATE CUSTOM REPOS ( Product, Repo Name, Description, Type, url, verify SSL, Download Policy )

# Docker
all_crps[0]="Docker;Docker-CE-7;Docker CentOS 7 repository - Stable;yum;https://download.docker.com/linux/centos/7/x86_64/stable/;true;immediate;mirror_content_only"
all_crps[1]="Docker;Docker-CE-8;Docker CentOS 8 repository - Stable;yum;https://download.docker.com/linux/centos/8/x86_64/stable/;true;immediate;mirror_content_only"

# Fedora EPEL
all_crps[2]="Fedora EPEL;EPEL6 x86_64;;yum;https://archives.fedoraproject.org/pub/archive/epel/6/x86_64/;true;immediate;additive"
all_crps[3]="Fedora EPEL;EPEL7 x86_64;;yum;https://dl.fedoraproject.org/pub/epel/7/x86_64/;true;immediate;additive"
all_crps[4]="Fedora EPEL;EPEL8 x86_64;;yum;https://dl.fedoraproject.org/pub/epel/8/Everything/x86_64/;true;immediate;additive"
all_crps[5]="Fedora EPEL;EPEL9 x86_64;;yum;https://dl.fedoraproject.org/pub/epel/9/Everything/x86_64/;true;immediate;additive"

# Gcloud - It has GPG Key GPG-KEY-Gcloud (add it manually after it gets created)
all_crps[6]="Gcloud;Gcloud-sdk-el7;;yum;https://packages.cloud.google.com/yum/repos/cloud-sdk-el7-x86_64;true;immediate;additive"

# Hewlett Packard Enterprise

	# This one requires authentication
	# FWPP_Current_6Server_x86_64
	# Satellite 6.12
	echo "FWPP_Current_6Server_x86_64"
	hammer repository create --product "Hewlett Packard Enterprise" --name "FWPP_Current_6Server_x86_64" --description "HPE Firmware Pack for ProLiant (FWPP)" --content-type "yum" --url "https://downloads.linux.hpe.com/SDR/repo/fwpp/rhel/6/x86_64/current/" --upstream-username "***********" --upstream-password "null" --verify-ssl-on-sync "true" --download-policy "immediate" --mirroring-policy "mirror_content_only" --organization-label ${ORG_LABEL}

all_crps[7]="Hewlett Packard Enterprise;HPSUM Current 6Server x86_64;HPE Smart Update Manager (SUM);yum;https://downloads.linux.hpe.com/SDR/repo/hpsum/rhel/6Server/x86_64/current/;true;immediate;mirror_content_only"
all_crps[8]="Hewlett Packard Enterprise;IP Gen8 Current;HPE ProLiant DL360 Gen8 Intelligent Provisioning (IP);yum;https://downloads.linux.hpe.com/repo/ip/rhel/current/x86_64/gen8/;true;immediate;mirror_content_only"
all_crps[9]="Hewlett Packard Enterprise;IP Gen9 Current;HPE ProLiant DL360 Gen9 Intelligent Provisioning (IP);yum;https://downloads.linux.hpe.com/repo/ip/rhel/current/x86_64/gen9/;true;immediate;mirror_content_only"
all_crps[10]="Hewlett Packard Enterprise;SPP Current 6Server x86_64;Service Pack for ProLiant (SPP);yum;https://downloads.linux.hpe.com/repo/spp/rhel/6Server/x86_64/current/;true;immediate;mirror_content_only"
all_crps[11]="Hewlett Packard Enterprise;STK Current 6Server x86_64;HPE Scripting Tools Repository (STK);yum;https://downloads.linux.hpe.com/SDR/repo/stk/rhel/6Server/x86_64/current/;true;immediate;mirror_content_only"

# InfluxData
all_crps[12]="InfluxData;InfluxData_RHEL7;;yum;https://repos.influxdata.com/rhel/7Server/x86_64/stable/;true;immediate;additive"

# Jenkins EIS
all_crps[13]="Jenkins EIS;Jenkins EIS-Latest;;yum;https://pkg.jenkins.io/redhat/;false;on_demand;additive"
all_crps[14]="Jenkins EIS;Jenkins EIS - LTS;;yum;https://pkg.jenkins.io/redhat-stable;false;on_demand;additive"

# Katello
all_crps[15]="Katello;Katello Client 6Server;;yum;https://fedorapeople.org/groups/katello/releases/yum/2.2/client/RHEL/6Server/x86_64/;true;immediate;additive"
all_crps[16]="Katello;Katello Client 7Server;;yum;https://fedorapeople.org/groups/katello/releases/yum/2.2/client/RHEL/7Server/x86_64/;true;immediate;additive"

# Signal Sciences Corp - WAF
all_crps[17]="Signal Sciences Corp - WAF;sigsci release EL7 x86_64;;yum;https://yum.signalsciences.net/release/el/7/x86_64;true;immediate;mirror_content_only"
all_crps[18]="Signal Sciences Corp - WAF;sigsci release EL8 x86_64;;yum;https://yum.signalsciences.net/release/el/8/x86_64;true;immediate;mirror_content_only"

# VMware
all_crps[19]="VMware;VMware Tools Latest RHEL6 x86_64;VMware Tools;yum;https://packages.vmware.com/tools/releases/latest/rhel6/x86_64;true;immediate;mirror_content_only"


for crps in "${all_crps[@]}"; do
  IFS=";" read -r -a arr <<< "${crps}"

  echo "Creating ${arr[1]}"
  hammer repository create --product "${arr[0]}" --name "${arr[1]}" --description "${arr[2]}" --content-type "${arr[3]}" --url "${arr[4]}" --verify-ssl-on-sync "${arr[5]}" --download-policy "${arr[6]}" --mirroring-policy "${arr[7]}" --organization-label ${ORG_LABEL}

done