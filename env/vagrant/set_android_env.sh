#!/bin/bash

cat >> ~/.bashrc <<'EOF'
export MALINE=/vagrant
export MALINE_ENV=$MALINE/env/emulab

export ANDROID_SDK_HOME=/mnt/storage/sdk
export ANDROID_SDK_ROOT=/mnt/storage/custom-android-sdk
export ANDROID_TMP=$ANDROID_SDK_HOME/.android
export AVDDIR=$ANDROID_SDK_HOME/.android/avd

# Where results of an experiment are stored
export EXP_ROOT=/mnt/experiments

export PATH=$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/tools:$MALINE/bin:$MALINE_ENV:$MALINE/lib/apktool:$PATH
EOF
