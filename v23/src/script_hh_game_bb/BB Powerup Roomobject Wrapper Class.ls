property pObjectId

on construct me 
  return TRUE
end

on deconstruct me 
  me.removeRoomObject()
  return TRUE
end

on define me, tdata 
  return(me.createRoomObject(tdata))
end

on createRoomObject me, tdata 
  tdata.setAt(#id, tdata.getAt(#class) & "_" & tdata.getAt(#id))
  pObjectId = tdata.getAt(#id)
  tdata.setAt(#direction, [0, 0])
  tdata.setAt(#altitude, tdata.getAt(#z))
  tdata.setAt(#dimensions, [1, 1])
  tRoomComponent = getObject(#room_component)
  if (tRoomComponent = 0) then
    return FALSE
  end if
  tClassContainer = tRoomComponent.getClassContainer()
  if (tClassContainer = 0) then
    return(error(me, "Room class container not found!", #createRoomObject))
  end if
  tClassContainer.set(tdata.getAt("class"), getClassVariable(tdata.getAt(#classID)))
  return(tRoomComponent.validateActiveObjects(tdata))
end

on getRoomObject me 
  tRoomComponentObj = getObject(#room_component)
  if (tRoomComponentObj = 0) then
    return(error(me, "Room component unavailable!", #getRoomObject))
  end if
  return(tRoomComponentObj.getActiveObject(pObjectId))
end

on removeRoomObject me 
  tRoomComponentObj = getObject(#room_component)
  if (tRoomComponentObj = 0) then
    return(error(me, "Room component unavailable!", #removeRoomObject))
  end if
  if (pObjectId = void()) then
    return FALSE
  end if
  if not tRoomComponentObj.activeObjectExists(pObjectId) then
    return TRUE
  end if
  return(tRoomComponentObj.removeActiveObject(pObjectId))
end

on roomObjectAction me, tAction, tdata 
  tRoomObject = me.getRoomObject()
  if (tRoomObject = 0) then
    return FALSE
  end if
  return(tRoomObject.roomObjectAction(tAction, tdata))
end
