!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! module delta nonuniform 
!
! Lucy Zhang, Axel Gerstenberger
! NWU, 04/22/2003
!
! contains:
!   - variables          !...all variables related to the delta function
!   - delta_initialize   !...calculate domain of influence for each solid node
!   - delta_exchange     !...performs exchange of information in both directions (fluid <--> solid)

module delta_nonuniform
  implicit none
  save

public
  !...use these parameters to define the direction of information flow
  integer,parameter :: delta_exchange_fluid_to_solid = 1
  integer,parameter :: delta_exchange_solid_to_fluid = 2  

  integer :: maxconn !...used to define connectivity matrix size

  integer :: ndelta !...defines type of delta function used -> right now, only "1" (RKPM) is available

  real*8,allocatable,save :: shrknode(:,:)      !...shape function for each node, contains the weights
  integer,allocatable,save :: cnn(:,:),ncnn(:)  !...connectivity arrays for domain of incluence for each solid node

 !...private subroutines
  private :: getinf,correct3d

contains

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
subroutine delta_initialize(nn_solids,x_solids,xna,ien,dwjp)
! Subroutine rkpm_delta
! Lucy Zhang
! 11/06/02
! Northwestern University

! This subroutine calculate the delta function using RKPM which is used for both
! ninterpolation and distribution of the velocities and forces respectively
! between fluids and solids domain.
  use error_memory
  use fluid_variables
  implicit none

 !...solids variables
  integer :: nn_solids

  real* 8 x_solids(nsd,nn_solids)

 !...fluids variables
  real* 8 xna(nsd,nn),xn(nsd,nen)
  integer ien(nen,ne)
  real* 8 dwjp(nn), adist(nsd,nn)

 !...local variables
  real*8 :: x(3), y(3), a(3)
  real*8 :: xr(nsd,nsd), cf(nsd,nsd) 
  real*8 :: b(4), bd(3,4)
  real*8 :: shp, shpd(3), det
  real*8 :: xmax,ymax,zmax,vol
  real*8 :: coef,avginf
  integer :: iq
  integer :: maxinf,mininf,totinf
  integer :: ie,inl,isd,nnum,node
  integer :: inf(maxconn),ninf
  integer :: i,n

  
  write(*,*) "*** Calculating RKPM delta function ***"

  if (allocated(shrknode)) then
     deallocate(shrknode)
  end if
  if (allocated(cnn)) then
     deallocate(cnn)
  end if
  if (allocated(ncnn)) then
     deallocate(ncnn)
  end if


  allocate(shrknode(maxconn,nn_solids),stat=error_id); call alloc_error("shrknode","delta_initialize",error_id)
  allocate(cnn(maxconn,nn_solids)     ,stat=error_id); call alloc_error("cnn",     "delta_initialize",error_id)
  allocate(ncnn(nn_solids)            ,stat=error_id); call alloc_error("ncnn",    "delta_initialize",error_id)



  !coef = 0.5
  coef = 0.6d0
  maxinf = 0
  mininf = 9999
  avginf = 0
  cnn(:,:)=0
  ncnn(:)=0
  shrknode(:,:)=0.0d0

 !...Calculate element coordinates
  call shape

 !...Calculate nodal weights
  dwjp(:) = 0.0
  adist(:,:) = 0.0
  totinf = 0

  do ie = 1,ne
     do inl=1,nen
        do isd=1,nsd
           nnum = ien(inl,ie)
           xn(isd,inl) = xna(isd,nnum)
        enddo
     enddo

     xmax = coef*(maxval(xn(1,1:nen)) - minval(xn(1,1:nen)))
     ymax = coef*(maxval(xn(2,1:nen)) - minval(xn(2,1:nen)))
     zmax = coef*(maxval(xn(3,1:nen)) - minval(xn(3,1:nen)))
        
     do inl = 1,nen
        node = ien(inl,ie) 
        adist(1,node) = max(adist(1,node),xmax)
        adist(2,node) = max(adist(2,node),ymax)
        adist(3,node) = max(adist(3,node),zmax)
     enddo

 !...Calculate volume
     if (nen == 4) then
        include "vol3d4n.fi"
     else
        include "vol3d8n.fi"
     endif
        
     do inl = 1,nen
        nnum = ien(inl,ie)
        dwjp(nnum) = dwjp(nnum) + vol/nen
     enddo
  enddo

	

! Calculate the RKPM shape function for the solids points
  do i = 1, nn_solids
     x(1:nsd)=x_solids(1:nsd,i) !get solids point coordinate
     ninf=0
     inf(:)=0
