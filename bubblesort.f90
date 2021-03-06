subroutine bubblesort(a,n,m,row)
! preform bubble sort for send_address matrix 
! matirx a to be sorted
! n --- length of a
! m ---width of a
! row --- which row to be sort
use mpi_variables

implicit none

integer a(n,m)
integer n
integer m
integer row
integer b

integer i
integer j
integer count
integer tmp(1,m)

do i=n,1,-1
	do j=1,i-1
	    if (a(j,row) .lt. a(j+1,row)) then
	    	tmp(1,:) = a(j,:)
	    	a(j,:) = a(j+1,:)
	    	a(j+1,:) = tmp(1,:)
	    endif
	enddo
enddo

b=a(1,row)
countrow=1

do i=1,n
	if (a(i,row) .eq. b) then
		count=count+1
	else
	    countrow=countrow+1
	    b=a(i,row)
	endif
enddo

if (myid == 0) write(*,*) 'countrow', countrow

allocate(sub_address(countrow,2))
! sub_address(proc id, number of nodes share by this proc)

b=a(1,row)
count=0
countrow=1
do i=1,n
    if (a(i,row) .eq. b) then
	    count=count+1
	else
	    sub_address(countrow,1)=b
	    sub_address(countrow,2)=count
	    countrow=countrow+1
	    b=a(i,row)
	    count=1
	endif
enddo
sub_address(countrow,1)=b
sub_address(countrow,2)=count

end
