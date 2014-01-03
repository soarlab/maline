<div id="table-of-contents">
<h2>Table of Contents</h2>
<div id="text-table-of-contents">
<ul>
<li><a href="#sec-1">1. Introduction</a></li>
<li><a href="#sec-2">2. Installation</a>
<ul>
<li><a href="#sec-2-1">2.1. Dependencies</a></li>
</ul>
</li>
<li><a href="#sec-3">3. Configuration</a>
<ul>
<li><a href="#sec-3-1">3.1. Path to Executables</a></li>
<li><a href="#sec-3-2">3.2. Android Virtual Device</a></li>
</ul>
</li>
</ul>
</div>
</div>


# Introduction

**maline** is an Android malware detection framework. If you are an Org-mode
user, you might want to read the [executable version](http://orgmode.org/worg/org-contrib/babel/intro.html) of this readme (the
README.org file in the root).

# Installation

**maline** was developed under Ubuntu 12.04 LTS. It is very likely it will work
under other POSIX systems (GNU/Linux and Mac alike). The Android version we
tested **maline** with is Android 4.4.2 (API version 19), which is assumed
throughout the readme.

**maline** is a collection of Bash and Python scripts, so no installation is
needed. It suffices to obtain **maline**, e.g. from Github:

    mkdir ~/projects
    cd ~/projects
    git clone git@github.com:soarlab/maline.git

## Dependencies

To use **maline**, you need the following:

-   [Android SDK](https://developer.android.com/sdk/index.html) - follow instructions for installation of the SDK.

-   [apktool](https://code.google.com/p/android-apktool/) - **maline** already ships with apktool.

-   expect - a command line tool that automates interactive applications

# Configuration

## Path to Executables

**maline** needs to be in the PATH environment variable. In particular, the
`bin/` directory should to be added to the variable, e.g.

    export MALINE=~/projects/maline/bin
    PATH=$PATH:$MALINE

## Android Virtual Device

**maline** executes Android apps in the Android Emulator, which comes within the
Android SDK. The Emulator is a QEMU-based emulator that runs Android Virtual
Devices (AVDs). By default, the ARM architecture is emulated, but that is very
slow. Therefore, if one has an `x86` host machine, it is better to create an
`x86` architecture-based virtual device image.  However, Intel has some nasty
long license that you have to accept before installing the Intel x86 System
Image.

First make sure to have the Android API version 19 and the respective Intel
x86 Atom System Image:

    android update sdk --no-ui
    android update sdk --no-ui --all --filter sysimg-19

Now, go ahead and create the image:

    android create avd -f -a -c 512M -s WVGA800 -n maline-android-19_x86 -t android-19 --abi x86

We want snapshots so that each app can be executed in a clean environment
(that's the `-a` parameter). We also create a 512 MB SD card and select the
800x480 screen resolution.

You can check that the device is created by executing:

    android list avd
