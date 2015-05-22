#!/bin/bash

function die() {
    echo $@ 2>&1
    exit 1
}
[ $(id -u) == 0 ] || die "Use must be root or use sudo"

# this is for Ubuntu 12.04 for x86-64
apt-get install -y build-essential fort77 libreadline-dev gfortran
