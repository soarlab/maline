#!/bin/bash

export MALINE=/mnt/storage/maline

export LOCAL=/mnt/storage
export SYSDIR=/mnt/storage/android-sdk/system-images/android-19/
#export BINARY=$LOCAL/android-binary
export BINARY=$LOCAL/android-binaries/linux-x86/bin
export SAN=$LOCAL
RAMDISK=/mnt/ramdisk
export SDK=$SAN/android-sdk-linux
# export ANDROID_SDK_HOME=$LOCAL
export ANDROID_SDK_HOME=$RAMDISK
export ANDROID_SDK_ROOT=$LOCAL/android-sdk
export ANDROID_HOST_OUT=$LOCAL
export ANDROID_TMP=$RAMDISK/.android
export AVDDIR=$RAMDISK/.android/avd

export LD_LIBRARY_PATH=$LOCAL/android-binaries/linux-x86/lib:$LD_LIBRARY_PATH

export PATH=$LOCAL/android-sdk/tools:$LOCAL/android-sdk/platform-tools:$BINARY/bin:$PATH
# export PATH=/mnt/storage/android-binaries/linux-x86/bin:$BINARY/bin:$PATH

# Add all users to the kvm user group
sudo usermod -a -G kvm marko
sudo usermod -a -G kvm simoatze
