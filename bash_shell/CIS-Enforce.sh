#!/bin/bash
#################################################################################################
# CIS Security Audit Script                                                                     #
# Created by Roger Nem                                                                          #
# This script will apply LEVEL ONE Center for Internet Security scored benchmarks               #
# v0.001 - 04/02/2018 - Created by Roger Nem                                                    #
#################################################################################################

echo "*********************************************************"
echo "CIS Security Hardening Script - CentOS 7"
echo "LEVEL ONE hardening (Scored)"
echo "NOTE: Run only in a bash shell"
echo ""
echo "WARNING: This script is only for CentOS 7"
echo "*********************************************************"

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

#################################################################################################
# Variables
#################################################################################################
CIS_CNF='/etc/modprobe.d/CIS.conf'
#################################################################################################

echo "*DATE:*"
date
echo "*OS*"
cat /etc/centos-release
echo "*KERNEL*"
uname -a
echo "*HOST*"
hostname
echo ""

echo "*********************************************************"
echo "THE FOLLOWING NEEDS TO BE DONE MANUALLY"
echo "*********************************************************"
echo "1.1.3, 1.1.4, 1.1.5 Check nodev,nosuid,noexec are set on /tmp (Scored)"
echo "1.1.8, 1.1.9, 1.1.10 Check nodev,nosuid,noexec are set on /var/tmp (Scored)"
echo "1.1.14 Ensure nodev option set on /home partition (Scored)"
echo "1.1.15, 1.1.16, 1.1.17 Check nodev,nosuid,noexec are set on /dev/shm (Scored)"
echo "1.2.3 Ensure gpgcheck is globally activated (Scored)"
echo "1.3.2 Ensure filesystem integrity is regularly checked (Scored)"
echo "1.4.3 Ensure authentication required for single user mode (Scored)"
echo "1.5.1 Ensure core dumps are restricted (Scored)"
echo "1.5.3 Ensure address space layout randomization (ASLR) is enabled (Scored)"
echo "1.6.1.1 Ensure SELinux is not disabled in bootloader configuration (Scored)"
echo "1.7.1.1 Ensure message of the day is configured properly (Scored)"
echo "1.7.2 Ensure GDM login banner is configured (Scored)"
echo "2.2.1.2 Ensure ntp is configured (Scored)"
echo "*********************************************************"
echo ""

echo "*********************************************************"
echo "THE FOLLOWING IS TAKEN CARE BY THE SCRIPT"
echo "*********************************************************"
echo ""

echo "1.1.1.1 Ensure mounting of cramfs filesystems is disabled (Scored)"
echo "1.1.1.2 Ensure mounting of freevxfs filesystems is disabled (Scored)"
echo "1.1.1.3 Ensure mounting of jffs2 filesystems is disabled (Scored)"
echo "1.1.1.4 Ensure mounting of hfs filesystems is disabled (Scored)"
echo "1.1.1.5 Ensure mounting of hfsplus filesystems is disabled (Scored)"
echo "1.1.1.6 Ensure mounting of squashfs filesystems is disabled (Scored)"
echo "1.1.1.7 Ensure mounting of udf filesystems is disabled (Scored)"
echo ""

if [ ! -f ${CIS_CNF} ]; then

        echo "install cramfs /bin/true    # CIS 1.1.1.1" > ${CIS_CNF}
        echo "install freevxfs /bin/true  # CIS 1.1.1.2" >> ${CIS_CNF}
        echo "install jffs2 /bin/true     # CIS 1.1.1.3" >> ${CIS_CNF}
        echo "install hfs /bin/true       # CIS 1.1.1.4" >> ${CIS_CNF}
        echo "install hfsplus /bin/true   # CIS 1.1.1.5" >> ${CIS_CNF}
        echo "install squashfs /bin/true  # CIS 1.1.1.6" >> ${CIS_CNF}
        echo "install udf /bin/true       # CIS 1.1.1.7" >> ${CIS_CNF}

else
        rm -f ${CIS_CNF}

        echo "install cramfs /bin/true    # CIS 1.1.1.1" > ${CIS_CNF}
        echo "install freevxfs /bin/true  # CIS 1.1.1.2" >> ${CIS_CNF}
        echo "install jffs2 /bin/true     # CIS 1.1.1.3" >> ${CIS_CNF}
        echo "install hfs /bin/true       # CIS 1.1.1.4" >> ${CIS_CNF}
        echo "install hfsplus /bin/true   # CIS 1.1.1.5" >> ${CIS_CNF}
        echo "install squashfs /bin/true  # CIS 1.1.1.6" >> ${CIS_CNF}
        echo "install udf /bin/true       # CIS 1.1.1.7" >> ${CIS_CNF}

