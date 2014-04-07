#!/bin/bash

# Call pase-new-logs.sh every 30 seconds
while :
do
    parse-new-logs.sh
    sleep 30s
done
