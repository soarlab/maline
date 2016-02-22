#!/bin/bash

# Script copied from Raimondas Sasnauskas

function die() {
    echo $@ 2>&1
    exit 1
}
[ $(id -u) == 0 ] || die "Use must be root or use sudo"

# this is for Ubuntu 12.04 for x86-64
echo 'linux-firmware hold' | dpkg --set-selections
echo 'grub-common hold' | dpkg --set-selections
echo 'grub-pc hold' | dpkg --set-selections
echo 'grub-pc-bin hold' | dpkg --set-selections
echo 'grub2-common hold' | dpkg --set-selections
echo 'linux-headers-2.6.38.7-1.0emulab hold' | dpkg --set-selections
echo 'linux-image-2.6.38.7-1.0emulab hold' | dpkg --set-selections

apt-get update
apt-get install -y bison ca-certificates-java curl expect gawk htop iotop java-common lib32gcc1 lib32ncurses5 lib32stdc++6 lib32tinfo5 libgl1-mesa-dev libasyncns0 libatk-wrapper-java libatk-wrapper-java-jni libbison-dev libcurl3 libdbi1 libffi-dev libflac8 libgdbm-dev libjffi-jni libjs-mochikit libjson0 liblcms2-2 libnspr4 libnss3 libnss3-1d libogg0 libpcsclite1 libprotobuf7 libpulse0 libreadline6-dev librrd4 libsigsegv2 libsndfile1 libsqlite3-dev libtinfo-dev libvorbis0a libvorbisenc2 libyaml-0-2 libyaml-dev openjdk-7-jre openjdk-7-jre-headless openjdk-7-jre-lib openjdk-7-jdk pkg-config python-mako python-markupsafe python-minimal python-protobuf quota screen sqlite3 tzdata-java unzip kvm tree git gnupg flex gperf build-essential zip libc6-dev g++-multilib mingw32 tofrodos python-markdown libxml2-utils xsltproc r-base gfortran libblas-dev liblapack-dev python-bs4 build-essential fort77 libreadline-dev libboost1.48-dev

# Check if i386-architecture-specific packages needed to build Android
# on Ubuntu 12.04 should be installed
if [ "$1" = "android-build" ]; then
    apt-get install -y libc6-i386 libncurses5-dev:i386 x11proto-core-dev libx11-dev:i386 libreadline6-dev:i386 libgl1-mesa-glx:i386 zlib1g-dev:i386
fi
apt-get autoremove -y

# Extend the default RAM disk size to 100000000 KB ~ 95 GB
sudo sed -i '/^GRUB_CMDLINE_LINUX\=/c \GRUB_CMDLINE_LINUX=\"console=tty0 console=ttyS0,115200 ramdisk_size=100000000\"' /etc/default/grub

# To build Android, we need this
sudo ln -s /usr/lib/i386-linux-gnu/mesa/libGL.so.1 /usr/lib/i386-linux-gnu/libGL.so

sudo update-grub

# Strongly discourage swappiness
sudo echo "vm.swappiness=0" >> /etc/sysctl.conf

# Prepare the screen tool for a multiuser mode
sudo chmod u+s /usr/bin/screen

reboot
