      subroutine  ibg_femcalcptforce(dnext_pt,
     $     dlptlocal_number,dlptlocal_head,dlptlocal_tail,
     $     acttype_con,fix_con,coord_pt,force_con,force_pt,
     $     accel_pt,vel_pt)
      implicit real*8 (a-h,o-z)
      include 'r_common' 
      include 'main_common'            

      integer dnext_pt( mn_point_alloc:mx_point_alloc )

      integer dlptlocal_number
      integer dlptlocal_head
      integer dlptlocal_tail

      dimension force_con(ix:iz,mn_point_alloc:mx_point_alloc)
      dimension force_pt( ix:iz, mn_point_alloc:mx_point_alloc )
      dimension acttype_con(mn_point_alloc:mx_point_alloc )
      dimension fix_con(mn_point_alloc:mx_point_alloc )
      dimension coord_pt( ix:iz, mn_point_alloc:mx_point_alloc )
      dimension accel_pt( ix:iz, mn_point_alloc:mx_point_alloc )
      dimension vel_pt(ix:iz, mn_point_alloc:mx_point_alloc )
      dimension unitvector(n_dim_space)

      if (dlptlocal_number .eq. 0) then
         return
      endif
      if (n_ibmfem .eq. 1) then
         call r_timefun
         call r_load
c++++++++         
c     concentrated force
c++++++++         
         if (numfn .gt. 0) then
            call r_nodalf
         endif

         do 104 i=1,nnd
            fix_con(i)= 1.0
 104     continue

         njc=0

         do 37 i=1,numgb
ccccccccccccccccccccccccccccccccccccccccccc
c     Fixed 1,2
ccccccccccccccccccccccccccccccccccccccccccc
            if (ndirgb(i) .eq. 111111) then
               do 38 j=1,numdir(i)
                  nl=nodegb(i,j)
c     
                  if (nxt(1,nl) .ne. 0) then
                     njc=njc+1
                     fix_con(nnd+njc)=-1
c     
c     horizonal support
c
                     xsr=dsqrt((dis(1,nl)-xtedis*nxt(1,nl))**2+
     $                    dis(2,nl)**2)
                  
                     tension = xk*(xsr-xtedis+xstretch)

                     unitvector(1)=(dis(1,nl)-
     $                    xtedis*nxt(1,nl))/xsr
                     unitvector(2)=0.0d0                     
                     unitvector(3)=dis(2,nl)/xsr
                     
                     predrf(nl)=predrf(nl)-
     $                    tension*unitvector(1)-
     $                    xvisc*vel_pt(ix,nl)
                     predrf(nl+nnd)=predrf(nl+nnd)-
     $                    tension*unitvector(3)-
     $                    xvisc*vel_pt(iz,nl)

                  endif

                  if (nxt(3,nl) .ne. 0) then
                     njc=njc+1
                     fix_con(nnd+njc)=-1
c
c     vertical support
c
                     xsr=dsqrt((dis(2,nl)-xtedis*nxt(3,nl))**2+
     $                    dis(1,nl)**2)
                  
                     tension = xk*(xsr-xtedis+xstretch)

                     unitvector(1)=dis(1,nl)/xsr
                     unitvector(2)=0.0d0
                     unitvector(3)=(dis(2,nl)-
     $                    xtedis*nxt(3,nl))/xsr                     
                  
                     predrf(nl)=predrf(nl)-
     $                    xvisc*vel_pt(ix,nl)-
     $                    tension*unitvector(1)
                     predrf(nl+nnd)=predrf(nl+nnd)-
     $                    xvisc*vel_pt(iz,nl)-
     $                    tension*unitvector(3)
                  endif
 38            continue
            endif
ccccccccccccccccccccccccccccccccccccccccccccccccc
c     Fixed 1
ccccccccccccccccccccccccccccccccccccccccccccccccc
            if (ndirgb(i) .eq. 110111) then
               do 47 j=1,numdir(i)
                  nl=nodegb(i,j)
                  fix_con(nl)=-2
                  predrf(nl)=0.0d0
 47            continue
            endif
ccccccccccccccccccccccccccccccccccccccccccccccccc
c     Fixed 2
ccccccccccccccccccccccccccccccccccccccccccccccccc
            if (ndirgb(i) .eq. 101111) then
               do 52 j=1,numdir(i)
                  nl=nnd+nodegb(i,j)
                  predrf(nl)=0.0d0
 52            continue
            endif
 37      continue

      endif


      icon = dlptlocal_head

      ipt = icon

      do 100 icon = dlptlocal_head, dlptlocal_tail
         ipt = icon   
         
         if ( (fix_con(icon) .eq. -1.0) ) then

            force_pt(ix, ipt) = 0.0d0
            force_pt(iy, ipt) = 0.0d0
            force_pt(iz, ipt) = 0.0d0

         elseif (fix_con(icon) .eq. -2.0)  then

            force_pt(ix, ipt) = 0.0d0
            force_pt(iy, ipt) = 0.0d0
            force_pt(iz, ipt) = 0.0d0

         elseif (n_ibmfem .eq. 1)  then 

c++++++
cOct. 22

            if(ipt. le. nptfem) then
            force_pt(ix, icon) = drf(icon)+predrf(icon)
            force_pt(iy, icon) = 0.0d0            
            force_pt(iz, icon) = drf(icon+nnd)+predrf(icon+nnd)
            else 
               force_pt(ix, icon) = force_con(ix,icon) -
     $              force_con(ix,icon-1)
               force_pt(iy, icon) = force_con(iy,icon) - 
     $              force_con(iy,icon-1)
               force_pt(iz, icon) = force_con(iz,icon) - 
     $              force_con(iz,icon-1)
            endif

c++++++
         elseif (n_ibmfem .eq. 0) then

            force_pt(ix, ipt) = force_con(ix,icon) -
     $           force_con(ix,icon-1)
            force_pt(iy, ipt) = force_con(iy,icon) - 
     $           force_con(iy,icon-1)
            force_pt(iz, ipt) = force_con(iz,icon) - 
     $           force_con(iz,icon-1)

            if (ipt .eq. nptfilea) then
               force_pt(ix, ipt) = force_pt(ix,ipt)-
     $              cma*accel_pt(ix,ipt)
               force_pt(iz, ipt) = force_pt(iz,ipt)-
     $              cma*accel_pt(iz,ipt)
            endif
         endif

 100  continue

      icon = dlptlocal_tail
      ipt = icon 

      return
      end







