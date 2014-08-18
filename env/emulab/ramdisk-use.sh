#!/bin/bash

df $RAMDISK/ | grep dev | awk -F" " '{print $5}'
