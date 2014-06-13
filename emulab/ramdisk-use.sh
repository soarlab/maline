#!/bin/bash

[ ! -z $RAMDISK ] || ( echo "--%" && exit 0 )

df $RAMDISK/ | grep dev | awk -F" " '{print $5}'
