#!/bin/bash
#
# Wrapper to simplify building RPM packages.
# Supports
# - building directly from git
# - specifying branch to build
#
# Copyright (C) 2005-2018 Inverse inc.
#
# Author: Inverse inc. <info@inverse.ca>

DATE="`date +%Y%m%d`"
BRANCH=$1
PASSPHRASE=$2

BUILD_DIR=~/rpmbuild
CURRENT_DIR=`pwd`
# valid values: .el6 .el5 .fc16
DIST=.el7
SPECFILE=addons/packages/A3.spec
VERSION_FILE=conf/a3-release
REPO=git@git.aerohive.com:A3/packetfence.git

if [[ "z$BRANCH" != "z" ]]; then
	echo "Starting rpm build process for branch $BRANCH"

else
	echo "You must specify a branch for build!"
	echo "$0: Performs the code checkout, tarball and rpm build of a PacketFence branch"
	echo
	echo "Usage:"
	echo -e "\t$0 <branch>"
	echo
	echo -e "<branch>:\tbranch to build"
	exit 255
fi

echo
echo "Fancy footwork with the git tree (checkout, copying SPEC, figure out version)"
echo "*****************************************************************************"
# This is all rather naive.. feel free to improve (if you understand what you are doing)
if [[ ! -d ~/build/packetfence ]]; then
  mkdir -p ~/build/
  cd ~/build/
  git clone $REPO
fi
cd ~/build/packetfence
git fetch
if [[ "$?" != "0" ]]; then
	echo "Problem fetching source code. Aborting build process..." && exit 1
fi
git checkout $BRANCH
if [[ "$?" != "0" ]]; then
	echo "Problem checking out branch $BRANCH. Aborting build process..." && exit 1
fi
git merge --ff-only origin/$BRANCH
if [[ "$?" != "0" ]]; then
	echo "Problem merging with origin/$BRANCH from $BRANCH. Aborting build process..." && exit 1
fi
VERSION=`cat \$VERSION_FILE | awk '{print $2}'`
PF_RELEASE=$VERSION-0.$DATE

# We update the build specfile
cp -f $SPECFILE $BUILD_DIR/SPECS/A3.spec

echo -e "\n\n\n"
echo Create tar.gz file
echo "******************"
git archive $BRANCH --prefix A3-$VERSION/ -o "${BUILD_DIR}/SOURCES/A3-${PF_RELEASE}.tar.gz"
if [[ "$?" != "0" ]]; then
	echo "Problem building the source tarball. Aborting build process..." && exit 2
else
    echo "Tarball created successfully"
fi

echo -e "\n\n\n"
echo "Building the RPMs"
echo "*****************"
if [ -n "$PASSPHRASE" ]; then
  $CURRENT_DIR/a3-rpm-build-expect.sh $VERSION $DIST $DATE $BUILD_DIR $PASSPHRASE
else
  /usr/bin/rpmbuild -ba --sign --define "ver $VERSION" --define 'snapshot 1' --define "dist $DIST" --define "rev 0.$DATE" $BUILD_DIR/SPECS/A3.spec 1>/dev/null
fi

if [[ "$?" != "0" ]]; then
	echo "Problem building the RPM. Aborting build process..." && exit 3
else
    echo "RPM built properly"
fi
