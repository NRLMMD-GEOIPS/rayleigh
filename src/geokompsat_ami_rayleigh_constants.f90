MODULE geokompsat_ami_rayleigh_constants
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
    character(len=64), parameter, dimension(4) :: geokompsat_ami_chan_names = &
        (/ 'VI004Rad', 'VI005Rad', 'VI006Rad', 'VI008Rad' /)

    TYPE(ChanConsts), DIMENSION(4) :: geokompsat_ami_chan_consts = (/ &
        ! Channel M03
        ! Make sure BLU/GRN/RED/VNIR is right - wavelengths match fci?
        !   I think B01 matches the constants (just need to check on RGBV)
        ChanConsts('BLU', &         !colorgun
                   'VI004Rad', &    !chname
                   200.080, &       !f_sun
                   -999.999, &      !f_sun_adj
                   0.187964, &      !ray_taus
                   0.142523, &      !raysa
                   0.0166342, &     !aoz
                   0.0, &           !awv
                   0.0, &           !ao2
                   0.0015588241), & !c0
        ! Channel M04
        ChanConsts('GRN', &
                   'VI005Rad', &
                   189.201, &
                   -999.999, &
                   0.134059, &
                   0.107953, &
                   0.0408352, &
                   0.0, &
                   0.0, &
                   0.0016611941), &
        ! Channel M05
        ChanConsts('RED', &
                   'VI006Rad', &
                   163.206, &
                   -999.999, &
                   0.0572842, &
                   0.0511178, &
                   0.0592310, &
                   0.00336870, &
                   0.0, &
                   0.0019254997), &
        ChanConsts('VNIR', &
                   'VI008Rad', &
                   97.745, &
                   -999.999, &
                   0.0157040, &
                   0.015079, &
                   0.00492040, &
                   0.00560000, &
                   0.0, &
                   0.0032324977) &
        /)
END MODULE geokompsat_ami_rayleigh_constants

