property pGeometry, pRoomGeometry, pTileLineOfSight, pWorldReady, pObjectCache, pWorldMaxX, pWorldMaxY, pTileGrid, pTileSpaceReserveList, pTileWidth, pAccuracyFactor, pLocationClass

on construct me
  pLocationClass = getClassVariable("gamesystem.location.class")
  pRoomGeometry = getThread(#room).getInterface().getGeometry()
  pGeometry = createObject(#temp, getClassVariable("gamesystem.geometry.class"))
  if not objectp(pGeometry) then
    return error(me, "Cannot create pGeometry.", #construct)
  end if
  pWorldReady = 0
  pTileWidth = 32
  pAccuracyFactor = 100
  pTileGrid = []
  pTileSpaceReserveList = [:]
  pObjectCache = [:]
  return 1
end

on deconstruct me
  pReady = 0
  pTileGrid = VOID
  pComponentToAngle = VOID
  pGeometry = VOID
  pTileLineOfSight = VOID
  return 1
end

on storeHeightMapArray me, tdata, tWorldWidth, tWorldHeight, tTileClass
  pWorldMaxX = tWorldWidth
  pWorldMaxY = tWorldHeight
  return me.createTileGrid(tdata, tTileClass)
end

on storeHeightmap me, tStr, tWorldWidth, tWorldHeight, tTileClass
  if voidp(tWorldHeight) then
    pWorldMaxY = tStr.line.count
  else
    pWorldMaxY = tWorldHeight
  end if
  if voidp(tWorldWidth) then
    pWorldMaxX = tStr.line[1].length
  else
    pWorldMaxX = tWorldWidth
  end if
  tdata = []
  repeat with tLocY = 1 to pWorldMaxY
    repeat with tLocX = 1 to pWorldMaxX
      tdata.append(tStr.line[tLocY].char[tLocX])
    end repeat
  end repeat
  return me.createTileGrid(tdata, tTileClass)
end

on createTileGrid me, tdata, tTileClass
  pTileGrid = []
  if tTileClass = VOID then
    tTileClass = []
  end if
  if tTileClass.ilk <> #list then
    tTileClass = list(tTileClass)
  end if
  tTileClass.addAt(1, getClassVariable("gamesystem.tile.class"))
  tFramework = me.getFacade()
  tCount = 1
  repeat with tLocY = 1 to pWorldMaxY
    pTileGrid[tLocY] = []
    repeat with tLocX = 1 to pWorldMaxX
      tTile = createObject(#temp, tTileClass)
      pTileGrid[tLocY][tLocX] = tTile
      tTileLocX = tLocX - 1
      tTileLocY = tLocY - 1
      tCenterLocX = tTileLocX * (pTileWidth * pAccuracyFactor)
      tCenterLocY = tTileLocY * (pTileWidth * pAccuracyFactor)
      tTile.define(tTileLocX, tTileLocY, tCenterLocX, tCenterLocY, pTileWidth, tdata[tCount], tFramework)
      tCount = tCount + 1
    end repeat
  end repeat
  pWorldReady = 1
  if pObjectCache.count > 0 then
    me.storeObjects(pObjectCache)
  end if
  me.getProcManager().distributeEvent(#world_ready)
  return 1
end

on storeObjects me, tdata
  if pWorldReady = 0 then
    pObjectCache = tdata
    return 0
  end if
  repeat with tItem in tdata
    if tItem[#height] = 0 then
      if not listp(tItem[#dimensions]) then
        tItem[#height] = 0
      else
        tItem[#height] = tItem[#dimensions][2]
      end if
    end if
    if not me.reserveTileForObject(tItem[#x], tItem[#y], tItem[#id], tItem[#height]) then
      error(me, "Unable to reserve tile for furniture!", #storeObjects)
    end if
  end repeat
  me.getProcManager().distributeEvent(#objects_ready)
  return 1
end

on initLocation me, tX, tY, tZ
  tObject = createObject(#temp, pLocationClass)
  if tObject = 0 then
    return error(me, "Cannot initialize location object.", #initLocation)
  end if
  tObject.define(tX, tY, tZ, pTileWidth, pAccuracyFactor)
  return tObject
end

on initLocationAsTile me, tX, tY, tZ
  tObject = me.initLocation(tX, tY, tZ)
  if tObject = 0 then
    return 0
  end if
  tObject.setTileLoc(tX, tY, tZ)
  return tObject
end

on getTile me, tLocX, tLocY
  tLocX = tLocX + 1
  tLocY = tLocY + 1
  if (tLocX <= 0) or (tLocY <= 0) then
    return 0
  end if
  if pTileGrid.count < tLocY then
    return 0
  end if
  tRow = pTileGrid[tLocY]
  if tRow.count < tLocX then
    return 0
  end if
  return tRow[tLocX]
end

on getTileNeighborInDirection me, tX, tY, tdir
  case tdir of
    0:
      return me.getTile(tX, tY - 1)
    1:
      return me.getTile(tX + 1, tY - 1)
    2:
      return me.getTile(tX + 1, tY)
    3:
      return me.getTile(tX + 1, tY + 1)
    4:
      return me.getTile(tX, tY + 1)
    5:
      return me.getTile(tX - 1, tY + 1)
    6:
      return me.getTile(tX - 1, tY)
    7:
      return me.getTile(tX - 1, tY - 1)
    otherwise:
      return error(me, "Invalid direction for tile:" && tdir, #getTileNeighborInDirection)
  end case
end

on reserveTileForObject me, tLocX, tLocY, tObjectId, tObjectHeight
  tTile = me.getTile(tLocX, tLocY)
  if tTile = 0 then
    return 0
  end if
  if not listp(pTileSpaceReserveList[tObjectId]) then
    pTileSpaceReserveList.setaProp(tObjectId, [])
  end if
  pTileSpaceReserveList[tObjectId].append(tTile)
  return tTile.addContent(tObjectId, [#height: tObjectHeight])
end

on clearObjectFromTileSpace me, tObjectId
  if not listp(pTileSpaceReserveList[tObjectId]) then
    return 1
  end if
  repeat with tTile in pTileSpaceReserveList[tObjectId]
    tTile.removeContent(tObjectId)
  end repeat
  pTileSpaceReserveList.setaProp(tObjectId, [])
  return 1
end

on getTileAtScreenCoordinate me, tLocX, tLocY
  tRoomGeometry = me.getRoomGeometry()
  if tRoomGeometry = 0 then
    return 0
  end if
  tloc = tRoomGeometry.getWorldCoordinate(tLocX, tLocY)
  if tloc = 0 then
    return 0
  end if
  return me.getTile(tloc[1], tloc[2])
end

on gettileatworldcoordinate me, tLocX, tLocY
  tMultiplier = pTileWidth * pAccuracyFactor
  if (tLocX < -(tMultiplier / 2)) or (tLocY < -(tMultiplier / 2)) then
    return 0
  end if
  return me.getTile((tLocX + (tMultiplier / 2)) / tMultiplier, (tLocY + (tMultiplier / 2)) / tMultiplier)
end

on convertTileToWorldCoordinate me, tLocX, tLocY, tlocz
  tMultiplier = pTileWidth * pAccuracyFactor
  return [#x: tLocX * tMultiplier, #y: tLocY * tMultiplier, #h: tlocz * tMultiplier]
end

on convertTileToScreenCoordinate me, tLocX, tLocY, tlocz
  tWorldCoordinate = me.convertTileToWorldCoordinate(tLocX, tLocY, tlocz)
  return me.convertWorldToScreenCoordinate(tWorldCoordinate.x, tWorldCoordinate.y, tWorldCoordinate.h)
end

on convertScreenToTileCoordinate me, tLocX, tLocY
  tRoomGeometry = me.getRoomGeometry()
  if tRoomGeometry = 0 then
    return 0
  end if
  tloc = tRoomGeometry.getWorldCoordinate(tLocX, tLocY)
  if tloc = 0 then
    return 0
  end if
  return [#x: tloc[1], #y: tloc[2]]
end

on convertworldtotilecoordinate me, tLocX, tLocY
  tMultiplier = pTileWidth * pAccuracyFactor
  return [#x: (tLocX + (tMultiplier / 2)) / tMultiplier, #y: (tLocY + (tMultiplier / 2)) / tMultiplier]
end

on convertWorldToScreenCoordinate me, tX, tY, tZ
  tRoomGeometry = me.getRoomGeometry()
  if tRoomGeometry = 0 then
    return 0
  end if
  tMultiplier = float(pTileWidth * pAccuracyFactor)
  tX = 0.5 + (tX / tMultiplier)
  tY = -0.5 + (tY / tMultiplier)
  tZ = tZ / tMultiplier
  tloc = tRoomGeometry.getScreenCoordinate(tX, tY, tZ)
  return tloc
end

on testForLineOfSightInTileMatrix me, tX1, tY1, tX2, tY2, tBlockingLevel, tExcludeFirst, tExcludeLast
  tTester = me.getTileLineOfSight()
  if tTester = 0 then
    return 0
  end if
  return tTester.testForLineOfSight(me, tX1, tY1, tX2, tY2, tBlockingLevel, tExcludeFirst, tExcludeLast)
end

on isBlockingLineOfSight me, tX, tY, tBlockingLevel
  tTile = me.getTile(tX, tY)
  if tTile = 0 then
    return 0
  end if
  return tTile.isBlockingLineOfSight(tBlockingLevel)
end

on getWorldReady me
  return pWorldReady
end

on getGeometry me
  return pGeometry
end

on getRoomGeometry me
  if not objectp(pRoomGeometry) then
    return error(me, "Cannot locate room thread geometry object!", #getRoomGeometry)
  end if
  return pRoomGeometry
end

on getTileLineOfSight me
  if not objectp(pTileLineOfSight) then
    pTileLineOfSight = createObject(#temp, getClassVariable("gamesystem.tilelineofsight.class"))
  end if
  return pTileLineOfSight
end
