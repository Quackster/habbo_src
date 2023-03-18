property pObjectId

on construct me
  return 1
end

on deconstruct me
  me.removeRoomObject()
  return 1
end

on define me, tdata
  return me.createRoomObject(tdata)
end

on createRoomObject me, tdata
  tdata[#id] = tdata[#class] & "_" & tdata[#id]
  pObjectId = tdata[#id]
  tdata[#direction] = [0, 0]
  tdata[#altitude] = tdata[#z]
  tdata[#dimensions] = [1, 1]
  tRoomComponent = getObject(#room_component)
  if tRoomComponent = 0 then
    return 0
  end if
  tClassContainer = tRoomComponent.getClassContainer()
  if tClassContainer = 0 then
    return error(me, "Room class container not found!", #createRoomObject)
  end if
  tClassContainer.set(tdata["class"], getClassVariable(tdata[#classID]))
  return tRoomComponent.createActiveObject(tdata)
end

on getRoomObject me
  tRoomComponentObj = getObject(#room_component)
  if tRoomComponentObj = 0 then
    return error(me, "Room component unavailable!", #getRoomObject)
  end if
  return tRoomComponentObj.getActiveObject(pObjectId)
end

on removeRoomObject me
  tRoomComponentObj = getObject(#room_component)
  if tRoomComponentObj = 0 then
    return error(me, "Room component unavailable!", #removeRoomObject)
  end if
  if pObjectId = VOID then
    return 0
  end if
  if not tRoomComponentObj.activeObjectExists(pObjectId) then
    return 1
  end if
  return tRoomComponentObj.removeActiveObject(pObjectId)
end

on roomObjectAction me, tAction, tdata
  tRoomObject = me.getRoomObject()
  if tRoomObject = 0 then
    return 0
  end if
  return tRoomObject.roomObjectAction(tAction, tdata)
end
