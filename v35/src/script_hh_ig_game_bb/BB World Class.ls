property pTileImages, pEmptyTileImage, pPriorityTaskList, pSecondaryTaskList, pWorldReady, pSecondaryTilesPerUpdate, pPriorityTilesPerUpdate, pBuffer, pGeometryCache, pGeometry, pSprite, pTileImageRect, pOrigMemberName, pMember

on construct me 
  pPriorityTilesPerUpdate = 8
  pSecondaryTilesPerUpdate = 2
  pPriorityTaskList = []
  pSecondaryTaskList = []
  pWorldReady = 0
  pGeometry = getObject(#room_interface).getGeometry()
  pTileImages = []
  tTeamId = 1
  repeat while tTeamId <= 4
    tTemp = []
    tstate = 1
    repeat while tstate <= 4
      tTemp.add(member("tile" & tTeamId & "_" & tstate).image)
      tstate = (1 + tstate)
    end repeat
    pTileImages.add(tTemp)
    tTeamId = (1 + tTeamId)
  end repeat
  pEmptyTileImage = member(getmemnum("tile0")).image
  pTileImageRect = pEmptyTileImage.rect
  pGeometryCache = []
  return TRUE
end

on deconstruct me 
  pGeometry = void()
  pTileImages = []
  pEmptyTileImage = []
  pGeometryCache = []
  removeUpdate(me.getID())
  me.clearAll()
end

on Refresh me, tTopic, tdata 
  if (tTopic = #fullgamestatus_tiles) then
    me.initBuffer()
    receiveUpdate(me.getID())
    me.Refresh(#gamestatus_flood, tdata)
  else
    if (tTopic = #gamereset) then
      me.initBuffer()
      receiveUpdate(me.getID())
    else
      if (tTopic = #world_ready) then
        pWorldReady = 1
      else
        if (tTopic = #gamestatus_tiles) then
          repeat while tTopic <= tdata
            tTileProps = getAt(tdata, tTopic)
            pPriorityTaskList.add(tTileProps)
            me.removeSecondaryTask(tTileProps)
          end repeat
        else
          if (tTopic = #gamestatus_flood) then
            repeat while tTopic <= tdata
              tTileProps = getAt(tdata, tTopic)
              pSecondaryTaskList.add(tTileProps)
            end repeat
          end if
        end if
      end if
    end if
  end if
end

on update me 
  if (pWorldReady = 0) then
    return FALSE
  end if
  if (pPriorityTaskList.count = 0) then
    if (pSecondaryTaskList.count = 0) then
      return TRUE
    end if
    tTilesToRender = 1
    repeat while tTilesToRender <= pSecondaryTilesPerUpdate
      if (pSecondaryTaskList.count = 0) then
        return TRUE
      end if
      tProps = pSecondaryTaskList.getAt(1)
      pSecondaryTaskList.deleteAt(1)
      me.render(tProps)
      tTilesToRender = (1 + tTilesToRender)
    end repeat
    exit repeat
  end if
  tTilesToRender = 1
  repeat while tTilesToRender <= pPriorityTilesPerUpdate
    tProps = pPriorityTaskList.getAt(1)
    pPriorityTaskList.deleteAt(1)
    me.render(tProps)
    if (pPriorityTaskList.count = 0) then
      return(me.update())
    end if
    tTilesToRender = (1 + tTilesToRender)
  end repeat
  return TRUE
end

on removeSecondaryTask me, tProps 
  tLocX = tProps.getAt(#x)
  tLocY = tProps.getAt(#y)
  i = 1
  repeat while i <= pSecondaryTaskList.count
    tItem = pSecondaryTaskList.getAt(i)
    if (tItem.getAt(#x) = tLocX) and (tItem.getAt(#y) = tLocY) then
      pSecondaryTaskList.deleteAt(i)
      return TRUE
    end if
    i = (1 + i)
  end repeat
  return TRUE
end

on render me, tProps 
  if not (ilk(tProps) = #propList) then
    return FALSE
  end if
  tstate = tProps.getAt(#jumps)
  tTeamId = tProps.getAt(#teamId)
  if tstate <= 0 then
    tImage = pEmptyTileImage
  else
    if tstate > pTileImages.getAt(tTeamId).count then
      return(error(me, "Invalid state on tile:" && tProps, #render))
    end if
    tImage = pTileImages.getAt(tTeamId).getAt(tstate)
  end if
  if (tImage = void()) then
    return FALSE
  end if
  tTargetRect = me.getTileRect(tProps.getAt(#x), tProps.getAt(#y))
  if (random(2) = 1) then
    pBuffer.copyPixels(tImage, tTargetRect, tImage.rect, [#ink:36, #paletteRef:member("bb_colors_1")])
  else
    pBuffer.copyPixels(tImage, tTargetRect, tImage.rect, [#ink:36])
  end if
  return TRUE
end

on getTileRect me, tX, tY 
  tIndexX = (tX + 1)
  tIndexY = (tY + 1)
  if pGeometryCache.count >= tIndexY then
    if (pGeometryCache.getAt(tIndexY) = 0) then
      pGeometryCache.setAt(tIndexY, [])
    end if
    if pGeometryCache.getAt(tIndexY).count >= tIndexX then
      if pGeometryCache.getAt(tIndexY).getAt(tIndexX) <> 0 then
        return(pGeometryCache.getAt(tIndexY).getAt(tIndexX))
      end if
    end if
  else
    pGeometryCache.setAt(tIndexY, [])
  end if
  tHeight = 0
  tGameSystem = me.getGameSystem()
  if (tGameSystem = 0) then
    return FALSE
  end if
  tWorld = tGameSystem.getWorld()
  tTile = tWorld.getTile(tX, tY)
  if tTile <> 0 then
    ttype = integer(tTile.getType())
    if integerp(ttype) then
      tHeight = ttype
    else
      return(error(me, "Invalid tile height:" && tX && tY && ttype, #getTileProperties))
    end if
  else
    return(error(me, "Invalid tile coordinates:" && tX && tY, #getTileProperties))
  end if
  tScreenLoc = pGeometry.getScreenCoordinate(tX, tY, tHeight)
  if (pSprite = void()) then
    return FALSE
  end if
  tScreenLoc.setAt(1, ((tScreenLoc.getAt(1) - pSprite.left) + 2))
  tScreenLoc.setAt(2, (((tScreenLoc.getAt(2) - pSprite.top) - (pTileImageRect.height / 2)) - 1))
  tTargetRect = (pTileImageRect + rect(tScreenLoc.getAt(1), tScreenLoc.getAt(2), tScreenLoc.getAt(1), tScreenLoc.getAt(2)))
  pGeometryCache.getAt(tIndexY).setAt(tIndexX, tTargetRect)
  return(tTargetRect)
end

on initBuffer me 
  pPriorityTaskList = []
  pSecondaryTaskList = []
  tName = "bin_image"
  pMember = member(getmemnum(tName))
  tVisObj = getObject(#room_interface).getRoomVisualizer()
  if (tVisObj = 0) then
    return(error(me, "Room visualizer not found.", #initBuffer))
  end if
  pSprite = tVisObj.getSprById("floor")
  if (pSprite = 0) then
    return(error(me, "Arena floor not found.", #initBuffer))
  end if
  if (pOrigMemberName = void()) then
    pOrigMemberName = pSprite.member.name
  end if
  tOrigMember = member(getmemnum(pOrigMemberName))
  tImg = tOrigMember.image
  pMember.image = image(tImg.width, tImg.height, 8)
  pMember.paletteRef = tOrigMember.paletteRef
  pMember.image.copyPixels(tImg, tImg.rect, tImg.rect)
  pMember.regPoint = tOrigMember.regPoint
  pBuffer = pMember.image
  pSprite.setMember(pMember)
end

on clearAll me 
  if (pMember.ilk = #member) then
    pMember.image = image(1, 1, 8)
  end if
  pBuffer = void()
  pMember = void()
  return TRUE
end
