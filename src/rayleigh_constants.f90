module rayleigh_constants
    !**********************************
    ! This module defines many of the constants required by process_color.f90.
    ! Also defined here is the get_consts subroutine, used to retrieve sensor
    ! and channel specific constants.
    !**********************************
    use config
    use viirs_rayleigh_constants
    use modis_rayleigh_constants
    use geokompsat_ami_rayleigh_constants
    use himawari8_ahi_rayleigh_constants
    use goes16_abi_rayleigh_constants
    use goes17_abi_rayleigh_constants
    use meteosat12_fci_rayleigh_constants
    use rayleigh_chan_constants
    use string_operations
    implicit none

    integer, parameter, private :: bd = 8

    ! Datatype sizes in bytes
    integer(bd), parameter :: num_sat_zen = 19
    integer(bd), parameter :: num_rel_azm = 37
    integer(bd), parameter :: num_sun_zen = 19
    !Constants
    real(bd), parameter :: pi = 3.14159
    real(bd), parameter :: dtor = pi/180.0
    real(bd), parameter :: uoz = 0.270
    real(bd), parameter :: small_num=1.0E-5
    ! Thresholds
    real(bd), parameter :: glint_thresh=25.0
    real(bd), parameter :: mean_thresh=0.5
    real(bd), parameter :: std_thresh=0.10
    real(bd), parameter :: min_ref = 0.0
    real(bd), parameter :: max_ref = 1.0

    contains

    subroutine get_consts(sensor, platform, chan_names, chan_consts)
        ! Returns the constants required to perform a rayleigh scattering
        ! correction for a given sensor and set of channel names.
        !
        ! INPUTS:
        !   sensor - a string of up to length name_size (defined in
        !            share/geoalgs_constants.f90) defining which sensor's
        !            constants are to be returned
        !   platform - a string of up to length name_size (defined in
        !              share/geoalgs_constants.f90) defining which platform's
        !              constants are returned
        !   chan_names - an array of channel names, each a string of up to
        !                length name_size defining which channel's constants are
        !                to be returned for the given sensor.
        !
        ! OUTPUTS:
        !   chan_consts - a variable of type ChanConsts containing all requested
        !                 channel constants for the given sensor.
        !                 Each channel's constants are accessible via:
        !                   chan_consts(channelName)
        !                 and each specific constant is available via:
        !                   chan_consts(channelName)(constantName)
        !                 Constants available for each channel are:
        !                   colorgun - Name of the color gun that the channel's
        !                              data will be placed in to create a
        !                              TrueColor image.
        !                              ("red", "green", or "blue")
        !                   chname - Name of the channel as seen in the original
        !                            data file.
        !                   f_sun - A constant used in the TrueColor calculation
        !                   f_sun_adj - A constant used in the TrueColor calculation
        !                   ray_taus - A constant used in the TrueColor calculation
        !                   raysa - A constant used in the TrueColor calculation
        !                   aoz - A constant used in the TrueColor calculation
        !                   awv - A constant used in the TrueColor calculation
        !                   ao2 - A constant used in the TrueColor calculation
        implicit none
        integer, parameter :: bd = 8
        character(len=*), intent(in) :: sensor
        character(len=*), intent(in) :: platform
        character(len=*), dimension(:), intent(in) :: chan_names
        integer(bd) :: cind, nchans, arr_ind
        character(len=64), allocatable, dimension(:) :: temp_names
        type(ChanConsts), allocatable, dimension(:) :: temp_consts
        type(ChanConsts), dimension(size(chan_names, 1)), intent(out) :: chan_consts

        print *, 'Entering rayleigh_constants.f90 get_consts() subroutine'
        ! Select the correct sensor's constants
        select case (trim(adjustl(sensor)))
            case ('viirs')
                nchans = size(viirs_chan_names, 1)
                allocate(temp_names(nchans))
                allocate(temp_consts(nchans))
                temp_names = viirs_chan_names
                temp_consts = viirs_chan_consts
            case ('modis')
                nchans = size(modis_chan_names, 1)
                allocate(temp_names(nchans))
                allocate(temp_consts(nchans))
                temp_names = modis_chan_names
                temp_consts = modis_chan_consts
            case ('ahi')
                nchans = size(himawari8_ahi_chan_names, 1)
                allocate(temp_names(nchans))
                allocate(temp_consts(nchans))
                temp_names = himawari8_ahi_chan_names
                temp_consts = himawari8_ahi_chan_consts
            case ('ami')
                nchans = size(geokompsat_ami_chan_names, 1)
                allocate(temp_names(nchans))
                allocate(temp_consts(nchans))
                temp_names = geokompsat_ami_chan_names
                temp_consts = geokompsat_ami_chan_consts
            case ('fci')
                nchans = size(meteosat12_fci_chan_names, 1)
                allocate(temp_names(nchans))
                allocate(temp_consts(nchans))
                temp_names = meteosat12_fci_chan_names
                temp_consts = meteosat12_fci_chan_consts
            case ('abi')
                if (trim(adjustl(platform)) .eq. 'goes16') then
                    nchans = size(goes16_abi_chan_names, 1)
                    allocate(temp_names(nchans))
                    allocate(temp_consts(nchans))
                    temp_names = goes16_abi_chan_names
                    temp_consts = goes16_abi_chan_consts
                else if (trim(adjustl(platform)) .eq. 'goes17') then
                    nchans = size(goes17_abi_chan_names, 1)
                    allocate(temp_names(nchans))
                    allocate(temp_consts(nchans))
                    temp_names = goes17_abi_chan_names
                    temp_consts = goes17_abi_chan_consts
                else
                    ! Assume goes 16 if match not found
                    nchans = size(goes16_abi_chan_names, 1)
                    allocate(temp_names(nchans))
                    allocate(temp_consts(nchans))
                    temp_names = goes16_abi_chan_names
                    temp_consts = goes16_abi_chan_consts
                endif
        end select

        do cind = lbound(chan_names, 1), ubound(chan_names, 1)
            arr_ind = find_in_array(temp_names, chan_names(cind))
            chan_consts(cind) = temp_consts(arr_ind)
            print *, 'Found '//chan_names(cind)//'\n'
        end do
        print *, 'Leaving get_consts()\n'

    end subroutine get_consts

    integer(bd) function find_in_array(arr, str)
        !Returns the first index of the input array that matches the input
        !string
        implicit none
        integer, parameter :: bd = 8
        character(len=*), dimension(:), intent(in) :: arr
        character(len=*), intent(in) :: str
        integer(bd) :: find

        do find = lbound(arr, 1), ubound(arr, 1)
            if (trim(adjustl(arr(find))) .eq. trim(adjustl(str))) then
                find_in_array = find
                exit
            end if
        end do
        return
    end function find_in_array

end module rayleigh_constants
