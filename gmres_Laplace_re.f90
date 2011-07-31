

subroutine gmres_Laplace_re(cal_ne,cal_domain,x,d,w,bg,dg,ien_den,bcnode_den,&
			offdomain,ne_offdomain)
	use fluid_variables, only: nsd,inner,outer
	use denmesh_variables, only:nn_den,ne_den,nen_den,nbc_den
!	use interface_variables
!	use allocate_variables, only:ne_inter_den,inter_ele_den
	use allocate_variables, only:ne_regen_ele,regen_ele
	use mpi_variables
	implicit none

	integer cal_ne,cal_domain(cal_ne)
	integer ne_offdomain,offdomain(ne_den)
	real* 8 x(nsd,nn_den)
	real* 8 d(nn_den)
	real* 8 bg(nn_den), dg(nn_den), w(nn_den)
	real* 8 Hm(inner+1,inner) !Henssenberg matrix
	real* 8 Vm(nn_den, inner+1) ! Krylov space matrix
	integer ien_den(nen_den,ne_den)
	integer bcnode_den(nbc_den,2)

	integer i,j,iouter,icount,INFO
	integer e1(inner+1)
	real* 8 x0(nn_den)
	real* 8 beta(inner+1)
	real* 8 eps
	real* 8 r0(nn_den)
	real* 8 rnorm, rnorm0,err
        real* 8 dv(nn_den)
	real* 8 Vy(nn_den)
        real* 8 avloc(nn_den)
	real* 8 temp(nn_den)
	character(1) TRAN
	real* 8 workls(2*inner)

	integer inl,node,ie
        real(8) test_var
	eps = 1.0e-6
	e1(:) = 0
	e1(1) = 1
	x0(:) = 0
	iouter = 1
	r0(:) = bg(:)
	TRAN = 'N'
	avloc(:) = 0
!	w(:) = 1
        call getnorm(r0,r0,nn_den,rnorm0)
        rnorm = sqrt(rnorm0)

!!!!!!!!!!!!!!!start outer loop!!!!!!!!!
	do 111, while((iouter .le. outer) .and. (rnorm .ge. 1.0e-9))

	Vm(:,:) = 0
	do icount = 1, nn_den
	   Vm(icount,1) = r0(icount)/rnorm
	end do ! get V1

	   beta(:) = rnorm*e1(:) ! get beta*e1
	   Hm(:,:) = 0
!!!!!!!!!!!!!!!!start inner loop!!!!!!!!!!!!!
	   do j=1,inner
	  

		 do icount=1, nn_den
		    dv(icount) = 1/w(icount)*Vm(icount,j)
		 end do!!!!!!!!!!calcule eps*inv(P)*V1
		
		avloc(:) = 0.0d0
		call blockgmres_Laplace(cal_ne,cal_domain,x,dv,avloc,ien_den)

!====================================================================================
!set residual at bc and offdomain to be 0
		do icount=1,ne_offdomain
		   ie=offdomain(icount)
		   do inl=1,nen_den
		      node=ien_den(inl,ie)
		      avloc(node)=0.0
		   end do
		end do
		do icount=1,nbc_den
		   avloc(bcnode_den(icount,1))=0.0
		end do
		do icount=1,ne_regen_ele
		   ie=regen_ele(icount)
		   do inl=1,nen_den
		      node=ien_den(inl,ie)
		      avloc(node)=0.0
		   end do
		end do
!======================================================================================
	      do i=1,j
		do icount = 1, nn_den
		   Hm(i,j)=Hm(i,j)+avloc(icount)*Vm(icount,i)
		 
		end do
	      end do  ! construct AVj and hi,j

	         
	      do icount = 1, nn_den
		 do i=1,j
		   Vm(icount,j+1) = Vm(icount,j+1)-Hm(i,j)*Vm(icount,i)
		 end do
		 Vm(icount,j+1)=Vm(icount,j+1)+avloc(icount)
	      end do  ! construct v(j+1)

	      do icount = 1, nn_den
		 temp(icount)=Vm(icount,j+1)
	      end do
	      call getnorm(temp, temp, nn_den,rnorm0)

	      Hm(j+1,j) = sqrt(rnorm0)

	      do icount = 1, nn_den
 		 Vm(icount,j+1)=Vm(icount,j+1)/Hm(j+1,j)
	      end do
	  end do  ! end inner loop
		
	call DGELS(TRAN,inner+1,inner,1,Hm,inner+1,beta,inner+1,workls,2*inner,INFO)
!!!!!!!!!!!!beta(1:inner) is ym, the solution!!!!!!!!!!!!!!!!!!!!!!!!!
	Vy(:) = 0
	do icount=1,nn_den
	   do i=1,inner
	      Vy(icount)=Vy(icount)+Vm(icount,i)*beta(i)
	   end do
	   x0(icount)=x0(icount)+Vy(icount)
	end do ! calculate Xm
	do icount = 1, nn_den
	   dv(icount) = 1.0/w(icount)*x0(icount)
	end do



	
	avloc(:) = 0.0d0
	call blockgmres_Laplace(cal_ne,cal_domain,x,dv,avloc,ien_den)
!====================================================================================
!set residual at bc and offdomain to be 0
                do icount=1,ne_offdomain
                   ie=offdomain(icount)
                   do inl=1,nen_den
                      node=ien_den(inl,ie)
                      avloc(node)=0.0
                   end do
                end do
                do icount=1,nbc_den
                   avloc(bcnode_den(icount,1))=0.0
                end do
                do icount=1,ne_regen_ele
                   ie=regen_ele(icount)
                   do inl=1,nen_den
                      node=ien_den(inl,ie)
                      avloc(node)=0.0
                   end do
                end do
!======================================================================================
!!!!!!!!!!calculate AXm
	do icount=1,nn_den
	   r0(icount) = bg(icount)-avloc(icount)
	end do !update r0=f-AX0
	call getnorm(r0,r0,nn_den,rnorm0)
	err = sqrt(rnorm0)

	rnorm = sqrt(rnorm0)
	iouter = iouter + 1        
if(myid==0) then
	write(*,*) 'err=',err
end if
111     continue  ! end outer loop
!write(*,*)'x0_2=',x0(:)

	dg(:) = 1/w(:)*x0(:) ! unscaled x0
!====================================================================================
                do icount=1,ne_offdomain
                   ie=offdomain(icount)
                   do inl=1,nen_den
                      node=ien_den(inl,ie)
                      dg(node)=0.0
                   end do
                end do
                do icount=1,nbc_den
                   dg(bcnode_den(icount,1))=0.0
                end do
                do icount=1,ne_regen_ele
                   ie=regen_ele(icount)
                   do inl=1,nen_den
                      node=ien_den(inl,ie)
                      dg(node)=0.0
                   end do
                end do
!======================================================================================

!write(*,*)'dg=',dg(:)
!write(*,*)'w=',w(:)
!stop
	return
	end subroutine gmres_Laplace_re