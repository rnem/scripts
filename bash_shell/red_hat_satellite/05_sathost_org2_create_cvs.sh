#!/bin/bash
#################################################################################
# RED HAT SATELLLITE - Create Org Content View(s) - CVs                         #
# Created by Roger Nem - 2023                                                   #
#################################################################################

#
# Enforce root
#
if [ ! $EUID ]; then
    printf "Error: Must be run as root\n\n"
    exit 1
fi

ORG_LABEL="COMP_ORG2"

declare -a all_cvs

# 1. CREATE CVs

all_cvs[0]='cv-app-docker;Grants access to Docker repositories'
all_cvs[1]='cv-app-gcloud;Grants access to Google Cloud repositories'
all_cvs[2]='cv-app-influxdb;Grants access to InfluxDB Time-Series Database repositories'
all_cvs[3]='cv-app-jenkins;Grants access to Jenkins repositories'
all_cvs[4]='cv-app-rh-ansible-engine;Grants access to Ansible Engine repositories'
all_cvs[5]='cv-app-rhel-rhscl;Grants access to Red Hat Software Collections RPMs'
all_cvs[6]='cv-app-rh-openstack;Grants access to OpenStack repositories'
all_cvs[8]='cv-app-sap-hana;Grants access to SAP HANA RPMs'
all_cvs[9]='cv-app-sap-hana-aws-rhel-8point2;Grants access to SAP HANA RHEL 8.2 RPMs only in AWS'
all_cvs[10]='cv-app-signal-sciences;Grants access to Signal Sciences WAF repositories'
all_cvs[11]='cv-os-rhel-6Server;Grants access to RHEL 6Server RPMs'
all_cvs[12]='cv-os-rhel-6Server-els;Red Hat Enterprise Linux Extended Life Cycle Support'
all_cvs[13]='cv-os-rhel-7point6-eus;Grants access to 7.6 EUS RPMs'
all_cvs[14]='cv-os-rhel-7Server;Grants access to RHEL 7Server RPMs'
all_cvs[15]='cv-os-rhel-8Server;Grants access to RHEL 8Server RPMs'
all_cvs[16]='cv-os-rhel-rhscl-7point6-eus;Grants access to Red Hat Software Collections RPMs for RHEL 7.6 EUS'
all_cvs[17]='cv-os-rhel-9Server;Grants access to RHEL 9Server RPMs'

for cvs in "${all_cvs[@]}"; do
  IFS=";" read -r -a arr <<< "${cvs}"

  echo "Creating ${arr[0]}"
  hammer content-view create --name "${arr[0]}" --label "${arr[0]}" --description "${arr[1]}" --organization-label ${ORG_LABEL}

done

echo ""

# 2. ADD REPOS NOW TO CVs

declare -a arr_repos_of_cvs

