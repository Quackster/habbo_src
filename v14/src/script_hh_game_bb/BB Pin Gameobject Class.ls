property pLocation, pDump, pObjectId

on construct me 
  pLocation = [#x:-1, #y:-1, #z:-1]
  return TRUE
end

on deconstruct me 
  me.removeRoomObject()
  return TRUE
end

on define me, tGameObject 
  tGameObject = tGameObject.duplicate()
  me.setGameObjectProperty(tGameObject)
  pLocation.setAt(#x, tGameObject.getAt(#x))
  pLocation.setAt(#y, tGameObject.getAt(#y))
  pLocation.setAt(#z, tGameObject.getAt(#z))
  tGameObject.addProp(#class, "bb2_pu_pins")
  tSystemId = me.getGameSystem().getID()
  tClassID = tSystemId & ".roomobject." & tGameObject.getAt(#str_type) & ".class"
  tGameObject.addProp(#classID, tClassID)
  me.createRoomObject(tGameObject)
  return TRUE
end

on executeGameObjectEvent me, tEvent, tdata 
  if pDump then
    put("* executeGameObjectEvent on" && me.getObjectId() & ":" && tEvent && tdata)
  end if
  if (tEvent = #gameend) then
    me.removeRoomObject()
  else
    put("* Gameobject: UNDEFINED EVENT:" && tEvent && tdata)
  end if
end

on createRoomObject me, tdata 
  tdata.setAt(#id, tdata.getAt(#str_type) & "_" & tdata.getAt(#id))
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
  tClassContainer.set(tdata.getAt(#class), getClassVariable(tdata.getAt(#classID)))
  return(tRoomComponent.validateActiveObjects(tdata))
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

on dump me 
  return(me.getGameObjectProperty(#str_type) && "id:" && me.getObjectId() && "loc:" && pLocation)
end
