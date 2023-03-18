property pActiveEffects, pRoomObject, pTypeIndex, pLocation, pDump

on construct me
  pActiveEffects = []
  pTypeIndex = ["bb2_pu_lghtbulb", "bb2_pu_spring", "bb2_pu_flashlght", "bb2_pu_cannon", "bb2_pu_pinbox", "bb2_pu_harlequin", "bb2_pu_bomb", "bb2_pu_drill", "bb2_pu_qstnmark"]
  return 1
end

on deconstruct me
  repeat with tEffect in pActiveEffects
    tEffect.deconstruct()
  end repeat
  pActiveEffects = []
  me.removeRoomObject()
  return 1
end

on define me, tGameObject
  tGameObject = tGameObject.duplicate()
  me.setGameObjectProperty(tGameObject)
  if tGameObject[#powerupType] < 1 then
    return error(me, "Invalid powerup type!", #define)
  end if
  if tGameObject[#powerupType] > pTypeIndex.count then
    return error(me, "Undefined powerup type, see pTypeIndex!", #define)
  end if
  me.setLocation(tGameObject[#x], tGameObject[#y], tGameObject[#z])
  tStrType = pTypeIndex[tGameObject[#powerupType]]
  tGameObject.addProp(#class, tStrType)
  tSystemId = me.getGameSystem().getID()
  tClassID = tSystemId & ".roomobject." & tGameObject[#str_type] & ".class"
  tGameObject.addProp(#classID, tClassID)
  me.createRoomObject(tGameObject)
  return 1
end

on update me
  repeat with i = 1 to pActiveEffects.count
    tEffect = pActiveEffects[i]
    if tEffect.pActive then
      tEffect.update()
      next repeat
    end if
    tEffect.deconstruct()
    pActiveEffects.deleteAt(i)
    me.pKilled = 1
  end repeat
  return 1
end

on executeGameObjectEvent me, tEvent, tdata
  if pDump then
    put "* executeGameObjectEvent on" && me.getObjectId() & ":" && tEvent && tdata
  end if
  case tEvent of
    #pickup_powerup:
      return me.roomObjectAction(#hide_roomobject)
    #gameend:
      me.removeRoomObject()
    otherwise:
      put "* Gameobject: UNDEFINED EVENT:" && tEvent && tdata
  end case
end

on createRoomObject me, tDataStruct
  pRoomObject = createObject(#temp, getClassVariable("bb_gamesystem.roomobject.powerup.wrapper.class"))
  if pRoomObject = 0 then
    return error(me, "Cannot create roomobject wrapper!", #createRoomObject)
  end if
  return pRoomObject.define(tDataStruct)
end

on removeRoomObject me
  if not objectp(pRoomObject) then
    return 1
  end if
  pRoomObject.deconstruct()
  pRoomObject = VOID
  return 1
end

on roomObjectAction me, tAction, tdata
  if not objectp(pRoomObject) then
    return 0
  end if
  return pRoomObject.roomObjectAction(tAction, tdata)
end
