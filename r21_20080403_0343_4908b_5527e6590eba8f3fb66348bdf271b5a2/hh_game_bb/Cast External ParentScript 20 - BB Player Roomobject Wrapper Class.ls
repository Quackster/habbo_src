property pRoomIndex, pRoomComponentObj

on construct me
  return 1
end

on deconstruct me
  me.removeRoomObject()
  pRoomComponentObj = VOID
  if not getObject(#session).exists("user_index") then
    return 1
  end if
  if pRoomIndex = getObject(#session).GET("user_index") then
    getObject(#session).Remove("user_index")
    if getObject(#session).exists("user_game_index") then
      getObject(#session).Remove("user_game_index")
    end if
  end if
  return 1
end

on define me, tdata
  tdata[#room_index] = tdata[#roomindex]
  if tdata[#room_index] < 0 then
    return error(me, "Invalid room index for avatar:" && tdata, #define)
  end if
  pRoomIndex = string(tdata[#room_index])
  if tdata[#name] = getObject(#session).GET(#userName) then
    getObject(#session).set("user_index", pRoomIndex)
    getObject(#session).set("user_game_index", tdata[#id])
  end if
  return me.createRoomObject(tdata)
end

on setLocation me, tdata
  tUserObject = me.getRoomObject()
  if tUserObject = 0 then
    return 0
  end if
  if not listp(tdata) then
    return 0
  end if
  return tUserObject.resetValues(tdata[#x], tdata[#y], tdata[#z], tdata[#dirBody], tdata[#dirBody])
end

on setTarget me, tCurrentLoc, tNextLoc
  tUserObject = me.getRoomObject()
  if tUserObject = 0 then
    return 0
  end if
  if listp(tNextLoc) then
    tParams = "mv " & tNextLoc[#x] & "," & tNextLoc[#y] & "," & tNextLoc[#z]
    call(symbol("action_mv"), [tUserObject], tParams)
  end if
  if listp(tCurrentLoc) then
    tUserObject.Refresh(tCurrentLoc[#x], tCurrentLoc[#y], tCurrentLoc[#z])
  end if
  return 1
end

on roomObjectAction me, tAction, tdata
  tUserObject = me.getRoomObject()
  if tUserObject = 0 then
    return 0
  end if
  return tUserObject.roomObjectAction(tAction, tdata)
end

on getPicture me
  tUserObject = me.getRoomObject()
  if tUserObject = 0 then
    return 0
  end if
  return tUserObject.getPicture()
end

on getRoomObject me
  tRoomComponentObj = getObject(#room_component)
  if tRoomComponentObj = 0 then
    return error(me, "Room component unavailable!", #getRoomObject)
  end if
  return tRoomComponentObj.getUserObject(pRoomIndex)
end

on createRoomObject me, tdata
  pRoomComponentObj = getObject(#room_component)
  if pRoomComponentObj = 0 then
    return error(me, "Room component unavailable!", #createRoomObject)
  end if
  tFigureSystemObj = getObject("Figure_System")
  if tFigureSystemObj = 0 then
    return error(me, "Figure system unavailable!", #createRoomObject)
  end if
  if pRoomComponentObj.userObjectExists(pRoomIndex) then
    return 1
  end if
  tAvatarStruct = [:]
  tClassID = "bb_gamesystem.roomobject.player.class"
  tPlayerClass = getVariable(tClassID)
  tClassContainer = pRoomComponentObj.getClassContainer()
  if tClassContainer = 0 then
    return error(me, "Unable to find class container.", #createRoomObject)
  end if
  tClassContainer.set(tClassID, tPlayerClass)
  tAvatarStruct.setaProp(#class, tClassID)
  tUserStrId = string(tdata[#roomindex])
  tAvatarStruct.addProp(#id, tUserStrId)
  tAvatarStruct.addProp(#name, tdata[#name])
  tAvatarStruct.addProp(#direction, [tdata[#dirBody], 0])
  tAvatarStruct.addProp(#x, tdata[#x])
  tAvatarStruct.addProp(#y, tdata[#y])
  tAvatarStruct.addProp(#h, tdata[#z])
  tAvatarStruct.addProp(#custom, tdata[#mission])
  tAvatarStruct.addProp(#sex, tdata[#sex])
  tAvatarStruct.addProp(#teamId, tdata[#teamId])
  if tdata[#name] = getObject(#session).GET(#userName) then
    getObject(#session).set("user_index", tUserStrId)
  end if
  tFigure = tFigureSystemObj.parseFigure(tdata[#figure], tdata[#sex], "user")
  tTeamId = tdata[#teamId] + 1
  tTeamColors = [rgb("#E73929"), rgb("#217BEF"), rgb("#FFCE21"), rgb("#8CE700")]
  tBallModel = ["model": "001", "color": tTeamColors[tTeamId]]
  tFigure.addProp("bl", tBallModel)
  tAvatarStruct.addProp(#figure, tFigure)
  if not pRoomComponentObj.validateUserObjects(tAvatarStruct) then
    return error(me, "BB: Room couldn't create avatar!", #createRoomObject)
  else
    return 1
  end if
end

on removeRoomObject me
  tRoomComponentObj = getObject(#room_component)
  if tRoomComponentObj = 0 then
    return error(me, "Room component unavailable!", #removeRoomObject)
  end if
  if pRoomIndex = VOID then
    return 0
  end if
  return tRoomComponentObj.removeUserObject(pRoomIndex)
end
