property pObjectId

on construct me 
  return(1)
end

on deconstruct me 
  me.removeRoomObject()
  return(1)
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
  if tRoomComponent = 0 then
    return(0)
  end if
  tClassContainer = tRoomComponent.getClassContainer()
  if tClassContainer = 0 then
    return(error(me, "Room class container not found!", #createRoomObject))
  end if
  tClassContainer.set(tdata.getAt("class"), getClassVariable(tdata.getAt(#classID)))
  return(tRoomComponent.validateActiveObjects(tdata))
end

on getRoomObject me 
  tRoomComponentObj = getObject(#room_component)
  if tRoomComponentObj = 0 then
    return(error(me, "Room component unavailable!", #getRoomObject))
  end if
  return(tRoomComponentObj.getActiveObject(pObjectId))
end

on removeRoomObject me 
  tRoomComponentObj = getObject(#room_component)
  if tRoomComponentObj = 0 then
    return(error(me, "Room component unavailable!", #removeRoomObject))
  end if
  if pObjectId = void() then
    return(0)
  end if
  if not tRoomComponentObj.activeObjectExists(pObjectId) then
    return(1)
  end if
  return(tRoomComponentObj.removeActiveObject(pObjectId))
end

on roomObjectAction me, tAction, tdata 
  tRoomObject = me.getRoomObject()
  if tRoomObject = 0 then
    return(0)
  end if
  return(tRoomObject.roomObjectAction(tAction, tdata))
end
