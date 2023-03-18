property pTileImages, pEmptyTileImage, pTileImageRect, pPriorityTaskList, pSecondaryTaskList, pPriorityTilesPerUpdate, pSecondaryTilesPerUpdate, pWorldReady, pGeometry, pGeometryCache, pSprite, pBuffer, pMember, pOrigMemberName

on construct me
  pPriorityTilesPerUpdate = 8
  pSecondaryTilesPerUpdate = 2
  pPriorityTaskList = []
  pSecondaryTaskList = []
  pWorldReady = 0
  pGeometry = getObject(#room_interface).getGeometry()
  pTileImages = []
  repeat with tTeamId = 1 to 4
    tTemp = []
    repeat with tstate = 1 to 4
      tTemp.add(member("tile" & tTeamId & "_" & tstate).image)
    end repeat
    pTileImages.add(tTemp)
  end repeat
  pEmptyTileImage = member(getmemnum("tile0")).image
  pTileImageRect = pEmptyTileImage.rect
  pGeometryCache = []
  return 1
end

on deconstruct me
  pGeometry = VOID
  pTileImages = []
  pEmptyTileImage = []
  pGeometryCache = []
  removeUpdate(me.getID())
  me.clearAll()
end

on Refresh me, tTopic, tdata
  case tTopic of
    #fullgamestatus_tiles:
      me.initBuffer()
      receiveUpdate(me.getID())
      me.Refresh(#gamestatus_flood, tdata)
    #gamereset:
      me.initBuffer()
      receiveUpdate(me.getID())
    #world_ready:
      pWorldReady = 1
    #gamestatus_tiles:
      repeat with tTileProps in tdata
        pPriorityTaskList.add(tTileProps)
        me.removeSecondaryTask(tTileProps)
      end repeat
    #gamestatus_flood:
      repeat with tTileProps in tdata
        pSecondaryTaskList.add(tTileProps)
      end repeat
  end case
end

on update me
  if pWorldReady = 0 then
    return 0
  end if
  if pPriorityTaskList.count = 0 then
    if pSecondaryTaskList.count = 0 then
      return 1
    end if
    repeat with tTilesToRender = 1 to pSecondaryTilesPerUpdate
      if pSecondaryTaskList.count = 0 then
        return 1
      end if
      tProps = pSecondaryTaskList[1]
      pSecondaryTaskList.deleteAt(1)
      me.render(tProps)
    end repeat
  else
    repeat with tTilesToRender = 1 to pPriorityTilesPerUpdate
      tProps = pPriorityTaskList[1]
      pPriorityTaskList.deleteAt(1)
      me.render(tProps)
      if pPriorityTaskList.count = 0 then
        return me.update()
      end if
    end repeat
  end if
  return 1
end

on removeSecondaryTask me, tProps
  tLocX = tProps[#x]
  tLocY = tProps[#y]
  repeat with i = 1 to pSecondaryTaskList.count
    tItem = pSecondaryTaskList[i]
    if (tItem[#x] = tLocX) and (tItem[#y] = tLocY) then
      pSecondaryTaskList.deleteAt(i)
      return 1
    end if
  end repeat
  return 1
end

on render me, tProps
  if not (ilk(tProps) = #propList) then
    return 0
  end if
  tstate = tProps[#jumps]
  tTeamId = tProps[#teamId]
  if tstate <= 0 then
    tImage = pEmptyTileImage
  else
    if tstate > pTileImages[tTeamId].count then
      return error(me, "Invalid state on tile:" && tProps, #render)
    end if
    tImage = pTileImages[tTeamId][tstate]
  end if
  if tImage = VOID then
    return 0
  end if
  tTargetRect = me.getTileRect(tProps[#x], tProps[#y])
  if random(2) = 1 then
    pBuffer.copyPixels(tImage, tTargetRect, tImage.rect, [#ink: 36, #paletteRef: member("bb_colors_1")])
  else
    pBuffer.copyPixels(tImage, tTargetRect, tImage.rect, [#ink: 36])
  end if
  return 1
end

on getTileRect me, tX, tY
  tIndexX = tX + 1
  tIndexY = tY + 1
  if pGeometryCache.count >= tIndexY then
    if pGeometryCache[tIndexY] = 0 then
      pGeometryCache[tIndexY] = []
    end if
    if pGeometryCache[tIndexY].count >= tIndexX then
      if pGeometryCache[tIndexY][tIndexX] <> 0 then
        return pGeometryCache[tIndexY][tIndexX]
      end if
    end if
  else
    pGeometryCache[tIndexY] = []
  end if
  tHeight = 0.0
  tGameSystem = me.getGameSystem()
  if tGameSystem = 0 then
    return 0
  end if
  tWorld = tGameSystem.getWorld()
  tTile = tWorld.getTile(tX, tY)
  if tTile <> 0 then
    ttype = integer(tTile.getType())
    if integerp(ttype) then
      tHeight = ttype
    else
      return error(me, "Invalid tile height:" && tX && tY && ttype, #getTileProperties)
    end if
  else
    return error(me, "Invalid tile coordinates:" && tX && tY, #getTileProperties)
  end if
  tScreenLoc = pGeometry.getScreenCoordinate(tX, tY, tHeight)
  if pSprite = VOID then
    return 0
  end if
  tScreenLoc[1] = tScreenLoc[1] - pSprite.left + 2
  tScreenLoc[2] = tScreenLoc[2] - pSprite.top - (pTileImageRect.height / 2) - 1
  tTargetRect = pTileImageRect + rect(tScreenLoc[1], tScreenLoc[2], tScreenLoc[1], tScreenLoc[2])
  pGeometryCache[tIndexY][tIndexX] = tTargetRect
  return tTargetRect
end

on initBuffer me
  pPriorityTaskList = []
  pSecondaryTaskList = []
  tName = "bin_image"
  pMember = member(getmemnum(tName))
  tVisObj = getObject(#room_interface).getRoomVisualizer()
  if tVisObj = 0 then
    return error(me, "Room visualizer not found.", #initBuffer)
  end if
  pSprite = tVisObj.getSprById("floor")
  if pSprite = 0 then
    return error(me, "Arena floor not found.", #initBuffer)
  end if
  if pOrigMemberName = VOID then
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
  if pMember.ilk = #member then
    pMember.image = image(1, 1, 8)
  end if
  pBuffer = VOID
  pMember = VOID
  return 1
end
