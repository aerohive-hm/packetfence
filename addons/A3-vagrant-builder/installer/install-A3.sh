#!/bin/bash

yum install open-vm-tools -y

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
yum install --enablerepo=packetfence,aerohive A3-PKI -y

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

# Install temporary Fingerbank API key
cat <<EOF > /usr/local/fingerbank/conf/fingerbank.conf
[upstream]
api_key=b201fafa5549042bb1b23948de1c7997bfdd8103
host=api.fingerbank.org
port=443
use_https=enabled
db_path = /api/v2/download/db
sqlite_db_retention = 2

[collector]
host=127.0.0.1
port=4723
use_https=enabled
inactive_endpoints_expiration=168
arp_lookup=disabled
query_cache_time=1440
db_persistence_interval=60

[query]
record_unmatched = disabled

[proxy]
use_proxy = disabled
host =
port =
verify_ssl = enabled
EOF
chmod 775 /usr/local/fingerbank/collector/set-env-fingerbank-conf.pl
