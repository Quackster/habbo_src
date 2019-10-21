on construct(me)
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
  pTileSpaceReserveList = []
  pObjectCache = []
  return(1)
  exit
end

on deconstruct(me)
  pReady = 0
  pTileGrid = void()
  pComponentToAngle = void()
  pGeometry = void()
  pTileLineOfSight = void()
  return(1)
  exit
end

on storeHeightMapArray(me, tdata, tWorldWidth, tWorldHeight, tTileClass)
  pWorldMaxX = tWorldWidth
  pWorldMaxY = tWorldHeight
  return(me.createTileGrid(tdata, tTileClass))
  exit
end

on storeHeightmap(me, tStr, tWorldWidth, tWorldHeight, tTileClass)
  if voidp(tWorldHeight) then
    pWorldMaxY = tStr.count(#line)
  else
    pWorldMaxY = tWorldHeight
  end if
  if voidp(tWorldWidth) then
    pWorldMaxX = tStr.getPropRef(#line, 1).length
  else
    pWorldMaxX = tWorldWidth
  end if
  tdata = []
  tLocY = 1
  repeat while tLocY <= pWorldMaxY
    tLocX = 1
    repeat while tLocX <= pWorldMaxX
      tdata.append(tStr.getPropRef(#line, tLocY).getProp(#char, tLocX))
      tLocX = 1 + tLocX
    end repeat
    tLocY = 1 + tLocY
  end repeat
  return(me.createTileGrid(tdata, tTileClass))
  exit
end

on createTileGrid(me, tdata, tTileClass)
  pTileGrid = []
  if tTileClass = void() then
    tTileClass = []
  end if
  if tTileClass.ilk <> #list then
    tTileClass = list(tTileClass)
  end if
  tTileClass.addAt(1, getClassVariable("gamesystem.tile.class"))
  tFramework = me.getFacade()
  tCount = 1
  tLocY = 1
  repeat while tLocY <= pWorldMaxY
    pTileGrid.setAt(tLocY, [])
    tLocX = 1
    repeat while tLocX <= pWorldMaxX
      tTile = createObject(#temp, tTileClass)
      pTileGrid.getAt(tLocY).setAt(tLocX, tTile)
      tTileLocX = tLocX - 1
      tTileLocY = tLocY - 1
      tCenterLocX = tTileLocX * pTileWidth * pAccuracyFactor
      tCenterLocY = tTileLocY * pTileWidth * pAccuracyFactor
      tTile.define(tTileLocX, tTileLocY, tCenterLocX, tCenterLocY, pTileWidth, tdata.getAt(tCount), tFramework)
      tCount = tCount + 1
      tLocX = 1 + tLocX
    end repeat
    tLocY = 1 + tLocY
  end repeat
  pWorldReady = 1
  if pObjectCache.count > 0 then
    me.storeObjects(pObjectCache)
  end if
  me.getProcManager().distributeEvent(#world_ready)
  return(1)
  exit
end

on storeObjects(me, tdata)
  if pWorldReady = 0 then
    pObjectCache = tdata
    return(0)
  end if
  repeat while me <= undefined
    tItem = getAt(undefined, tdata)
    if tItem.getAt(#height) = 0 then
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
  return(1)
  exit
end

on initLocation(me, tX, tY, tZ)
  tObject = createObject(#temp, pLocationClass)
  if tObject = 0 then
    return(error(me, "Cannot initialize location object.", #initLocation))
  end if
  tObject.define(tX, tY, tZ, pTileWidth, pAccuracyFactor)
  return(tObject)
  exit
end

on initLocationAsTile(me, tX, tY, tZ)
  tObject = me.initLocation(tX, tY, tZ)
  if tObject = 0 then
    return(0)
  end if
  tObject.setTileLoc(tX, tY, tZ)
  return(tObject)
  exit
end

on getTile(me, tLocX, tLocY)
  tLocX = tLocX + 1
  tLocY = tLocY + 1
  if tLocX <= 0 or tLocY <= 0 then
    return(0)
  end if
  if pTileGrid.count < tLocY then
    return(0)
  end if
  tRow = pTileGrid.getAt(tLocY)
  if tRow.count < tLocX then
    return(0)
  end if
  return(tRow.getAt(tLocX))
  exit
end

on getTileNeighborInDirection(me, tX, tY, tdir)
  if me = 0 then
    return(me.getTile(tX, tY - 1))
  else
    if me = 1 then
      return(me.getTile(tX + 1, tY - 1))
    else
      if me = 2 then
        return(me.getTile(tX + 1, tY))
      else
        if me = 3 then
          return(me.getTile(tX + 1, tY + 1))
        else
          if me = 4 then
            return(me.getTile(tX, tY + 1))
          else
            if me = 5 then
              return(me.getTile(tX - 1, tY + 1))
            else
              if me = 6 then
                return(me.getTile(tX - 1, tY))
              else
                if me = 7 then
                  return(me.getTile(tX - 1, tY - 1))
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

on reserveTileForObject(me, tLocX, tLocY, tObjectId, tObjectHeight)
  tTile = me.getTile(tLocX, tLocY)
  if tTile = 0 then
    return(0)
  end if
  if not listp(pTileSpaceReserveList.getAt(tObjectId)) then
    pTileSpaceReserveList.setaProp(tObjectId, [])
  end if
  pTileSpaceReserveList.getAt(tObjectId).append(tTile)
  return(tTile.addContent(tObjectId, [#height:tObjectHeight]))
  exit
end

on clearObjectFromTileSpace(me, tObjectId)
  if not listp(pTileSpaceReserveList.getAt(tObjectId)) then
    return(1)
  end if
  repeat while me <= undefined
    tTile = getAt(undefined, tObjectId)
    tTile.removeContent(tObjectId)
  end repeat
  pTileSpaceReserveList.setaProp(tObjectId, [])
  return(1)
  exit
end

on getTileAtScreenCoordinate(me, tLocX, tLocY)
  tRoomGeometry = me.getRoomGeometry()
  if tRoomGeometry = 0 then
    return(0)
  end if
  tloc = tRoomGeometry.getWorldCoordinate(tLocX, tLocY)
  if tloc = 0 then
    return(0)
  end if
  return(me.getTile(tloc.getAt(1), tloc.getAt(2)))
  exit
end

on gettileatworldcoordinate(me, tLocX, tLocY)
  tMultiplier = pTileWidth * pAccuracyFactor
  if tLocX < -tMultiplier / 2 or tLocY < -tMultiplier / 2 then
    return(0)
  end if
  return(me.getTile(tLocX + tMultiplier / 2 / tMultiplier, tLocY + tMultiplier / 2 / tMultiplier))
  exit
end

on convertTileToWorldCoordinate(me, tLocX, tLocY, tlocz)
  tMultiplier = pTileWidth * pAccuracyFactor
  return([#x:tLocX * tMultiplier, #y:tLocY * tMultiplier, #h:tlocz * tMultiplier])
  exit
end

on convertTileToScreenCoordinate(me, tLocX, tLocY, tlocz)
  tWorldCoordinate = me.convertTileToWorldCoordinate(tLocX, tLocY, tlocz)
  return(me.convertWorldToScreenCoordinate(tWorldCoordinate.x, tWorldCoordinate.y, tWorldCoordinate.h))
  exit
end

on convertScreenToTileCoordinate(me, tLocX, tLocY)
  tRoomGeometry = me.getRoomGeometry()
  if tRoomGeometry = 0 then
    return(0)
  end if
  tloc = tRoomGeometry.getWorldCoordinate(tLocX, tLocY)
  if tloc = 0 then
    return(0)
  end if
  return([#x:tloc.getAt(1), #y:tloc.getAt(2)])
  exit
end

on convertworldtotilecoordinate(me, tLocX, tLocY)
  tMultiplier = pTileWidth * pAccuracyFactor
  return([#x:tLocX + tMultiplier / 2 / tMultiplier, #y:tLocY + tMultiplier / 2 / tMultiplier])
  exit
end

on convertWorldToScreenCoordinate(me, tX, tY, tZ)
  tRoomGeometry = me.getRoomGeometry()
  if tRoomGeometry = 0 then
    return(0)
  end if
  tMultiplier = float(pTileWidth * pAccuracyFactor)
  tX = 0 + tX / tMultiplier
  tY = -0 + tY / tMultiplier
  tZ = tZ / tMultiplier
  tloc = tRoomGeometry.getScreenCoordinate(tX, tY, tZ)
  return(tloc)
  exit
end

on testForLineOfSightInTileMatrix(me, tX1, tY1, tX2, tY2, tBlockingLevel, tExcludeFirst, tExcludeLast)
  tTester = me.getTileLineOfSight()
  if tTester = 0 then
    return(0)
  end if
  return(tTester.testForLineOfSight(me, tX1, tY1, tX2, tY2, tBlockingLevel, tExcludeFirst, tExcludeLast))
  exit
end

on isBlockingLineOfSight(me, tX, tY, tBlockingLevel)
  tTile = me.getTile(tX, tY)
  if tTile = 0 then
    return(0)
  end if
  return(tTile.isBlockingLineOfSight(tBlockingLevel))
  exit
end

on getWorldReady(me)
  return(pWorldReady)
  exit
end

on getGeometry(me)
  return(pGeometry)
  exit
end

on getRoomGeometry(me)
  if not objectp(pRoomGeometry) then
    return(error(me, "Cannot locate room thread geometry object!", #getRoomGeometry))
  end if
  return(pRoomGeometry)
  exit
end

on getTileLineOfSight(me)
  if not objectp(pTileLineOfSight) then
    pTileLineOfSight = createObject(#temp, getClassVariable("gamesystem.tilelineofsight.class"))
  end if
  return(pTileLineOfSight)
  exit
end