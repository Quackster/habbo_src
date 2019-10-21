on construct(me)
  pContent = []
  return(1)
  exit
end

on deconstruct(me)
  pContent = void()
  return(1)
  exit
end

on define(me, tLocX, tLocY, tWorldX, tWorldY, ttype)
  pLocX = tLocX
  pLocY = tLocY
  x = tWorldX
  y = tWorldY
  z = 0
  pType = ttype
  pContent = []
  return(1)
  exit
end

on addContent(me, tItemID, tItemProps)
  pContent.addProp(tItemID, tItemProps)
  return(1)
  exit
end

on removeContent(me, tItemID)
  pContent.deleteProp(tItemID)
  return(1)
  exit
end

on getX(me)
  return(pLocX)
  exit
end

on getY(me)
  return(pLocY)
  exit
end

on getType(me)
  return(pType)
  exit
end

on getWorldCoordinate(me)
  return([#x:x, #y:y, #z:z])
  exit
end

on getLocation(me)
  return([#x:pLocX, #y:pLocY])
  exit
end

on locationIsInTileRange(me, tLocX, tLocY)
  return(abs(pLocX - tLocX) <= 1 and abs(pLocY - tLocY) <= 1)
  exit
end

on isAvailable(me)
  return(not me.isOccupied() and me.isFloorTile())
  exit
end

on isOccupied(me)
  return(pContent.count > 0)
  exit
end

on getOccupiedHeight(me)
  if pContent.count = 0 then
    return(0)
  end if
  tMaxHeight = 0
  repeat while me <= undefined
    tItem = getAt(undefined, undefined)
    if tItem.getAt(#height) > tMaxHeight then
      tMaxHeight = tItem.getAt(#height)
    end if
  end repeat
  return(tMaxHeight)
  exit
end

on isFloorTile(me)
  return(integerp(integer(pType)))
  exit
end

on dump(me)
  return("Tile:" && pLocX & "," & pLocY & ":" && me.isAvailable() && me.getOccupiedHeight())
  exit
end