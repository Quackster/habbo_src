on prepare(me, tdata)
  if pProcessActive then
    me.delay(50, #doorLogin)
  else
    pTargetData = []
  end if
  pProcessActive = 0
  pAnimCounter = 0
  pKickCounter = 0
  pResetStateCounter = 0
  pKickMe = 0
  if tdata.count > 0 then
    me.updateStuffdata(tdata.getAt(#stuffdata))
  else
    me.updateStuffdata("")
  end if
  if getObject(#session).exists("target_door_ID") then
    if getObject(#session).GET("target_door_ID") = me.getID() then
      getObject(#session).set("target_door_ID", 0)
      me.animate(12)
      pKickMe = 1
      me.delay(800, #kickOut)
    end if
  end if
  return(1)
  exit
end

on updateStuffdata(me, tValue)
  tValue = integer(tValue)
  me.setState(tValue)
  exit
end

on select(me)
  if the doubleClick then
    tRoom = getThread(#room).getComponent()
    tUserObj = tRoom.getOwnUser()
    if tUserObj = 0 then
      return(1)
    end if
    if me.pLocX = tUserObj.pLocX and me.pLocY = tUserObj.pLocY then
      return(me.tryDoor())
    end if
    tUserIsClose = 0
    tCloseList = ["0":[0, 1], "2":[-1, 0], "4":[0, -1], "6":[1, 0]]
    tDelta = tCloseList.getAt(string(me.getProp(#pDirection, 1)))
    if not voidp(tDelta) then
      if me.pLocX - tUserObj.pLocX = tDelta.getAt(1) and me.pLocY - tUserObj.pLocY = tDelta.getAt(2) then
        tUserIsClose = 1
      else
        return(tRoom.getRoomConnection().send("MOVE", [#integer:me.pLocX - tDelta.getAt(1), #integer:me.pLocY - tDelta.getAt(2)]))
      end if
    end if
    if tUserIsClose then
      tRoom.getRoomConnection().send("INTODOOR", [#integer:integer(me.getID())])
      me.tryDoor()
    end if
  end if
  return(1)
  exit
end

on tryDoor(me)
  if getObject(#session).exists("target_door_ID") then
    tTargetDoorID = getObject(#session).GET("target_door_ID")
    if tTargetDoorID <> 0 then
      return(1)
    end if
  end if
  getObject(#session).set("current_door_ID", me.getID())
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("GETDOORFLAT", [#integer:integer(me.getID())])
  end if
  return(1)
  exit
end

on startTeleport(me, tDataList)
  pTargetData = tDataList
  pProcessActive = 1
  me.animate(50)
  getThread(#room).getComponent().getRoomConnection().send("DOORGOIN", [#integer:integer(me.getID())])
  exit
end

on doorLogin(me)
  pProcessActive = 0
  getObject(#session).set("target_door_ID", pTargetData.getAt(#teleport))
  return(getThread(#room).getComponent().enterDoor(pTargetData))
  exit
end

on prepareToKick(me, tIncomer)
  if tIncomer = getObject(#session).GET("user_name") then
    pKickMe = 1
  else
    pKickMe = 0
  end if
  pKickCounter = 20
  exit
end

on kickOut(me)
  tRoom = getThread(#room).getComponent()
  me.setState(1)
  pResetStateCounter = 20
  if pKickMe then
    pKickMe = 0
    tCloseList = ["0":[0, -1], "2":[1, 0], "4":[0, 1], "6":[-1, 0]]
    tDelta = tCloseList.getAt(string(me.getProp(#pDirection, 1)))
    if not voidp(tDelta) then
      tRoom.getRoomConnection().send("MOVE", [#integer:me.pLocX + tDelta.getAt(1), #integer:me.pLocY + tDelta.getAt(2)])
    end if
  end if
  exit
end

on animate(me, tTime)
  if voidp(tTime) then
    tTime = 25
  end if
  pAnimCounter = tTime
  exit
end

on update(me)
  callAncestor(#update, [me])
  if pAnimCounter > 0 then
    pAnimCounter = pAnimCounter - 1
    if me.pState = 1 then
      me.setState(2)
    end if
    if pAnimCounter = 0 then
      pResetStateCounter = 20
      if pProcessActive then
        return(me.doorLogin())
      end if
    end if
  end if
  if pKickCounter > 0 then
    pKickCounter = pKickCounter - 1
    if pKickCounter = 0 then
      me.kickOut()
    end if
  end if
  if pResetStateCounter > 0 then
    pResetStateCounter = pResetStateCounter - 1
    if pResetStateCounter = 0 then
      me.setState(0)
    end if
  end if
  exit
end