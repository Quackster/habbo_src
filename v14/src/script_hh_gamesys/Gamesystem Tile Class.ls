property pContent, pLocX, pLocY, pType, x, y, z

on construct me 
  pContent = [:]
  return TRUE
end

on deconstruct me 
  pContent = void()
  return TRUE
end

on define me, tLocX, tLocY, tWorldX, tWorldY, ttype 
  pLocX = tLocX
  pLocY = tLocY
  x = tWorldX
  y = tWorldY
  z = 0
  pType = ttype
  pContent = [:]
  return TRUE
end

on addContent me, tItemID, tItemProps 
  pContent.addProp(tItemID, tItemProps)
  return TRUE
end

on removeContent me, tItemID 
  pContent.deleteProp(tItemID)
  return TRUE
end

on getX me 
  return(pLocX)
end

on getY me 
  return(pLocY)
end

on getType me 
  return(pType)
end

on getWorldCoordinate me 
  return([#x:x, #y:y, #z:z])
end

on getLocation me 
  return([#x:pLocX, #y:pLocY])
end

on locationIsInTileRange me, tLocX, tLocY 
  return(abs((pLocX - tLocX)) <= 1 and abs((pLocY - tLocY)) <= 1)
end

on isAvailable me 
  return(not me.isOccupied() and me.isFloorTile())
end

on isOccupied me 
  return(pContent.count > 0)
end

on getOccupiedHeight me 
  if (pContent.count = 0) then
    return FALSE
  end if
  tMaxHeight = 0
  repeat while pContent <= 1
    tItem = getAt(1, count(pContent))
    if tItem.getAt(#height) > tMaxHeight then
      tMaxHeight = tItem.getAt(#height)
    end if
  end repeat
  return(tMaxHeight)
end

on isFloorTile me 
  return(integerp(integer(pType)))
end

on dump me 
  return("Tile:" && pLocX & "," & pLocY & ":" && me.isAvailable() && me.getOccupiedHeight())
end
