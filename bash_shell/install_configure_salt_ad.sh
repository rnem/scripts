#!/bin/bash
########################################################################################################
# Automated Installation & Configuration of SALT / Active Directory Script - by Roger Nem (2015)       #
#                                                                                                      #
# History:                                                                                             #
# v0.001  - Roger Nem - First Version                                                                  # 
# v0.002  - Roger Nem - Script updates - IP address, permissions, files                                #
# v0.003  - Roger Nem - Script updates: Adapted to use the new server naming convention instead of IPs #
#                                                                                                      #
########################################################################################################

# -------------------------------------------------------
# Variables
# -------------------------------------------------------
today=$(date +%Y-%m-%d-%H:%M:%S)

DCNS1=172.10.1.11
DCNS2=172.10.1.12

salt_server=1.2.3.4

host=`hostname`

eth0=`/sbin/ifconfig eth0 | sed '/inet\ /!d;s/.*r://g;s/\ .*//g'`
eth1=`/sbin/ifconfig eth1 | sed '/inet\ /!d;s/.*r://g;s/\ .*//g'`

if [[ -z "$eth0" ]]; then
	ip=$eth1;
else
	ip=$eth0;
fi;

alias_name=`echo $ip | sed 's/\./_/g'`
alias_name_new=`hostname -s`

hosts_file="/etc/hosts"
network_files="/etc/sysconfig/network-scripts/ifcfg-eth*"
resolv_file="/etc/resolv.conf"
nsswitch_file="/etc/nsswitch.conf"
krb5_file="/etc/krb5.conf"
smb_file="/etc/samba/smb.conf"
sssd_file="/etc/sssd/sssd.conf"
password_auth_ac_file="/etc/pam.d/password-auth-ac"
password_auth_file="/etc/pam.d/password-auth"
system_auth_ac_file="/etc/pam.d/system-auth-ac"
system_auth_file="/etc/pam.d/system-auth"

