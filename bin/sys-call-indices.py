#!/usr/bin/env python

# Copyright 2013,2014 Marko Dimjašević, Simone Atzeni, Ivo Ugrina, Zvonimir Rakamarić
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


# Extracts a pair of system call names given a unique integer that
# identifes the pair

import sys

def import_sys_call_list():
    global num_of_sys_calls
    global sys_call_dict

    num_of_sys_calls = 0
    sys_call_dict = dict()

    with open("../data/syscalls-list", 'r') as f:
        for line in f:
            sys_call_dict[num_of_sys_calls] = line[:-1]
            num_of_sys_calls += 1

def name(index):
    return sys_call_dict[index]

if __name__ == "__main__":
    sys_call_dict = dict()
    num_of_sys_calls = 0
    import_sys_call_list()

    for line in sys.stdin:
        index = int(line[:-1]) - 1
        s1 = index / num_of_sys_calls
        s2 = index % num_of_sys_calls
        print "%d = (%d, %d) = (%s, %s)" % (index, s1, s2, name(s1), name(s2))
