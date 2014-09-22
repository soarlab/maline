# Introduction

<img src="docs/images/maline-logo.png" alt="maline logo" title="maline" align="right" />

**maline** is a free software Android malware detection framework. If you are an
Org-mode user, you might want to read the [executable version](http://orgmode.org/worg/org-contrib/babel/intro.html) of this readme
(the README.org file in the root). If you are interested in running extensive
experiments with **maline**, take a look at the README file in the `env/emulab`
directory, where you can find a lot of information on setting up a
reproducible research environment.

# Installation

**maline** has been developed under Ubuntu 12.04.3 LTS. It is very likely it
will work under other POSIX systems too (GNU/Linux and Mac alike). The Android
version we tested **maline** with is Android 4.4.3 (API version 19), which is
assumed throughout the readme.

## Dependencies

To use **maline**, you need the following:
-   Android SDK - please [download and use our build](http://www.cs.utah.edu/formal_verification/downloads/custom-android-sdk.tar.xz) of the SDK. It is a
    stripped-down version with multiple bug fixes applied. Based on our
    experience, it is very unlikely **maline** will work correctly with the
    official version provided by Google. The official version ships without the
    fixes for multiple showstopping bugs.
-   [OpenJDK 7](http://openjdk.java.net/)
-   [apktool](https://code.google.com/p/android-apktool/) - **maline** already ships with apktool, which is licensed under the
    Apache License 2.0.
-   [GNU Octave](https://www.gnu.org/software/octave/) - a programming language for numerical computations. It is
    available through a Ubuntu's default repository.
-   [LIBSVM](http://www.csie.ntu.edu.tw/~cjlin/libsvm/) - **maline** already ships with LIBSVM, which is licensed under the
    Modified BSD License.
-   [R](http://www.r-project.org/) - an environment for statistical computing and graphics.
-   [Bash](http://www.gnu.org/software/bash/) - ships with Ubuntu.
-   [expect](http://sourceforge.net/projects/expect/) - a command line tool that automates interactive applications. It is
    available through a Ubuntu's default repository.

There are other dependencies we used throughout the project - such as for
building Android from source - that you might not need for all the phases of
**maline**. An extensive list of such dependencies and particular packages of
the tools listed above can be found in `env/emulab/prepare-node.sh`.

## Building

First obtain **maline**, e.g. from Github:

    mkdir ~/projects
    cd ~/projects
    git clone git@github.com:soarlab/maline.git

Then change directory and build **maline** by running `make`:

    cd maline
    make

# Configuration

## Unpacking the SDK

Let's assume you have downloaded [the custom SDK](http://www.cs.utah.edu/formal_verification/downloads/custom-android-sdk.tar.xz) into your home directory. This
is how you would unpack it:

    tar -C ~/projects/ -xf ~/custom-android-sdk.tar.xz

## Path to Executables

**maline** needs an environment variable named `$MALINE`, which should point to
the tool root directory. In addition, it's `bin/` directory should be in the
PATH variable. A few tools provided with the SDK should be on the path as
well. Therefore, execute the following commands:

    export MALINE=~/projects/maline
    PATH=$MALINE/bin:~/projects/custom-android-sdk/tools:~/projects/custom-android-sdk/platform-tools:$PATH

## Android Virtual Device

**maline** executes Android apps in the Android Emulator, which comes within the
Android SDK. The Emulator is a QEMU-based emulator that runs Android Virtual
Devices (AVDs). By default, the ARM architecture is emulated, but that is very
slow. Instead, on an `x86` host machine it is better to create an `x86`
architecture-based virtual device image.

To create an x86-based AVD device, run:

    avd-create.sh -a x86 -d maline-avd

The device creation process usually takes about 5 minutes.

Now you have a clean environment where each app can be executed. That is so
because the above executed `avd-create.sh` command creates an AVD device with
a clean snapshot that will be reloaded every time a new app is analyzed.

You can check that the device is created by executing:

    android list avd

You should see a device with a name `maline-avd`.

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

It is assumed that malicious applications have file names consisting of 64
hexadecimal characters. That is how **maline** distinguishes malicious from
benign apps in its learning phase.

To execute the apps and get their execution logs, run the following:

    maline.sh -f apk-list-file -d maline-avd

As **maline** is executing, obtained `.log` files are parsed and as a result one
`.graph` file per `.log` file is generated. From the `.graph` files we
generate a feature vector for every analyzed app by executing:

    create-feature-matrix.sh regular

Now it is possible to classify the data by running the following:

    run-classdroid.sh FEATURES_FILE SHUFFLE_MODE [0 | 1]

The classification used is Support Vector Machine (SVM).
A new folder will be created to store the temporary file used for the
classification process and a file called "result.dat" will contain the
final results.

The SVM methods used consists in classify the features using Linear and Polynomial
Kernel (from 1st to 4th degree) applying 50% or 90% of the data set for training.

# Emulab

In the development of **maline**, we have been using [Emulab](http://www.emulab.net) extensively. Emulab
is a network testbed developed by [The Flux Research Group](http://www.flux.utah.edu/) from the University
of Utah. We are thankful to the group for providing us with such an amazing
computing infrastructure!

# Copyright

**maline** is a free software framework licensed under the terms of the GNU
Affero General Public License, version 3 or (at your option) any later
version. You can find the text of the license in COPYING.

There are software dependencies for **maline**. All of them are free software
too. Read their copyright notices for more information.

To the extent possible under law, Marko Dimjašević has waived all copyright
and related or neighboring rights to this README ([CC0](https://creativecommons.org/publicdomain/zero/1.0/)).