LIGHTGREEN='\033[1;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NOCOLOR='\033[0m'
# -------------------------------------------------------

# -------------------------------------------------------
# /etc/hosts
# -------------------------------------------------------
echo ""
echo -e "${YELLOW}Starting $hosts_file configs${NOCOLOR}"
echo ""

# Add new lines to the beginning of /etc/hosts
# sed works the opposite way - bottom to top
sed -i -e '1i\\' $hosts_file
sed -i '1i#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@' $hosts_file
sed -i "1i$salt_server  salt" $hosts_file
sed -i "1i$ip   $host $alias_name $alias_name_new" $hosts_file
sed -i '1i#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@' $hosts_file
sed -i '1i##  DSU Automated Configuration - DO NOT DELETE/CHANGE  ##' $hosts_file
sed -i '1i#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@' $hosts_file

echo ""
echo -e "${YELLOW}--------------------------------------------------"
echo "Here is the final $hosts_file file"
echo -e "--------------------------------------------------${NOCOLOR}"
cat $hosts_file
echo -e "${YELLOW}--------------------------------------------------${NOCOLOR}"

# -------------------------------------------------------
# /etc/sysconfig/network-scripts/ifcfg-eth*
# -------------------------------------------------------
echo ""
echo -e "${YELLOW}--------------------------------------------------"
echo "Starting network-scripts configs"
echo -e "--------------------------------------------------${NOCOLOR}"
echo ""

sed -i".$today.bak" '/DNS/d' $network_files

# -------------------------------------------------------
# Install SALT MINION
# -------------------------------------------------------
yum -y install salt-minion

# -------------------------------------------------------
# Install & Config AD 
# -------------------------------------------------------
yum -y install sssd krb5-workstation samba

# -------------------------------------------------------
# /etc/resolv.conf
# -------------------------------------------------------
echo ""
echo -e "${YELLOW}--------------------------------------------------"
echo "Starting $resolv_file configs"
echo -e "--------------------------------------------------${NOCOLOR}"
echo ""

chattr -i $resolv_file
rm -rf $resolv_file

echo "#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" >> $resolv_file
echo "##  DSU Automated Configuration - DO NOT DELETE/CHANGE  ##" >> $resolv_file
echo "#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" >> $resolv_file
echo "nameserver $DCNS1" >> $resolv_file 
echo "nameserver $DCNS2" >> $resolv_file
echo "domain domainrack.local" >> $resolv_file
echo "#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" >> $resolv_file

cat $resolv_file

# -------------------------------------------------------
# /etc/nsswitch.conf
# -------------------------------------------------------
echo ""
echo -e "${YELLOW}--------------------------------------------------"
echo "Starting $nsswitch_file configs"
echo -e "--------------------------------------------------${NOCOLOR}"
echo ""

rm -rf $nsswitch_file

echo "#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" >> $nsswitch_file
echo "##  DSU Automated Configuration - DO NOT DELETE/CHANGE  ##" >> $nsswitch_file
echo "#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" >> $nsswitch_file
echo "passwd:     files sss" >> $nsswitch_file
echo "shadow:     files sss" >> $nsswitch_file
echo "group:      files sss" >> $nsswitch_file
echo "hosts:      files dns" >> $nsswitch_file
echo "bootparams: nisplus [NOTFOUND=return] files" >> $nsswitch_file
echo "ethers:     files" >> $nsswitch_file
echo "netmasks:   files" >> $nsswitch_file
echo "networks:   files" >> $nsswitch_file
echo "protocols:  files" >> $nsswitch_file
echo "rpc:        files" >> $nsswitch_file
echo "services:   files sss" >> $nsswitch_file
echo "netgroup:   files sss" >> $nsswitch_file
echo "publickey:  nisplus" >> $nsswitch_file
echo "automount:  files sss" >> $nsswitch_file
echo "aliases:    files nisplus" >> $nsswitch_file
echo "#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" >> $nsswitch_file

cat $nsswitch_file

# -------------------------------------------------------
# /etc/krb5.conf
# -------------------------------------------------------
echo ""
echo -e "${YELLOW}--------------------------------------------------"
echo "Starting $krb5_file configs"
echo -e "--------------------------------------------------${NOCOLOR}"
echo ""

rm -rf $krb5_file

echo "#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" >> $krb5_file
echo "##  DSU Automated Configuration - DO NOT DELETE/CHANGE  ##" >> $krb5_file
echo "#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" >> $krb5_file
echo "[logging]" >> $krb5_file
echo " default = FILE:/var/log/krb5libs.log" >> $krb5_file
echo "" >> $krb5_file
echo "[libdefaults]" >> $krb5_file
echo " default_realm = DOMAINRACK.LOCAL" >> $krb5_file
echo " dns_lookup_realm = true" >> $krb5_file
echo " dns_lookup_kdc = true" >> $krb5_file
echo " ticket_lifetime = 1h" >> $krb5_file
echo " renew_lifetime = 1d" >> $krb5_file
echo " rdns = false" >> $krb5_file
echo " forwardable = yes" >> $krb5_file
echo "" >> $krb5_file
echo "[domain_realm]" >> $krb5_file
echo " .domainrack.local = DOMAINRACK.LOCAL" >> $krb5_file
echo " domainrack.local = DOMAINRACK.LOCAL" >> $krb5_file
echo "#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" >> $krb5_file

cat $krb5_file

# -------------------------------------------------------
# /etc/samba/smb.conf
# -------------------------------------------------------
echo ""
echo -e "${YELLOW}--------------------------------------------------"
echo "Starting $smb_file configs"
echo -e "--------------------------------------------------${NOCOLOR}"
echo ""

rm -rf $smb_file

echo "#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" >> $smb_file
echo "##  DSU Automated Configuration - DO NOT DELETE/CHANGE  ##" >> $smb_file
echo "#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" >> $smb_file
echo "[global]" >> $smb_file
echo "   netbios name = $alias_name_new" >> $smb_file
echo "   workgroup = DOMAINRACK" >> $smb_file
echo "   client signing = yes" >> $smb_file
echo "   client use spnego = yes" >> $smb_file
echo "   kerberos method = secrets and keytab" >> $smb_file
echo "   log file = /var/log/samba/%m.log" >> $smb_file
echo "   realm = DOMAINRACK.LOCAL" >> $smb_file
echo "   security = ads" >> $smb_file
echo "#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" >> $smb_file

cat /etc/samba/smb.conf

# -------------------------------------------------------
# /etc/sssd/sssd.conf
# -------------------------------------------------------
echo ""
echo -e "${YELLOW}--------------------------------------------------"
echo "Starting $sssd_file configs"
echo -e "--------------------------------------------------${NOCOLOR}"
echo ""

if [ -f $sssd_file ]; then rm -rf $sssd_file; fi

echo "#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" >> $sssd_file
echo "##  DSU Automated Configuration - DO NOT DELETE/CHANGE  ##" >> $sssd_file
echo "#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" >> $sssd_file
echo "[sssd]" >> $sssd_file
echo "config_file_version = 2" >> $sssd_file
echo "domains = DOMAINRACK.LOCAL" >> $sssd_file
echo "services = nss, pam" >> $sssd_file
echo "use_fully_qualified_domains = true" >> $sssd_file
echo "" >> $sssd_file
echo "# For NETBIOS Domain: DOMAINRACK" >> $sssd_file
echo "[domain/DOMAINRACK.LOCAL]" >> $sssd_file
echo "id_provider = ad" >> $sssd_file
echo "auth_provider = ad" >> $sssd_file
echo "chpass_provider = ad" >> $sssd_file
echo "access_provider = ad" >> $sssd_file
echo "ldap_schema = ad" >> $sssd_file
echo "ldap_id_mapping = true" >> $sssd_file
echo "cache_credentials = false" >> $sssd_file
echo "ldap_force_upper_case_realm = true" >> $sssd_file
echo "ldap_disable_referrals = true" >> $sssd_file
echo "fallback_homedir = /home/%u" >> $sssd_file
echo "default_shell = /bin/bash" >> $sssd_file
echo "dns_discovery_domain = DOMAINRACK.LOCAL" >> $sssd_file
echo "enumerate = false" >> $sssd_file
echo "#debug_level = 6" >> $sssd_file
echo "" >> $sssd_file
echo "case_sensitive = Preserving" >> $sssd_file
echo "" >> $sssd_file
echo "[pam]" >> $sssd_file
echo "#debug_level = 10" >> $sssd_file
echo "" >> $sssd_file
echo "[nss]" >> $sssd_file
echo "#debug_level = 10" >> $sssd_file
echo "#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" >> $sssd_file

cat $sssd_file

# -------------------------------------------------------
# /etc/pam.d
# -------------------------------------------------------
echo ""
echo -e "${YELLOW}--------------------------------------------------"
echo "Starting pam.d configs"
echo -e "--------------------------------------------------${NOCOLOR}"
echo ""

if [ -f $password_auth_ac_file ]; then rm -rf $password_auth_ac_file; fi;
if [ -f $password_auth_file ]; then rm -rf $password_auth_file; fi;

echo "#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" >> $password_auth_ac_file
echo "##  DSU Automated Configuration - DO NOT DELETE/CHANGE  ##" >> $password_auth_ac_file
echo "#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" >> $password_auth_ac_file
echo "#%PAM-1.0" >> $password_auth_ac_file
echo "# This file is auto-generated." >> $password_auth_ac_file
echo "# User changes will be destroyed the next time authconfig is run." >> $password_auth_ac_file
echo "auth        required      pam_env.so" >> $password_auth_ac_file
echo "auth        sufficient    pam_unix.so nullok try_first_pass" >> $password_auth_ac_file
echo "auth        requisite     pam_succeed_if.so uid >= 500 quiet" >> $password_auth_ac_file
echo "auth        sufficient    pam_sss.so use_first_pass" >> $password_auth_ac_file
echo "auth        required      pam_deny.so" >> $password_auth_ac_file
echo "" >> $password_auth_ac_file
echo "account     required      pam_unix.so" >> $password_auth_ac_file
echo "account     sufficient    pam_localuser.so" >> $password_auth_ac_file
echo "account     sufficient    pam_succeed_if.so uid < 500 quiet" >> $password_auth_ac_file
echo "account     [default=bad success=ok user_unknown=ignore] pam_sss.so" >> $password_auth_ac_file
echo "account     required      pam_permit.so" >> $password_auth_ac_file
echo "" >> $password_auth_ac_file
echo "password    requisite     pam_cracklib.so retry=5 difok=0 minlen=16 ucredit=-1 lcredit=-2 dcredit=-1 ocredit=-1" >> $password_auth_ac_file
echo "password    sufficient    pam_unix.so sha512 shadow nullok try_first_pass use_authtok" >> $password_auth_ac_file
echo "password    sufficient    pam_sss.so use_authtok" >> $password_auth_ac_file
echo "password    required      pam_deny.so" >> $password_auth_ac_file
echo "" >> $password_auth_ac_file
echo "session     optional      pam_keyinit.so revoke" >> $password_auth_ac_file
echo "session     required      pam_limits.so" >> $password_auth_ac_file
echo "session     optional      pam_mkhomedir.so umask=0077" >> $password_auth_ac_file
echo "session     [success=1 default=ignore] pam_succeed_if.so service in crond quiet use_uid" >> $password_auth_ac_file
echo "session     required      pam_unix.so" >> $password_auth_ac_file
echo "session     optional      pam_sss.so" >> $password_auth_ac_file
echo "#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" >> $password_auth_ac_file


if [ -f $system_auth_ac_file ]; then rm -rf $system_auth_ac_file; fi;
if [ -f $system_auth_file ]; then rm -rf $system_auth_file; fi;

echo "#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" >> $system_auth_ac_file
echo "##  DSU Automated Configuration - DO NOT DELETE/CHANGE  ##" >> $system_auth_ac_file
echo "#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" >> $system_auth_ac_file
echo "#%PAM-1.0" >> $system_auth_ac_file
echo "# This file is auto-generated." >> $system_auth_ac_file
echo "# User changes will be destroyed the next time authconfig is run." >> $system_auth_ac_file
echo "auth        required      pam_env.so" >> $system_auth_ac_file
echo "auth        sufficient    pam_unix.so nullok try_first_pass" >> $system_auth_ac_file
echo "auth        requisite     pam_succeed_if.so uid >= 500 quiet" >> $system_auth_ac_file
echo "auth        sufficient    pam_sss.so use_first_pass" >> $system_auth_ac_file
echo "auth        required      pam_deny.so" >> $system_auth_ac_file
echo "" >> $system_auth_ac_file
echo "account     required      pam_unix.so" >> $system_auth_ac_file
echo "account     sufficient    pam_localuser.so" >> $system_auth_ac_file
echo "account     sufficient    pam_succeed_if.so uid < 500 quiet" >> $system_auth_ac_file
echo "account     [default=bad success=ok user_unknown=ignore] pam_sss.so" >> $system_auth_ac_file
echo "account     required      pam_permit.so" >> $system_auth_ac_file
echo "" >> $system_auth_ac_file
echo "password    requisite     pam_cracklib.so retry=5 difok=0 minlen=16 ucredit=-1 lcredit=-2 dcredit=-1 ocredit=-1" >> $system_auth_ac_file
echo "password    sufficient    pam_unix.so sha512 shadow nullok try_first_pass use_authtok" >> $system_auth_ac_file
echo "password    sufficient    pam_sss.so use_authtok" >> $system_auth_ac_file
echo "password    required      pam_deny.so" >> $system_auth_ac_file
echo "" >> $system_auth_ac_file
echo "session     optional      pam_keyinit.so revoke" >> $system_auth_ac_file
echo "session     required      pam_limits.so" >> $system_auth_ac_file
echo "session     optional      pam_mkhomedir.so umask=0077" >> $system_auth_ac_file
echo "session     [success=1 default=ignore] pam_succeed_if.so service in crond quiet use_uid" >> $system_auth_ac_file
echo "session     required      pam_unix.so" >> $system_auth_ac_file
echo "session     optional      pam_sss.so" >> $system_auth_ac_file
echo "#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" >> $system_auth_ac_file

cd /etc/pam.d/

#ln -s [TARGET DIRECTORY OR FILE] ./[SHORTCUT]
ln -s password-auth-ac password-auth
ln -s system-auth-ac system-auth

cat $password_auth_ac_file
cat $system_auth_ac_file

# -------------------------------------------------------
# Permissions
# -------------------------------------------------------
echo ""
echo -e "${YELLOW}--------------------------------------------------"
echo "Setting Permissions"
echo -e "--------------------------------------------------${NOCOLOR}"
echo ""

chown root:utmp /var/log/btmp && chmod 600 /var/log/btmp

chown root:root $resolv_file
chmod 644 $resolv_file
chattr +i $resolv_file		# -rw-r--r-- 1 root root 77 Jun 12 18:48 /etc/resolv.conf

chown root:root $nsswitch_file
chmod 644 $nsswitch_file	# -rw-r--r-- 1 root root 335 Jun 12 18:48 /etc/nsswitch.conf

chown root:root $krb5_file
chmod 644 $krb5_file		# -rw-r--r-- 1 root root 314 Jun 12 18:52 /etc/krb5.conf

chown root:root $smb_file
chmod 644 $smb_file		# -rw-r--r-- 1 root root 242 Jun 12 18:49 /etc/samba/smb.conf

chown root:root $sssd_file
chmod 600 $sssd_file		# -rw------- 1 root root 511 Jun 12 18:50 /etc/sssd/sssd.conf

# -------------------------------------------------------
# JOIN AD
# -------------------------------------------------------
echo ""
echo -e "${YELLOW}--------------------------------------------------"
echo "Starting to join server to AD"
echo -e "--------------------------------------------------${NOCOLOR}"
echo ""

rm -rf /var/lib/sss/{db,mc}/*

read -p "Write your AD USERNAME, hit ENTER and then write your AD password: " username
echo "kinit $username"

kinit $username
klist
echo ""
net ads -k join

yum -y install authconfig
authconfig --update --enablesssd --enablesssdauth --enablemkhomedir --disableldap --disableldapauth --disablekrb5 --disablewinbind --disablewinbindauth

if [ $(net ads testjoin >/dev/null 2>&1; echo $?) -eq 0 ]; then 
	echo ""
	echo -e "${LIGHTGREEN}Join is OK${NOCOLOR}"
else 
	echo ""
	echo -e "${RED}There was an error. Please verify /etc/hosts and /etc/samba/smb.conf and then run the commands below manually${NOCOLOR}"
	echo ""
	echo -e "${YELLOW}1) rm -rf /var/lib/sss/{db,mc}/*${NOCOLOR}"
	echo -e "${YELLOW}2) kdestroy${NOCOLOR}"
	echo -e "${YELLOW}3) kinit $username${NOCOLOR}"
	echo -e "${YELLOW}4) net ads -k join${NOCOLOR}"
	echo -e "${YELLOW}5) net ads testjoin${NOCOLOR}"
	echo -e "${YELLOW}6) service sssd start${NOCOLOR}"
	echo -e "${YELLOW}7) chkconfig sssd on${NOCOLOR}"
fi;
echo ""

# -------------------------------------------------------
# Start / restart services
# -------------------------------------------------------
service salt-minion start
chkconfig salt-minion on

service sssd start
chkconfig sssd on

service sshd restart
# -------------------------------------------------------

echo ""
echo -e "${LIGHTGREEN}ALL DONE! GREAT JOB! Please verify everything now and exit the server${NOCOLOR}"
echo ""