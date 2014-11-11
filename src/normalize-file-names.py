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

logsdir = sys.argv[1]

os.chdir(logsdir)

files = os.listdir("./")
files = [x[:-4] for x in files if x[-4:] == ".log"]

tmp = [(x, x.split("-", -1)) for x in files]
f = [(x[1][1] + "-" + x[1][2], x[0]) for x in tmp]
f.sort(key=lambda y: y[0])

for i in range(0, len(f)):
    print(i)
    #print(f[i][1] + ".log" + " --> " + str(i + 1) + "-" + f[i][0] + ".log")
    os.rename(f[i][1] + ".log", str(i + 1) + "-" + f[i][0] + ".log")
    os.rename(f[i][1] + ".graph", str(i + 1) + "-" + f[i][0] + ".graph")
    os.rename(f[i][1] + ".freq", str(i + 1) + "-" + f[i][0] + ".freq")
