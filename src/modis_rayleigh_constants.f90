MODULE modis_rayleigh_constants
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

    CHARACTER(LEN=64), DIMENSION(4) :: modis_chan_names = &
        (/ 'chan1.0Rad', 'chan2.0Rad', 'chan3.0Rad', 'chan4.0Rad' /)
    TYPE(ChanConsts), DIMENSION(4) :: modis_chan_consts = (/ &
        ! modis_ch01
        ChanConsts('RED', &           !colorgun
                   'chan1.0Rad', &    !chname
                   160.2, &           !f_sun
                   -999.999, &        !f_sun_adj
                   0.05131, &         !ray_taus
                   0.0492007, &       !raysa
                   0.056965, &        !aoz
                   0.003539, &        !awv
                   0.0, &             !ao2
                   0.00201941), &     !c0
        ! modis_ch02
        ChanConsts('VNIR', &
                   'chan2.0Rad', &
                   99.1, &
                   -999.999, &
                   0.01657, &
                   0.017137, &
                   0.0052724, &
                   0.0051, &
                   0.0, &
                   0.00327573), &
        ! modis_ch03
        ChanConsts('BLU', &
                   'chan3.0Rad', &
                   202.3, &
                   -999.999, &
                   0.189789, &
                   0.142865, &
                   0.015816, &
                   0.0, &
                   0.0, &
                   0.00155510), &
        ! modis_ch04
        ChanConsts('GRN', &
                   'chan4.0Rad', &
                   186.0, &
                   -999.999, &
                   0.09490, &
                   0.0801539, &
                   0.09338, &
                   0.0008, &
                   0.0, &
                   0.00173456) &
        /)
END MODULE modis_rayleigh_constants
