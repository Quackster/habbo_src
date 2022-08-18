property pGeometry, pWorldMaxY, pWorldMaxX, pTileGrid, pTileWidth, pAccuracyFactor, pObjectCache, pWorldReady, pLocationClass, pTileSpaceReserveList, pRoomGeometry, pTileLineOfSight



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

  pObjectCache = [:]

  return TRUE

end



on deconstruct me 

  pReady = 0

  pTileGrid = void()

  pComponentToAngle = void()

  pGeometry = void()

  pTileLineOfSight = void()

  return TRUE

end



on storeHeightMapArray me, tdata, tWorldWidth, tWorldHeight, tTileClass 

  pWorldMaxX = tWorldWidth

  pWorldMaxY = tWorldHeight

  return(me.createTileGrid(tdata, tTileClass))

end



on storeHeightmap me, tStr, tWorldWidth, tWorldHeight, tTileClass 

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

      tLocX = (1 + tLocX)

    end repeat

    tLocY = (1 + tLocY)

  end repeat

  return(me.createTileGrid(tdata, tTileClass))

end



on createTileGrid me, tdata, tTileClass 

  pTileGrid = []

  if (tTileClass = void()) then

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

      tTileLocX = (tLocX - 1)

      tTileLocY = (tLocY - 1)

      tCenterLocX = (tTileLocX * (pTileWidth * pAccuracyFactor))

      tCenterLocY = (tTileLocY * (pTileWidth * pAccuracyFactor))

      tTile.define(tTileLocX, tTileLocY, tCenterLocX, tCenterLocY, pTileWidth, tdata.getAt(tCount), tFramework)

      tCount = (tCount + 1)

      tLocX = (1 + tLocX)

    end repeat

    tLocY = (1 + tLocY)

  end repeat

  pWorldReady = 1

  if pObjectCache.count > 0 then

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

  repeat while tdata <= undefined

    tItem = getAt(undefined, tdata)

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

  tRow = pTileGrid.getAt(tLocY)

  if tRow.count < tLocX then

    return FALSE

  end if

  return(tRow.getAt(tLocX))

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



on reserveTileForObject me, tLocX, tLocY, tObjectId, tObjectHeight 

  tTile = me.getTile(tLocX, tLocY)

  if (tTile = 0) then

    return FALSE

  end if

  if not listp(pTileSpaceReserveList.getAt(tObjectId)) then

    pTileSpaceReserveList.setaProp(tObjectId, [])

  end if

  pTileSpaceReserveList.getAt(tObjectId).append(tTile)

  return(tTile.addContent(tObjectId, [#height:tObjectHeight]))

end



on clearObjectFromTileSpace me, tObjectId 

  if not listp(pTileSpaceReserveList.getAt(tObjectId)) then

    return TRUE

  end if

  repeat while pTileSpaceReserveList.getAt(tObjectId) <= undefined

    tTile = getAt(undefined, tObjectId)

    tTile.removeContent(tObjectId)

  end repeat

  pTileSpaceReserveList.setaProp(tObjectId, [])

  return TRUE

end



on getTileAtScreenCoordinate me, tLocX, tLocY 

  tRoomGeometry = me.getRoomGeometry()

  if (tRoomGeometry = 0) then

    return FALSE

  end if

  tloc = tRoomGeometry.getWorldCoordinate(tLocX, tLocY)

  if (tloc = 0) then

    return FALSE

  end if

  return(me.getTile(tloc.getAt(1), tloc.getAt(2)))

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



on convertTileToScreenCoordinate me, tLocX, tLocY, tlocz 

  tWorldCoordinate = me.convertTileToWorldCoordinate(tLocX, tLocY, tlocz)

  return(me.convertWorldToScreenCoordinate(tWorldCoordinate.x, tWorldCoordinate.y, tWorldCoordinate.h))

end



on convertScreenToTileCoordinate me, tLocX, tLocY 

  tRoomGeometry = me.getRoomGeometry()

  if (tRoomGeometry = 0) then

    return FALSE

  end if

  tloc = tRoomGeometry.getWorldCoordinate(tLocX, tLocY)

  if (tloc = 0) then

    return FALSE

  end if

  return([#x:tloc.getAt(1), #y:tloc.getAt(2)])

end



on convertworldtotilecoordinate me, tLocX, tLocY 

  tMultiplier = (pTileWidth * pAccuracyFactor)

  return([#x:((tLocX + (tMultiplier / 2)) / tMultiplier), #y:((tLocY + (tMultiplier / 2)) / tMultiplier)])

end



on convertWorldToScreenCoordinate me, tX, tY, tZ 

  tRoomGeometry = me.getRoomGeometry()

  if (tRoomGeometry = 0) then

    return FALSE

  end if

  tMultiplier = float((pTileWidth * pAccuracyFactor))

  tX = (0.5 + (tX / tMultiplier))

  tY = (-0.5 + (tY / tMultiplier))

  tZ = (tZ / tMultiplier)

  tloc = tRoomGeometry.getScreenCoordinate(tX, tY, tZ)

  return(tloc)

end



on testForLineOfSightInTileMatrix me, tX1, tY1, tX2, tY2, tBlockingLevel, tExcludeFirst, tExcludeLast 

  tTester = me.getTileLineOfSight()

  if (tTester = 0) then

    return FALSE

  end if

  return(tTester.testForLineOfSight(me, tX1, tY1, tX2, tY2, tBlockingLevel, tExcludeFirst, tExcludeLast))

end



on isBlockingLineOfSight me, tX, tY, tBlockingLevel 

  tTile = me.getTile(tX, tY)

  if (tTile = 0) then

    return FALSE

  end if

  return(tTile.isBlockingLineOfSight(tBlockingLevel))

end



on getWorldReady me 

  return(pWorldReady)

end



on getGeometry me 

  return(pGeometry)

end



on getRoomGeometry me 

  if not objectp(pRoomGeometry) then

    return(error(me, "Cannot locate room thread geometry object!", #getRoomGeometry))

  end if

  return(pRoomGeometry)

end



on getTileLineOfSight me 

  if not objectp(pTileLineOfSight) then

    pTileLineOfSight = createObject(#temp, getClassVariable("gamesystem.tilelineofsight.class"))

  end if

  return(pTileLineOfSight)

end

