on prepare(me, tdata)
  if pProcessActive then
    me.delay(500, #doorLogin)
  else
    pTargetData = []
  end if
  pProcessActive = 0
  pAnimActive = 0
  pAnimTime = 10
  pKickTime = 0
  pDoorOpentimer = 0
  pCloseDoorTimer = 0
  if tdata.count > 0 then
    me.updateStuffdata(tdata.getAt(#stuffdata))
  else
    me.updateStuffdata("")
  end if
  if getObject(#session).exists("target_door_ID") then
    if getObject(#session).GET("target_door_ID") = me.getID() then
      getObject(#session).set("target_door_ID", 0)
      me.animate(12)
      me.delay(800, #kickOut)
    end if
  end if
  return(1)
  exit
end

on updateStuffdata(me, tValue)
  if tValue = "TRUE" then
    tValue = 2
    pDoorOpentimer = 18
  else
    if tValue = "FALSE" then
      tValue = 1
      pDoorOpentimer = 0
    end if
  end if
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
        return(tRoom.getRoomConnection().send("MOVE", [#short:me.pLocX - tDelta.getAt(1), #short:me.pLocY - tDelta.getAt(2)]))
      end if
    end if
    if tUserIsClose then
      tRoom.getRoomConnection().send("SETSTUFFDATA", [#string:string(me.getID()), #string:"TRUE"])
      tRoom.getRoomConnection().send("INTODOOR", me.getID())
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
    getConnection(getVariable("connection.info.id")).send("GETDOORFLAT", me.getID())
  end if
  return(1)
  exit
end

on startTeleport(me, tDataList)
  pTargetData = tDataList
  pProcessActive = 1
  me.animate(50)
  getThread(#room).getComponent().getRoomConnection().send("DOORGOIN", me.getID())
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
    pKickTime = 20
  end if
  exit
end

on kickOut(me)
  tRoom = getThread(#room).getComponent()
  tRoom.getRoomConnection().send("SETSTUFFDATA", [#string:string(me.getID()), #string:"TRUE"])
  tCloseList = ["0":[0, -1], "2":[1, 0], "4":[0, 1], "6":[-1, 0]]
  tDelta = tCloseList.getAt(string(me.getProp(#pDirection, 1)))
  if not voidp(tDelta) then
    tRoom.getRoomConnection().send("MOVE", [#short:me.pLocX + tDelta.getAt(1), #short:me.pLocY + tDelta.getAt(2)])
  end if
  exit
end

on animate(me, tTime)
  if voidp(tTime) then
    tTime = 25
  end if
  pAnimTime = tTime
  pAnimActive = 1
  exit
end

on update(me)
  callAncestor(#update, [me])
  if pDoorOpentimer > 0 then
    pDoorOpentimer = pDoorOpentimer - 1
    if pDoorOpentimer = 0 then
      getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", [#string:string(me.getID()), #string:"FALSE"])
    end if
  end if
  if pAnimActive > 0 then
    pAnimActive = pAnimActive + 1 mod pAnimTime
    if me.pState = 1 then
      me.setState(3)
    end if
  end if
  if pAnimActive = pAnimTime - 1 then
    pAnimActive = 0
    pCloseDoorTimer = 20
    if pProcessActive then
      return(me.doorLogin())
    end if
  end if
  if pKickTime > 0 then
    pKickTime = pKickTime - 1
    if pKickTime = 0 then
      me.kickOut()
    end if
  end if
  if pCloseDoorTimer > 0 then
    pCloseDoorTimer = pCloseDoorTimer - 1
    if pCloseDoorTimer = 0 then
      me.setState(1)
    end if
  end if
  exit
end