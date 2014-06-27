# Prerequisites

To run an experiment on an Emulab machine, use a clean installation of Ubuntu
12.04.4 LTS.

# Preparation

The first script that needs to be executed on a pristine operating system
installation is `prepare-node.sh`, with root permissions, e.g.:

    sudo prepare-node.sh

This will install various needed software packages and prepare the machine
system-wide for KVM virtualization to speed up Android Virtual Devices. The
script will reboot the system once it is done.

Next thing is to set up permissions on two external storage partitions:

    source prepare-storage.sh

Because we have been using a d820 Emulab node, which has 128 GB of RAM, we
store Android Virtual Devices in a RAM disk. To set up the disk, execute:

    source prepare-ramdisk.sh

Finally, to set up various environment variables needed by **maline**, run:

    source set_android_env.sh

# Running an experiment

To start running the first phase of the analysis in **maline**, start an
experiment with optionally multiple instances of **maline** running in
parallel. Name the experiment, provide the number of instances, and an input
list of applications to be analyzed:

    source start-exp.sh full-test-14-06-20 20 /mnt/storage/input-files/apk-full-list

This will start an experiment named *full-test-14-06-20* with *20* **maline**
instances, each instance analyzing an equal share of apps listed in a file
`/mnt/storage/input-files/apk-full-list`.

Instructions on how to watch the experiment are given at the end of the
command output.

Once the first phase is done, run the following command while in the same
directory as when `start-exp.sh` returned:

    create-features-file.sh

to generate a file with features for all the analyzed applications.
