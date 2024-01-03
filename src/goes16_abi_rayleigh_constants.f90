MODULE goes16_abi_rayleigh_constants
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

    character(len=64), parameter, dimension(3) :: goes16_abi_chan_names = &
        (/ 'B01Rad', 'B02Rad', 'B03Rad' /)

    TYPE(ChanConsts), DIMENSION(3) :: goes16_abi_chan_consts = (/ &
        ! Channel M03
        ! Make sure BLU/GRN/RED/VNIR is right - wavelengths match abi?
        !   I think B01 matches the constants (just need to check on RGBV)
        ChanConsts('BLU', &         !colorgun
                   'B01Rad', &    !chname
                   199.852, &       !f_sun
                   -999.999, &      !f_sun_adj
                   0.187798, &      !ray_taus
                   0.142422, &      !raysa
                   0.0166797, &     !aoz
                   0.0, &           !awv
                   0.0, &           !ao2
                   0.0015771), &    !c0
        ! Channel M05
        ChanConsts('RED', &
                   'B02Rad', &
                   163.004, &
                   -999.999, &
                   0.0578528, &
                   0.0597570, &
                   0.0597570, &
                   0.00332913, &
                   0.0, &
                   0.0019501), &
        ChanConsts('VNIR', &
                   'B03Rad', &
                   97.422, &
                   -999.999, &
                   0.0155816, &
                   0.0149658, &
                   0.00487816, &
                   0.00566000, &
                   0.0, &
                   0.003324) &
        /)
END MODULE goes16_abi_rayleigh_constants