fi

echo "rmmod cramfs freevxfs jffs2 hfs hfsplus squashfs udf"
rmmod cramfs
rmmod freevxfs
rmmod jffs2
rmmod hfs
rmmod hfsplus
rmmod squashfs
rmmod udf

echo ""

echo "1.1.21 Ensure sticky bit is set on all world-writable directories (Scored)"
echo ""
#df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -type d -perm -0002 2>/dev/null | xargs chmod a+t
echo "*** Dangerous post-install. Not enforcing."
echo ""

echo "1.1.22 Disable Automounting (Scored)"
echo "$ systemctl disable autofs"
systemctl disable autofs
echo ""

echo "1.3.1 Ensure AIDE is installed (Scored)"
echo "$ yum install aide"
echo "$ aide --init"
echo "$ mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz"
yum install aide
aide --init
mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
echo ""

echo "1.3.2 Ensure filesystem integrity is regularly checked (Scored) - DO IT MANUALLY"
echo ""

echo "1.4.1 Ensure permissions on bootloader config are configured (Scored)"
echo ""
chown root:root /boot/grub2/grub.cfg
chmod og-rwx /boot/grub2/grub.cfg
chown root:root /boot/grub2/user.cfg
chmod og-rwx /boot/grub2/user.cfg
echo ""

echo "1.4.2 Ensure bootloader password is set (Scored)"
echo  "*** Problematic for production systems. Not implementing per SPE policy."
echo ""

echo "1.5.4 Ensure prelink is disabled (Scored)"
echo ""
prelink -ua
yum remove prelink -y
echo ""

echo "1.7.1.5 Ensure permissions on /etc/issue are configured (Scored)"
echo ""
chown root:root /etc/issue
chmod 644 /etc/issue
echo ""

echo "1.8 Ensure updates, patches, and additional security software are installed (Scored)"
echo ""
yum update --security
echo ""

echo "2.1.1 Ensure chargen services are not enabled (Scored)"
echo ""
chkconfig chargen-dgram off
chkconfig chargen-stream off
echo ""

echo "2.1.2 Ensure daytime services are not enabled (Scored)"
echo ""
chkconfig daytime-dgram off
chkconfig daytime-stream off
echo ""

echo "2.1.3 Ensure discard services are not enabled (Scored)"
echo ""
chkconfig discard-dgram off
chkconfig discard-stream off
echo ""

echo "2.1.4 Ensure echo services are not enabled (Scored)"
echo ""
chkconfig echo-dgram off
chkconfig echo-stream off
echo ""

echo "2.1.5 Ensure time services are not enabled (Scored)"
echo ""
chkconfig time-dgram off
chkconfig time-stream off
echo ""

echo "2.1.6 Ensure tftp server is not enabled (Scored)"
echo ""
chkconfig tftp off
echo ""

echo "2.1.7 Ensure xinetd is not enabled (Scored)"
echo ""
systemctl disable xinetd
echo ""

echo "2.2.1.3 Ensure chrony is configured (Scored)"
echo "*** NTP is used at SPE, not Chrony."
echo ""

echo "2.2.2 Ensure X Window System is not installed (Scored)"
echo ""
yum remove xorg-x11* -y
echo ""

echo "2.2.3 Ensure Avahi Server is not enabled (Scored)"
echo ""
systemctl disable avahi-daemon
echo ""

echo "2.2.4 Ensure CUPS is not enabled (Scored)"
echo ""
systemctl disable cups
echo ""

echo "2.2.5 Ensure DHCP Server is not enabled (Scored)"
echo ""
systemctl disable dhcpd
echo ""

echo "2.2.6 Ensure LDAP server is not enabled (Scored)"
echo ""
systemctl disable slapd
echo ""

echo "2.2.7 Ensure NFS and RPC are not enabled (Scored)"
echo ""
systemctl disable nfs
systemctl disable nfs-server
systemctl disable rpcbind
echo ""

echo "2.2.8 Ensure DNS Server is not enabled (Scored)"
echo ""
systemctl disable named
