#!/bin/bash

# Set up local yum repository
cat <<EOF >/etc/yum.repos.d/aerohive.repo
[packetfence]
name=Clone of Inverse\'s PacketFence Repository
baseurl=http://10.16.134.140/yum/packetfence/\$basearch
gpgcheck=0
enabled=0

[aerohive]
name=Aerohive Build Repository
baseurl=http://10.16.134.140/yum/aerohive/\$basearch
gpgcheck=0
enabled=0
EOF

# PacketFence installation
yum install perl -y
yum install --enablerepo=packetfence,aerohive A3 -y

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
