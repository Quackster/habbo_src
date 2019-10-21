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

on render me, tValue 
  if (me.getRoomObject() = 0) then
    return FALSE
  end if
  return(me.getRoomObject().setFrame(tValue))
end

on animate me, tValue 
  if (me.getRoomObject() = 0) then
    return FALSE
  end if
  me.getRoomObject().animate()
  me.delay(1000, #render, tValue)
  return TRUE
end

on createRoomObject me, tdata 
  tdata.setAt(#id, "sbm_" & tdata.getAt(#id))
  pObjectId = tdata.getAt(#id)
  tdata.setAt(#class, "snowball_machine")
  tdata.setAt(#direction, [0, 0])
  tdata.setAt(#altitude, 0)
  tdata.setAt(#dimensions, [0, 0])
  tdata.setAt(#x, tdata.getAt(#tile_x))
  tdata.setAt(#y, tdata.getAt(#tile_y))
  tRoomComponent = getObject(#room_component)
  if (tRoomComponent = 0) then
    return FALSE
  end if
  tClassContainer = tRoomComponent.getClassContainer()
  if (tClassContainer = 0) then
    return(error(me, "Room class container not found!", #createRoomObject))
  end if
  tClassContainer.set(tdata.getAt("class"), getClassVariable("snowwar.object_snowball_machine.roomobject.class"))
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
