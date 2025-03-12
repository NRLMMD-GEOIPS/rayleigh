#!/bin/env python

for fname in ['ch01','ch02','ch03','ch04']:

    fp = open('AMI_GEOKOMPSAT-2A_rayleigh_'+fname+'.dat','r')
    outf = open('AMI_GEOKOMPSAT-2A_rayleigh_'+fname+'_GeoIPS.dat','w')

    newline = []

    for line in fp:
        newline += line.split()
        if len(newline) == 3:
            newline = []
        elif len(newline) == 19:
            outf.write(' '.join(newline)+'\n')
            newline = []
        elif len(newline) == 37:
            outf.write(' '.join(newline)+'\n')
            newline = []
