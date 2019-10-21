on construct(me)
  pLocation = [#x:-1, #y:-1, #z:-1]
  return(1)
  exit
end

on deconstruct(me)
  me.removeRoomObject()
  return(1)
  exit
end

on define(me, tGameObject)
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
  return(1)
  exit
end

on executeGameObjectEvent(me, tEvent, tdata)
  if pDump then
    put("* executeGameObjectEvent on" && me.getObjectId() & ":" && tEvent && tdata)
  end if
  if me = #gameend then
    me.removeRoomObject()
  else
    put("* Gameobject: UNDEFINED EVENT:" && tEvent && tdata)
  end if
  exit
end

on createRoomObject(me, tdata)
  tdata.setAt(#id, tdata.getAt(#str_type) & "_" & tdata.getAt(#id))
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
  tClassContainer.set(tdata.getAt(#class), getClassVariable(tdata.getAt(#classID)))
  return(tRoomComponent.createActiveObject(tdata))
  exit
end

on removeRoomObject(me)
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
  exit
end

on dump(me)
  return(me.getGameObjectProperty(#str_type) && "id:" && me.getObjectId() && "loc:" && pLocation)
  exit
end