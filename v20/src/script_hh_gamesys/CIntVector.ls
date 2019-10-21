on new(me, a_iX, a_iY, a_iZ)
  x = integer(a_iX)
  y = integer(a_iY)
  z = integer(a_iZ)
  return(me)
  exit
end

on ilk(me)
  return(#intvector)
  exit
end

on length(me)
  return(abs(x) + abs(y) + abs(z) / 3)
  exit
end

on add(me, a_rVec)
  return(intvector(x + a_rVec.x, y + a_rVec.y, z + a_rVec.z))
  exit
end

on substract(me, a_rVec)
  return(intvector(x - a_rVec.x, y - a_rVec.y, z - a_rVec.z))
  exit
end

on multiply(me, a_rScalar)
  return(intvector(x * a_rScalar, y * a_rScalar, z * a_rScalar))
  exit
end

on divide(me, a_rScalar)
  return(intvector(x / a_rScalar, y / a_rScalar, z / a_rScalar))
  exit
end

on dot(me, a_rVec)
  return(x * a_rVec.x + y * a_rVec.y + z * a_rVec.z)
  exit
end

on cross(me, a_rVec)
  return(intvector(y * a_rVec.z - z * a_rVec.y, z * a_rVec.x - x * a_rVec.z, x * a_rVec.y - y * a_rVec.x))
  exit
end

on dump(me)
  put("* Vector" && x && y && z)
  exit
end