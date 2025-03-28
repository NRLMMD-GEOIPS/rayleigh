#!/bin/env python

for fname in ["ch01", "ch02", "ch03", "ch04"]:

    fp = open("FCI_MTG1_rayleigh_" + fname + "_v1.dat", "r")
    outf = open("FCI_MTG1_rayleigh_" + fname + "_GeoIPS.dat", "w")

    newline = []

    for line in fp:
        newline += line.split()
        if len(newline) == 3:
            newline = []
        elif len(newline) == 19:
            outf.write(" ".join(newline) + "\n")
            newline = []
        elif len(newline) == 37:
            outf.write(" ".join(newline) + "\n")
            newline = []
