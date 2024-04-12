 | # # # Distribution Statement A. Approved for public release. Distribution unlimited.
 | # # #
 | # # # Author:
 | # # # Naval Research Laboratory, Marine Meteorology Division
 | # # #
 | # # # This program is free software: you can redistribute it and/or modify it under
 | # # # the terms of the NRLMMD License included with this program. This program is
 | # # # distributed WITHOUT ANY WARRANTY; without even the implied warranty of
 | # # # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the included license
 | # # # for more details. If you did not receive the license, for more information see:
 | # # # https://github.com/U-S-NRL-Marine-Meteorology-Division/

Rayleigh Scattering
===================
The :func:`rayleigh <geoalgs.rayleigh>` function is a generalized method for applying a rayleigh
scattering correction to satellite data.  Currently this function is capable of handling MODIS
and VIIRS data.  Input channels must be any combination of blue, green, red, and near infrared (NIR).

The return value will be an array of the same size as the input radiances array whose values have
been converted from radiances to reflectances.  The output array's channels will be in same order
as the input array.

Input Data
++++++++++
All input strings are case insensitive.

All angles variables should be in degrees.

All input arrays must have the same first (`lines`) and second (`samples`) dimension sizes.
The third (`nchans`) dimension of the radiances array indicates the number of channels
that the rayleigh correction will be applied to.  These channels can include blue, green,
red, and near infrared channels.

Accepted VIIRS channels:

* Blue:  moderate band 3
* Green: moderate band 4
* Red:   moderate band 5
* NIR:   moderate band 7

Accepted MODIS channels:

* Blue:  band 3
* Green: band 4
* Red:   band 1
* NIR:   band 2

Output Data:
++++++++++++
The output data will be an array of the form `reflectances(lines, samples, nchans)`.
The output reflectances datasets will be in the same order as in the input radiances array.

Calling :func:`geoalgs.rayleigh`
++++++++++++++++++++++++++++++++

.. warning:: Due to some magic performed by python and f2py, dimension information does not need to be passed
             to the function and **likely should not be passed**.  If passed they must match the dimensions of the input
             arrays exactly.

.. function:: geoalgs.rayleigh(sensor, chan_names, jday, radiances, sat_zen, sun_zen, rel_azm[, nchans, lines, samples])

    :param sensor: Name of the input data's sensor
    :type sensor: str
    :param chan_names: Array the names of the channels whose data is contained in the `radiances` array
    :type chan_names: array of str
    :param jday: Julian day of year
    :type jday: int
    :param radiances: 3-D array of radiances *(lines, samples, nchans)*
    :type radiances: array of floats
    :param sat_zen: 2-D array of satellite zenith angles *(lines, samples)*
    :type sat_zen: array of floats
    :param sun_zen: 2-D array of solar zenith angles *(lines, samples)*
    :type sun_zen: array of floats
    :param rel_azm: 2-D array of relative azimuth angles *(lines, samples)*
    :type rel_azm: array of floats
    :param nchans: Number of channels in the input `radiances` dataset
    :type nchans: int or assumed
    :param lines: Number of lines in the input `radiances` dataset
    :type lines: int or assumed
    :param samples: Number of samples in the input `radiances` dataset
    :type samples: int or assumed


.. note:: `chan_names` must be in the same order as the input `radiances`
