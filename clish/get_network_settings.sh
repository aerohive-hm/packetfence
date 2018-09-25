#!/bin/sh
network_setting=/aerohive_app/scripts/set_networking_properties.js
nic=`ifconfig | grep flags | grep -i RUNNING | grep -v LOOPBACK | head -n 1 | awk -F':' '{print $1}'`
ifcfg="/etc/sysconfig/network-scripts/ifcfg-$nic"
Get_Network_Settings()
{
grep -i "DHCP" $ifcfg > /dev/null
#If DHCP, we get from running env, else from static file
if [ $? -eq 0 ]; then
  network_ip=`ip addr |grep inet|grep -v inet6|grep -v 127.0.0.1|awk '{print $2}'|awk -F/ '{print $1}'`
  network_netmask=`ifconfig -a|grep inet|grep -v inet6|grep -v 127.0.0.1|awk '{print $4}'`
  network_hostname=`hostname`
  network_gateway=`netstat -rn |grep UG|grep 0.0.0.0|awk '{print $2}'`
else
  network_ip=`cat $ifcfg|grep IPADDR|awk -F= '{print $2}'`
  network_netmask=`cat $ifcfg|grep NETMASK|awk -F= '{print $2}'`
  network_hostname=`hostname`
  network_gateway=`cat /etc/sysconfig/network|grep GATEWAY|awk -F= '{print $2}'`
fi
network_dns=`cat /etc/resolv.conf |grep nameserver|head -1|awk '{print $2}'`
}

Get_Network_Settings

echo "Network IP Address:       [$network_ip]"
echo "Network netmask:          [$network_netmask]"
echo "Network default gateway:  [$network_gateway]"
echo "Hostname:                 [$network_hostname]"
echo "DNS server:               [$network_dns]"

