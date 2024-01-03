SKIP += get_consts find_in_array

RAYLEIGHIMP := "from .$(notdir $(LIB)).rayleigh import rayleigh"
RAYCONSTIMP := "from .$(notdir $(LIB)).librayleigh_constants import rayleigh_constants as _rayleigh_constants" --fortran

#Main target
#rayleigh: init librayleigh_constants.so librayleigh.so $(BIN)/process_viirs_color
rayleigh: init $(LIB)/rayleigh.py

$(LIB)/rayleigh.py: $(SRC)/rayleigh/rayleigh.py librayleigh.so librayleigh_constants.so config
	@echo ""
	@echo "----------------------------------"
	@echo Making library: $@
	-ln -s $< $@
	$(ADDIMPORT) $(RAYLEIGHIMP)
	$(ADDIMPORT) $(RAYCONSTIMP)
	$(MODULEDOC) $(SRC)/rayleigh
	@echo "----------------------------------"
	@echo ""

#Libraries with Python bindings
librayleigh.so: rayleigh.f90 process_color.o config.o string_operations.o rayleigh_constants.o modis_rayleigh_constants.o viirs_rayleigh_constants.o himawari8_ahi_rayleigh_constants.o goes16_abi_rayleigh_constants.o goes17_abi_rayleigh_constants.o rayleigh_chan_constants.o config.o prettyprint.o
#SWITCH BACK AFTER FIGURING OUT "USE" IN F2PY
librayleigh_constants.so: rayleigh_constants.f90 config.o string_operations.o modis_rayleigh_constants.o viirs_rayleigh_constants.o himawari8_ahi_rayleigh_constants.o goes16_abi_rayleigh_constants.o goes17_abi_rayleigh_constants.o rayleigh_chan_constants.o
#rayleigh_constants.so: $(rayleighOBJ) $(LIB)/libgeoips.a(constants.o) rayleigh/rayleigh_constants.f90


#Object dependancies
process_color.o: process_color.f90 config.mod rayleigh_constants.mod prettyprint.o
#SWITCH BACK AFTER FIGURING OUT "USE" IN F2PY
rayleigh_constants.o: rayleigh_constants.f90 string_operations.mod modis_rayleigh_constants.mod viirs_rayleigh_constants.mod himawari8_ahi_rayleigh_constants.mod goes16_abi_rayleigh_constants.mod goes17_abi_rayleigh_constants.mod config.o
modis_rayleigh_constants.o: modis_rayleigh_constants.f90 rayleigh_chan_constants.mod
viirs_rayleigh_constants.o: viirs_rayleigh_constants.f90 rayleigh_chan_constants.mod
himawari8_ahi_rayleigh_constants.o: himawari8_ahi_rayleigh_constants.f90 rayleigh_chan_constants.mod
goes16_abi_rayleigh_constants.o: goes16_abi_rayleigh_constants.f90 rayleigh_chan_constants.mod
goes17_abi_rayleigh_constants.o: goes17_abi_rayleigh_constants.f90 rayleigh_chan_constants.mod
rayleigh_chan_constants.o: config.o

.PHONY: clean_rayleigh
clean_rayleigh:
	@echo ""
	@echo "----------------------------------"
	@echo "Cleaning Rayleigh"
	@echo ""
	-rm $(LIB)/librayleigh_constants.so
	-rm $(LIB)/librayleigh.so
	-rm $(LIB)/rayleigh.py
	$(DELIMPORT) $(RAYLEIGHIMP)
	$(DELIMPORT) $(RAYCONSTIMP)
	@echo "----------------------------------"
