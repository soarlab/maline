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
<li><a href="#sec-4">4. Usage</a></li>
</ul>
</div>
</div>

# Introduction

**maline** is an Android malware detection framework. It is a free software
framework licensed under the terms of the GNU Affero General Public License,
version 3 or (at your option) any later version. If you are an Org-mode user,
you might want to read the [executable version](http://orgmode.org/worg/org-contrib/babel/intro.html) of this readme (the README.org
file in the root).

# Installation

**maline** was developed under Ubuntu 12.04.3 LTS. It is very likely it will
work under other POSIX systems too (GNU/Linux and Mac alike). The Android
version we tested **maline** with is Android 4.4.2 (API version 19), which is
assumed throughout the readme.

**maline** is a collection of Bash and Python scripts, so no installation is
needed. It suffices to obtain **maline**, e.g. from Github:

    mkdir ~/projects
    cd ~/projects
    git clone git@github.com:soarlab/maline.git

## Dependencies

To use **maline**, you need the following:

-   [Android SDK](https://developer.android.com/sdk/index.html) - follow instructions for installation of the SDK.

-   [apktool](https://code.google.com/p/android-apktool/) - **maline** already ships with apktool, which is licensed under the
    Apache License 2.0.

-   [GNU Octave](https://www.gnu.org/software/octave/) - a programming language for numerical computations. It is
    available through a Ubuntu's default repository.

-   [LIBSVM](http://www.csie.ntu.edu.tw/~cjlin/libsvm/) - **maline** already ships with LIBSVM, which is licensed under the
    Modified BSD License.

-   [Bash](http://www.gnu.org/software/bash/) - ships with Ubuntu.

-   [Python](http://www.python.org/) - we tested **maline** with Python 2.7.3, but it might work with more
    recent versions too. It is available through a Ubuntu's default repository.

-   [expect](http://sourceforge.net/projects/expect/) - a command line tool that automates interactive applications. It is
    available through a Ubuntu's default repository.

# Configuration

## Path to Executables

**maline** needs to be in the PATH environment variable. In particular, the
`bin/` directory should to be added to the variable, e.g.

    export MALINE=~/projects/maline
    PATH=$PATH:$MALINE/bin

## Android Virtual Device

**maline** executes Android apps in the Android Emulator, which comes within the
Android SDK. The Emulator is a QEMU-based emulator that runs Android Virtual
Devices (AVDs). By default, the ARM architecture is emulated, but that is very
slow. Therefore, if one has an `x86` host machine, it is better to create an
`x86` architecture-based virtual device image.  However, Intel has some nasty
long license that you have to accept before installing the Intel x86 System
Image.

First make sure to have the Android API version 19:

    android update sdk --no-ui

If you want to use an Intel x86 Atom System Image, then install the image
through the SDK first:

    android update sdk --no-ui --all --filter sysimg-19

and then create an AVD device by executing:

    avd-create.sh -a x86 -d maline-android-19

Otherwise, if you want to base your AVD device on an ARM architecture, execute:

    avd-create.sh -a armeabi-v7a -d maline-android-19

The device creation process usually takes about 5 minutes.

Now you have a clean environment where each app can be executed. That is so
because the above executed `avd-create.sh` command creates an AVD device with
a clean snapshot that will be reloaded every time a new app is analyzed.

You can check that the device is created by executing:

    android list avd

You should see a device with a name `maline-android-19`.

# Usage

In order to execute Android apps in **maline**, one first needs to create a list
of the apps. For example, let's assume that there are 6 apps in the `apps/`
sub-directory within the root **maline** directory. Then their list can be
stored to a file `apk-list-file` that has paths to the apps:

    ~/projects/maline/apps/com.nephoapp.anarxiv_1.apk
    ~/projects/maline/apps/org.ale.scanner.zotero_2.apk
    ~/projects/maline/apps/ed8a51225a3862e30817640ba7ec5b88ee04c98a.apk
    ~/projects/maline/apps/vu.de.urpool.quickdroid_49.apk
    ~/projects/maline/apps/to.networld.android.divedroid_1.apk
    ~/projects/maline/apps/4147f7d801c4bc5241536886309d507c5124fe3b.apk

To execute the apps and get their execution logs, run the following:

    maline.sh -c 55432 -b 55184 -s 13234 -f apk-list-file -e -d maline-android-19
