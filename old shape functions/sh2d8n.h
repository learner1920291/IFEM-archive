
      sh(0,1) = sq(0,1,iq)
      sh(0,2) = sq(0,2,iq)
      sh(0,3) = sq(0,3,iq)
      sh(0,4) = sq(0,4,iq)
      sh(0,5) = sq(0,5,iq)
      sh(0,6) = sq(0,6,iq)
      sh(0,7) = sq(0,7,iq)
      sh(0,8) = sq(0,8,iq)

      xr(1,1) = &
          + sq(1,1,iq) * x(1, 1) + sq(1,2,iq) * x(1, 2)  &
          + sq(1,3,iq) * x(1, 3) + sq(1,4,iq) * x(1, 4)  &
          + sq(1,5,iq) * x(1, 5) + sq(1,6,iq) * x(1, 6)  &
          + sq(1,7,iq) * x(1, 7) + sq(1,8,iq) * x(1, 8)
      xr(1,2) =  &
           + sq(1,1,iq) * x(2, 1) + sq(1,2,iq) * x(2, 2)  &
           + sq(1,3,iq) * x(2, 3) + sq(1,4,iq) * x(2, 4)  &
           + sq(1,5,iq) * x(2, 5) + sq(1,6,iq) * x(2, 6)  &
           + sq(1,7,iq) * x(2, 7) + sq(1,8,iq) * x(2, 8)  
      xr(1,3) =  &
           + sq(1,1,iq) * x(3, 1) + sq(1,2,iq) * x(3, 2)  &
           + sq(1,3,iq) * x(3, 3) + sq(1,4,iq) * x(3, 4)  &
           + sq(1,5,iq) * x(3, 5) + sq(1,6,iq) * x(3, 6)  &
           + sq(1,7,iq) * x(3, 7) + sq(1,8,iq) * x(3, 8)  
      xr(2,1) =  &
           + sq(2,1,iq) * x(1, 1) + sq(2,2,iq) * x(1, 2)  &
           + sq(2,3,iq) * x(1, 3) + sq(2,4,iq) * x(1, 4)  &
           + sq(2,5,iq) * x(1, 5) + sq(2,6,iq) * x(1, 6)  &
           + sq(2,7,iq) * x(1, 7) + sq(2,8,iq) * x(1, 8)
      xr(2,2) =  &
           + sq(2,1,iq) * x(2, 1) + sq(2,2,iq) * x(2, 2)  &
           + sq(2,3,iq) * x(2, 3) + sq(2,4,iq) * x(2, 4)  &
           + sq(2,5,iq) * x(2, 5) + sq(2,6,iq) * x(2, 6)  &
           + sq(2,7,iq) * x(2, 7) + sq(2,8,iq) * x(2, 8)
      xr(2,3) =  &
           + sq(2,1,iq) * x(3, 1) + sq(2,2,iq) * x(3, 2)  &
           + sq(2,3,iq) * x(3, 3) + sq(2,4,iq) * x(3, 4)  &
           + sq(2,5,iq) * x(3, 5) + sq(2,6,iq) * x(3, 6)  &
           + sq(2,7,iq) * x(3, 7) + sq(2,8,iq) * x(3, 8)
      xr(3,1) =  &
           + sq(3,1,iq) * x(1, 1) + sq(3,2,iq) * x(1, 2)  &
           + sq(3,3,iq) * x(1, 3) + sq(3,4,iq) * x(1, 4)  &
           + sq(3,5,iq) * x(1, 5) + sq(3,6,iq) * x(1, 6)  &
           + sq(3,7,iq) * x(1, 7) + sq(3,8,iq) * x(1, 8) 
      xr(3,2) =  &
           + sq(3,1,iq) * x(2, 1) + sq(3,2,iq) * x(2, 2)  &
           + sq(3,3,iq) * x(2, 3) + sq(3,4,iq) * x(2, 4)  &
           + sq(3,5,iq) * x(2, 5) + sq(3,6,iq) * x(2, 6)  &
           + sq(3,7,iq) * x(2, 7) + sq(3,8,iq) * x(2, 8)
      xr(3,3) =  &
           + sq(3,1,iq) * x(3, 1) + sq(3,2,iq) * x(3, 2)  &
           + sq(3,3,iq) * x(3, 3) + sq(3,4,iq) * x(3, 4)  &
           + sq(3,5,iq) * x(3, 5) + sq(3,6,iq) * x(3, 6)  &
           + sq(3,7,iq) * x(3, 7) + sq(3,8,iq) * x(3, 8)

