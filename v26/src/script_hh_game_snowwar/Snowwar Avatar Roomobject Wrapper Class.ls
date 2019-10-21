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
    if getObject(#session).exists("user_index") then
      getObject(#session).Remove("user_index")
    end if
    if getObject(#session).exists("user_game_index") then
      getObject(#session).Remove("user_game_index")
    end if
  end if
  return(1)
  exit
end

on define(me, tdata)
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

on gameObjectMoveDone(me, tX, tY, tH, tDirHead, tDirBody, tAction)
  tUserObject = me.getRoomObject()
  if tUserObject = 0 then
    return(0)
  end if
  return(tUserObject.gameObjectMoveDone(tX, tY, tH, tDirHead, tDirBody, tAction))
  exit
end

on gameObjectAction(me, tAction, tdata)
  tUserObject = me.getRoomObject()
  if tUserObject = 0 then
    return(0)
  end if
  return(tUserObject.gameObjectAction(tAction, tdata))
  exit
end

on gameObjectRefreshLocation(me, tX, tY, tH, tDirHead, tDirBody)
  tUserObject = me.getRoomObject()
  if tUserObject = 0 then
    return(0)
  end if
  return(tUserObject.resetValues(tX, tY, tH, tDirHead, tDirBody))
  exit
end

on gameObjectNewMoveTarget(me, tX, tY, tH, tDirHead, tDirBody, tAction)
  tUserObject = me.getRoomObject()
  if tUserObject = 0 then
    return(0)
  end if
  return(tUserObject.gameObjectNewMoveTarget(tX, tY, tH, tDirHead, tDirBody, tAction))
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
  tRoomComponentObj = getObject(#room_component)
  if tRoomComponentObj = 0 then
    return(error(me, "Room component unavailable!", #createRoomObject))
  end if
  tFigureSystemObj = getObject("Figure_System")
  if tFigureSystemObj = 0 then
    return(error(me, "Figure system unavailable!", #createRoomObject))
  end if
  tAvatarStruct = tdata.duplicate()
  tAvatarStruct.setAt(#id, pRoomIndex)
  tAvatarStruct.setaProp(#direction, [tdata.getAt(#dirBody), tdata.getAt(#dirBody)])
  tClassID = "snowwar.object_avatar.roomobject.class"
  tPlayerClass = getVariable(tClassID)
  tClassContainer = tRoomComponentObj.getClassContainer()
  if tClassContainer = 0 then
    return(error(me, "Avatar manager failed to initialize", #createRoomObject))
  end if
  tClassContainer.set(tClassID, tPlayerClass)
  tAvatarStruct.setaProp(#class, tClassID)
  tAvatarStruct.setaProp(#x, tdata.getAt(#next_tile_x))
  tAvatarStruct.setaProp(#y, tdata.getAt(#next_tile_y))
  if tdata.getAt(#next_tile_z) = void() then
    tAvatarStruct.setaProp(#h, 0)
  else
    tAvatarStruct.setaProp(#h, tdata.getAt(#next_tile_z))
  end if
  if tdata.getAt(#figure) = "" then
    return(error(me, "Figure not found in human data, server probably didn't send it in GAMERESET (249)", #createRoomObject))
  end if
  tAvatarStruct.setaProp(#custom, tdata.getAt(#mission))
  tFigure = tFigureSystemObj.parseFigure(tdata.getAt(#figure), tdata.getAt(#sex), "user")
  tAvatarStruct.setaProp(#figure, tFigure)
  if not tRoomComponentObj.validateUserObjects(tAvatarStruct) then
    return(error(me, "Room couldn't create avatar!", #createRoomObject))
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
  if not tRoomComponentObj.userObjectExists(pRoomIndex) then
    return(1)
  end if
  return(tRoomComponentObj.removeUserObject(pRoomIndex))
  exit
end