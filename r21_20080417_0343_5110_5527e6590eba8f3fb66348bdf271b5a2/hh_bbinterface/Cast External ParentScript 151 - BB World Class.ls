property pTileImages, pPriorityTaskList, pSecondaryTaskList, pPriorityTilesPerUpdate, pGeometry, pSprite, pBuffer, pMember

on construct me
  pPriorityTilesPerUpdate = 4
  pPriorityTaskList = []
  pSecondaryTaskList = []
  pGeometry = getObject(#room_interface).getGeometry()
  pTileImages = []
  repeat with tTeamId = 1 to 4
    tTemp = []
    repeat with tstate = 1 to 4
      tTemp.add(member("tile" & tTeamId & "_" & tstate).image)
    end repeat
    pTileImages.add(tTemp)
  end repeat
  return 1
end

on deconstruct me
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
  if pPriorityTaskList.count = 0 then
    if pSecondaryTaskList.count = 0 then
      return 1
    end if
    tProps = pSecondaryTaskList[1]
    pSecondaryTaskList.deleteAt(1)
    me.render(tProps)
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
  tLocX = tProps[#locX]
  tLocY = tProps[#locY]
  repeat with i = 1 to pSecondaryTaskList.count
    tItem = pSecondaryTaskList[i]
    if (tItem[#locX] = tLocX) and (tItem[#locY] = tLocY) then
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
  tTeamId = tProps[#teamId] + 1
  if tstate = 0 then
    return 1
  end if
  tImage = pTileImages[tTeamId][tstate]
  if tImage = VOID then
    return 0
  end if
  tScreenLoc = pGeometry.getScreenCoordinate(tProps[#locX], tProps[#locY], 0.0)
  if pSprite = VOID then
    return 0
  end if
  tScreenLoc[1] = tScreenLoc[1] - pSprite.left + 2
  tScreenLoc[2] = tScreenLoc[2] - pSprite.top - (tImage.height / 2) - 1
  tTargetRect = tImage.rect + rect(tScreenLoc[1], tScreenLoc[2], tScreenLoc[1], tScreenLoc[2])
  pBuffer.copyPixels(tImage, tTargetRect, tImage.rect, [#ink: 36])
  return 1
end

on initBuffer me
  pPriorityTaskList = []
  pSecondaryTaskList = []
  tName = "__bounce_tempworld"
  if getmemnum(tName) = 0 then
    pMember = member(createMember(tName, #bitmap))
  else
    pMember = member(getmemnum(tName))
  end if
  tVisObj = getObject(#room_interface).getRoomVisualizer()
  if tVisObj = 0 then
    return error(me, "Room visualizer not found.", #initBuffer)
  end if
  pSprite = tVisObj.getSprById("floor")
  if pSprite = 0 then
    return error(me, "Arena floor not found.", #initBuffer)
  end if
  tImg = member("bb_arena").image
  pMember.image = image(tImg.width, tImg.height, 8)
  pMember.image.copyPixels(tImg, tImg.rect, tImg.rect)
  pMember.regPoint = member("bb_arena").regPoint
  pBuffer = pMember.image
  pSprite.setMember(pMember)
  return 1
end

on clearAll me
  pBuffer = VOID
  if pMember <> VOID then
    removeMember(pMember.name)
  end if
  pMember = VOID
  return 1
end
