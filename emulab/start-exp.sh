#!/bin/bash

function die() {
    echo >&2 "$@"
    exit 1
}

function perform_init_checks() {
    # Check if needed variables have been set
    [ ! -z $EXP_NAME ] || die "Experiment name not provided"
    
    [ ! -z $COUNT ] || die "Number of maline instances not provided"
    [ $COUNT -le $COUNT_LIMIT ] || die "Too many instances! Set it up to $COUNT_LIMIT"
    
    [ ! -z $APP_FILE ] || die "A file with apps not provided"
    [ -f $APP_FILE ] || die "Invalid file with a list of apps"
    
    [ ! -z $AVDDIR ] || die "Environment variable AVDDIR not set"
    [ -d $AVDDIR ] || die "Non-existing directory $AVDDIR"
    
    [ -d $OLD_ANDROID_TMP ] || die "Non-existing directory $OLD_ANDROID_TMP"
    [ -d $ANDROID_TMP ] || die "Non-existing directory $ANDROID_TMP"
    [ ! -z $MALINE ] || die "Environment variable MALINE not set"

    [ ! -z $EXP_ROOT ] || die "Environment variable EXP_ROOT not set"
}

function init_avd() {
    EXISTING_AVD=maline-99
    rsync -a $OLD_ANDROID_TMP/$EXISTING_AVD.avd $AVDDIR/
    rsync -a $OLD_ANDROID_TMP/$EXISTING_AVD.ini $AVDDIR/
}

function git_init() {
    cd $1 &>/dev/null
    git clean -fd &>/dev/null
    git reset --hard &>/dev/null
    git log -n 1 --pretty=oneline > $2
    cd - &>/dev/null
}


# Short experiment name
EXP_NAME=$1

# Number of maline instances to start
COUNT=$2
# Limit due to the memory size (each AVD needs about 5 GB)
COUNT_LIMIT=25

# A file with a list of apps to be analyzed
APP_FILE=$3

# Location of pristine AVDs
OLD_ANDROID_TMP=/mnt/storage/.android/avd

perform_init_checks

# "d/p" in window titles designates a virtual device and a piece of
# the problem to be solved with the same number

# Create the experiment root directory and a few needed subdirectories
THIS_EXP_ROOT=$EXP_ROOT/$EXP_NAME
[ ! -d $THIS_EXP_ROOT ] || die "An experiment named $EXP_NAME at $THIS_EXP_ROOT already exists!"
echo -n "Creating an experiment directory at $THIS_EXP_ROOT ... "
mkdir -p $THIS_EXP_ROOT/screen-logs/ && echo "done" || die "failed. Aborting..."
mkdir -p $THIS_EXP_ROOT/input-lists
ANDROID_LOG_DIR=$THIS_EXP_ROOT/android-logs # This directory will be created in maline.sh


# Make sure to clean up maline and maline-experiments repositories and
# to write down the version of both used in the experiment
git_init $MALINE "$THIS_EXP_ROOT/maline-version-used"
cd $MALINE
make &>/dev/null
cd - &>/dev/null

git_init $MALINE_ENV "$THIS_EXP_ROOT/maline-experiments-version-used"

# Write down system package versions installed during the experiment
dpkg -l | grep ^ii > $THIS_EXP_ROOT/system-packages-installed

# Split the input file. The output is in $APP_COPY_FILE.XX
APP_COPY_FILE=$THIS_EXP_ROOT/input-lists/app-list
cp $APP_FILE $APP_COPY_FILE

split-file.sh $APP_COPY_FILE $COUNT &>/dev/null

# create a configuration file for screen
TIMESTAMP=$(date +"%Y-%m-%d-%H-%M-%S")
SCREENRC=$THIS_EXP_ROOT/screenrc
cp $MALINE_ENV/screenrc $SCREENRC
sed -i "s/name-goes-here/$EXP_NAME/g" $SCREENRC
echo "deflog on" >> $SCREENRC
echo "logfile $THIS_EXP_ROOT/screen-logs/$EXP_NAME-$TIMESTAMP-maline-%n.log" >> $SCREENRC
echo "log on" >> $SCREENRC

# Clean-up leftover screen sessions
screen -wipe &>/dev/null
# Start a screen daemon in the detached mode
screen -dmS "$EXP_NAME" -t "d/p: 0" -c $SCREENRC

# Memory space is precious so delete any leftover system images and
# modem files
rm -f $ANDROID_TMP/emulator-* &>/dev/null
rm -f $ANDROID_TMP/modem-nv-ram-* &>/dev/null

init_avd

for i in $(seq 0 $(($COUNT-1))); do
    if [ $i -ne 0 ]; then
	# Open a new window
	screen -S "$EXP_NAME" -X screen -t "d/p: $i"
    fi

    # Start a command in its own screen window
    CMD="maline.sh -f $APP_COPY_FILE.$(printf "%02d" $i) -d maline-$i -l $ANDROID_LOG_DIR -p $THIS_EXP_ROOT/per-app-time-and-calls/maline-$i"
    echo -n "Starting instance #$i in a detached screen... "
    # \\r is there to avoid a window being closed once the command
    # finishes
    screen -S "$EXP_NAME" -p $i -X stuff "$CMD$(printf \\r)" && echo "done" || echo "failed"
done

# Have a work-around for Android emulator not responding if a person
# is not watching the experiment
screen-screening.sh $EXP_NAME $COUNT &
SCREENING_PID=$!

# Put an indication file for the next phase of the experiment
echo $SCREENING_PID > $THIS_EXP_ROOT/.maline-started

echo ""
echo "Changing directory to $THIS_EXP_ROOT. All experiment data will be stored here."
cd $THIS_EXP_ROOT &>/dev/null
echo ""
echo "All users from the Maline user group can watch the progress of the experiment by executing:"
echo "  screen -x $USER/$EXP_NAME"

echo ""
echo "When this part is done, run the following in the current experiment directory to generate a features file:"
echo "  create-features-file.sh"
