MODULE himawari8_ahi_rayleigh_constants
    !***********************************
    ! This module defines an object containing ChanConsts objects.
    ! Each ChanConsts object describes the parameters needed to perform
    !   a Rayleigh scattering correction on a specific channel.
    ! To add a new channel, simply add a new element to this object.
    ! The fields in each element are:
    !   f_sun, ray_taus, raysa, aoz, awv, ao2
    ! These constants were taken from Steve Miller's original
    !   Rayleigh scattering code located in:
    !   /data/users/processing/postprocs/modis/FOCUS_HDFLINK/TRUE_VEG_DUST_1KM_HDF/PROGS/process_modis_color.f90
    !
    ! Jeremy Solbrig - 20121025
    !***********************************
    USE rayleigh_chan_constants

    ! B13 is used to scale B1-4, but does not get corrected.
    ! So must be included in list of channels in productfile, and rayleigh.py,
    !   but not in here because these are the channels that actually 
    !   get corrected.

    character(len=64), parameter, dimension(4) :: himawari8_ahi_chan_names = &
        (/ 'B01Rad', 'B02Rad', 'B03Rad', 'B04Rad' /)

    TYPE(ChanConsts), DIMENSION(4) :: himawari8_ahi_chan_consts = (/ &
        ! Channel M03
        ! Make sure BLU/GRN/RED/VNIR is right - wavelengths match ahi?
        !   I think B01 matches the constants (just need to check on RGBV)
        ChanConsts('BLU', &         !colorgun
                   'B01Rad', &    !chname
                   200.036, &       !f_sun
                   -999.999, &      !f_sun_adj
                   0.188628, &      !ray_taus
                   0.142926, &      !raysa
                   0.0164524, &     !aoz
                   0.0, &           !awv
                   0.0, &           !ao2
                   0.0015588241), & !c0
        ! Channel M04
        ChanConsts('GRN', &
                   'B02Rad', &
                   188.965, &
                   -999.999, &
                   0.132874, &
                   0.107150, &
                   0.0416672, &
                   0.0, &
                   0.0, &
                   0.0016611941), &
        ! Channel M05
        ChanConsts('RED', &
                   'B03Rad', &
                   163.114, &
                   -999.999, &
                   0.0580715, &
                   0.0517576, &
                   0.0599593, &
                   0.00331391, &
                   0.0, &
                   0.0019254997), &
        ChanConsts('VNIR', &
                   'B04Rad', &
                   96.848, &
                   -999.999, &
                   0.0163772, &
                   0.0157037, &
                   0.00515272, &
                   0.00527000, &
                   0.0, &
                   0.0032324977) &
        /)
END MODULE himawari8_ahi_rayleigh_constants

