#!/usr/bin/env python3

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

import os
import sys

if len(sys.argv) != 4:
    print("Usage: hardlink-intersection.py ANDROID-LOGS INTERSECTION-SET-LIST INTERSECTED-ANDROID-LOGS")
    sys.exit(1)

logsdir = sys.argv[1]
interseclist = sys.argv[2]
intersecdir = sys.argv[3]

os.mkdir(intersecdir)

os.chdir(logsdir)

files = os.listdir("./")

# take only logs and remove ".log" part from the name of a file
files = [x[:-4] for x in files if x[-4:] == ".log"]

# create appname-apkname string and keep original file name
tmp = [(x, x.split("-", -1)) for x in files]
f = [(x[1][1] + "-" + x[1][2], x[0]) for x in tmp]

# intersection list
tmp = open(interseclist, "r")
L = [x[:-1] for x in tmp.readlines()]

for x in f:
    if x[0] in L:
        os.link(logsdir + "/" + x[1] + ".log", intersecdir + "/" + x[1] + ".log")
        os.link(logsdir + "/" + x[1] + ".graph", intersecdir + "/" + x[1] + ".graph")
        os.link(logsdir + "/" + x[1] + ".freq", intersecdir + "/" + x[1] + ".freq")