!  jacobian
      cf(1,1) = + (xr(2,2)*xr(3,3) - xr(3,2)*xr(2,3))
      cf(1,2) = - (xr(1,2)*xr(3,3) - xr(3,2)*xr(1,3))
      cf(1,3) = + (xr(1,2)*xr(2,3) - xr(2,2)*xr(1,3))
      cf(2,1) = - (xr(2,1)*xr(3,3) - xr(3,1)*xr(2,3))
      cf(2,2) = + (xr(1,1)*xr(3,3) - xr(3,1)*xr(1,3))
      cf(2,3) = - (xr(1,1)*xr(2,3) - xr(2,1)*xr(1,3))
      cf(3,1) = + (xr(2,1)*xr(3,2) - xr(3,1)*xr(2,2))
      cf(3,2) = - (xr(1,1)*xr(3,2) - xr(3,1)*xr(1,2))
      cf(3,3) = + (xr(1,1)*xr(2,2) - xr(2,1)*xr(1,2))

      det = xr(1,1) * cf(1,1) + xr(2,1) * cf(1,2) + xr(3,1) * cf(1,3)

      sx(1,1) = cf(1,1)/det
      sx(1,2) = cf(2,1)/det
      sx(1,3) = cf(3,1)/det
      sx(2,1) = cf(1,2)/det
      sx(2,2) = cf(2,2)/det
      sx(2,3) = cf(3,2)/det
      sx(3,1) = cf(1,3)/det
      sx(3,2) = cf(2,3)/det
      sx(3,3) = cf(3,3)/det

!  global first derivatives

      sh(1,1)=sq(1,1,iq)*sx(1,1)+sq(2,1,iq)*sx(2,1)+sq(3,1,iq)*sx(3,1)
      sh(2,1)=sq(1,1,iq)*sx(1,2)+sq(2,1,iq)*sx(2,2)+sq(3,1,iq)*sx(3,2)
      sh(3,1)=sq(1,1,iq)*sx(1,3)+sq(2,1,iq)*sx(2,3)+sq(3,1,iq)*sx(3,3)
      sh(1,2)=sq(1,2,iq)*sx(1,1)+sq(2,2,iq)*sx(2,1)+sq(3,2,iq)*sx(3,1)
      sh(2,2)=sq(1,2,iq)*sx(1,2)+sq(2,2,iq)*sx(2,2)+sq(3,2,iq)*sx(3,2)
      sh(3,2)=sq(1,2,iq)*sx(1,3)+sq(2,2,iq)*sx(2,3)+sq(3,2,iq)*sx(3,3)
      sh(1,3)=sq(1,3,iq)*sx(1,1)+sq(2,3,iq)*sx(2,1)+sq(3,3,iq)*sx(3,1)
      sh(2,3)=sq(1,3,iq)*sx(1,2)+sq(2,3,iq)*sx(2,2)+sq(3,3,iq)*sx(3,2)
      sh(3,3)=sq(1,3,iq)*sx(1,3)+sq(2,3,iq)*sx(2,3)+sq(3,3,iq)*sx(3,3)
      sh(1,4)=sq(1,4,iq)*sx(1,1)+sq(2,4,iq)*sx(2,1)+sq(3,4,iq)*sx(3,1)
      sh(2,4)=sq(1,4,iq)*sx(1,2)+sq(2,4,iq)*sx(2,2)+sq(3,4,iq)*sx(3,2)
      sh(3,4)=sq(1,4,iq)*sx(1,3)+sq(2,4,iq)*sx(2,3)+sq(3,4,iq)*sx(3,3)
      sh(1,5)=sq(1,5,iq)*sx(1,1)+sq(2,5,iq)*sx(2,1)+sq(3,5,iq)*sx(3,1)
      sh(2,5)=sq(1,5,iq)*sx(1,2)+sq(2,5,iq)*sx(2,2)+sq(3,5,iq)*sx(3,2)
      sh(3,5)=sq(1,5,iq)*sx(1,3)+sq(2,5,iq)*sx(2,3)+sq(3,5,iq)*sx(3,3)
      sh(1,6)=sq(1,6,iq)*sx(1,1)+sq(2,6,iq)*sx(2,1)+sq(3,6,iq)*sx(3,1)
      sh(2,6)=sq(1,6,iq)*sx(1,2)+sq(2,6,iq)*sx(2,2)+sq(3,6,iq)*sx(3,2)
      sh(3,6)=sq(1,6,iq)*sx(1,3)+sq(2,6,iq)*sx(2,3)+sq(3,6,iq)*sx(3,3)
      sh(1,7)=sq(1,7,iq)*sx(1,1)+sq(2,7,iq)*sx(2,1)+sq(3,7,iq)*sx(3,1)
      sh(2,7)=sq(1,7,iq)*sx(1,2)+sq(2,7,iq)*sx(2,2)+sq(3,7,iq)*sx(3,2)
      sh(3,7)=sq(1,7,iq)*sx(1,3)+sq(2,7,iq)*sx(2,3)+sq(3,7,iq)*sx(3,3)
      sh(1,8)=sq(1,8,iq)*sx(1,1)+sq(2,8,iq)*sx(2,1)+sq(3,8,iq)*sx(3,1)
      sh(2,8)=sq(1,8,iq)*sx(1,2)+sq(2,8,iq)*sx(2,2)+sq(3,8,iq)*sx(3,2)
      sh(3,8)=sq(1,8,iq)*sx(1,3)+sq(2,8,iq)*sx(2,3)+sq(3,8,iq)*sx(3,3)

