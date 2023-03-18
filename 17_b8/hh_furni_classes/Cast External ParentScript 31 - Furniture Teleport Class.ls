property pDoorOpentimer, pProcessActive, pAnimActive, pAnimTime, pKickTime, pTargetData

on prepare me, tdata
  pProcessActive = 0
  pAnimActive = 0
  pAnimTime = 10
  pKickTime = 0
  pTargetData = [:]
  if me.pSprList.count < 3 then
    return 0
  end if
  me.pSprList[3].visible = 0
  if tdata.count > 0 then
    me.updateStuffdata(tdata[#stuffdata])
  end if
  if getObject(#session).exists("target_door_ID") then
    if getObject(#session).GET("target_door_ID") = me.getID() then
      getObject(#session).set("target_door_ID", 0)
      me.animate(12)
      me.delay(800, #kickOut)
    end if
  end if
  return 1
end

on updateStuffdata me, tValue
  if me.pSprList.count < 2 then
    return 0
  end if
  if tValue = "TRUE" then
    pDoorOpentimer = 18
  else
    tCurName = me.pSprList[1].member.name
    tNewName = tCurName.char[1..length(tCurName) - 1] & 0
    tmember = member(abs(getmemnum(tNewName)))
    me.pSprList[1].castNum = tmember.number
    me.pSprList[1].width = tmember.width
    me.pSprList[1].height = tmember.height
    tMaskMem = me.pSprList[2].member.name
    tNewMask = tMaskMem.char[1..length(tMaskMem) - 1] & 0
    tmember = member(abs(getmemnum(tNewMask)))
    me.pSprList[2].castNum = tmember.number
    me.pSprList[2].width = tmember.width
    me.pSprList[2].height = tmember.height
    pDoorOpentimer = 0
  end if
end

on select me
  if the doubleClick then
    tUserObj = getThread(#room).getComponent().getOwnUser()
    if tUserObj = 0 then
      return 1
    end if
    if (me.pLocX = tUserObj.pLocX) and (me.pLocY = tUserObj.pLocY) then
      return me.tryDoor()
    end if
    tUserIsClose = 0
    case me.pDirection[1] of
      4:
        if (me.pLocX = tUserObj.pLocX) and ((me.pLocY - tUserObj.pLocY) = -1) then
          tUserIsClose = 1
        else
          return getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short: me.pLocX, #short: me.pLocY + 1])
        end if
      0:
        if (me.pLocX = tUserObj.pLocX) and ((me.pLocY - tUserObj.pLocY) = 1) then
          tUserIsClose = 1
        else
          return getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short: me.pLocX, #short: me.pLocY - 1])
        end if
      2:
        if (me.pLocY = tUserObj.pLocY) and ((me.pLocX - tUserObj.pLocX) = -1) then
          tUserIsClose = 1
        else
          return getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short: me.pLocX + 1, #short: me.pLocY])
        end if
      6:
        if (me.pLocY = tUserObj.pLocY) and ((me.pLocX - tUserObj.pLocX) = 1) then
          tUserIsClose = 1
        else
          return getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short: me.pLocX - 1, #short: me.pLocY])
        end if
    end case
    if tUserIsClose then
      getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", [#string: string(me.getID()), #string: "TRUE"])
      getThread(#room).getComponent().getRoomConnection().send("INTODOOR", me.getID())
      me.tryDoor()
    end if
  end if
  return 1
end

on tryDoor me
  getObject(#session).set("current_door_ID", me.getID())
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("GETDOORFLAT", me.getID())
  end if
  return 1
end

on startTeleport me, tDataList
  pTargetData = tDataList
  pProcessActive = 1
  me.animate(50)
  getThread(#room).getComponent().getRoomConnection().send("DOORGOIN", me.getID())
end

on doorLogin me
  pProcessActive = 0
  getObject(#session).set("target_door_ID", pTargetData[#teleport])
  return getThread(#room).getComponent().enterDoor(pTargetData)
end

on prepareToKick me, tIncomer
  if tIncomer = getObject(#session).GET("user_name") then
    pKickTime = 20
  end if
end

on kickOut me
  tRoom = getThread(#room).getComponent()
  getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", [#string: string(me.getID()), #string: "TRUE"])
  if me.pDirection[1] = 2 then
    tRoom.getRoomConnection().send("MOVE", [#short: me.pLocX + 1, #short: me.pLocY])
  else
    tRoom.getRoomConnection().send("MOVE", [#short: me.pLocX, #short: me.pLocY + 1])
  end if
end

on animate me, tTime
  if voidp(tTime) then
    tTime = 25
  end if
  pAnimTime = tTime
  pAnimActive = 1
end

on update me
  if me.pSprList.count < 3 then
    return 
  end if
  if pDoorOpentimer > 0 then
    tCurName = me.pSprList[1].member.name
    tNewName = tCurName.char[1..length(tCurName) - 1] & 1
    tmember = member(abs(getmemnum(tNewName)))
    me.pSprList[1].castNum = tmember.number
    me.pSprList[1].width = tmember.width
    me.pSprList[1].height = tmember.height
    tCurName = me.pSprList[2].member.name
    tNewName = tCurName.char[1..length(tCurName) - 1] & 1
    tmember = member(abs(getmemnum(tNewName)))
    me.pSprList[2].castNum = tmember.number
    me.pSprList[2].width = tmember.width
    me.pSprList[2].height = tmember.height
    pDoorOpentimer = pDoorOpentimer - 1
    if pDoorOpentimer = 0 then
      getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", [#string: string(me.getID()), #string: "FALSE"])
    end if
  end if
  if pAnimActive > 0 then
    tName = me.pSprList[1].member.name
    if tName.char[length(tName)] = "1" then
      me.pSprList[3].visible = 0
    else
      pAnimActive = (pAnimActive + 1) mod pAnimTime
      tVisible = pAnimActive mod 2
      if tVisible and (random(4) > 1) then
        me.pSprList[3].visible = 1
      else
        me.pSprList[3].visible = 0
      end if
    end if
  end if
  if pProcessActive and (pAnimActive = (pAnimTime - 1)) then
    return me.doorLogin()
  end if
  if pKickTime > 0 then
    pKickTime = pKickTime - 1
    if pKickTime = 0 then
      me.kickOut()
    end if
  end if
end
