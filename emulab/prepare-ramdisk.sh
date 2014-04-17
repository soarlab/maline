#!/bin/bash

LOCAL=/mnt/storage
ANDROID_TMP_OLD=$LOCAL/.android

# Create a RAM disk directory
RAMDISK=/mnt/ramdisk
sudo mkdir -p $RAMDISK/.android

# This will create a ram disk of the default size (~ 65 GB)
RAM_DEV=/dev/ram0
sudo mkfs -q $RAM_DEV

# Mount the file system and copy the old .android there
sudo mount $RAM_DEV $RAMDISK
GROUP=`id -ng`
sudo chown $USER:$GROUP $RAMDISK
sudo chmod 775 $RAMDISK
rsync -a --progress $ANDROID_TMP_OLD/avd $RAMDISK/.android/
