property x, y, z, pTileWidth, pAccuracyFactor, pTileFactor

on define me, tX, tY, tZ, tTileWidth, tAccuracyFactor
  x = tX
  y = tY
  z = tZ
  pTileWidth = tTileWidth
  pAccuracyFactor = tAccuracyFactor
  pTileFactor = pTileWidth * pAccuracyFactor
  return 1
end

on setLocation me, tX, tY, tZ
  me.setLoc(tX, tY, tZ)
end

on setLoc me, tX, tY, tZ
  x = tX
  y = tY
  z = tZ
end

on getLoc me
  return [#x: x, #y: y, #z: z]
end

on getLocation me
  return [#x: x, #y: y, #z: z]
end

on setTileLoc me, tX, tY, tZ
  x = tX * pTileFactor
  y = tY * pTileFactor
  z = tZ * pTileFactor
end

on getTileLoc me
  return [#x: (x + (pTileFactor / 2)) / pTileFactor, #y: (y + (pTileFactor / 2)) / pTileFactor]
end

on getTileX me
  return (x + (pTileFactor / 2)) / pTileFactor
end

on getTileY me
  return (y + (pTileFactor / 2)) / pTileFactor
end

on getTileZ me
  return (z + (pTileFactor / 2)) / pTileFactor
end

on isInDistance me, tLocX, tLocY, tDistance
  tDistanceX = abs(tLocX - x)
  tDistanceY = abs(tLocY - y)
  if (tDistanceY > tDistance) or (tDistanceX > tDistance) then
    return 0
  end if
  if ((tDistanceX * tDistanceX) + (tDistanceY * tDistanceY)) < (tDistance * tDistance) then
    return 1
  end if
  return 0
end

on dump me
  return "* Location:" && x && y && z & ", at tile:" && me.getTileLoc()
end
