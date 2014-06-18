#!/bin/bash

# Call parse-new-logs.sh periodically in an infinite loop
while :
do
    parse-new-logs.sh $1
    sleep 5s
done
