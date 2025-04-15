#!/bin/env python

# # # This source code is subject to the license referenced at
# # # https://github.com/NRLMMD-GEOIPS.

for fname in ["ch01", "ch02", "ch03"]:
    fp = open("ABI_GOESR_rayleigh_" + fname + ".dat", "r")
    outf = open("ABI_GOESR_rayleigh_" + fname + "_GeoIPS.dat", "w")

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
