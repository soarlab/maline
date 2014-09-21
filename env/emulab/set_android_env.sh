#!/bin/bash

export MALINE=/mnt/storage/maline
export MALINE_ENV=$MALINE/env/emulab

export RAMDISK=/mnt/ramdisk
# ANDROID_SDK_HOME has a default value of ~/.android.                                            
export ANDROID_SDK_HOME=$RAMDISK
export ANDROID_SDK_ROOT=/mnt/storage/custom-android-sdk
export ANDROID_TMP=$RAMDISK/.android
export AVDDIR=$RAMDISK/.android/avd

# Where results of an experiment are stored
export EXP_ROOT=/mnt/experiments

export PATH=$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/tools:$MALINE/bin:$MALINE_ENV:$MALINE/lib/apktool:$PATH

# Add all users to the kvm user group                                                            
sudo usermod -a -G kvm marko
sudo usermod -a -G kvm simoatze

# Prepare the screen tool for a multiuser mode
sudo chmod 755 /var/run/screen
