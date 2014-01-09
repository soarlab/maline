#!/bin/bash

echo 'Backing up old features data file...'
backup=$MALINE/data/feature_data_$(date +"%m%d%Y_%H%M%S").dat
echo $backup
cp $MALINE/data/feature_data.dat $backup
echo 'Generating new features data file from app trace log...'
filename=$MALINE/tools
cd $filename
octave --eval 'loaddata.m'
