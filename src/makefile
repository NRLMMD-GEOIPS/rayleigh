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

REPO_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
REPO_DIR:=$(shell dirname $(realpath $(REPO_DIR)))

LIB=$(REPO_DIR)/rayleigh/lib
INC=$(REPO_DIR)/rayleigh/inc

FORTRAN_UTILS_LIB=${GEOIPS_DEPENDENCIES_DIR}/share/lib/fortran_utils
FORTRAN_UTILS_INC=${GEOIPS_DEPENDENCIES_DIR}/share/inc/fortran_utils

FINCS = -I. -I$(INC) -I$(FORTRAN_UTILS_INC)
FLIBS = -L. -L$(LIB) -L$(FORTRAN_UTILS_LIB)

ifeq ('$(GEOIPS_FORTRAN_COMPILER)','ifort')
FC = ifort
F2P_COMPILER_FLAGS = --fcompiler=intelem --compiler=intelem
FFLAGS = -warn all -fPIC -O3 -module $(INC) $(FLIBS) $(FINCS)
else
FC = gfortran
F2P_COMPILER_FLAGS = --fcompiler=gnu95
FFLAGS = -Wall -fPIC -O3 -J$(INC) $(FLIBS) $(FINCS)
endif

#F2PCFLAGS = --fcompiler=$(FCNAME) --f90flags='-fopenmp' -lgomp --quiet --opt="-O3" $(FLIBS) $(FINCS)
# F2PCFLAGS = --fcompiler=$(FCNAME) --quiet --opt="-O3" $(FLIBS) $(FINCS)
F2PCFLAGS = $(F2P_COMPILER_FLAGS) --opt="-O3" $(FLIBS) $(FINCS)

#Libraries with Python bindings
$(LIB)/librayleigh.so: rayleigh.f90 $(LIB)/process_color.o $(LIB)/rayleigh_constants.o $(LIB)/modis_rayleigh_constants.o $(LIB)/viirs_rayleigh_constants.o $(LIB)/himawari8_ahi_rayleigh_constants.o $(LIB)/geokompsat_ami_rayleigh_constants.o $(LIB)/meteosat12_fci_rayleigh_constants.o $(LIB)/goes16_abi_rayleigh_constants.o $(LIB)/goes17_abi_rayleigh_constants.o $(LIB)/rayleigh_chan_constants.o $(FORTRAN_UTILS_LIB)/config.o $(FORTRAN_UTILS_LIB)/prettyprint.o $(FORTRAN_UTILS_LIB)/string_operations.o

$(LIB)/librayleigh_constants.so: rayleigh_constants.f90 $(LIB)/modis_rayleigh_constants.o $(LIB)/viirs_rayleigh_constants.o $(LIB)/himawari8_ahi_rayleigh_constants.o $(LIB)/geokompsat_ami_rayleigh_constants.o $(LIB)/meteosat12_fci_rayleigh_constants.o $(LIB)/goes16_abi_rayleigh_constants.o $(LIB)/goes17_abi_rayleigh_constants.o $(LIB)/rayleigh_chan_constants.o $(FORTRAN_UTILS_LIB)/config.o $(FORTRAN_UTILS_LIB)/prettyprint.o $(FORTRAN_UTILS_LIB)/string_operations.o

$(LIB)/process_color.o: process_color.f90 $(FORTRAN_UTILS_INC)/config.mod $(INC)/rayleigh_constants.mod $(FORTRAN_UTILS_LIB)/prettyprint.o

$(LIB)/rayleigh_constants.o: rayleigh_constants.f90 $(LIB)/modis_rayleigh_constants.o $(LIB)/viirs_rayleigh_constants.o $(LIB)/himawari8_ahi_rayleigh_constants.o $(LIB)/geokompsat_ami_rayleigh_constants.o $(LIB)/meteosat12_fci_rayleigh_constants.o $(LIB)/goes16_abi_rayleigh_constants.o $(LIB)/goes17_abi_rayleigh_constants.o $(LIB)/rayleigh_chan_constants.o $(FORTRAN_UTILS_LIB)/config.o $(FORTRAN_UTILS_LIB)/prettyprint.o $(FORTRAN_UTILS_LIB)/string_operations.o

$(INC)/rayleigh_constants.mod: $(LIB)/rayleigh_constants.o

$(LIB)/modis_rayleigh_constants.o: modis_rayleigh_constants.f90 $(INC)/rayleigh_chan_constants.mod

$(LIB)/viirs_rayleigh_constants.o: viirs_rayleigh_constants.f90 $(INC)/rayleigh_chan_constants.mod

$(LIB)/himawari8_ahi_rayleigh_constants.o: himawari8_ahi_rayleigh_constants.f90 $(INC)/rayleigh_chan_constants.mod

$(LIB)/geokompsat_ami_rayleigh_constants.o: geokompsat_ami_rayleigh_constants.f90 $(INC)/rayleigh_chan_constants.mod

$(LIB)/meteosat12_fci_rayleigh_constants.o: meteosat12_fci_rayleigh_constants.f90 $(INC)/rayleigh_chan_constants.mod

$(LIB)/goes16_abi_rayleigh_constants.o: goes16_abi_rayleigh_constants.f90 $(INC)/rayleigh_chan_constants.mod

$(LIB)/goes17_abi_rayleigh_constants.o: goes17_abi_rayleigh_constants.f90 $(INC)/rayleigh_chan_constants.mod

$(LIB)/rayleigh_chan_constants.o: $(FORTRAN_UTILS_LIB)/config.o

$(INC)/rayleigh_chan_constants.mod: $(LIB)/rayleigh_chan_constants.o

#####################################################
### Required builds from other fortran packages
$(FORTRAN_UTILS_LIB)/config.o:
	echo "make -C $(FORTRAN_UTILS)/config $(FORTRAN_UTILS_LIB)/config.o"
	echo "MUST build fortran_utils first"
	exit 1

$(FORTRAN_UTILS_INC)/config.mod:
	echo "make -C $(FORTRAN_UTILS)/config $(FORTRAN_UTILS_LIB)/config.o"
	echo "MUST build fortran_utils first"
	exit 1

$(FORTRAN_UTILS_LIB)/prettyprint.o:
	echo "make -C $(FORTRAN_UTILS)/utils $(FORTRAN_UTILS_LIB)/prettyprint.o"
	echo "MUST build fortran_utils first"
	exit 1

$(FORTRAN_UTILS_LIB)/string_operations.o:
	echo "make -C $(FORTRAN_UTILS)/utils $(FORTRAN_UTILS_LIB)/string_operations.o"
	echo "MUST build fortran_utils first"
	exit 1

#####################################################
### Actual build commands for *.so (f2py) and *.o (gfortran) files
$(LIB)/lib%.so: %.f90
	mkdir -p $(INC) $(LIB)
	touch $(LIB)/__init__.py
	f2py $(F2PCFLAGS) -m lib$* -c $?
	mv lib$**.so $(LIB)/lib$*.so

$(LIB)/%.o: %.f90
	mkdir -p $(INC) $(LIB)
	touch $(LIB)/__init__.py
	# This also creates $(INC)/$*.mod
	$(FC) -c $(FFLAGS) $< -o $@

clean:
	rm -rfv $(REPO_DIR)/rayleigh/lib/__pycache__/
	rm -fv $(REPO_DIR)/rayleigh/lib/*
	rm -fv $(REPO_DIR)/rayleigh/inc/*
