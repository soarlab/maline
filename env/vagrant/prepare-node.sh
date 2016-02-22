#!/bin/bash

# Copyright 2016 Marko Dimjašević, Simone Atzeni, Ivo Ugrina, Zvonimir Rakamarić
#
# This file is part of maline.
#
# maline is free software: you can redistribute it and/or modify it
# under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# maline is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with maline.  If not, see <http://www.gnu.org/licenses/>.


function die() {
    echo $@ 2>&1
    exit 1
}
[ $(id -u) == 0 ] || die "Use must be root or use sudo"


# Install dependencies
apt-get update
apt-get install -y bison ca-certificates-java curl expect gawk htop iotop java-common lib32gcc1 lib32ncurses5 lib32stdc++6 lib32tinfo5 libgl1-mesa-dev libasyncns0 libatk-wrapper-java libatk-wrapper-java-jni libbison-dev libcurl3 libdbi1 libffi-dev libflac8 libgdbm-dev libjffi-jni libjs-mochikit libjson0 liblcms2-2 libnspr4 libnss3 libnss3-1d libogg0 libpcsclite1 libprotobuf7 libpulse0 libreadline6-dev librrd4 libsigsegv2 libsndfile1 libsqlite3-dev libtinfo-dev libvorbis0a libvorbisenc2 libyaml-0-2 libyaml-dev openjdk-7-jre openjdk-7-jre-headless openjdk-7-jre-lib openjdk-7-jdk pkg-config python-mako python-markupsafe python-minimal python-protobuf quota screen sqlite3 tzdata-java unzip kvm tree git gnupg flex gperf build-essential zip libc6-dev g++-multilib mingw32 tofrodos python-markdown libxml2-utils xsltproc r-base gfortran libblas-dev liblapack-dev python-bs4 build-essential fort77 libreadline-dev libboost1.48-dev

# Install the editor
apt-get install -y emacs

# Check if i386-architecture-specific packages needed to build Android
# on Ubuntu 12.04 should be installed
if [ "$1" = "android-build" ]; then
    apt-get install -y libc6-i386 libncurses5-dev:i386 x11proto-core-dev libx11-dev:i386 libreadline6-dev:i386 libgl1-mesa-glx:i386 zlib1g-dev:i386
fi

# Remove unneeded packages
apt-get autoremove -y

# To build Android, we need this
# ln -s /usr/lib/i386-linux-gnu/mesa/libGL.so.1 /usr/lib/i386-linux-gnu/libGL.so

sudo usermod -a -G kvm $USER
