SUBROUTINE process_color(sensor, platform, chan_names, lines, samples, nchans, &
                         jday, radiances, sat_zen, sun_zen, rel_azm, &
                         infrared, ref)
    !-------------------------------------------------------------------------------------------
    ! This subroutine is the main subroutine used to generically apply rayleigh
    ! scattering correction to satellite data.  Currently this package is
    ! capable of handling MODIS and VIIRS data.
    !
    ! NOTE:  This routine performs most of the correction, however, it is kept
    ! separate from rayleigh_correction.f90 in order to allow for the needs of
    ! the forthcoming Bluelight Dust enhancement and to allow backwards
    ! compatability with CIRA's code.  This may be combined into
    ! rayleigh_correction.f90 in the future.
    !
    ! Inputs:
    !   sensorName - Name of the input data's sensor as a string of up to length
    !                name_size (defined in share/geoalgs_constants.f90.  
    !                Currently only accepts "MODIS" or "VIIRS".
    !   platform   - Name of the input data's platform as a string.
    !   chan_names - An array of strings corresponding to the name of each
    !                in the same order as the data in the "radiances" array.
    !                This is used to determine which channel constants to
    !                associate with each channel array in "radiances" when
    !                calculating the correction.  NOTE:  These channel names
    !                must be of the length specified by name_size in
    !                rayleigh_constants.py.  If the strings are initially
    !                shorter, they must be padded with spaces on the right hand
    !                side of each string prior to passing to this routine.
    !   lines      - Integer number of lines in the dataset.
    !   samples    - Integer number of samples in the dataset.
    !   nchans     - Number of channels in the dataset (third dimension of
    !                radiances array)
    !   jday       - Integer julian day of year.
    !   radiances  - Three dimensional array of radiances.
    !                (lines, samples, nchans)
    !   sat_zen    - Two dimensional array of satellite zenith angles.
    !                (lines, samples)
    !   sun_zen    - Two dimensional array of solar zenith angles.
    !                (lines, samples)
    !   rel_azm    - Two dimensional array of relative azimuth angles.
    !                (lines, samples) Range [-180, 180]
    !
    ! Python call signature:
    !   ref = process_color(sensorName, chan_names, lines,
    !                       samples, nchans, jday, radiances,
    !                       sat_zen, sun_zen, rel_azm)
    !
    ! This routine is written as a subroutine in order to allow it to be
    ! compiled using f2py.  Doing so allows the subroutine to be imported by
    ! python routines and used as a normal python module.  Calls to compile this
    ! routine are available in ../Makefile.  Compiling this routine will produce
    ! process_color.so.  To import from process_color.so simply use the
    ! following iimport in Python:
    !
    !   from process_color import process_color
    !
    ! IMPORTANT NOTES:
    ! Typically in Fortran we are able to make use of ALLOCATE statements to
    ! handle dynamic array sizes.  When using F2Py, however, this is not
    ! possible.  All ALLOCATEs must be stripped out of the code.  As a
    ! consequence, there are more required inputs than would typically be
    ! expected.  For instance, "lines" and "samples" are required inputs in
    ! order to determine the shape of the various input arrays.  Normally these
    ! values could be inferred and the arrays could be allocated dynamically,
    ! however, when using F2Py, this is not possible and the values must be
    ! known a priori and passed.
    !
    ! As noted previously, since Fortran cannot handle normal Python arrays of
    ! strings, each of the strings in the array passed to chan_names must be
    ! padded on the right hand side with spaces to the length specified by the
    ! name_size parameter in rayleigh_constants.f90.  For an example of this, see
    ! ../rayleigh.py.  There may be a better way to handle this, but I have not
    ! thought of it yet.
    !
    ! REQUIRED FILES (see ../README.txt for descriptions):
    !   string_operations.f90
    !   rayleigh_chan_constants.f90
    !   rayleigh_constants.f90
    !   modis_rayleigh_constants.f90
    !   viirs_rayleigh_constants.f90
    !-------------------------------------------------------------------------------------------

    USE rayleigh_constants
    USE config
    IMPLICIT NONE

    integer, parameter :: bd = 8

    !***************************************************************
    ! INPUTS
    !***************************************************************
    ! Dataset dimentions
    INTEGER(bd), INTENT(IN)     :: lines
    INTEGER(bd), INTENT(IN)     :: samples
    INTEGER(bd), INTENT(IN)     :: nchans
    INTEGER(bd), INTENT(IN)     :: jday
    ! Identifying information
    CHARACTER(len=*), INTENT(IN)   :: sensor, platform
    CHARACTER(len=*), DIMENSION(nchans), INTENT(IN) :: chan_names
    ! Input Datasets
    REAL(bd), DIMENSION(lines, samples, nchans), INTENT(IN) :: radiances
    REAL(bd), DIMENSION(lines, samples), INTENT(IN) :: sat_zen
    REAL(bd), DIMENSION(lines, samples), INTENT(IN) :: sun_zen
    REAL(bd), DIMENSION(lines, samples), INTENT(IN) :: rel_azm
    REAL(bd), DIMENSION(lines, samples), INTENT(IN) :: infrared

    !***************************************************************
    ! OUTPUT
    !***************************************************************
    REAL(bd), DIMENSION(lines, samples, nchans) :: rad
    REAL(bd), DIMENSION(lines, samples, nchans), INTENT(OUT) :: ref

    !***************************************************************
    ! DERIVED TYPES CONTAINING CHANNEL INFORMATION
    !***************************************************************
    TYPE(ChanConsts), DIMENSION(nchans) :: chan_consts

    !***************************************************************
    ! INTERNAL VARIABLES
    !***************************************************************
    ! Counters
    INTEGER(bd) :: sind,ii,jj
    INTEGER(bd) :: lind
    INTEGER(bd) :: cind
    ! Indices returned by locate()
    INTEGER(bd) :: isat
    INTEGER(bd) :: iazm
    INTEGER(bd) :: isun
    ! Calculated values
    REAL(bd) :: sun_earth_distance
    REAL(bd) :: sat_zen_pix
    REAL(bd) :: sun_zen_pix
    REAL(bd) :: rel_azm_pix
    REAL(bd) :: frac_sat
    REAL(bd) :: frac_rel_azm
    REAL(bd) :: frac_sun
    REAL(kind=4) :: currref,min_log_ref,max_log_ref
    REAL(bd), DIMENSION(lines, samples) :: HH,mublend,blendfactor,blendfactor2,currtro,sunzen_thr
    REAL(bd), DIMENSION(nchans) :: term_11
    REAL(bd), DIMENSION(nchans) :: term_12
    REAL(bd), DIMENSION(nchans) :: term_21
    REAL(bd), DIMENSION(nchans) :: term_22 
    REAL(bd), DIMENSION(lines, samples, nchans) :: ray_ref
    REAL(bd), DIMENSION(lines, samples) :: airmass
    REAL(bd), DIMENSION(lines, samples) :: mu_sat
    REAL(bd), DIMENSION(lines, samples) :: mu_sun
    REAL(bd), DIMENSION(lines, samples) :: tro
    REAL(bd), DIMENSION(lines, samples) :: trayd
    REAL(bd), DIMENSION(lines, samples) :: trayu
    REAL(bd), DIMENSION(lines, samples) :: trans_sun
    REAL(bd), DIMENSION(lines, samples) :: trans_sat
    LOGICAL, DIMENSION(lines, samples) :: good_mask
    ! Data
    REAL(bd), DIMENSION(num_sat_zen) :: sat_zen_tabvals
    REAL(bd), DIMENSION(num_rel_azm) :: rel_azm_tabvals
    REAL(bd), DIMENSION(num_sun_zen) :: sun_zen_tabvals
    REAL(bd), DIMENSION(num_sun_zen, num_rel_azm, num_sat_zen, nchans) :: tabdat
    ! Constant arrays, one element per channel
    REAL(bd), DIMENSION(nchans) :: f_sun
    REAL(bd), DIMENSION(nchans) :: f_sun_adj
    REAL(bd), DIMENSION(nchans) :: ray_taus
    REAL(bd), DIMENSION(nchans) :: raysa
    REAL(bd), DIMENSION(nchans) :: aoz
    REAL(bd), DIMENSION(nchans) :: awv
    REAL(bd), DIMENSION(nchans) :: ao2
    REAL(bd), DIMENSION(nchans) :: c0

    !***************************************************************
    ! f2py Signature Information
    !***************************************************************
    !f2py integer(bd), intent(in) :: lines
    !f2py integer(bd), intent(in) :: samples
    !f2py integer(bd), intent(in) :: nchans
    !f2py integer(bd), intent(in) :: jday
    !f2py character(len=*), intent(in) :: sensor
    !f2py character(len=*), intent(in) :: platform
    !f2py character(len=*), dimension(nchans), intent(in) :: chan_names
    !f2py real(bd), dimension(lines, samples, nchans), intent(in) :: radiances
    !f2py real(bd), dimension(lines, samples), intent(in) :: sat_zen
    !f2py real(bd), dimension(lines, samples), intent(in) :: sun_zen
    !f2py real(bd), dimension(lines, samples), intent(in) :: rel_azm
    !f2py integer(bd), dimension(lines, samples), intent(in) :: land_mask
    !f2py integer(bd), dimension(lines, samples), optional, intent(in) :: infrared(:,:) = -1
    !f2py real(bd), dimension(lines, samples, nchans), intent(out) :: ref


    print *, "Entered process_color.f90 subroutine"

    print *, "Lines     = ", lines
    print *, "Samples   = ", samples
    print *, "NChans    = ", nchans
    print *, "JDay      = ", jday
    print *, "Required channels: ", chan_names

    sun_earth_distance = 1.0-0.016729*cos(0.9856*(jday-4.0)*dtor)
    print *, "Computed sun_earth_distance as: ",sun_earth_distance

    ! Gather channel constants
    CALL get_consts(sensor, platform, chan_names, chan_consts)
    DO cind = LBOUND(chan_consts, 1), UBOUND(chan_consts, 1)
        chan_consts(cind)%f_sun_adj = chan_consts(cind)%f_sun/(sun_earth_distance**2)
        print *, "cind = ", cind
        print *, "  Color Gun = ", chan_consts(cind)%colorgun
        print *, "  Chan Name = ", chan_consts(cind)%chname
        print *, "  f_sun ... = ", chan_consts(cind)%f_sun
        print *, "  f_sun_adj = ", chan_consts(cind)%f_sun_adj
        print *, "  ray_taus  = ", chan_consts(cind)%ray_taus
        print *, "  raysa ... = ", chan_consts(cind)%raysa
        print *, "  aoz ..... = ", chan_consts(cind)%aoz
        print *, "  awv ..... = ", chan_consts(cind)%awv
        print *, "  ao2 ..... = ", chan_consts(cind)%ao2, '\n'
        print *, "  c0 ...... = ", chan_consts(cind)%c0, '\n'
        f_sun(cind)     = chan_consts(cind)%f_sun
        f_sun_adj(cind) = chan_consts(cind)%f_sun_adj
        ray_taus(cind)  = chan_consts(cind)%ray_taus
        raysa(cind)     = chan_consts(cind)%raysa
        aoz(cind)       = chan_consts(cind)%aoz
        awv(cind)       = chan_consts(cind)%awv
        ao2(cind)       = chan_consts(cind)%ao2
        c0(cind)        = chan_consts(cind)%c0
    END DO

    print *, ""


    print *, "max of sat_zen = ", maxval(sat_zen)
    print *, "min of sat_zen = ", minval(sat_zen)
    print *, "max of sun_zen = ", maxval(sun_zen)
    print *, "min of sun_zen = ", minval(sun_zen)
    print *, "max of rel_azm = ", maxval(rel_azm)
    print *, "min of rel_azm = ", minval(rel_azm)
    !print *,"DEBUG: max of land_mask = ", maxval(land_mask)
    !print *,"DEBUG: min of land_mask = ", minval(land_mask)

    rad = radiances

    ! Rayleigh-correct the data
    !
    ! Get lookup tables for these channels
    !
    ! NOTE:  satellite zeniths = 19 angles evenly spaced 0,5,10,...90 
    !        relative azimuths = 37 angles evenly spaced 0,5,10,...180 
    !        solar zeniths     = 19 angles evenly spaced 0,5,10,...90
!    do cind=1, size(chan_consts%colorgun)
!        print *, chan_consts(cind)%colorgun
!    end do
    CALL read_tables(sensor, chan_consts%colorgun, sat_zen_tabvals, rel_azm_tabvals, sun_zen_tabvals, tabdat)

    !print *,"sat_zen_tabvals(:) = ",sat_zen_tabvals(:)
    !print *,"rel_azm_tabvals(:) = ",rel_azm_tabvals(:)
    !print *,"sun_zen_tabvals(:) = ",sun_zen_tabvals(:)
    !print *,"tabdat(:,1,1,1) = ",tabdat(:,1,1,1)
    !print *,"tabdat(:,1,19,1) = ",tabdat(:,1,19,1)

    ! Compute rayleigh-corrected reflectances
    print *,"Computing Rayleigh Correction."
    ! Loop over data, correcting pixel by pixel
    ray_ref = 0.0
    DO lind=1,lines
        DO sind=1,samples
        ! Check for earth-scene data
        !IF (sat_zen(lind,sind) /= -9999. .and. sat_zen(lind,sind) < 89.9 .and. sun_zen(lind,sind) < 89.9) THEN

        ! Get sat/sol/relaz values for this pixel
        sat_zen_pix = sat_zen(lind, sind)
        rel_azm_pix = rel_azm(lind, sind)
        sun_zen_pix = sun_zen(lind, sind)

        !DEBUG
        !    sat_zen_pix = 0.0
        !    rel_azm_pix = 0.0
        !    sun_zen_pix = 87.5
        !  print *,"sat_zen_pix = ",sat_zen_pix
        !  print *,"rel_azm_pix = ",rel_azm_pix
        !  print *,"sun_zen_pix = ",sun_zen_pix

        ! Interpolate tabdat to find the rayleigh component
        call LOCATE(sat_zen_tabvals,num_sat_zen,sat_zen_pix,isat)
        isat = min(num_sat_zen-1,isat)
        isat = max(1,isat)
        !print *,"isat = ",isat

        call LOCATE(rel_azm_tabvals,num_rel_azm,rel_azm_pix,iazm)
        iazm = min(num_rel_azm-1,iazm)
        iazm = max(1,iazm)
        !print *,"iazm = ",iazm

        call LOCATE(sun_zen_tabvals,num_sun_zen,sun_zen_pix,isun)
        isun = min(num_sun_zen,isun)
        isun = max(1,isun)
        !print *,"isun = ",isun

        frac_sat = (sat_zen_pix - sat_zen_tabvals(isat))/(sat_zen_tabvals(isat+1)-sat_zen_tabvals(isat))
        frac_rel_azm = (rel_azm_pix - rel_azm_tabvals(iazm))/(rel_azm_tabvals(iazm+1)-rel_azm_tabvals(iazm))
        frac_sun = (sun_zen_pix - sun_zen_tabvals(isun))/(sun_zen_tabvals(isun+1)-sun_zen_tabvals(isun))

        term_11 = (1.0-frac_sun)*tabdat(isat,iazm,isun,:) + (frac_sun)*tabdat(isat,iazm,isun+1,:)
        term_21 = (1.0-frac_sun)*tabdat(isat,iazm+1,isun,:) + (frac_sun)*tabdat(isat,iazm+1,isun+1,:)
        term_22 = (1.0-frac_sun)*tabdat(isat+1,iazm+1,isun,:) + (frac_sun)*tabdat(isat+1,iazm+1,isun+1,:)
        term_12 = (1.0-frac_sun)*tabdat(isat+1,iazm,isun,:) + (frac_sun)*tabdat(isat+1,iazm,isun+1,:)

        ray_ref(lind, sind, :) = (1.0-frac_sat)*(1.0-frac_rel_azm)*term_11 + &
                              (frac_sat)*(1.0-frac_rel_azm)*term_12 + &
                              (1.0-frac_sat)*(frac_rel_azm)*term_21 + &
                              (frac_sat)*(frac_rel_azm)*term_22
!       print *,"j, k, computed ray_ref(j,k) = ",j,k,ray_ref(j,k)

        END DO !lind => lines
    END DO !sind => samples

    print *, ""

    !Channel independant matrix calculations
    print *,"Performing Matrix Calculations"
    mu_sun = cos(sun_zen*dtor)
    mu_sat = cos(sat_zen*dtor)
    print *, "max of mu_sat = ", maxval(mu_sat)
    print *, "min of mu_sat = ", minval(mu_sat)
    print *, "max of mu_sun = ", maxval(mu_sun)
    print *, "min of mu_sun = ", minval(mu_sun)

    airmass = 1.0/mu_sun + 1.0/mu_sat

    min_log_ref = -1.6
    max_log_ref = 0.176

    ! If geostationary, then calculate a hight-dependent adjustment factor
    ! This is used to adjust for the large differences in path length
    ! that occur for high viewing angles when clouds are present
    if (infrared(1, 1) .ne. -1) then
        where (infrared < 233.0)
            HH = 0.295
        elsewhere
            where (infrared > 283.0)
                HH = 1.0
            elsewhere
                HH = 0.295 + (1.0 - 0.295) * (infrared - 233.0) / (283.0 - 233.0)
            endwhere
        endwhere
        where (mu_sat < 0.60)
            mublend = 1.0
        elsewhere
            where (mu_sat > 0.80)
                mublend = 0.0
            elsewhere
                mublend = (0.8 - mu_sat) / (0.80 - 0.60)
            endwhere
        endwhere
    else
        HH(:, :) = 0.0
        mublend(:, :) = 0.0
    endif

    !DO cind = LBOUND(chan_consts, 1), UBOUND(chan_consts, 1)
    DO cind = 1, nchans
        print *, ""
        !Do Matrix Calculations
        print *, "  cind = ", cind
        print *, "  data Channel Name = ", chan_names(cind)
        print *, "  chan_consts Channel Name = ", chan_consts(cind)%chname

        ! Point independent matrix calculations, that happen before 
        ! AHI extra corrections.
        trans_sat = exp(-1.0*ray_taus(cind)/mu_sat)
        trans_sun = exp(-1.0*ray_taus(cind)/mu_sun)
        ! The 10.0 is to change the units of radiance to mW/cm^2-sr-um
        tro = rad(:, :, cind) *pi / ( 10.0 * f_sun_adj(cind) * mu_sun * exp(-1.0*airmass*uoz*aoz(cind)) )

        trayu = ( (2.0/3.0 + mu_sat)+(2.0/3.0 - mu_sat)*trans_sat) / &
                    ( 4.0/3.0 + ray_taus(cind) )
        trayd = ( (2.0/3.0 + mu_sun)+(2.0/3.0 - mu_sun)*trans_sun) / &
                    ( 4.0/3.0 + ray_taus(cind) )


        print *, "  Rayleigh correcting"
        ! Orig equation
        ! From Steve's code
        ! tro = mublend * (tro - HH * ray_ref(:,:,cind)) / &
        !           (trayu * trayd * exp(-1.0 * airmass * (ao2(cind) + awv(cind)))) + &
        !       (1.0 - mublend) * (tro - ray_ref(:,:,cind)) / &
        !           (trayu * trayd * exp(-1.0 * airmass * (ao2(cind) + awv(cind))))
        ! Refactored
        tro = (tro - ray_ref(:,:,cind) + (1 - HH) * mublend * ray_ref(:,:,cind)) / &
                  (trayu * trayd * exp(-1.0 * airmass * (ao2(cind) + awv(cind))))
        ref(:, :, cind) = tro/(1.0+raysa(cind)*tro)  !units of reflectance [0-1]

        ref(:, :, cind) = blend_corr_with_uncorr(c0(cind), ref(:,:,cind), rad(:,:,cind), sat_zen, sun_zen)
    END DO ! cind


    !-------
    ! Data Q/C
    !-------
    print *,"Truncating results to fall within [0,1]"
    ! Truncate negative numbers to 0, if they occur
    where (ref .ne. -999.0)
        where (ref < min_ref) ref = min_ref
        
        ! Truncate numbers greater than unity to unity, if they occur
        where (ref > max_ref) ref = max_ref
    endwhere

    !***************************************************************
    CONTAINS
    !***************************************************************
    SUBROUTINE locate(interp_arr, arr_size, input_val, interp_index)
        ! Retrieve the index in interp_arr where the value most closely matches
        ! the value in input_val.  Return that index.
        ! Simple midpoint search
        implicit none
        integer, parameter :: bd = 8
        INTEGER(bd), INTENT(IN) :: arr_size ! Size of array being interpolated to
        INTEGER(bd), INTENT(OUT) :: interp_index ! Index of closest match
        REAL(bd), INTENT(IN) :: input_val ! Value to search for
        ! Array in which to locate closest match to input_val
        REAL(bd), DIMENSION(:), INTENT(IN) :: interp_arr
        INTEGER(bd) :: loop_ind, lower, mid, upper
        lower = 0
        upper = arr_size+1

        do loop_ind=1, 2*arr_size
            if (upper-lower <= 1) then
                exit
            endif
            mid = (upper + lower)/2
            if ((interp_arr(arr_size) >= interp_arr(1)) .eqv. (input_val >= interp_arr(mid))) then
                lower = mid
            else
                upper = mid
            endif
        end do

        if (input_val == interp_arr(1)) then
            interp_index = 1
        elseif (input_val == interp_arr(arr_size)) then
            interp_index = arr_size-1
        else
            interp_index = lower
        endif
    END SUBROUTINE locate

    subroutine read_tables(sensor, chan_names, sat_zen, rel_azm, sun_zen, tabdat)
        ! Given sensor name and a list of channel names
        ! returns the lookup table values for all requested channels
        ! as arrays of reals
        use config
        implicit none
        integer, parameter :: bd = 8

        logical :: ex
        integer :: io_stat
        character(len=*) :: sensor
        character(len=*), dimension(:) :: chan_names
        character(len=512) :: fname

        real(bd), dimension(num_sat_zen), intent(out) :: sat_zen
        real(bd), dimension(num_rel_azm), intent(out) :: rel_azm
        real(bd), dimension(num_sun_zen), intent(out) :: sun_zen
        real(bd), dimension(num_sat_zen, num_rel_azm, num_sun_zen, size(chan_names)), intent(out) :: tabdat

        do cind = 1, nchans
            print *, trim(adjustl(chan_names(cind))), cind, nchans
            if (.not. (trim(adjustl(chan_names(cind))) == 'RED' .or. &
                       trim(adjustl(chan_names(cind))) == 'GRN' .or. &
                       trim(adjustl(chan_names(cind))) == 'BLU' .or. &
                       trim(adjustl(chan_names(cind))) == 'VNIR') &
               ) then
                cycle
            endif
            ! Read data from each channel's lookup table
            fname = trim(adjustl(ancildat_path)) // '/rayleigh/' // trim(adjustl(sensor)) &
                // '/' // trim(adjustl(chan_names(cind))) // '.dat'
            print *, fname
            inquire(file=fname, exist=ex)
            open (unit=20, file=fname, status="old", action="read")
            read (unit=20, fmt=*) sat_zen(:)
            read (unit=20, fmt=*) rel_azm(:)
            read (unit=20, fmt=*) sun_zen(:)
            read (unit=20, fmt=*) tabdat(:,:,:,cind)
            close(20)
        end do
    end subroutine read_tables

    elemental real(bd) function blend_corr_with_uncorr(c0, corr, uncorr, sat_zen, sun_zen) result(blend)
        implicit none
        integer, parameter :: bd = 8
        real(bd), intent(in) :: c0, uncorr, corr, sat_zen, sun_zen
        real(bd) :: fact
        real(bd), parameter :: deg2rad = 3.14159 / 180.0
        real(bd), parameter :: min_sun_zen = 75.0
        real(bd), parameter :: max_sun_zen = 85.0
        real(bd), parameter :: min_sat_zen = 75.0
        real(bd), parameter :: max_sat_zen = 85.0

        ! Blend is a running value that is modified in the if statements below
        blend = corr

        ! If sun_zen between 75.0 and 85.0, then blend uncorrected and corrected data
        if (sun_zen < max_sun_zen .and. sun_zen >= min_sun_zen) then
            fact = sin(deg2rad * 90.0 * (sun_zen - min_sun_zen) / (max_sun_zen - min_sun_zen))
            blend = fact * c0 * uncorr + (1.0 - fact) * blend
        endif

        ! If sat_zen between 75.0 and 85.0, then blend uncorrected data with the data from
        ! the previous step
        if (sat_zen < max_sat_zen .and. sat_zen >= min_sat_zen) then
            fact = (sat_zen - min_sat_zen) / (max_sat_zen - min_sat_zen)
            blend = fact * c0 * uncorr + (1.0 - fact) * blend
        endif

        ! If sun_zen is 85.0 or greater, then use unblended data
        if (sun_zen >= max_sun_zen .or. sat_zen >= max_sat_zen) then
            blend = c0 * uncorr
        endif

        ! ! If an angle is too large, set to bad value
        ! if (sun_zen >= 89.5 .or. sat_zen >= 89.5) then
        !     blend = -999.0
        ! endif

    endfunction blend_corr_with_uncorr


end subroutine process_color
