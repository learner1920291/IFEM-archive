      sh(0,1) = sq(0,1,iq) 
      sh(0,2) = sq(0,2,iq) 
      sh(0,3) = sq(0,3,iq) 
      sh(0,4) = sq(0,4,iq) 

      xr(1,1) = x(1,1) - x(1,4)
      xr(1,2) = x(2,1) - x(2,4)
      xr(1,3) = x(3,1) - x(3,4)
      xr(2,1) = x(1,2) - x(1,4)
      xr(2,2) = x(2,2) - x(2,4)
      xr(2,3) = x(3,2) - x(3,4)
      xr(3,1) = x(1,3) - x(1,4)
      xr(3,2) = x(2,3) - x(2,4)
      xr(3,3) = x(3,3) - x(3,4)

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

      det = ( xr(1,1) * cf(1,1) + xr(2,1) * cf(1,2) + xr(3,1) * cf(1,3) )

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
      sh(1,1) = sx(1,1)
      sh(1,2) = sx(2,1)
      sh(1,3) = sx(3,1)
      sh(1,4) = - sx(1,1) - sx(2,1) - sx(3,1)

      sh(2,1) = sx(1,2)
      sh(2,2) = sx(2,2)
      sh(2,3) = sx(3,2)
      sh(2,4) = - sx(1,2) - sx(2,2) - sx(3,2)

      sh(3,1) = sx(1,3)
      sh(3,2) = sx(2,3)
      sh(3,3) = sx(3,3)
      sh(3,4) = - sx(1,3) - sx(2,3) - sx(3,3)
