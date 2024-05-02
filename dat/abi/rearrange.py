#!/bin/env python

# # # Distribution Statement A. Approved for public release. Distribution unlimited.
# # #
# # # Author:
# # # Naval Research Laboratory, Marine Meteorology Division
# # #
# # # This program is free software: you can redistribute it and/or modify it under
# # # the terms of the NRLMMD License included with this program. This program is
# # # distributed WITHOUT ANY WARRANTY; without even the implied warranty of
# # # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the included license
# # # for more details. If you did not receive the license, for more information see:
# # # https://github.com/U-S-NRL-Marine-Meteorology-Division/

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
