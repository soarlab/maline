#!/bin/bash

echo 'Running classdroid for apps classification...'
filename=$MALINE/tools
cd $filename
octave --eval 'classdroid.m'
