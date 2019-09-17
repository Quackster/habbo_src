property pDataChunk, DoorOpentimer, pAnimActive, pAnimTime, pProcessActive, pKickTime

on new me, tName, tMemberPrefix, tMemberFigureType, tLocX, tLocY, tHeight, tDirection, lDimensions, spr, taltitude, pData, partColors, update 
  ancestor = new(script("FUSEMember Class"), tName, tMemberPrefix, tMemberFigureType, tLocX, tLocY, tHeight, tDirection, lDimensions, spr, taltitude, pData)
  initMember(me, tName, tMemberPrefix, tMemberFigureType, tLocX, tLocY, tHeight, tDirection, lDimensions, spr, taltitude, pData, partColors, update)
  gTargetDoorIp = void()
  pProcessActive = 0
  pAnimActive = 0
  pAnimTime = 10
  pKickTime = 0
  pDataChunk = void()
  if gTargetDoorID = me.id then
    gTargetRoomId = void()
    me.kickOut(gMyName)
  end if
  return(me)
end

on updateStuffdata me, tProp, tValue 
  if tValue = "TRUE" then
    DoorOpentimer = 18
  else
    mNamer = me.getPropRef(#lSprites, 1).member.name
    newMNamer = mNamer.char[1..mNamer.length - 1] & 0
    me.getPropRef(#lSprites, 1).castNum = getmemnum(newMNamer)
    tMaskMem = me.getPropRef(#lSprites, 2).member.name
    tNewMask = tMaskMem.char[1..tMaskMem.length - 1] & 0
    me.getPropRef(#lSprites, 2).castNum = abs(getmemnum(tNewMask))
    DoorOpentimer = 0
  end if
end

on initMember me, tName, tMemberPrefix, tMemberFigureType, tLocX, tLocY, tHeight, tDirection, lDimensions, spr, taltitude, pData, partColors, update 
  updateStuffdata(me, "DOOOPEN", getaProp(me.pData, "DOOROPEN"))
end

on mouseDown me 
  mySpr = getaProp(gpObjects, gMyName)
  if mySpr < 1 then
    return()
  end if
  userObj = sprite(mySpr).getProp(#scriptInstanceList, 1)
  if the doubleClick and userObj <> void() then
    gChosenTeleport = me
    if me.locX = userObj.locX and me.locY = userObj.locY then
      tryDoor(me)
    end if
    if me.getProp(#direction, 1) = 4 then
      if me.locX = userObj.locX and me.locY - userObj.locY = -1 then
        tryDoor(me)
        return()
      else
        sendFuseMsg("Move" && me.locX && me.locY + 1)
        return()
      end if
    else
      if me.getProp(#direction, 1) = 0 then
        if me.locX = userObj.locX and me.locY - userObj.locY = 1 then
          tryDoor(me)
          return()
        else
          sendFuseMsg("Move" && me.locX && me.locY - 1)
          return()
        end if
      else
        if me.getProp(#direction, 1) = 2 then
          if me.locY = userObj.locY and me.locX - userObj.locX = -1 then
            tryDoor(me)
            return()
          else
            sendFuseMsg("Move" && me.locX + 1 && me.locY)
            return()
          end if
        else
          if me.getProp(#direction, 1) = 6 then
            if me.locY = userObj.locY and me.locX - userObj.locX = 1 then
              tryDoor(me)
              return()
            else
              sendFuseMsg("Move" && me.locX - 1 && me.locY)
              return()
            end if
          end if
        end if
      end if
    end if
    return()
  end if
  if listp(gpUiButtons) and the movieName contains "private" then
    mouseDown(hiliter, 1)
    gChosenStuffId = me.id
    if not voidp(gChosenStuffSprite) then
      sendSprite(gChosenStuffSprite, #unhilite)
    end if
    gChosenStuffSprite = me.spriteNum
    gChosenStuffType = #stuff
    setInfoTexts(me)
    myUserObj = sprite(getaProp(gpObjects, gMyName)).getProp(#scriptInstanceList, 1)
    if myUserObj.controller = 1 then
      hilite(me)
      if the optionDown then
        moveStuff(hiliter, gChosenStuffSprite)
      end if
    end if
  end if
end

on tryDoor me 
  sendFuseMsg("SETSTUFFDATA /" & me.id & "/" & "DOOROPEN" & "/" & "TRUE")
  sendFuseMsg("IntoDoor" && me.id)
  sendEPFuseMsg("GETDOORFLAT /" & me.id)
end

on prepareToKick me, tIncomer 
  if tIncomer <> gMyName then
    return()
  end if
  pKickTime = 18
end

on kickOut me, tIncomer 
  sendFuseMsg("SETSTUFFDATA /" & me.id & "/" & "DOOROPEN" & "/" & "TRUE")
  if me.getProp(#direction, 1) = 2 then
    sendFuseMsg("Move" && me.locX + 1 && me.locY)
  else
    sendFuseMsg("Move" && me.locX && me.locY + 1)
  end if
end

on startTeleport me, tDataChunk 
  pDataChunk = tDataChunk
  pProcessActive = 1
  sendFuseMsg("DOORGOIN /" & me.id)
end

on doorLogin me 
  gTargetDoorID = value(pDataChunk.getProp(#line, 2))
  tTargetRoomData = pDataChunk.getProp(#line, 3, pDataChunk.count(#line))
  tSaveDelim = the itemDelimiter
  the itemDelimiter = "/"
  tFlatID = tTargetRoomData.getProp(#item, 1)
  tFlatName = tTargetRoomData.getProp(#item, 2)
  towner = tTargetRoomData.getProp(#item, 3)
  tFloorA = tTargetRoomData.getProp(#item, 5)
  tFloorB = tTargetRoomData.getProp(#item, 6)
  tAddress = tTargetRoomData.getProp(#item, 7)
  tip = tTargetRoomData.getProp(#item, 8)
  tPort = tTargetRoomData.getProp(#item, 9)
  tInfoTxt = tTargetRoomData.getProp(#item, 12)
  the itemDelimiter = tSaveDelim
  pProcessActive = 0
  member(getmemnum("room.info")).text = AddTextToField("Room") && tFlatName & "\r" & AddTextToField("Owner") && towner
  if integer(tFlatID) = gChosenFlatId then
    sendFuseMsg("GOVIADOOR /" & integer(tFlatID) & "/" & gTargetDoorID)
    gTargetDoorID = void()
    return()
  end if
  gChosenFlatId = integer(tFlatID)
  gConnectionInstance = void()
  gChosenUnitIp = tip
  gChosenUnitPort = integer(tPort)
  gFloor = 111
  gWallPaper = 201
  gFlatWaitStart = the milliSeconds
  go(2)
end

on error me 
  pKickTime = 40
  put("The other door is disabled...")
end

on animate me, tTime, tDirection 
  if voidp(tTime) then
    tTime = 20
  end if
  pAnimTime = tTime
  pAnimActive = 1
end

on exitFrame me 
  if DoorOpentimer > 0 then
    mNamer = me.getPropRef(#lSprites, 1).member.name
    newMNamer = mNamer.char[1..mNamer.length - 1] & 1
    me.getPropRef(#lSprites, 1).castNum = abs(getmemnum(newMNamer))
    tMaskMem = me.getPropRef(#lSprites, 2).member.name
    tNewMask = tMaskMem.char[1..tMaskMem.length - 1] & 1
    me.getPropRef(#lSprites, 2).castNum = abs(getmemnum(tNewMask))
    DoorOpentimer = DoorOpentimer - 1
    if DoorOpentimer = 0 then
      sendFuseMsg("SETSTUFFDATA /" & me.id & "/" & "DOOROPEN" & "/" & "FALSE")
    end if
  end if
  if pAnimActive > 0 then
    if DoorOpentimer > 0 then
      tMaskMem = me.getPropRef(#lSprites, 3).member.name
      tNewMask = tMaskMem.char[1..tMaskMem.length - 1] & 0
      me.getPropRef(#lSprites, 3).castNum = abs(getmemnum(tNewMask))
    else
      pAnimActive = pAnimActive + 1
      if pAnimActive = pAnimTime then
        pAnimActive = 0
      end if
      tMaskMem = me.getPropRef(#lSprites, 3).member.name
      tNewMask = tMaskMem.char[1..tMaskMem.length - 1] & pAnimActive mod 2
      me.getPropRef(#lSprites, 3).castNum = abs(getmemnum(tNewMask))
    end if
  end if
  if pProcessActive and pAnimActive = pAnimTime - 1 then
    doorLogin()
    return()
  end if
  if pKickTime > 0 then
    pKickTime = pKickTime - 1
    if pKickTime = 0 then
      kickOut(me)
    end if
  end if
end
