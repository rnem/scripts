#!/bin/bash
###################################################
# Script to Update Salt Grains                    #
# Created by Roger Nem                            #
# v0001 - First version                           #
###################################################

# Grains content
# ----------------
# Zone: AMS, EMEA or APAC
# Market: <corresponding>
# Location: *
# Hosting: Shared, Dedicated, Ecommerce
# Server: Staging, Production or Pre-Production
# Type: **
# OS: <corresponding>
# CloudAccount: <corresponding one – e.g. domain>

# vm-all-all-php1-staging
# vm-ams-br-site-stag1
# r61919-ldeslkw1.domainrack.local

# -------------------------------------------------------------
# Variables
# -------------------------------------------------------------
today=$(date +"%Y-%m-%d %T")
hostname=$(hostname)
naming_type=$(echo $hostname | cut -d "-" -f1 | tr [a-z] [A-Z])
debug="false"
# -------------------------------------------------------------

shopt -s nocasematch    # Make it not case sensitive

if [[ $naming_type == "VM"* ]]
then
    # Applicable to OLD naming convention

    zone=$(echo $hostname | cut -d "-" -f2 | tr [a-z] [A-Z])
    tmp_market=$(echo $hostname | cut -d "-" -f3 | tr [a-z] [A-Z])

    case $tmp_market in
        ALL*)
          market="ALL"
          ;;
        *)
          market=$(echo $hostname | cut -d "-" -f3 | cut -c1-2 | tr [a-z] [A-Z])
          ;;
    esac

    location="L"
    server=${hostname##*-}

    case $hostname in
        *clamav*)
          type="A"
          ;;
        *git*)
          type="G"
          ;;
        *jump*|*bastion*)
          type="B"
          ;;
        *salt*)
          type="O"
          ;;
        *)
          type="W"
          ;;
    esac

    case $zone in
        ALL)
          hosting="Shared"
          ;;
        *)
          hosting="Dedicated"
          ;;
    esac

else
    # Applicable to the NEW naming convention

    market=$(echo $hostname | cut -d'-' -f2 | cut -c5-6 | tr [a-z] [A-Z])

    case $market in
        AR|BO|BR|CA|CBR|CL|CO|CP|CR|DO|EC|GT|MX|NW|PA|PE|PP|PR|PY|TT|US|UY|VE)
          zone="AMS"
          ;;
        AU|CN|ID|IN|JP|KR|LK|MY|NZ|PH|PK|SG|TH|TW|UZ|VN)
          zone="APAC"
          ;;
        *)
          zone="EMEA"
          ;;
    esac

    location=$(echo $hostname | cut -d "-" -f2 | cut -c1 | tr [a-z] [A-Z])
    tmp_hosting=$(echo $hostname | cut -d "-" -f2 | cut -c3 | tr [a-z] [A-Z])

    case $tmp_hosting in
        A)
          hosting="Shared"
          ;;
        E)
          hosting="Dedicated"
          ;;
        *)
          hosting="Other"
          ;;
    esac

    server=$(echo $hostname | cut -d "-" -f2 | cut -c4 | tr [a-z] [A-Z])
    type=$(echo $hostname | cut -d "-" -f2 | cut -c7 | tr [a-z] [A-Z])
fi


case $zone in
    AOA|APAC)
      fzone="APAC"
      ;;
    AMS)
      fzone="AMS"
      ;;
    EMEA|EMENA|EUR)
      fzone="EMEA"
      ;;
    ALL)
      fzone="ALL"
      ;;
esac

case $server in
    stag*)
      fserver="Staging"
      ;;
    prod*)
      fserver="Production"
      ;;
    P)
      fserver="Production"
      ;;
    S)
      fserver="Staging"
      ;;
    *)
      fserver="Other"
      ;;
esac

#OSBRAND=$(/bin/egrep -io -m 1 "Ubuntu|CentOS|RHEL" /etc/*-release|/usr/bin/head -n 1 |cut -d":" -f2)
tmp_OSBRAND=$(cat /etc/*-release | /usr/bin/cut -d' ' -f1 | /usr/bin/cut -d'=' -f2 | /usr/bin/head -n 1)
case $tmp_OSBRAND in
    Red)
      OSBRAND="RHEL"
      ;;
    CentOS)
      OSBRAND="CentOS"
      ;;
    Ubuntu)
      OSBRAND="Ubuntu"
      ;;
    *)
      OSBRAND="Other"
      ;;
esac

# All at the moment are being created under the "domain" cloud account
CloudAccount="domain"


if [[ "${debug}" == "true" ]]
then
    # Output
    echo "$hostname,$fzone,$market,$location,$hosting,$fserver,$type,$OSBRAND,$CloudAccount"

else

    cp /etc/salt/grains /etc/salt/grains.orig.$today
    rm -f /etc/salt/grains

    # Update the grains
    echo "Zone: $fzone" >> /etc/salt/grains
    echo "Market: $market" >> /etc/salt/grains
    echo "Location: $location" >> /etc/salt/grains
    echo "Hosting: $hosting" >> /etc/salt/grains
    echo "Server: $fserver" >> /etc/salt/grains
    echo "Type: $type" >> /etc/salt/grains
    echo "OS: $OSBRAND" >> /etc/salt/grains
    echo "CloudAccount: $CloudAccount" >> /etc/salt/grains

    chmod 644 /etc/salt/grains
    chown root:root /etc/salt/grains

    echo "Grains Updated,$hostname,$fzone,$market,$location,$hosting,$fserver,$type,$OSBRAND,$CloudAccount"

    # Troubleshooting
    #echo "Zone: $fzone"
    #echo "Market: $market"
    #echo "Location: $location"
    #echo "Hosting: $hosting"
    #echo "Server: $fserver"
    #echo "Type: $type"
    #echo "OS: $OSBRAND"
    #echo "CloudAccount: $CloudAccount"

fi

shopt -u nocasematch    # Unset not case sensitive matching