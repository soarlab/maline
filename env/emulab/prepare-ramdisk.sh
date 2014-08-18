#!/bin/bash

GROUP=`id -ng`

sudo chown $USER:$GROUP /mnt

LOCAL=/mnt/storage
ANDROID_TMP_OLD=$LOCAL/.android

# Create a RAM disk directory
export RAMDISK=/mnt/ramdisk
mkdir -p $RAMDISK

# This will create a ram disk of the default size (~ 95 GB)
RAM_DEV=/dev/ram0
sudo mkfs -q $RAM_DEV

# Mount the file system. Copying the original .android here will be
# done by an experiment script
sudo mount $RAM_DEV $RAMDISK
sudo chown $USER:$GROUP $RAMDISK
sudo chmod 775 $RAMDISK
mkdir -p $RAMDISK/.android/avd
