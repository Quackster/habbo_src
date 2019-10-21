on define(me, tX, tY, tZ, tTileWidth, tAccuracyFactor)
  x = tX
  y = tY
  z = tZ
  pTileWidth = tTileWidth
  pAccuracyFactor = tAccuracyFactor
  pTileFactor = pTileWidth * pAccuracyFactor
  return(1)
  exit
end

on setLocation(me, tX, tY, tZ)
  me.setLoc(tX, tY, tZ)
  exit
end

on setLoc(me, tX, tY, tZ)
  x = tX
  y = tY
  z = tZ
  exit
end

on getLoc(me)
  return([#x:x, #y:y, #z:z])
  exit
end

on getLocation(me)
  return([#x:x, #y:y, #z:z])
  exit
end

on setTileLoc(me, tX, tY, tZ)
  x = tX * pTileFactor
  y = tY * pTileFactor
  z = tZ * pTileFactor
  exit
end

on getTileLoc(me)
  return([#x:x + pTileFactor / 2 / pTileFactor, #y:y + pTileFactor / 2 / pTileFactor])
  exit
end

on getTileX(me)
  return(x + pTileFactor / 2 / pTileFactor)
  exit
end

on getTileY(me)
  return(y + pTileFactor / 2 / pTileFactor)
  exit
end

on getTileZ(me)
  return(z + pTileFactor / 2 / pTileFactor)
  exit
end

on dump(me)
  return("* Location:" && x && y && z & ", at tile:" && me.getTileLoc())
  exit
end