arr_repos_of_cvs[0]="cv-app-docker;Docker;Docker-CE-7" # cv, product, repository
arr_repos_of_cvs[1]="cv-app-docker;Docker;Docker-CE-8"
arr_repos_of_cvs[2]="cv-app-gcloud;Gcloud;Gcloud-sdk-el7"
arr_repos_of_cvs[3]="cv-app-influxdb;InfluxData;InfluxData_RHEL7"
arr_repos_of_cvs[4]="cv-app-jenkins;Jenkins EIS;Jenkins EIS-Latest"
arr_repos_of_cvs[5]="cv-app-jenkins;Jenkins EIS;Jenkins EIS - LTS"
arr_repos_of_cvs[6]="cv-app-rh-ansible-engine;Red Hat Ansible Engine;Red Hat Ansible Engine 2 for RHEL 8 x86_64 RPMs"
arr_repos_of_cvs[7]="cv-app-rh-ansible-engine;Red Hat Ansible Engine;Red Hat Ansible Engine 2 RPMs for Red Hat Enterprise Linux 7 Server x86_64"
arr_repos_of_cvs[8]="cv-app-rhel-rhscl;Red Hat Software Collections (for RHEL Server);Red Hat Software Collections RPMs for Red Hat Enterprise Linux 6 Server x86_64 6Server"
arr_repos_of_cvs[9]="cv-app-rhel-rhscl;Red Hat Software Collections (for RHEL Server);Red Hat Software Collections RPMs for Red Hat Enterprise Linux 7 Server x86_64 7Server"
arr_repos_of_cvs[10]="cv-app-rh-openstack;Red Hat Enterprise Linux Server;Red Hat OpenStack Platform 14 Tools for RHEL 7 Server RPMs x86_64"
arr_repos_of_cvs[11]="cv-app-sap-hana;Red Hat Enterprise Linux for SAP Solutions for x86_64;Red Hat Enterprise Linux for SAP HANA RHEL 7 Server RPMs x86_64 7Server"
arr_repos_of_cvs[12]="cv-app-sap-hana;Red Hat Enterprise Linux for SAP Applications for x86_64;Red Hat Enterprise Linux for SAP RHEL 7 Server RPMs x86_64 7Server"
arr_repos_of_cvs[13]="cv-app-sap-hana-aws-rhel-8point2;Fedora EPEL;EPEL8 x86_64"
arr_repos_of_cvs[14]="cv-app-sap-hana-aws-rhel-8point2;Red Hat Enterprise Linux for x86_64 - Extended Update Support;Red Hat Enterprise Linux 8 for x86_64 - AppStream - Extended Update Support RPMs 8.2"
arr_repos_of_cvs[15]="cv-app-sap-hana-aws-rhel-8point2;Red Hat Enterprise Linux for x86_64;Red Hat Enterprise Linux 8 for x86_64 - AppStream RPMs 8.2"
arr_repos_of_cvs[16]="cv-app-sap-hana-aws-rhel-8point2;Red Hat Enterprise Linux for x86_64 - Update Services for SAP Solutions;Red Hat Enterprise Linux 8 for x86_64 - AppStream - Update Services for SAP Solutions RPMs 8.2"
arr_repos_of_cvs[17]="cv-app-sap-hana-aws-rhel-8point2;Red Hat Enterprise Linux for x86_64 - Extended Update Support;Red Hat Enterprise Linux 8 for x86_64 - BaseOS - Extended Update Support RPMs 8.2"
arr_repos_of_cvs[18]="cv-app-sap-hana-aws-rhel-8point2;Red Hat Enterprise Linux for x86_64;Red Hat Enterprise Linux 8 for x86_64 - BaseOS RPMs 8.2"
arr_repos_of_cvs[19]="cv-app-sap-hana-aws-rhel-8point2;Red Hat Enterprise Linux for x86_64 - Update Services for SAP Solutions;Red Hat Enterprise Linux 8 for x86_64 - BaseOS - Update Services for SAP Solutions RPMs 8.2"
arr_repos_of_cvs[20]="cv-app-sap-hana-aws-rhel-8point2;Red Hat Enterprise Linux for SAP Applications for x86_64 - Extended Update Support;Red Hat Enterprise Linux 8 for x86_64 - SAP NetWeaver - Extended Update Support RPMs 8.2"
arr_repos_of_cvs[21]="cv-app-sap-hana-aws-rhel-8point2;Red Hat Enterprise Linux for SAP Applications for x86_64;Red Hat Enterprise Linux 8 for x86_64 - SAP NetWeaver RPMs 8.2"
arr_repos_of_cvs[22]="cv-app-sap-hana-aws-rhel-8point2;Red Hat Enterprise Linux for SAP Applications for x86_64 - Update Services for SAP Solutions;Red Hat Enterprise Linux 8 for x86_64 - SAP NetWeaver - Update Services for SAP Solutions RPMs 8.2"
arr_repos_of_cvs[23]="cv-app-sap-hana-aws-rhel-8point2;Red Hat Enterprise Linux for SAP Solutions for x86_64 - Extended Update Support;Red Hat Enterprise Linux 8 for x86_64 - SAP Solutions - Extended Update Support RPMs 8.2"
arr_repos_of_cvs[24]="cv-app-sap-hana-aws-rhel-8point2;Red Hat Enterprise Linux for SAP Solutions for x86_64;Red Hat Enterprise Linux 8 for x86_64 - SAP Solutions RPMs 8.2"
arr_repos_of_cvs[25]="cv-app-sap-hana-aws-rhel-8point2;Red Hat Enterprise Linux for SAP Solutions for x86_64 - Update Services for SAP Solutions;Red Hat Enterprise Linux 8 for x86_64 - SAP Solutions - Update Services for SAP Solutions RPMs 8.2"
arr_repos_of_cvs[26]="cv-app-sap-hana-aws-rhel-8point2;Red Hat Enterprise Linux for x86_64 - Extended Update Support;Red Hat Enterprise Linux 8 for x86_64 - Supplementary - Extended Update Support RPMs 8.2"
arr_repos_of_cvs[27]="cv-app-sap-hana-aws-rhel-8point2;Red Hat Enterprise Linux for x86_64;Red Hat Enterprise Linux 8 for x86_64 - Supplementary RPMs 8.2"
arr_repos_of_cvs[28]="cv-app-signal-sciences;Signal Sciences Corp - WAF;sigsci release EL7 x86_64"
arr_repos_of_cvs[29]="cv-os-rhel-6Server;Fedora EPEL;EPEL6 x86_64"
arr_repos_of_cvs[30]="cv-os-rhel-6Server;Red Hat Enterprise Linux Server;Red Hat Enterprise Linux 6 Server - Extras RPMs x86_64"
arr_repos_of_cvs[31]="cv-os-rhel-6Server;Red Hat Enterprise Linux Server;Red Hat Enterprise Linux 6 Server - Optional RPMs x86_64 6Server"
arr_repos_of_cvs[32]="cv-os-rhel-6Server;Red Hat Enterprise Linux Server;Red Hat Enterprise Linux 6 Server - RH Common RPMs x86_64 6Server"
arr_repos_of_cvs[33]="cv-os-rhel-6Server;Red Hat Enterprise Linux Server;Red Hat Enterprise Linux 6 Server RPMs x86_64 6Server"
arr_repos_of_cvs[34]="cv-os-rhel-6Server;VMware;VMware Tools Latest RHEL6 x86_64"
arr_repos_of_cvs[35]="cv-os-rhel-6Server-els;Red Hat Enterprise Linux Server - Extended Life Cycle Support;Red Hat Enterprise Linux 6 Server - Extended Life Cycle Support - Optional RPMs x86_64"
arr_repos_of_cvs[36]="cv-os-rhel-6Server-els;Red Hat Enterprise Linux Server - Extended Life Cycle Support;Red Hat Enterprise Linux 6 Server - Extended Life Cycle Support RPMs x86_64"
arr_repos_of_cvs[37]="cv-os-rhel-7point6-eus;Red Hat Enterprise Linux for x86_64 - Extended Update Support;Red Hat Enterprise Linux 7 Server - Extended Update Support - Optional RPMs x86_64 7.6"
arr_repos_of_cvs[38]="cv-os-rhel-7point6-eus;Red Hat Enterprise Linux for x86_64 - Extended Update Support;Red Hat Enterprise Linux 7 Server - Extended Update Support RPMs x86_64 7.6"
arr_repos_of_cvs[39]="cv-os-rhel-7point6-eus;Red Hat Enterprise Linux for x86_64 - Extended Update Support;Red Hat Enterprise Linux 7 Server - Extended Update Support - Supplementary RPMs x86_64 7.6"
arr_repos_of_cvs[40]="cv-os-rhel-7Server;Fedora EPEL;EPEL7 x86_64"
arr_repos_of_cvs[41]="cv-os-rhel-7Server;Red Hat Enterprise Linux Server;Red Hat Enterprise Linux 7 Server - Extras RPMs x86_64"
arr_repos_of_cvs[42]="cv-os-rhel-7Server;Red Hat Enterprise Linux Server;Red Hat Enterprise Linux 7 Server - Optional RPMs x86_64 7Server"
arr_repos_of_cvs[43]="cv-os-rhel-7Server;Red Hat Enterprise Linux Server;Red Hat Enterprise Linux 7 Server - RH Common RPMs x86_64 7Server"
arr_repos_of_cvs[44]="cv-os-rhel-7Server;Red Hat Enterprise Linux Server;Red Hat Enterprise Linux 7 Server RPMs x86_64 7Server"
arr_repos_of_cvs[45]="cv-os-rhel-7Server;Red Hat Enterprise Linux Server;Red Hat Enterprise Linux 7 Server - Supplementary RPMs x86_64 7Server"
arr_repos_of_cvs[46]="cv-os-rhel-8Server;Fedora EPEL;EPEL8 x86_64"
arr_repos_of_cvs[47]="cv-os-rhel-8Server;Red Hat Enterprise Linux for x86_64;Red Hat Enterprise Linux 8 for x86_64 - AppStream RPMs 8"
arr_repos_of_cvs[48]="cv-os-rhel-8Server;Red Hat Enterprise Linux for x86_64;Red Hat Enterprise Linux 8 for x86_64 - BaseOS RPMs 8"
arr_repos_of_cvs[49]="cv-os-rhel-8Server;Red Hat Enterprise Linux for x86_64;Red Hat Enterprise Linux 8 for x86_64 - Supplementary RPMs 8"
arr_repos_of_cvs[50]="cv-os-rhel-9Server;Fedora EPEL;EPEL9 x86_64"
arr_repos_of_cvs[51]="cv-os-rhel-9Server;Red Hat Enterprise Linux for x86_64;Red Hat Enterprise Linux 9 for x86_64 - AppStream RPMs 9"
arr_repos_of_cvs[52]="cv-os-rhel-9Server;Red Hat Enterprise Linux for x86_64;Red Hat Enterprise Linux 9 for x86_64 - BaseOS RPMs 9"
arr_repos_of_cvs[53]="cv-os-rhel-rhscl-7point6-eus;Red Hat Software Collections (for RHEL Server);Red Hat Software Collections RPMs for Red Hat Enterprise Linux 7 RHEL 7 Server EUS x86_64 7.6"
arr_repos_of_cvs[54]="cv-os-rhel-rhscl-7point6-eus;Red Hat Software Collections (for RHEL Server);Red Hat Software Collections RPMs for Red Hat Enterprise Linux 7 Server x86_64 7.6"

for repos_cvs in "${arr_repos_of_cvs[@]}"; do
  IFS=";" read -r -a arr <<< "${repos_cvs}"

  echo "Adding repository ${arr[2]} to ${arr[0]}"
  hammer content-view add-repository --name "${arr[0]}" --product "${arr[1]}" --repository "${arr[2]}" --organization-label ${ORG_LABEL}

done