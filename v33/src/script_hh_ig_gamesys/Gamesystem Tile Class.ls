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

on define(me, tLocX, tLocY, tWorldX, tWorldY, tWidth, ttype, tFramework)
  pLocX = tLocX
  pLocY = tLocY
  x = tWorldX
  y = tWorldY
  z = 0
  pTileWidth = tWidth
  pType = ttype
  pContent = []
  pGameSystem = tFramework
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

on getTileNeighborInDirection(me, tdir)
  tGameSystem = me.getGameSystem()
  if tGameSystem = 0 then
    return(0)
  end if
  if me = 0 then
    return(tGameSystem.getTile(pLocX, pLocY - 1))
  else
    if me = 1 then
      return(tGameSystem.getTile(pLocX + 1, pLocY - 1))
    else
      if me = 2 then
        return(tGameSystem.getTile(pLocX + 1, pLocY))
      else
        if me = 3 then
          return(tGameSystem.getTile(pLocX + 1, pLocY + 1))
        else
          if me = 4 then
            return(tGameSystem.getTile(pLocX, pLocY + 1))
          else
            if me = 5 then
              return(tGameSystem.getTile(pLocX - 1, pLocY + 1))
            else
              if me = 6 then
                return(tGameSystem.getTile(pLocX - 1, pLocY))
              else
                if me = 7 then
                  return(tGameSystem.getTile(pLocX - 1, pLocY - 1))
                else
                  return(error(me, "Invalid direction for tile:" && tdir, #getTileNeighborInDirection))
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
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

on getWorldX(me)
  return(x)
  exit
end

on getWorldY(me)
  return(y)
  exit
end

on getWorldZ(me)
  return(z)
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

on getDiameter(me)
  return(pTileWidth * 100)
  exit
end

on locationIsInTileRange(me, tLocX, tLocY)
  return(abs(pLocX - tLocX) <= 1 and abs(pLocY - tLocY) <= 1)
  exit
end

on worldLocationIsInTileRange(me, tLocX, tLocY)
  return(abs(x - tLocX) < pTileWidth * 100 and abs(y - tLocY) < pTileWidth * 100)
  exit
end

on isInDistance(me, tLocX, tLocY, tDistance)
  tDistanceX = abs(tLocX - x)
  tDistanceY = abs(tLocY - y)
  if tDistanceY > tDistance or tDistanceX > tDistance then
    return(0)
  end if
  if tDistanceX * tDistanceX + tDistanceY * tDistanceY < tDistance * tDistance then
    return(1)
  end if
  return(0)
  exit
end

on isBlockingLineOfSight(me)
  put("* DEFAULT isBlockingLineOfSight, override!")
  return(0)
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
    if tItem.getaProp(#height) > tMaxHeight then
      tMaxHeight = tItem.getaProp(#height)
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

on getGameSystem(me)
  return(pGameSystem)
  exit
end