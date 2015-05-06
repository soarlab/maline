#!/usr/bin/env python

import sys
import re
import subprocess
import os
import numpy as np
import matplotlib as mpl
mpl.use('pdf')
import matplotlib.pyplot as plt

minDict = {'10': 6, '14': 4, '1': 1, '3': 3, '5': 1, '4': 7, '7': 23, '11': 8, '9': 39, '8': 64}
tgtDict = {'11': 4, '10': 1, '13': 3, '15': 7, '14': 3, '17': 61, '16': 9, '19': 29, '18': 32, '4': 1, '7': 1, '8': 6}

x_min = []
y_min = []
x_min_label = []
x_tgt = []
y_tgt = []
x_tgt_label = []

for k in minDict:
    x_min.append(int(k))
    y_min.append(int(minDict[k]))
    x_min_label.append(k)
    
for k in tgtDict:
    x_tgt.append(int(k))
    y_tgt.append(int(tgtDict[k]))
    x_tgt_label.append(k)

# print x_min
# print y_min
# print x_tgt
# print y_tgt

xlabel = "version"
ylabel = "count"
title = "Goodware" + " Versions Distribution"
output = "goodware" + "_versions.pdf"

n_groups = 1

fig, ax = plt.subplots()

index = np.arange(1)
bar_width = 0.5

opacity = 0.8

pos = 0.5

plt.bar(x_min, 
        y_min, 
        bar_width,
        align='center', 
        alpha=opacity,
        edgecolor = "none", 
        label=x_min)

# Setting axis labels and ticks
ax.grid(False)
for tic in ax.xaxis.get_major_ticks():
    tic.tick1On = tic.tick2On = False
for tic in ax.yaxis.get_major_ticks():
    tic.tick2On = False

ax.set_xticklabels(x_min_label)
plt.title(title)
# plt.legend(loc=0,prop={'size':10},fontsize=font_size_legend)

plt.savefig(output, format='pdf')
