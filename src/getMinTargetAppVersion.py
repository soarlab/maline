#!/usr/bin/env python

# Copyright 2013,2014 Marko Dimjasevic, Simone Atzeni, Ivo Ugrina, Zvonimir Rakamaric
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

import sys
import re
import subprocess
import os
import numpy as np
import matplotlib as mpl
mpl.use('pdf')
import matplotlib.pyplot as plt

minDict = {}
tgtDict = {}

def get_version(dirname, ext):

    cmd = ''
    if ext == '0':
        print "pippo"
        cmd = 'find {0} -type f'.format(dirname)
    else:
        cmd = 'find {0} -type f -name "*.{1}"'.format(dirname, ext)
    p = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=True)
    (res, err) = p.communicate()
    fileList = str(res).split("\n")
    for f in fileList:
        if f != '':
            #print "File: {0}".format(str(f))

            cmd = "getAppVersion.sh %s" % f
            p = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=True)
            (res, err) = p.communicate()
            if res is not '':
                if ' ' in res:
                    min, tgt = res.split(" ")
                else:
                    min = res
                
                if (min is not ''):
                    if '\n' in min:
                        min = min.replace("\n", "")
                    if (min in minDict):
                        minDict[min]+=1
                    else:
                        minDict[min] = 1
                    
                if tgt is not '':
                    if '\n' in tgt:
                        tgt = tgt.replace("\n","")
                    if tgt in tgtDict:
                        tgtDict[tgt]+=1 
                    else:
                        tgtDict[tgt] = 1

    print "Min Versions: {0}".format(minDict)
    print "Tgt Versions: {0}".format(tgtDict)
                 
                       
if __name__ == "__main__":
    if (len(sys.argv) > 2):

        get_version(str(sys.argv[1]), str(sys.argv[2]))
    else:
        print 'Usage:', str(sys.argv[0]), "AppsFolder Extension"