! get a list of influence nodes from the fluids grid
     call getinf(inf,ninf,x,xna,adist,nn,nsd,maxconn)
     cnn(1:ninf,i)=inf(1:ninf)
     ncnn(i)=ninf

     if (ninf > maxinf) maxinf = ninf
     if (ninf < mininf) mininf = ninf
     totinf = totinf + ninf
! calculate the correction function
     call correct3d(b,bd,x,xna,adist,dwjp,nn,1,inf,ninf,maxconn)
     do n = 1, ninf
        nnum = inf(n)
        do isd = 1,nsd
           y(isd) = xna(isd,nnum)
           a(isd) = adist(isd,nnum)
        enddo
        call RKPMshape3d(shp,b,bd,x,y,a,dwjp(nnum))
        shrknode(n,i)=shp
     enddo
  enddo

  avginf = totinf/nn_solids
  write(6,'("  Maximum Influence Nodes = ",i7)') maxinf
  write(6,'("  Minimum Influence Nodes = ",i7)') mininf
  write(6,'("  Average Influence Nodes = ",f7.2)') avginf

  return
end subroutine delta_initialize

!cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
!c This subroutine finds the influence points of point x
!cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
subroutine getinf(inf,ninf,x,xna,adist,nn,nsd,maxconn)
  
  integer :: ninf,nn,nsd,maxconn
  real*8 x(3), xna(nsd,nn), adist(nsd,nn)
  real*8 r(nsd)
  integer inf(maxconn)
  integer i

!!!! MAKE SURE MAXCONN IS DEFINED IN COMMON.H
!cccccccccccccccccc
!   x = the coordinate of the point to be calculated for
!   xna = the coordinate of all points
!   r = the distance between point x and other points in the system
!   inf = a collection of all the influence points
!   ninf = total number of influence points
!   adist = the radial distance of the influence domain
!cccccccccccccccccc

  ninf = 0
  do i = 1,nn
     r(1:nsd) = x(1:nsd) - xna(1:nsd,i)
     if ((abs(r(1)).le.2*adist(1,i)).and.(abs(r(2)).le.2*adist(2,i)).and.(abs(r(3)).le.2*adist(3,i))) then
        ninf = ninf + 1
        inf(ninf) = i
     endif
  enddo

  if (ninf > maxconn) then
     write (*,*) "Too many influence nodes!"
     write (*,*) ninf
  elseif (ninf.lt.4) then
     write (*,*) "Not enough influence nodes!"
     write (*,*) ninf
  endif

  return
end subroutine getinf

!ccccccccccccccccccccccccccccccccccccccccccccccccccc
!
!......3-D correct function......
!
subroutine correct3d(b,bd,cpt,cjp,dcjp,dwjp,nep,iInter,inf,ninf,maxconn)
  implicit none

  integer nep,iInter
  integer maxconn,ninf,inf(maxconn)
  real*8 b(*),bd(3,*),cpt(3)
  real*8 cjp(3,nep),dcjp(3,nep),dwjp(nep)
     

  if (iInter .eq. 1) then
	 call correct3dl(b,bd,cpt,cjp,dcjp,dwjp,nep,inf,ninf,maxconn)
  elseif(iInter .eq. 11)  then
     call correct3dtl(b,bd,cpt,cjp,dcjp,dwjp,nep,inf,ninf,maxconn)
  else
     print *, 'wrong iInter'
     stop
  endif
  return
end subroutine correct3d


!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

!SUBROUTINE DELTA
! Lucy Zhang
! 11/06/02
!
! Northwestern University
! This subroutine calculate the delta function which is used for both
! interpolation and distribution of the velocities and forces respectively
! between fluids and solids domain.
!
! There are 3 options for calculating
! 1. RKPM - cubic spline for non-uniform spacing
! 2. RKPM - cubic spline for uniform spacing
! 3. Original delta function for uniform spacing 

