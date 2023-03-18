property pLocX, pLocY, x, y, z, pType, pContent

on construct me
  pContent = [:]
  return 1
end

on deconstruct me
  pContent = VOID
  return 1
end

on define me, tLocX, tLocY, tWorldX, tWorldY, ttype
  pLocX = tLocX
  pLocY = tLocY
  x = tWorldX
  y = tWorldY
  z = 0
  pType = ttype
  pContent = [:]
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

on getX me
  return pLocX
end

on getY me
  return pLocY
end

on getType me
  return pType
end

on getWorldCoordinate me
  return [#x: x, #y: y, #z: z]
end

on getLocation me
  return [#x: pLocX, #y: pLocY]
end

on locationIsInTileRange me, tLocX, tLocY
  return (abs(pLocX - tLocX) <= 1) and (abs(pLocY - tLocY) <= 1)
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
    if tItem[#height] > tMaxHeight then
      tMaxHeight = tItem[#height]
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
