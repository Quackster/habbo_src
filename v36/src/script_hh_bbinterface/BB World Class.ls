property pTileImages, pPriorityTaskList, pSecondaryTaskList, pPriorityTilesPerUpdate, pGeometry, pSprite, pBuffer, pMember

on construct me 
  pPriorityTilesPerUpdate = 4
  pPriorityTaskList = []
  pSecondaryTaskList = []
  pGeometry = getObject(#room_interface).getGeometry()
  pTileImages = []
  tTeamId = 1
  repeat while tTeamId <= 4
    tTemp = []
    tstate = 1
    repeat while tstate <= 4
      tTemp.add(member("tile" & tTeamId & "_" & tstate).image)
      tstate = 1 + tstate
    end repeat
    pTileImages.add(tTemp)
    tTeamId = 1 + tTeamId
  end repeat
  return(1)
end

on deconstruct me 
  removeUpdate(me.getID())
  me.clearAll()
end

on Refresh me, tTopic, tdata 
  if tTopic = #fullgamestatus_tiles then
    me.initBuffer()
    receiveUpdate(me.getID())
    me.Refresh(#gamestatus_flood, tdata)
  else
    if tTopic = #gamereset then
      me.initBuffer()
      receiveUpdate(me.getID())
    else
      if tTopic = #gamestatus_tiles then
        repeat while tTopic <= tdata
          tTileProps = getAt(tdata, tTopic)
          pPriorityTaskList.add(tTileProps)
          me.removeSecondaryTask(tTileProps)
        end repeat
      else
        if tTopic = #gamestatus_flood then
          repeat while tTopic <= tdata
            tTileProps = getAt(tdata, tTopic)
            pSecondaryTaskList.add(tTileProps)
          end repeat
        end if
      end if
    end if
  end if
end

on update me 
  if pPriorityTaskList.count = 0 then
    if pSecondaryTaskList.count = 0 then
      return(1)
    end if
    tProps = pSecondaryTaskList.getAt(1)
    pSecondaryTaskList.deleteAt(1)
    me.render(tProps)
  else
    tTilesToRender = 1
    repeat while tTilesToRender <= pPriorityTilesPerUpdate
      tProps = pPriorityTaskList.getAt(1)
      pPriorityTaskList.deleteAt(1)
      me.render(tProps)
      if pPriorityTaskList.count = 0 then
        return(me.update())
      end if
      tTilesToRender = 1 + tTilesToRender
    end repeat
  end if
  return(1)
end

on removeSecondaryTask me, tProps 
  tLocX = tProps.getAt(#locX)
  tLocY = tProps.getAt(#locY)
  i = 1
  repeat while i <= pSecondaryTaskList.count
    tItem = pSecondaryTaskList.getAt(i)
    if tItem.getAt(#locX) = tLocX and tItem.getAt(#locY) = tLocY then
      pSecondaryTaskList.deleteAt(i)
      return(1)
    end if
    i = 1 + i
  end repeat
  return(1)
end

on render me, tProps 
  if not ilk(tProps) = #propList then
    return(0)
  end if
  tstate = tProps.getAt(#jumps)
  tTeamId = tProps.getAt(#teamId) + 1
  if tstate = 0 then
    return(1)
  end if
  tImage = pTileImages.getAt(tTeamId).getAt(tstate)
  if tImage = void() then
    return(0)
  end if
  tScreenLoc = pGeometry.getScreenCoordinate(tProps.getAt(#locX), tProps.getAt(#locY), 0)
  if pSprite = void() then
    return(0)
  end if
  tScreenLoc.setAt(1, tScreenLoc.getAt(1) - pSprite.left + 2)
  tScreenLoc.setAt(2, tScreenLoc.getAt(2) - pSprite.top - (tImage.height / 2) - 1)
  tTargetRect = tImage.rect + rect(tScreenLoc.getAt(1), tScreenLoc.getAt(2), tScreenLoc.getAt(1), tScreenLoc.getAt(2))
  pBuffer.copyPixels(tImage, tTargetRect, tImage.rect, [#ink:36])
  return(1)
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
    return(error(me, "Room visualizer not found.", #initBuffer))
  end if
  pSprite = tVisObj.getSprById("floor")
  if pSprite = 0 then
    return(error(me, "Arena floor not found.", #initBuffer))
  end if
  tImg = member("bb_arena").image
  pMember.image = image(tImg.width, tImg.height, 8)
  image.copyPixels(tImg, tImg.rect, tImg.rect)
  pMember.regPoint = member("bb_arena").regPoint
  pBuffer = pMember.image
  pSprite.setMember(pMember)
  return(1)
end

on clearAll me 
  pBuffer = void()
  if pMember <> void() then
    removeMember(pMember.name)
  end if
  pMember = void()
  return(1)
end
