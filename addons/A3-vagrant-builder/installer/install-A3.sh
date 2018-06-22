#!/bin/bash

yum install open-vm-tools -y

# Copy GPG public key
cp /vagrant/data/RPM* /etc/pki/rpm-gpg/

# Set up local yum repository
cat <<EOF >/etc/yum.repos.d/aerohive.repo
[packetfence]
name=Clone of Inverse\'s PacketFence Repository
baseurl=http://a3-build-01.dev.aerohive.com/yum/packetfence/\$basearch
gpgcheck=0
enabled=0

[aerohive]
name=Aerohive Build Repository
baseurl=http://a3-build-01.dev.aerohive.com/yum/aerohive/\$basearch
gpgcheck=0
enabled=0
EOF

# A3 installation
yum install perl -y
yum install --enablerepo=packetfence,aerohive A3 -y
yum install --enablerepo=packetfence,aerohive --disablerepo=A3_os,A3_deps,A3_release A3-PKI -y

# Don't need our repository anymore
rm /etc/yum.repos.d/aerohive.repo

# Setting the hostname
hostname A3
echo "A3" > /etc/hostname
echo "NETWORKING=yes HOSTNAME=A3" > /etc/sysconfig/network

# Setting up rc.local so it modifies /etc/issue to display instructions on setting up the ZEN
cat /vagrant/installer/rc.local > /etc/rc.local

# Systemd won't execute /etc/rc.local unless we do this
chmod +x /etc/rc.d/rc.local

# Set the root password
echo "aerohive" | passwd root --stdin

# Enable password authentication for SSH
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config

# Put the demo user insert statement into the schema file
cat <<EOT >> /usr/local/pf/db/pf-schema.sql
--
-- Insert the demo user for testing
--

INSERT INTO password (pid, password, valid_from, expiration, access_duration, access_level, category) VALUES ('demouser', 'demouser', NOW(), '2038-01-01', '1D', NULL, 1);

EOT

# Set up /usr/local/A3 as a alias for /usr/local/pf
cd /usr/local
ln -sf pf A3

# Add pfcmd to /usr/local/bin for convenience
ln -sf /usr/local/pf/bin/pfcmd /usr/local/bin/pfcmd

# Install temporary Fingerbank API key
cat <<EOF > /usr/local/fingerbank/conf/fingerbank.conf
[upstream]
api_key=b201fafa5549042bb1b23948de1c7997bfdd8103
EOF

# Update syslog config
cd /etc && patch -p0 <<EOF
--- rsyslog.conf	2018-04-09 22:45:24.467160894 +0000
+++ rsyslog.conf.new	2018-04-09 22:53:01.103250343 +0000
@@ -51,7 +51,7 @@

 # Log anything (except mail) of level info or higher.
 # Don't log private authentication messages!
-*.info;mail.none;authpriv.none;cron.none                /var/log/messages
+*.info;mail.none;authpriv.none;cron.none                -/var/log/messages

 # The authpriv file has restricted access.
 authpriv.*                                              /var/log/secure
EOF

# remove the vb guest additional
rm -rf /opt/VBoxGuestAdditions*
systemctl disable vboxadd
systemctl disable vboxadd-service
rm -rf /usr/lib/systemd/system/vboxadd*
