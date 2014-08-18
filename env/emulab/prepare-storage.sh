#!/bin/bash

GROUP=`id -ng`
IMG=/mnt/storage
sudo chown $USER:$GROUP $IMG
sudo chmod 775 $IMG

EXP=/mnt/experiments
sudo chown $USER:$GROUP $EXP
sudo chmod 775 $EXP
