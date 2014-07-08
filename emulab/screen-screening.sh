#!/bin/bash

# Session name
EXP_NAME=$1

# Number of windows within the session
COUNT=$2

while :
do
    sleep 5m
    for i in $(seq 1 $COUNT); do
	screen -S "$EXP_NAME" -X next
	sleep 0.5s
    done
done
