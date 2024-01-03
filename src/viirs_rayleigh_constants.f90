MODULE viirs_rayleigh_constants
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

!NRL and FNMOC use different variable names.
!Rely on the preprocessor to determine which based on whether -DIAMFNMOC was
!passed on compile.
!#ifdef IAMFNMOC
!    !FNMOC style names
!    character(len=64), parameter, dimension(4) :: viirs_chan_names = &
!        (/ 'M03', 'M04', 'M05', 'M07' /)
!    character(len=64), parameter, dimension(4) :: viirs_ref_names = &
!        (/ 'M03', 'M04', 'M05', 'M07' /)
!#else
!    !NRL style names
!    character(len=64), parameter, dimension(4) :: viirs_chan_names = &
!        (/ 'SVM03Rad', 'SVM04Rad', 'SVM05Rad', 'SVM07Rad' /)
!    character(len=64), parameter, dimension(4) :: viirs_ref_names = &
!        (/ 'SVM03Ref', 'SVM04Ref', 'SVM05Ref', 'SVM07Ref' /)
!#endif

    !NRL style names
    character(len=64), parameter, dimension(4) :: viirs_chan_names = &
        (/ 'M03Rad', 'M04Rad', 'M05Rad', 'M07Rad' /)
    character(len=64), parameter, dimension(4) :: viirs_ref_names = &
        (/ 'M03Ref', 'M04Ref', 'M05Ref', 'M07Ref' /)

    TYPE(ChanConsts), DIMENSION(4) :: viirs_chan_consts = (/ &
        ! Channel M03
        ChanConsts('BLU', &         !colorgun
                   viirs_ref_names(1), &    !chname
                   194.142, &       !f_sun
                   -999.999, &      !f_sun_adj
                   0.159419, &      !ray_taus
                   0.124679, &      !raysa
                   0.0244511, &     !aoz
                   0.0, &           !awv
                   0.0, &           !ao2
                   0.0000244174153), &!c0
        ! Channel M04
        ChanConsts('GRN', &
                   viirs_ref_names(2), &
                   185.93, &
                   -999.999, &
                   0.0942, &
                   0.0797469, &
                   0.09338, &
                   0.0008, &
                   0.0, &
                   0.0000244174153), &
        ! Channel M05
        ChanConsts('RED', &
                   viirs_ref_names(3), &
                   151.538, &
                   -999.999, &
                   0.04352, &
                   0.0396954, &
                   0.04604, &
                   0.00422421, &
                   0.0, &
                   0.0000244174153), &
        ! Channel M07
        ChanConsts('VNIR', &
                   viirs_ref_names(4), &
                   100.0, &
                   -999.999, &
                   0.0155, &
                   0.01489, &
                   0.00485, &
                   0.0057, &
                   0.0, &
                   0.0000244174153) &
        /)
END MODULE viirs_rayleigh_constants

