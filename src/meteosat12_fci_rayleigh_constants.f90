MODULE meteosat12_fci_rayleigh_constants
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
    ! Evan Rose - 20241219
    !***********************************
    USE rayleigh_chan_constants

    ! B13 is used to scale B1-4, but does not get corrected.
    ! So must be included in list of channels in productfile, and rayleigh.py,
    !   but not in here because these are the channels that actually
    !   get corrected.

    character(len=64), parameter, dimension(4) :: meteosat12_fci_chan_names = &
        (/ 'B01Rad', 'B02Rad', 'B03Rad', 'B04Rad' /)

    TYPE(ChanConsts), DIMENSION(4) :: meteosat12_fci_chan_consts = (/ &
        ! Channel M03
        ! Make sure BLU/GRN/RED/VNIR is right - wavelengths match fci?
        !   I think B01 matches the constants (just need to check on RGBV)
        ChanConsts('BLU', &         !colorgun
                   'B01Rad', &    !chname
                   188.415, &       !f_sun
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
                   189.339, &
                   -999.999, &
                   0.126288, &
                   0.102648, &
                   0.0502208, &
                   0.000128, &
                   0.0, &
                   0.0016611941), &
        ! Channel M05
        ChanConsts('RED', &
                   'B03Rad', &
                   163.516, &
                   -999.999, &
                   0.0565844, &
                   0.0505479, &
                   0.0585837, &
                   0.00341739, &
                   0.0, &
                   0.0019254997), &
        ChanConsts('VNIR', &
                   'B04Rad', &
                   98.653, &
                   -999.999, &
                   0.0167240, &
                   0.0160246, &
                   0.00527240, &
                   0.0051, &
                   0.0, &
                   0.0032324977) &
        /)
END MODULE meteosat12_fci_rayleigh_constants

