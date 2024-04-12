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

"""
This python3-based geoips code is developed from the geoips1-based rayleigh.py.
Input fields and associated infomation are reorganized to fit GEOIPS platform
"""

# Python Standard Libraries
import logging

LOG = logging.getLogger(__name__)

# Installed Libraries
import numpy as np


# GeoIPS Libraries
# from geoips.lib.librayleigh import rayleigh    #this is the fortrain-based rayleigh correction lib.
# from geoips.utils.log_setup import interactive_log_setup


# log = interactive_log_setup(logging.getLogger(__name__))


##################################################################
#  The variable names MUST be the same length !!!
#  Pad with spaces on the right hand side to make them the same length.
#  Added strip() to data_file.variables(var_map[color]) so it reads the right variable.
##################################################################

viirs_var_map = {
    "BLU": "M03Rad",
    "GRN": "M04Rad",
    "RED": "M05Rad",
    "NIR": "M07Rad",
    "SATZEN": "satellite_zenith_angle",
    "SUNZEN": "solar_zenith_angle",
    "SATAZM": "satellite_azimuth_angle",
    "SUNAZM": "solar_azimuth_angle",
}
modis_var_map = {
    "BLU": "chan3.0Rad",
    "GRN": "chan4.0Rad",
    "RED": "chan1.0Rad",
    "NIR": "chan2.0Rad",
    "SATZEN": "satellite_zenith_angle",
    "SUNZEN": "solar_zenith_angle",
    "SATAZM": "satellite_azimuth_angle",
    "SUNAZM": "solar_azimuth_angle",
}
ahi_var_map = {
    "BLU": "B01Rad",
    "GRN": "B02Rad",
    "RED": "B03Rad",
    "NIR": "B04Rad",
    "IR": "B13BT ",
    "SATZEN": "satellite_zenith_angle",
    "SUNZEN": "solar_zenith_angle",
    "SATAZM": "satellite_azimuth_angle",
    "SUNAZM": "solar_azimuth_angle",
}
abi_var_map = {
    "BLU": "B01Rad",
    "RED": "B02Rad",
    "NIR": "B03Rad",
    "IR": "B13BT ",
    "SATZEN": "satellite_zenith_angle",
    "SUNZEN": "solar_zenith_angle",
    "SATAZM": "satellite_azimuth_angle",
    "SUNAZM": "solar_azimuth_angle",
}

sensor_var_maps = {
    "viirs": viirs_var_map,
    "modis": modis_var_map,
    "ahi": ahi_var_map,
    "abi": abi_var_map,
}

LOG.info("finishing setup selection of sensor channels %s", ahi_var_map)


