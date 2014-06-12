#!/bin/bash

# Short experiment name
EXP_NAME=$1

# Number of maline instances to start
COUNT=$2

# "d/p" in window titles designates a virtual device and a piece of
# the problem to be solved with the same number

# Start a screen daemon in the detached mode
screen -dmS $EXP_NAME -t "d/p: 0"

for i in $(seq 0 $(($COUNT-1))); do
    if [ $i -ne 0 ]; then
	# Open a new window
	screen -S $EXP_NAME -X screen -t "d/p: $i"
    fi
    # Start a command in its own screen window
    screen -S $EXP_NAME -p $i -X stuff "echo $i$(printf \\r)"
done
