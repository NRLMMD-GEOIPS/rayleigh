module rayleigh_chan_constants
    !**********************************
    ! This module defines the base ChanConsts object.
    ! ChanConsts objects contain the parameters needed to perform
    !   a Rayleigh scattering correction on a specific channel
    !   for a specific sensor.
    !**********************************
    implicit none
    integer, parameter, private :: bd = 8
    type :: ChanConsts
        character(len=64) :: colorgun
        character(len=64) :: chname
        real(bd) :: f_sun
        real(bd) :: f_sun_adj
        real(bd) :: ray_taus
        real(bd) :: raysa
        real(bd) :: aoz
        real(bd) :: awv
        real(bd) :: ao2
        real(bd) :: c0
    end type ChanConsts
end module rayleigh_chan_constants
