subroutine rayleigh(nchans, lines, samples, sensor, platform, chan_names, jday, &
                    radiances, sat_zen, sun_zen, rel_azm, infrared, reflectances)
                    ! radiances, sat_zen, sun_zen, rel_azm, reflectances)
    !-------------------------------------------------------------------------------------------
    ! This subroutine is generically used to apply a rayleigh scattering
    ! correction to satellite data.  Currently this package is capable of
    ! handling MODIS and VIIRS data.
    !
    ! Inputs:
    !   nchans     - Number of channels in the dataset (third dimension of radiances array)
    !   lines      - Integer number of lines in the dataset.
    !   samples    - Integer number of samples in the dataset.
    !   sensor     - Name of the input data's sensor as a string.
    !                Currently accepts MODIS, VIIRS, ABI, and AHI.
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
    ! Outputs:
    !   reflectances - Three dimensional array of rayleigh corrected radiances.
    !                  (lines, samples, nchans)
    !
    ! Python call signature:
    !   reflectances = rayleigh(nchans, lines, samples, sensor, platform, chan_names,
    !                           jday, radiances, sat_zen, sun_zen, rel_azm
    !                          )
    !
    ! This routine is written as a subroutine in order to allow it to be
    ! compiled using f2py.  Doing so allows the subroutine to be imported by
    ! python routines and used as a normal python module.  Calls to compile this
    ! routine are available in ../Makefile.  Compiling this routine will produce
    ! rayleigh.so.  To import from rayleigh.so simply use
    ! the following import in Python:
    !
    !   from rayleigh import rayleigh
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
    !   process_color.f90
    !   string_operations.f90
    !   rayleigh_chan_constants.f90
    !   rayleigh_constants.f90
    !   modis_rayleigh_constants.f90
    !   viirs_rayleigh_constants.f90
    !
    !-------------------------------------------------------------------------------------------

    use config
    use rayleigh_constants
    implicit NONE
    integer, parameter :: bd = 8

    !***************************************************************
    ! INPUTS
    !***************************************************************
    ! Dataset dimentions
    integer(bd), intent(in)     :: lines
    integer(bd), intent(in)     :: samples
    integer(bd), intent(in)     :: nchans
    integer(bd), intent(in)     :: jday
    ! Identifying information
    CHARACTER(len=*), intent(in)   :: sensor, platform
    CHARACTER(len=*), dimension(nchans), intent(in) :: chan_names
    ! Input Datasets
    real(bd), dimension(lines, samples, nchans), intent(in) :: radiances
    real(bd), dimension(lines, samples), intent(in) :: sat_zen
    real(bd), dimension(lines, samples), intent(in) :: sun_zen
    real(bd), dimension(lines, samples), intent(in) :: rel_azm
    real(bd), dimension(lines, samples), intent(in) :: infrared
!    integer(kind=1), dimension(lines, samples), intent(in) :: land_mask

    !***************************************************************
    ! OUTPUT
    !***************************************************************
    real(bd), dimension(lines, samples, nchans), intent(out) :: reflectances

    !***************************************************************
    ! f2py Signature Information
    !***************************************************************
    !f2py integer(bd), intent(in) :: nchans
    !f2py integer(bd), intent(in) :: lines
    !f2py integer(bd), intent(in) :: samples
    !f2py integer(bd), intent(in) :: jday
    !f2py character*(*), intent(in) :: sensor
    !f2py character*(*), intent(in) :: platform
    !f2py character*(*), dimension(nchans), intent(in) :: chan_names
    !f2py real(bd), dimension(lines, samples, nchans) intent(in), :: radiances
    !f2py real(bd), dimension(lines, samples), intent(in) :: sat_zen
    !f2py real(bd), dimension(lines, samples), intent(in) :: sun_zen
    !f2py real(bd), dimension(lines, samples), intent(in) :: rel_azm
    !f2py real(bd), dimension(lines, samples), optional, intent(in) :: infrared(:,:) = -1
    !f2py real(bd), dimension(lines, samples, nchans) intent(out), :: reflectances

    ! Report on inputs
    print *, 'Entering rayleigh.f90 rayleigh Fortran subroutine.'
    print *, 'Inputs:'
    print *, '             lines - ', lines
    print *, '           samples - ', samples
    print *, '              jday - ', jday
    print *, '            sensor - ', sensor
    print *, '          platform - ', platform
    print *, '        chan_names - ', chan_names

    ! Call process_color to perform most of rayleigh correction
    ! Must hold off on last two steps in order to maintain data
    !   for dust correction
    call process_color(sensor, platform, chan_names, lines, samples, nchans, jday, radiances, &
                       sat_zen, sun_zen, rel_azm, infrared, reflectances)
    print *, "REFSHAPE2", shape(reflectances)

    ! Scale the processed data if applicable
    !print *,"Scaling the data by log_10"
    !reflectances = log10(reflectances)
    !call normalize(reflectances, log10(min_ref), log10(max_ref))

! DO NOT NORMALIZE IN RAYLEIGH!  Scale somewhere else if needed (productfile? product python script?)
! Blue Light Dust, for example, does NOT use scaled values.
!    contains
!
!    subroutine normalize(arr, min_val, max_val)
!        real(bd), dimension(:,:,:), intent(inout) :: arr
!        real(bd), intent(in) :: min_val
!        real(bd), intent(in) :: max_val
!        arr = arr - min_val
!        arr = arr * ABS(1.0/(max_val - min_val))
!    end subroutine normalize

end subroutine rayleigh
