#!/bin/sh
nic=`ifconfig | grep flags | grep -i RUNNING | grep -v LOOPBACK | head -n 1 | awk -F':' '{print $1}'`
ifcfg="/etc/sysconfig/network-scripts/ifcfg-$nic"
network=/etc/sysconfig/network

sub_proto(){
  sed -i.bak "s/BOOTPROTO.*/BOOTPROTO=static/g" $ifcfg
}

SetIP()
{
grep -i IPADDR $ifcfg > /dev/null 2>&1
if [ $? -eq 0 ]; then
    sed -i.bak "s/IPADDR=.*/IPADDR=$ip/i" $ifcfg 
else
    echo "IPADDR=$ip" >> $ifcfg
fi
sub_proto
}

SetNetmask()
{
grep -i NETMASK $ifcfg > /dev/null 2>&1
if [ $? -eq 0 ]; then
    sed -i.bak "s/NETMASK=.*/NETMASK=$netmask/i" $ifcfg 
else
    echo "NETMASK=$netmask" >> $ifcfg
fi
sub_proto
}

SetGateway()
{
grep -i GATEWAY $ifcfg > /dev/null 2>&1
if [ $? -eq 0 ]; then
    sed -i.bak "s/GATEWAY=.*/GATEWAY=$gateway/i" $ifcfg 
else
    echo "GATEWAY=$gateway" >> $ifcfg
fi
grep -i GATEWAY $network > /dev/null 2>&1
if [ $? -eq 0 ]; then
    sed -i.bak "s/GATEWAY=.*/GATEWAY=$gateway/i" $network
else
    echo "GATEWAY=$gateway" >> $network
fi
sub_proto
}

MainRoutine()
{
  if [ -n "$ip" ]; then
     SetIP
  fi
  if [ -n "$netmask" ]; then
     SetNetmask
  fi
  if [ -n "$gateway" ]; then
     SetGateway
  fi
}

Usage()
{
 echo "$script_name [-i] IP Address [-m] NetMak [-g] Gateway"
 exit 1
}
while [ $# -gt 0 ]; do
case "$1" in
-i | -ip )
    shift
    ip=$1
;;
-g | -gateway )
    shift
    gateway=$1
;;
-m | -netmask )
    shift
    netmask=$1
;;
*)
    Usage
;;
esac;
shift
done

MainRoutine

