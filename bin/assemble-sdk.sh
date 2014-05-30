#!/bin/bash

# Copyright 2013,2014 Marko Dimjašević, Simone Atzeni, Ivo Ugrina, Zvonimir Rakamarić
#
# This file is part of maline.
#
# maline is free software: you can redistribute it and/or modify it
# under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# maline is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with maline.  If not, see <http://www.gnu.org/licenses/>.

# If you want to assemble a custom Android SDK in a root directory
# other than the current directory, specify a path to it with the -p
# parameter. To compress it into an archive, add the -a parameter. The
# only mandatory parameter is -r which specifies a path to the root of
# the Android repo structure.
#
# Example usage: assemble-sdk.sh -p /tmp/ -a -r /mnt/storage/android-repo

set -e

CREATE_ARCHIVE=0
ASSEMBLE_DIR=`pwd`/custom-android-sdk
SCRIPTNAME=`basename $0`

while getopts "p:ar:" OPTION; do
    case $OPTION in
	p)
	    ASSEMBLE_DIR="$OPTARG"/custom-android-sdk;;
	a)
	    CREATE_ARCHIVE=1;;
	r)
	    REPO_DIR="$OPTARG";;
	# \?)
	#     echo "Invalid option: -$OPTARG" >&2;;
    esac
done

check_and_exit() {
    if [ -z "$2" ]; then
	echo "$SCRIPTNAME: Parameter \"$1\" is missing"
	echo "Aborting..."
	exit 1
    fi
}

# Check if the mandatory parameter is provided
check_and_exit "-r" $REPO_DIR

CURR_DIR=`pwd`
ANDROID_VERSION="4.4.3.2.1.000.000"

#  make a root directory for the sdk and cd into it
mkdir $ASSEMBLE_DIR
cd $ASSEMBLE_DIR

echo "Assembling the SDK..."

# make needed sub-directories:
mkdir -p platforms/android-19 platform-tools system-images/android-19 tools/lib/x86_64/swt/

# copy platform target(s) from the build into the custom SDK
rsync -a $REPO_DIR/out/host/linux-x86/sdk/android-sdk*/platforms/android-$ANDROID_VERSION/ platforms/android-19/

# copy system images
rsync -a $REPO_DIR/out/host/linux-x86/sdk/android-sdk*/system-images/android-$ANDROID_VERSION/ system-images/android-19/

# copy the initial snapshot image and build the mksdcard tool
mkdir -p tools/lib/emulator
rsync -a $REPO_DIR/sdk/emulator/snapshot/snapshots.img tools/lib/emulator/
gcc $REPO_DIR/sdk/emulator/mksdcard/src/source/mksdcard.c -o $ASSEMBLE_DIR/tools/mksdcard

# copy a library so that we can use the Dalvik runtime instead of the new default ART runtime
rsync -a $REPO_DIR/out/target/product/generic_x86/system/lib/libdvm.so tools/lib/

# copy the android and abd tools from prebuilts and the build, respectively
rsync -a $REPO_DIR/prebuilts/devtools/tools/android tools/
rsync -a $REPO_DIR/out/host/linux-x86/sdk/android-sdk*/platform-tools/adb platform-tools/

# build emulator tools and libraries and copy them
$REPO_DIR/external/qemu/android-rebuild.sh
rsync -a $REPO_DIR/external/qemu/objs/emulator tools/
rsync -a $REPO_DIR/external/qemu/objs/emulator64-arm tools/
rsync -a $REPO_DIR/external/qemu/objs/emulator64-x86 tools/
rsync -a $REPO_DIR/external/qemu/objs/lib/ tools/lib/
rsync -a $REPO_DIR/external/qemu/objs/libs tools/

# copy dependency JAR archives from the prebuilts
rsync -a $REPO_DIR/prebuilts/devtools/tools/lib/ tools/lib/
rsync -a $REPO_DIR/prebuilts/tools/linux-x86_64/swt/swt.jar tools/lib/x86_64/swt/

echo "Done assembling the SDK"

# check if the user wants an archive
if [ "$CREATE_ARCHIVE" -eq 1 ]; then
    echo "Creating an SDK archive..."

    cd $ASSEMBLE_DIR/..
    tar cf custom-android-sdk.tar.xz --xz custom-android-sdk

    echo "Done creating the SDK archive"
fi

cd $CURR_DIR
