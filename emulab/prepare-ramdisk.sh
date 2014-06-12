#!/bin/bash

GROUP=`id -ng`

sudo chown $USER:$GROUP /mnt

LOCAL=/mnt/storage
ANDROID_TMP_OLD=$LOCAL/.android

# Create a RAM disk directory
RAMDISK=/mnt/ramdisk
mkdir -p $RAMDISK

# This will create a ram disk of the default size (~ 100 GB)
RAM_DEV=/dev/ram0
sudo mkfs -q $RAM_DEV

# Mount the file system and copy the old .android there
sudo mount $RAM_DEV $RAMDISK
sudo chown $USER:$GROUP $RAMDISK
sudo chmod 775 $RAMDISK
mkdir -p $RAMDISK/.android/avd
rsync -a --progress $ANDROID_TMP_OLD/avd/maline-* $RAMDISK/.android/avd/
