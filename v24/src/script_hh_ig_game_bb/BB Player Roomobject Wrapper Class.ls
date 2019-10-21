on construct(me)
  return(1)
  exit
end

on deconstruct(me)
  me.removeRoomObject()
  pRoomComponentObj = void()
  if not getObject(#session).exists("user_index") then
    return(1)
  end if
  if pRoomIndex = getObject(#session).GET("user_index") then
    getObject(#session).Remove("user_index")
    if getObject(#session).exists("user_game_index") then
      getObject(#session).Remove("user_game_index")
    end if
  end if
  return(1)
  exit
end

on define(me, tdata)
  tdata.setAt(#room_index, tdata.getAt(#roomindex))
  if tdata.getAt(#room_index) < 0 then
    return(error(me, "Invalid room index for avatar:" && tdata, #define))
  end if
  pRoomIndex = string(tdata.getAt(#room_index))
  if tdata.getAt(#name) = getObject(#session).GET(#userName) then
    getObject(#session).set("user_index", pRoomIndex)
    getObject(#session).set("user_game_index", tdata.getAt(#id))
  end if
  return(me.createRoomObject(tdata))
  exit
end

on setLocation(me, tdata)
  tUserObject = me.getRoomObject()
  if tUserObject = 0 then
    return(0)
  end if
  if not listp(tdata) then
    return(0)
  end if
  return(tUserObject.resetValues(tdata.getAt(#x), tdata.getAt(#y), tdata.getAt(#z), tdata.getAt(#dirBody), tdata.getAt(#dirBody)))
  exit
end

on setTarget(me, tCurrentLoc, tNextLoc)
  tUserObject = me.getRoomObject()
  if tUserObject = 0 then
    return(0)
  end if
  if listp(tNextLoc) then
    tParams = "mv " & tNextLoc.getAt(#x) & "," & tNextLoc.getAt(#y) & "," & tNextLoc.getAt(#z)
    call(symbol("action_mv"), [tUserObject], tParams)
  end if
  if listp(tCurrentLoc) then
    tUserObject.Refresh(tCurrentLoc.getAt(#x), tCurrentLoc.getAt(#y), tCurrentLoc.getAt(#z))
  end if
  return(1)
  exit
end

on roomObjectAction(me, tAction, tdata)
  tUserObject = me.getRoomObject()
  if tUserObject = 0 then
    return(0)
  end if
  return(tUserObject.roomObjectAction(tAction, tdata))
  exit
end

on getPicture(me)
  tUserObject = me.getRoomObject()
  if tUserObject = 0 then
    return(0)
  end if
  return(tUserObject.getPicture())
  exit
end

on getRoomObject(me)
  tRoomComponentObj = getObject(#room_component)
  if tRoomComponentObj = 0 then
    return(error(me, "Room component unavailable!", #getRoomObject))
  end if
  return(tRoomComponentObj.getUserObject(pRoomIndex))
  exit
end

on createRoomObject(me, tdata)
  pRoomComponentObj = getObject(#room_component)
  if pRoomComponentObj = 0 then
    return(error(me, "Room component unavailable!", #createRoomObject))
  end if
  tFigureSystemObj = getObject("Figure_System")
  if tFigureSystemObj = 0 then
    return(error(me, "Figure system unavailable!", #createRoomObject))
  end if
  if pRoomComponentObj.userObjectExists(pRoomIndex) then
    return(1)
  end if
  tAvatarStruct = []
  tClassID = "bb_gamesystem.roomobject.player.class"
  tPlayerClass = getVariable(tClassID)
  tClassContainer = pRoomComponentObj.getClassContainer()
  if tClassContainer = 0 then
    return(error(me, "Unable to find class container.", #createRoomObject))
  end if
  tClassContainer.set(tClassID, tPlayerClass)
  tAvatarStruct.setaProp(#class, tClassID)
  tUserStrId = string(tdata.getAt(#roomindex))
  tAvatarStruct.addProp(#id, tUserStrId)
  tAvatarStruct.addProp(#name, tdata.getAt(#name))
  tAvatarStruct.addProp(#direction, [tdata.getAt(#dirBody), 0])
  tAvatarStruct.addProp(#x, tdata.getAt(#x))
  tAvatarStruct.addProp(#y, tdata.getAt(#y))
  tAvatarStruct.addProp(#h, tdata.getAt(#z))
  tAvatarStruct.addProp(#custom, tdata.getAt(#mission))
  tAvatarStruct.addProp(#sex, tdata.getAt(#sex))
  tAvatarStruct.addProp(#teamId, tdata.getAt(#teamId))
  if tdata.getAt(#name) = getObject(#session).GET(#userName) then
    getObject(#session).set("user_index", tUserStrId)
  end if
  tFigure = tFigureSystemObj.parseFigure(tdata.getAt(#figure), tdata.getAt(#sex), "user")
  tTeamId = tdata.getAt(#teamId)
  tTeamColors = [rgb("#E73929"), rgb("#217BEF"), rgb("#8CE700"), rgb("#FFCE21")]
  tBallModel = ["model":"001", "color":tTeamColors.getAt(tTeamId)]
  tFigure.addProp("bl", tBallModel)
  tAvatarStruct.addProp(#figure, tFigure)
  if not pRoomComponentObj.createUserObject(tAvatarStruct) then
    return(error(me, "BB: Room couldn't create avatar!", #createRoomObject))
  else
    return(1)
  end if
  exit
end

on removeRoomObject(me)
  tRoomComponentObj = getObject(#room_component)
  if tRoomComponentObj = 0 then
    return(error(me, "Room component unavailable!", #removeRoomObject))
  end if
  if pRoomIndex = void() then
    return(0)
  end if
  return(tRoomComponentObj.removeUserObject(pRoomIndex))
  exit
end