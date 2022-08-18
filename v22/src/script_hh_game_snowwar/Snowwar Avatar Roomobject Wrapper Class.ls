property pRoomIndex

on construct me
  return 1
end

on deconstruct me
  me.removeRoomObject()
  pRoomComponentObj = VOID
  if not getObject(#session).exists("user_index") then
    return 1
  end if
  if (pRoomIndex = getObject(#session).GET("user_index")) then
    if getObject(#session).exists("user_index") then
      getObject(#session).Remove("user_index")
    end if
    if getObject(#session).exists("user_game_index") then
      getObject(#session).Remove("user_game_index")
    end if
  end if
  return 1
end

on define me, tdata
  if (tdata[#room_index] < 0) then
    return error(me, ("Invalid room index for avatar:" && tdata), #define)
  end if
  pRoomIndex = string(tdata[#room_index])
  if (tdata[#name] = getObject(#session).GET(#userName)) then
    getObject(#session).set("user_index", pRoomIndex)
    getObject(#session).set("user_game_index", tdata[#id])
  end if
  return me.createRoomObject(tdata)
end

on gameObjectMoveDone me, tX, tY, tH, tDirHead, tDirBody, tAction
  tUserObject = me.getRoomObject()
  if (tUserObject = 0) then
    return 0
  end if
  return tUserObject.gameObjectMoveDone(tX, tY, tH, tDirHead, tDirBody, tAction)
end

on gameObjectAction me, tAction, tdata
  tUserObject = me.getRoomObject()
  if (tUserObject = 0) then
    return 0
  end if
  return tUserObject.gameObjectAction(tAction, tdata)
end

on gameObjectRefreshLocation me, tX, tY, tH, tDirHead, tDirBody
  tUserObject = me.getRoomObject()
  if (tUserObject = 0) then
    return 0
  end if
  return tUserObject.resetValues(tX, tY, tH, tDirHead, tDirBody)
end

on gameObjectNewMoveTarget me, tX, tY, tH, tDirHead, tDirBody, tAction
  tUserObject = me.getRoomObject()
  if (tUserObject = 0) then
    return 0
  end if
  return tUserObject.gameObjectNewMoveTarget(tX, tY, tH, tDirHead, tDirBody, tAction)
end

on getPicture me
  tUserObject = me.getRoomObject()
  if (tUserObject = 0) then
    return 0
  end if
  return tUserObject.getPicture()
end

on getRoomObject me
  tRoomComponentObj = getObject(#room_component)
  if (tRoomComponentObj = 0) then
    return error(me, "Room component unavailable!", #getRoomObject)
  end if
  return tRoomComponentObj.getUserObject(pRoomIndex)
end

on createRoomObject me, tdata
  tRoomComponentObj = getObject(#room_component)
  if (tRoomComponentObj = 0) then
    return error(me, "Room component unavailable!", #createRoomObject)
  end if
  tFigureSystemObj = getObject("Figure_System")
  if (tFigureSystemObj = 0) then
    return error(me, "Figure system unavailable!", #createRoomObject)
  end if
  tAvatarStruct = tdata.duplicate()
  tAvatarStruct[#id] = pRoomIndex
  tAvatarStruct.setaProp(#direction, [tdata[#dirBody], tdata[#dirBody]])
  tClassID = "snowwar.object_avatar.roomobject.class"
  tPlayerClass = getVariable(tClassID)
  tClassContainer = tRoomComponentObj.getClassContainer()
  if (tClassContainer = 0) then
    return error(me, "Avatar manager failed to initialize", #createRoomObject)
  end if
  tClassContainer.set(tClassID, tPlayerClass)
  tAvatarStruct.setaProp(#class, tClassID)
  tAvatarStruct.setaProp(#x, tdata[#next_tile_x])
  tAvatarStruct.setaProp(#y, tdata[#next_tile_y])
  if (tdata[#next_tile_z] = VOID) then
    tAvatarStruct.setaProp(#h, 0.0)
  else
    tAvatarStruct.setaProp(#h, tdata[#next_tile_z])
  end if
  if (tdata[#figure] = EMPTY) then
    return error(me, "Figure not found in human data, server probably didn't send it in GAMERESET (249)", #createRoomObject)
  end if
  tAvatarStruct.setaProp(#custom, tdata[#mission])
  tFigure = tFigureSystemObj.parseFigure(tdata[#figure], tdata[#sex], "user")
  tAvatarStruct.setaProp(#figure, tFigure)
  if not tRoomComponentObj.validateUserObjects(tAvatarStruct) then
    return error(me, "Room couldn't create avatar!", #createRoomObject)
  else
    return 1
  end if
end

on removeRoomObject me
  tRoomComponentObj = getObject(#room_component)
  if (tRoomComponentObj = 0) then
    return error(me, "Room component unavailable!", #removeRoomObject)
  end if
  if (pRoomIndex = VOID) then
    return 0
  end if
  if not tRoomComponentObj.userObjectExists(pRoomIndex) then
    return 1
  end if
  return tRoomComponentObj.removeUserObject(pRoomIndex)
end
