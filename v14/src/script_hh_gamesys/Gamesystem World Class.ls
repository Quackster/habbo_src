property pGeometry, pWorldMaxY, pTileGrid, pWorldMaxX, pTileWidth, pAccuracyFactor, pObjectCache, pWorldReady, pLocationClass, pTileSpaceReserveList, pRoomGeometry

on construct me 
  pLocationClass = getClassVariable("gamesystem.location.class")
  pRoomGeometry = getThread(#room).getInterface().getGeometry()
  pGeometry = createObject(#temp, getClassVariable("gamesystem.geometry.class"))
  if not objectp(pGeometry) then
    return(error(me, "Cannot create pGeometry.", #construct))
  end if
  pWorldReady = 0
  pTileWidth = 32
  pAccuracyFactor = 100
  pTileGrid = []
  pTileSpaceReserveList = [:]
  return TRUE
end

on deconstruct me 
  pReady = 0
  pTileGrid = void()
  pComponentToAngle = void()
  pGeometry = void()
  return TRUE
end

on storeHeightmap me, tdata 
  pReceivedMap = tdata
  pWorldMaxY = tdata.count(#line)
  pWorldMaxX = tdata.getPropRef(#line, 1).length
  pTileGrid = []
  tTileClass = getClassVariable("gamesystem.tile.class")
  tLocY = 1
  repeat while tLocY <= pWorldMaxY
    pTileGrid.setAt(tLocY, [])
    tLocX = 1
    repeat while tLocX <= pWorldMaxX
      tTile = createObject(#temp, tTileClass)
      pTileGrid.getAt(tLocY).setAt(tLocX, tTile)
      tTileLocX = (tLocX - 1)
      tTileLocY = (tLocY - 1)
      tCenterLocX = (tTileLocX * (pTileWidth * pAccuracyFactor))
      tCenterLocY = (tTileLocY * (pTileWidth * pAccuracyFactor))
      tTile.define(tTileLocX, tTileLocY, tCenterLocX, tCenterLocY, tdata.getPropRef(#line, tLocY).getProp(#char, tLocX))
      tLocX = (1 + tLocX)
    end repeat
    tLocY = (1 + tLocY)
  end repeat
  pWorldReady = 1
  if pObjectCache <> void() then
    me.storeObjects(pObjectCache)
  end if
  me.getProcManager().distributeEvent(#world_ready)
  return TRUE
end

on storeObjects me, tdata 
  if (pWorldReady = 0) then
    pObjectCache = tdata
    return FALSE
  end if
  repeat while tdata <= 1
    tItem = getAt(1, count(tdata))
    if (tItem.getAt(#height) = 0) then
      if not listp(tItem.getAt(#dimensions)) then
        tItem.setAt(#height, 0)
      else
        tItem.setAt(#height, tItem.getAt(#dimensions).getAt(2))
      end if
    end if
    if not me.reserveTileForObject(tItem.getAt(#x), tItem.getAt(#y), tItem.getAt(#id), tItem.getAt(#height)) then
      error(me, "Unable to reserve tile for furniture!", #storeObjects)
    end if
  end repeat
  me.getProcManager().distributeEvent(#objects_ready)
  return TRUE
end

on initLocation me, tX, tY, tZ 
  tObject = createObject(#temp, pLocationClass)
  if (tObject = 0) then
    return(error(me, "Cannot initialize location object.", #initLocation))
  end if
  tObject.define(tX, tY, tZ, pTileWidth, pAccuracyFactor)
  return(tObject)
end

on initLocationAsTile me, tX, tY, tZ 
  tObject = me.initLocation(tX, tY, tZ)
  if (tObject = 0) then
    return FALSE
  end if
  tObject.setTileLoc(tX, tY, tZ)
  return(tObject)
end

on getTile me, tLocX, tLocY 
  tLocX = (tLocX + 1)
  tLocY = (tLocY + 1)
  if tLocX <= 0 or tLocY <= 0 then
    return FALSE
  end if
  if pTileGrid.count < tLocY then
    return FALSE
  end if
  if pTileGrid.getAt(tLocY).count < tLocX then
    return FALSE
  end if
  return(pTileGrid.getAt(tLocY).getAt(tLocX))
end

on getTileNeighborInDirection me, tX, tY, tdir 
  if (tdir = 0) then
    return(me.getTile(tX, (tY - 1)))
  else
    if (tdir = 1) then
      return(me.getTile((tX + 1), (tY - 1)))
    else
      if (tdir = 2) then
        return(me.getTile((tX + 1), tY))
      else
        if (tdir = 3) then
          return(me.getTile((tX + 1), (tY + 1)))
        else
          if (tdir = 4) then
            return(me.getTile(tX, (tY + 1)))
          else
            if (tdir = 5) then
              return(me.getTile((tX - 1), (tY + 1)))
            else
              if (tdir = 6) then
                return(me.getTile((tX - 1), tY))
              else
                if (tdir = 7) then
                  return(me.getTile((tX - 1), (tY - 1)))
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
end

on reserveTileForObject me, tLocX, tLocY, tObjectID, tObjectHeight 
  tTile = me.getTile(tLocX, tLocY)
  if (tTile = 0) then
    return FALSE
  end if
  if not listp(pTileSpaceReserveList.getAt(tObjectID)) then
    pTileSpaceReserveList.setaProp(tObjectID, [])
  end if
  pTileSpaceReserveList.getAt(tObjectID).append(tTile)
  return(tTile.addContent(tObjectID, [#height:tObjectHeight]))
end

on clearObjectFromTileSpace me, tObjectID 
  if not listp(pTileSpaceReserveList.getAt(tObjectID)) then
    return TRUE
  end if
  repeat while pTileSpaceReserveList.getAt(tObjectID) <= 1
    tTile = getAt(1, count(pTileSpaceReserveList.getAt(tObjectID)))
    tTile.removeContent(tObjectID)
  end repeat
  pTileSpaceReserveList.setaProp(tObjectID, [])
  return TRUE
end

on gettileatworldcoordinate me, tLocX, tLocY 
  tMultiplier = (pTileWidth * pAccuracyFactor)
  if tLocX < -(tMultiplier / 2) or tLocY < -(tMultiplier / 2) then
    return FALSE
  end if
  return(me.getTile(((tLocX + (tMultiplier / 2)) / tMultiplier), ((tLocY + (tMultiplier / 2)) / tMultiplier)))
end

on convertTileToWorldCoordinate me, tLocX, tLocY, tlocz 
  tMultiplier = (pTileWidth * pAccuracyFactor)
  return([#x:(tLocX * tMultiplier), #y:(tLocY * tMultiplier), #h:(tlocz * tMultiplier)])
end

on convertworldtotilecoordinate me, tLocX, tLocY, tlocz 
  tMultiplier = (pTileWidth * pAccuracyFactor)
  return([#x:((tLocX + (tMultiplier / 2)) / tMultiplier), #y:((tLocY + (tMultiplier / 2)) / tMultiplier)])
  return([#x:(tLocX * tMultiplier), #y:(tLocY * tMultiplier), #h:(tlocz * tMultiplier)])
end

on convertWorldToScreenCoordinate me, tX, tY, tZ 
  if (pRoomGeometry = 0) then
    return FALSE
  end if
  tMultiplier = float((pTileWidth * pAccuracyFactor))
  tX = (0.5 + (tX / tMultiplier))
  tY = (-0.5 + (tY / tMultiplier))
  tZ = (tZ / tMultiplier)
  tloc = pRoomGeometry.getScreenCoordinate(tX, tY, tZ)
  return(tloc)
end

on getWorldReady me 
  return(pWorldReady)
end

on getGeometry me 
  return(pGeometry)
end
