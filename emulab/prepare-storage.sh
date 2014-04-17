#!/bin/bash

GROUP=`id -ng`
IMG=/mnt/storage
sudo chown $USER:$GROUP $IMG
sudo chmod 775 $IMG
