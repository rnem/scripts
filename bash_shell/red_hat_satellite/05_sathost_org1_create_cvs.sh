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

ORG_LABEL="COMP_ORG1"

declare -a all_cvs

# 1. CREATE CVs

all_cvs[0]='cv-7Server'
all_cvs[1]='cv-8Server'
all_cvs[2]='cv-AnyPhysicalServer'

for cvs in "${all_cvs[@]}"; do
  IFS=";" read -r -a arr <<< "${cvs}"

  echo "Creating ${arr[0]}"
  hammer content-view create --name "${arr[0]}" --label "${arr[0]}" --organization-label ${ORG_LABEL}

done

echo ""

# 2. ADD REPOS NOW TO CVs

declare -a arr_repos_of_cvs

arr_repos_of_cvs[0]="cv-7Server;Fedora EPEL;EPEL7 x86_64" # product, repository
arr_repos_of_cvs[1]="cv-7Server;Hewlett Packard Enterprise;FWPP Current 7Server x86_64"
arr_repos_of_cvs[2]="cv-7Server;Hewlett Packard Enterprise;HPSUM Current 7Server x86_64"
arr_repos_of_cvs[3]="cv-7Server;Hewlett Packard Enterprise;SPP Current 7Server x86_64"
arr_repos_of_cvs[4]="cv-7Server;Hewlett Packard Enterprise;STK Current 7Server x86_64"
arr_repos_of_cvs[5]="cv-7Server;Red Hat Enterprise Linux Server;Red Hat Enterprise Linux 7 Server - Extras RPMs x86_64"
arr_repos_of_cvs[6]="cv-7Server;Red Hat Enterprise Linux Server;Red Hat Enterprise Linux 7 Server - Optional RPMs x86_64 7Server"
arr_repos_of_cvs[7]="cv-7Server;Red Hat Enterprise Linux Server;Red Hat Enterprise Linux 7 Server RPMs x86_64 7Server"
arr_repos_of_cvs[8]="cv-7Server;Red Hat Enterprise Linux Server;Red Hat Satellite Tools 6.10 for RHEL 7 Server RPMs x86_64"
arr_repos_of_cvs[9]="cv-7Server;Red Hat Enterprise Linux Server;Red Hat Satellite Tools 6.7 for RHEL 7 Server RPMs x86_64"

arr_repos_of_cvs[10]="cv-8Server;Fedora EPEL;EPEL8 x86_64"
arr_repos_of_cvs[11]="cv-8Server;Red Hat Enterprise Linux for x86_64;Red Hat Enterprise Linux 8 for x86_64 - AppStream RPMs 8"
arr_repos_of_cvs[12]="cv-8Server;Red Hat Enterprise Linux for x86_64;Red Hat Enterprise Linux 8 for x86_64 - BaseOS RPMs 8"
arr_repos_of_cvs[13]="cv-8Server;Red Hat Enterprise Linux for x86_64;Red Hat Enterprise Linux 8 for x86_64 - Supplementary RPMs 8"
arr_repos_of_cvs[14]="cv-8Server;Red Hat Enterprise Linux for x86_64;Red Hat Satellite Tools 6.7 for RHEL 8 x86_64 RPMs"
arr_repos_of_cvs[15]="cv-8Server;Red Hat Enterprise Linux for x86_64;Red Hat Satellite Tools 6.10 for RHEL 8 x86_64 RPMs"

arr_repos_of_cvs[16]="cv-AnyPhysicalServer;Hewlett Packard Enterprise;IP Gen8 Current"
arr_repos_of_cvs[17]="cv-AnyPhysicalServer;Hewlett Packard Enterprise;IP Gen9 Current"
arr_repos_of_cvs[18]="cv-AnyPhysicalServer;VMware;VMware Tools Latest RHEL6 x86_64"

for repos_cvs in "${arr_repos_of_cvs[@]}"; do
  IFS=";" read -r -a arr <<< "${repos_cvs}"

  echo "Adding repository ${arr[2]} to ${arr[0]}"
  hammer content-view add-repository --name "${arr[0]}" --product "${arr[1]}" --repository "${arr[2]}" --organization-label ${ORG_LABEL}

done

# -----------------
# INFORMATIONAL ONLY
# -----------------
# hammer --no-headers repository list --organization-label ${ORG_LABEL}
# 50 | EPEL6 x86_64                                                          | Fedora EPEL                         | yum          | https://archives.fedoraproject.org/pub/archive/epel/6/x86_64/
# 53 | Red Hat Enterprise Linux 6 Server - Extras RPMs x86_64                | Red Hat Enterprise Linux Server     | yum          | https://cdn.redhat.com/content/dist/rhel/server/6/6Server/x86_64/extras/os
# 54 | Red Hat Enterprise Linux 6 Server - Optional RPMs x86_64 6Server      | Red Hat Enterprise Linux Server     | yum          | https://cdn.redhat.com/content/dist/rhel/server/6/6Server/x86_64/optional/os
# 55 | Red Hat Enterprise Linux 6 Server RPMs x86_64 6Server                 | Red Hat Enterprise Linux Server     | yum          | https://cdn.redhat.com/content/dist/rhel/server/6/6Server/x86_64/os
# 56 | Red Hat Enterprise Linux 6 Server - Supplementary RPMs x86_64 6Server | Red Hat Enterprise Linux Server     | yum          | https://cdn.redhat.com/content/dist/rhel/server/6/6Server/x86_64/supplementar...
# 65 | Red Hat Satellite Tools 6.7 for RHEL 6 Server RPMs x86_64             | Red Hat Enterprise Linux Server     | yum          | https://cdn.redhat.com/content/dist/rhel/server/6/6Server/x86_64/sat-tools/6....
# etc

# hammer repository list --organization-label ${ORG_LABEL} --search "EPEL6"
# ---|-----------------------|-------------|--------------|------------------------------------------------------------------
# ID | NAME                  | PRODUCT     | CONTENT TYPE | URL
# ---|-----------------------|-------------|--------------|------------------------------------------------------------------
# 50 | EPEL6 x86_64          | Fedora EPEL | yum          | https://archives.fedoraproject.org/pub/archive/epel/6/x86_64/