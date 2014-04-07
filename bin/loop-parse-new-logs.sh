#!/bin/bash

# Call parse-new-logs.sh periodically in an infinite loop
while :
do
    parse-new-logs.sh &
    sleep 10s
done
