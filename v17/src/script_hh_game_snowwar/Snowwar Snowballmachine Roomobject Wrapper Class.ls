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

on render me, tValue
  if (me.getRoomObject() = 0) then
    return 0
  end if
  return me.getRoomObject().setFrame(tValue)
end

on animate me, tValue
  if (me.getRoomObject() = 0) then
    return 0
  end if
  me.getRoomObject().animate()
  me.delay(1000, #render, tValue)
  return 1
end

on createRoomObject me, tdata
  tdata[#id] = ("sbm_" & tdata[#id])
  pObjectId = tdata[#id]
  tdata[#class] = "snowball_machine"
  tdata[#direction] = [0, 0]
  tdata[#altitude] = 0.0
  tdata[#dimensions] = [0, 0]
  tdata[#x] = tdata[#tile_x]
  tdata[#y] = tdata[#tile_y]
  tRoomComponent = getObject(#room_component)
  if (tRoomComponent = 0) then
    return 0
  end if
  tClassContainer = tRoomComponent.getClassContainer()
  if (tClassContainer = 0) then
    return error(me, "Room class container not found!", #createRoomObject)
  end if
  tClassContainer.set(tdata["class"], getClassVariable("snowwar.object_snowball_machine.roomobject.class"))
  return tRoomComponent.validateActiveObjects(tdata)
end

on getRoomObject me
  tRoomComponentObj = getObject(#room_component)
  if (tRoomComponentObj = 0) then
    return error(me, "Room component unavailable!", #getRoomObject)
  end if
  return tRoomComponentObj.getActiveObject(pObjectId)
end

on removeRoomObject me
  tRoomComponentObj = getObject(#room_component)
  if (tRoomComponentObj = 0) then
    return error(me, "Room component unavailable!", #removeRoomObject)
  end if
  if (pObjectId = VOID) then
    return 0
  end if
  if not tRoomComponentObj.activeObjectExists(pObjectId) then
    return 1
  end if
  return tRoomComponentObj.removeActiveObject(pObjectId)
end