def rayleigh(xobj):
    """Using xarray variables implemented in geoips"""
    source_name = xobj.source_name
    platform_name = xobj.platform_name
    start_datetime = xobj.start_datetime

    try:
        var_map = sensor_var_maps[source_name]
    except KeyError:
        raise ValueError(
            "Unrecognized sensor %s.  Accepted sensors include: %s"
            % (source_name, ", ".join(sensor_var_maps.keys()))
        )

    # Gather the correct data into the correct variables for each variable
    color_names = []
    var_names = []
    rad_data = []
    try:
        rad_data.append(xobj[var_map["RED"].strip()])
        color_names.append("RED")
        var_names.append(var_map["RED"])
    except KeyError:
        pass
    try:
        rad_data.append(xobj[var_map["GRN"].strip()])
        color_names.append("GRN")
        var_names.append(var_map["GRN"])
    except KeyError:
        pass
    try:
        rad_data.append(xobj[var_map["BLU"].strip()])
        color_names.append("BLU")
        var_names.append(var_map["BLU"])
    except KeyError:
        pass

    try:
        rad_data.append(xobj[var_map["NIR"].strip()])
        color_names.append("NIR")
        var_names.append(var_map["NIR"])
    except KeyError:
        pass

    # Moving IR to an optional argument rather than joining it to the rest of the variables
    #       for abi and ahi only
    try:
        lwir = xobj[var_map["IR"].strip()]
    except KeyError:
        pass

    rad_data = np.ma.dstack(
        rad_data
    )  # stack the thes fields into a multi-dimentional xobj

    # See if we need to calculate angles now
    # has_key is not available in python 3
    dosatzen = False
    dosunzen = False
    dorelazm = False
    if var_map["SATZEN"] not in xobj.keys():
        LOG.info("    Going to calculate satellite_zenith_angle")
        dosatzen = True
    if var_map["SUNZEN"] not in xobj.keys():
        LOG.info("    Going to calculate solar_zenith_angle")
        dosunzen = True
    if (
        "SUNAZM" in var_map.keys()
        and "SATAZM" in var_map.keys()
        and var_map["SUNAZM"] not in xobj.keys()
        and var_map["SATAZM"] not in xobj.keys()
    ):
        LOG.info("    Going to calculate RelAzimuth")
        dorelazm = True

    # Apply satsuncalc package to estimate satellite_zenith_angle, solar_zenith_angle and relative Azimuth if they are not available
    #       For VIIRS, Modis, AHI and ABI, these variables are present after output from their readers.
    #       Thus, the following call of satsuncalc is not really needed, but included for a complete code.
    #       However, if satsuncalc is used, you must first install this package, which requires another package:
    #       pass_prediction.  Thus, pass_prediction package should be also installed.
    # Note:  since pass_predition will not be installed for geoips for now, the following section is commented out.
    """ 
    if dosatzen or dosunzen or dorelazm:
        print ('call the satsuncalc.py in the satsuncalc package : waiting for pass_prediction package')
        shell()
        from satsuncalc import satsuncalc
        sat_zenith, sat_azimuth, sun_zenith, sun_azimuth, rel_azimuth, sunglint, scatter = \
            satsuncalc.satsuncalc(platform_name,
                       start_datetime,
                       xobj['longitude'],
                       xobj['latitude'],
                       dosatzen=dosatzen,
                       dosunzen=dosunzen,
                       dorelazm=dorelazm)
    """
    # Fill in from xobj if there.
    if not dosatzen:
        LOG.info("    Using satellite_zenith_angle from input xobj")
        sat_zenith = xobj[var_map["SATZEN"]]
    if not dosunzen:
        LOG.info("    Using solar_zenith_angle from input xobj")
        sun_zenith = xobj[var_map["SUNZEN"]]
    if not dorelazm:
        if "SATAZM" in var_map.keys() and "SUNAZM" in var_map.keys():
            LOG.info(
                "    Using satellite_azimuth_angle and solar_azimuth_angle from input xobj to get RelAzimuth"
            )
            delta = xobj[var_map["SUNAZM"]] - xobj[var_map["SATAZM"]]
            delta = np.where(delta >= 360, delta - 360, delta)
            delta = np.where(delta < 0, delta + 360, delta)
            rel_azimuth = np.abs(delta - 180)
        else:
            raise ValueError("No path specified for azimuth angle data.")

    if not len(rad_data):
        raise ValueError("No correctable fields found in input xobj.")

    save_mask = rad_data.mask
    LOG.info(str(var_names) + " len(rad_data) " + str(rad_data.shape))

    # Build a list of the arguments to be passed to the rayleigh correction fortran routine
    rayleigh_args = [
        source_name,
        platform_name,
        var_names,
        int(start_datetime.strftime("%j")),
        rad_data,
        sat_zenith,
        sun_zenith,
        rel_azimuth,
    ]
    rayleigh_kwargs = {}

    # If we have it, pass the longwave IR data as a keyword argument
    try:
        rayleigh_kwargs["infrared"] = lwir
    except NameError:
        pass

    # rad_data(nx,ny,chans):  chans(Red, Grn, Blu)
    # call the fortrain-based raileigh function, which is not same rayleigh function defined in this ocde.
    # subroutine rayleigh(nchans, lines, samples, sensor, platform, chan_names, jday, &
    #                radiances, sat_zen, sun_zen, rel_azm, infrared, reflectances)
    # Python call signature:
    #   reflectances = rayleigh(nchans, lines, samples, sensor, platform, chan_names,
    #                           jday, radiances, sat_zen, sun_zen, rel_azm)

    from rayleigh.lib.librayleigh import (
        rayleigh,
    )  # this is to call the fortrain-based rayleigh correction lib.

    ref_data = rayleigh(*rayleigh_args, **rayleigh_kwargs)

    # Only need RGB for final image.
    ref_data = np.ma.array(ref_data, mask=save_mask)
    out_data = {}
    for cind, color_name in enumerate(color_names):
        out_data[color_name] = ref_data[:, :, cind]

    return out_data
