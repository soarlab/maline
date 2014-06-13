#!/bin/bash

function die() {
    echo >&2 "$@"
    exit 1
}

function copy_avd() {
    EXISTING_AVD=maline-1
    echo -n "Making a copy for maline-$1... "
    rsync -a $OLD_ANDROID_TMP/$EXISTING_AVD.avd/ $AVDDIR/maline-$1.avd/
    sed -i "s/$EXISTING_AVD/maline-$1/g" $AVDDIR/maline-$1.avd/*ini
    rsync -a $OLD_ANDROID_TMP/$EXISTING_AVD.ini $AVDDIR/maline-$1.ini
    sed -i "s/$EXISTING_AVD/maline-$1/g" $AVDDIR/maline-$1.ini
    echo "done"
}

# Short experiment name
EXP_NAME=$1

# Number of maline instances to start
COUNT=$2
# Limit due to the memory size (each AVD needs about 5 GB)
COUNT_LIMIT=20

# A file with a list of apps to be analyzed
APP_FILE=$3

# Location of pristine AVDs
OLD_ANDROID_TMP=/mnt/storage/.android/avd

# "d/p" in window titles designates a virtual device and a piece of
# the problem to be solved with the same number

# Check if needed variables have been set
[ ! -z $EXP_NAME ] || die "Experiment name not provided"

[ ! -z $COUNT ] || die "Number of maline instances not provided"
[ $COUNT -le $COUNT_LIMIT ] || die "Too many instances! Set it up to $COUNT_LIMIT"

[ ! -z $APP_FILE ] || die "A file with apps not provided"
[ -f $APP_FILE ] || "Invalid file with a list of apps"

[ ! -z $AVDDIR ] || die "Environment variable AVDDIR not set"
[ -d $AVDDIR ] || die "Non-existing directory $AVDDIR"

[ -d $OLD_ANDROID_TMP ] || die "Non-existing directory $OLD_ANDROID_TMP"
[ ! -z $MALINE ] || die "Environment variable $MALINE not set"

# Split the input file. The output is in $APP_FILE.XX
split-file.sh $APP_FILE $COUNT &>/dev/null

# Start a screen daemon in the detached mode
screen -dmS "$EXP_NAME" -t "d/p: 0" -c $MALINE_ENV/.screenrc

for i in $(seq 0 $(($COUNT-1))); do
    if [ $i -ne 0 ]; then
	# Open a new window
	screen -S "$EXP_NAME" -X screen -t "d/p: $i"
    fi
    # Copy an AVD if needed
    copy_avd $i

    # Start a command in its own screen window
    CMD="maline.sh -f $APP_FILE.$(printf "%02d" $i) -d maline-$i"
    echo -n "Starting instance #$i in a detached screen... "
    screen -S "$EXP_NAME" -p $i -X stuff "$CMD$(printf \\r)" && echo "done" || echo "failed"
done
