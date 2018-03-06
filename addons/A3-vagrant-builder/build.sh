#!/bin/bash

OVFTOOL=/usr/bin/ovftool
VAGRANT=/usr/bin/vagrant
VBOXMANAGE=/usr/bin/VBoxManage

/usr/bin/rm -rf work/ A3.ova

$VAGRANT destroy -f

$VAGRANT up

$VAGRANT halt

$VBOXMANAGE modifyvm A3 --memory 8192
$VBOXMANAGE modifyvm A3 --uartmode1 disconnected

$VAGRANT package

/usr/bin/mkdir -p work
/usr/bin/tar -C work/ -xvf package.box
/usr/bin/rm -f package.box
/usr/bin/cp -pf A3-release.ovf work/box.ovf

cd work/

# TODO: sign OVA
$OVFTOOL --lax box.ovf ../A3.ova
