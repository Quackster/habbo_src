property pObjectId, pLocation, pDump

on construct me
  pLocation = [#x: -1, #y: -1, #z: -1]
  return 1
end

on deconstruct me
  me.removeRoomObject()
  return 1
end

on define me, tGameObject
  tGameObject = tGameObject.duplicate()
  me.setGameObjectProperty(tGameObject)
  pLocation[#x] = tGameObject[#x]
  pLocation[#y] = tGameObject[#y]
  pLocation[#z] = tGameObject[#z]
  tGameObject.addProp(#class, "bb2_pu_pins")
  tSystemId = me.getGameSystem().getID()
  tClassID = tSystemId & ".roomobject." & tGameObject[#str_type] & ".class"
  tGameObject.addProp(#classID, tClassID)
  me.createRoomObject(tGameObject)
  return 1
end

on executeGameObjectEvent me, tEvent, tdata
  if pDump then
    put "* executeGameObjectEvent on" && me.getObjectId() & ":" && tEvent && tdata
  end if
  case tEvent of
    #gameend:
      me.removeRoomObject()
    otherwise:
      put "* Gameobject: UNDEFINED EVENT:" && tEvent && tdata
  end case
end

on createRoomObject me, tdata
  tdata[#id] = tdata[#str_type] & "_" & tdata[#id]
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
  tClassContainer.set(tdata[#class], getClassVariable(tdata[#classID]))
  return tRoomComponent.validateActiveObjects(tdata)
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

on dump me
  return me.getGameObjectProperty(#str_type) && "id:" && me.getObjectId() && "loc:" && pLocation
end
