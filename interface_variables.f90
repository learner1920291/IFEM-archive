module interface_variables
  implicit none
  save


  integer :: nn_inter     !# of interface points
  integer :: nn_inter_ini
  real(8) :: sur_tension  !surface tension force
  real(8) :: den_inter !density of bubble
  real(8) :: vis_inter !viscousity of bubble
  integer :: maxmatrix
  real(8) :: scale_inter(3) ! 
  real(8) :: shift_inter(3)
  real(8) :: maxdcurv
  real(8) :: vol_corr  !volume corretion
  real(8) :: total_length
  real(8) :: hsp
  real(8) :: rkpm_scale
  real(8) :: max_dcurv
  real(8) :: max_hg
  integer :: nbc
  real(8) :: mass0
  real(8) :: static_angle ! static contact angle
  real(8) :: ad_re_angle ! used for advancing and receding angle, this is the angle difference to static_angle
  real(8) :: Hoff    ! parameter calcualted using hoffman's equation
end module interface_variables
