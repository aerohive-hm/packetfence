#!/bin/bash -e

OVFTOOL=/usr/bin/ovftool
VAGRANT=/usr/bin/vagrant
VBOXMANAGE=/usr/bin/VBoxManage
PK_FILE=/root/.ssh/private_key/all_certs.pem
PK_PASSWORD=$1

/usr/bin/rm -rf work/ devel A3.ova

if [ "$BUILD_TYPE" != "RELEASE" ]; then
    /usr/bin/touch devel
fi

$VAGRANT destroy -f

if ! $VAGRANT up; then
    echo "Failed to build VM. Exiting"
    exit 1
fi

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
if [ ! -z $PK_PASSWORD ]; then
	$OVFTOOL --lax --privateKey=$PK_FILE --privateKeyPassword=$PK_PASSWORD box.ovf ../A3-signed.ova
fi
