property pLocX, pLocY, x, y, z, pTileWidth, pType, pContent, pGameSystem

on construct me
  pContent = [:]
  return 1
end

on deconstruct me
  pContent = VOID
  return 1
end

on define me, tLocX, tLocY, tWorldX, tWorldY, tWidth, ttype, tFramework
  pLocX = tLocX
  pLocY = tLocY
  x = tWorldX
  y = tWorldY
  z = 0
  pTileWidth = tWidth
  pType = ttype
  pContent = [:]
  pGameSystem = tFramework
  return 1
end

on addContent me, tItemID, tItemProps
  pContent.addProp(tItemID, tItemProps)
  return 1
end

on removeContent me, tItemID
  pContent.deleteProp(tItemID)
  return 1
end

on getTileNeighborInDirection me, tdir
  tGameSystem = me.getGameSystem()
  if tGameSystem = 0 then
    return 0
  end if
  case tdir of
    0:
      return tGameSystem.getTile(pLocX, pLocY - 1)
    1:
      return tGameSystem.getTile(pLocX + 1, pLocY - 1)
    2:
      return tGameSystem.getTile(pLocX + 1, pLocY)
    3:
      return tGameSystem.getTile(pLocX + 1, pLocY + 1)
    4:
      return tGameSystem.getTile(pLocX, pLocY + 1)
    5:
      return tGameSystem.getTile(pLocX - 1, pLocY + 1)
    6:
      return tGameSystem.getTile(pLocX - 1, pLocY)
    7:
      return tGameSystem.getTile(pLocX - 1, pLocY - 1)
    otherwise:
      return error(me, "Invalid direction for tile:" && tdir, #getTileNeighborInDirection)
  end case
end

on getX me
  return pLocX
end

on getY me
  return pLocY
end

on getType me
  return pType
end

on getWorldX me
  return x
end

on getWorldY me
  return y
end

on getWorldZ me
  return z
end

on getWorldCoordinate me
  return [#x: x, #y: y, #z: z]
end

on getLocation me
  return [#x: pLocX, #y: pLocY]
end

on getDiameter me
  return pTileWidth * 100
end

on locationIsInTileRange me, tLocX, tLocY
  return (abs(pLocX - tLocX) <= 1) and (abs(pLocY - tLocY) <= 1)
end

on worldLocationIsInTileRange me, tLocX, tLocY
  return (abs(x - tLocX) < (pTileWidth * 100)) and (abs(y - tLocY) < (pTileWidth * 100))
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

on isBlockingLineOfSight me
  put "* DEFAULT isBlockingLineOfSight, override!"
  return 0
end

on isAvailable me
  return not me.isOccupied() and me.isFloorTile()
end

on isOccupied me
  return pContent.count > 0
end

on getOccupiedHeight me
  if pContent.count = 0 then
    return 0
  end if
  tMaxHeight = 0
  repeat with tItem in pContent
    if tItem.getaProp(#height) > tMaxHeight then
      tMaxHeight = tItem.getaProp(#height)
    end if
  end repeat
  return tMaxHeight
end

on isFloorTile me
  return integerp(integer(pType))
end

on dump me
  return "Tile:" && pLocX & "," & pLocY & ":" && me.isAvailable() && me.getOccupiedHeight()
end

on getGameSystem me
  return pGameSystem
end