subroutine delta_exchange(data_solids,nn_solids,data_fluids,nn_fluids,ndelta,dv,ibuf)
  implicit none
  integer,intent(in) :: ibuf,ndelta

 !...solids variables
  integer,intent(in)   :: nn_solids
  real*8,intent(inout) :: data_solids(3,nn_solids)

 !...fluids variables
  integer,intent(in)   :: nn_fluids
  real*8,intent(inout) :: data_fluids(3,nn_fluids)
  real*8,intent(in)    :: dv(nn_fluids)

 !...local variables
  integer :: inn,icnn,pt
  real*8  :: tot_vel(nn_fluids),tot_vel_fluid,vol_inf 
  !real*8  :: tot_force_solid,tot_force_fluid


  tot_vel_fluid = 0
  tot_vel(1:nn_fluids)=0.0
  if (ndelta == 1) then                  !c    If non-uniform grid 

     if (ibuf == delta_exchange_fluid_to_solid) then  !velocity interpolation

        write(*,*) '*** Interpolating Velocity onto Solid ***'

        data_solids(:,:)=0
        do inn=1,nn_solids
           vol_inf=0.0d0
           do icnn=1,ncnn(inn)
              pt=cnn(icnn,inn)
              data_solids(1:3,inn) = data_solids(1:3,inn) + data_fluids(1:3,pt) * shrknode(icnn,inn)
		      tot_vel(pt)=data_fluids(1,pt)
		      vol_inf = vol_inf + dv(pt)
           enddo
           !data_solids(1:3,inn)=data_solids(1:3,inn)/vol_inf
        enddo
!c		tot_vel_solid=sum(data_solids(1,:))
!c		tot_vel_fluid=sum(tot_vel(:))
!c		tot_vel_fluid=sum(data_fluids(1,:))
!c		write(*,*) 'total vel in solid=',tot_vel_solid
!c		write(*,*) 'total vel in fluid=',tot_vel_fluid

     elseif (ibuf == delta_exchange_solid_to_fluid) then !force distribution

	    write(*,*) '*** Distributing Forces onto Fluid ***'
	    data_fluids(:,:)=0
        do inn=1,nn_solids
           do icnn=1,ncnn(inn)
              pt=cnn(icnn,inn)
              data_fluids(1:3,pt) = data_fluids(1:3,pt) + data_solids(1:3,inn) * shrknode(icnn,inn)
           enddo	
        enddo
	    !tot_force_solid=sum(data_solids(1,:))
	    !tot_force_fluid=sum(data_fluids(1,:))
        !write(*,*) 'total force in solid=',tot_force_solid
	    !write(*,*) ' total force in fluid=',tot_force_fluid
     endif
  else

!c    if uniform grid
!c         do inn=1,nn_solids
!c            if (ndelta .eq.2) then
!c               call delta_rkpm_uniform(deltaeachaxis,inn,
!c     +              dlptlocal_number,coord_pt)
!c            elseif (ndelta .eq.3) then
!c               call delta_original(deltaeachaxis,inn,
!c     +              dlptlocal_number,coord_pt)
!c            endif
!c
!c            do k=0,n_c_del_oneaxis-1
!c               do j=0,n_c_del_oneaxis-1
!c                  do i=0,n_c_del_oneaxis-1
!c                     wt_delta(i,j,k) = deltaeachaxis(i,1)
!c     $                    * deltaeachaxis(j,2)
!c     $                    * deltaeachaxis(k,3)
!c                  enddo
!c               enddo
!c            enddo
!c         
!c            i0=modrealinto( coord_pt(1,ipt), mn_ce1, mx_ce1)
!c     $           - n_lo_gc_del_oneaxis
!c            j0=modrealinto( coord_pt(2,ipt), mn_ce2, mx_ce2)
!c     $           - n_lo_gc_del_oneaxis
!c            k0=modrealinto( coord_pt(3,ipt), mn_ce3, mx_ce3)
!c     $           - n_lo_gc_del_oneaxis
!c         
!c            if (ibuf .eq. 2) then !force distribution
!c               do k = 0, n_c_del_oneaxis - 1 
!c                  do j = 0, n_c_del_oneaxis - 1 
!c                     do i = 0, n_c_del_oneaxis - 1       
!c                        do idim = 1,3
!c                           data_fluids(i0+i,j0+j,k0+k,idim)
!c     $                          = data_fluids(i0+i,j0+j,k0+k,idim)
!c     $                          + data_solids(idim,ipt) * wt_delta(i,j,k)
!c                        
!c                        enddo
!c                     enddo
!c                  enddo
!c               enddo
!c            
!c            elseif (ibuf .eq. 1) then !velocity interpolation
!c               do k=0,n_c_del_oneaxis - 1 
!c                  do j=0,n_c_del_oneaxis - 1 
!c                     do i=0,n_c_del_oneaxis - 1 
!c                        do idim = 1,3
!c                           data_solids(idim,ipt)
!c     $                          = data_solids(idim,ipt)
!c     $                          + data_fluids(i0+i,j0+j,k0+k, idim)
!c     $                          * wt_delta(i,j,k)
!c                        enddo
!c                     enddo
!c                  enddo
!c               enddo
!c            endif 
!c
!c         enddo ! end of loop in nn_solids
!c
  endif ! end of option for delta function

      
  return
end subroutine delta_exchange

end module delta_nonuniform