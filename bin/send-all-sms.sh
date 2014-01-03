#!/bin/bash

# File to read phone numbers and messages from. Phone numbers contain numbers only and the rest of the line is an SMS text message
FILENAME="$1"

CONSOLE_PORT="$2"

while read line
do
    A=( $line )

    LEN=${#A[@]}

    MSG=""
    
    for (( i=1; i<$LEN; i++ ))
    do
	MSG="${MSG}${A[${i}]} "
    done

    PHONE_NUM=${A[0]}

    send-sms $CONSOLE_PORT $PHONE_NUM "$MSG"

    sleep 7s
done < $FILENAME
