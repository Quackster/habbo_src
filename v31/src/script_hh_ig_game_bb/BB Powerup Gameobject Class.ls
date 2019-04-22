property pActiveEffects, pTypeIndex, pDump, pRoomObject

on construct me 
  pActiveEffects = []
  pTypeIndex = ["bb2_pu_lghtbulb", "bb2_pu_spring", "bb2_pu_flashlght", "bb2_pu_cannon", "bb2_pu_pinbox", "bb2_pu_harlequin", "bb2_pu_bomb", "bb2_pu_drill", "bb2_pu_qstnmark"]
  return(1)
end

on deconstruct me 
  repeat while pActiveEffects <= undefined
    tEffect = getAt(undefined, undefined)
    tEffect.deconstruct()
  end repeat
  pActiveEffects = []
  me.removeRoomObject()
  return(1)
end

on define me, tGameObject 
  tGameObject = tGameObject.duplicate()
  me.setGameObjectProperty(tGameObject)
  if tGameObject.getAt(#powerupType) < 1 then
    return(error(me, "Invalid powerup type!", #define))
  end if
  if tGameObject.getAt(#powerupType) > pTypeIndex.count then
    return(error(me, "Undefined powerup type, see pTypeIndex!", #define))
  end if
  me.setLocation(tGameObject.getAt(#x), tGameObject.getAt(#y), tGameObject.getAt(#z))
  tStrType = pTypeIndex.getAt(tGameObject.getAt(#powerupType))
  tGameObject.addProp(#class, tStrType)
  tSystemId = me.getGameSystem().getID()
  tClassID = tSystemId & ".roomobject." & tGameObject.getAt(#str_type) & ".class"
  tGameObject.addProp(#classID, tClassID)
  me.createRoomObject(tGameObject)
  return(1)
end

on update me 
  i = 1
  repeat while i <= pActiveEffects.count
    tEffect = pActiveEffects.getAt(i)
    if tEffect.pActive then
      tEffect.update()
    else
      tEffect.deconstruct()
      pActiveEffects.deleteAt(i)
      me.pKilled = 1
    end if
    i = 1 + i
  end repeat
  return(1)
end

on executeGameObjectEvent me, tEvent, tdata 
  if pDump then
    put("* executeGameObjectEvent on" && me.getObjectId() & ":" && tEvent && tdata)
  end if
  if tEvent = #pickup_powerup then
    return(me.roomObjectAction(#hide_roomobject))
  else
    if tEvent = #gameend then
      me.removeRoomObject()
    else
      put("* Gameobject: UNDEFINED EVENT:" && tEvent && tdata)
    end if
  end if
end

on createRoomObject me, tDataStruct 
  pRoomObject = createObject(#temp, getClassVariable("bb_gamesystem.roomobject.powerup.wrapper.class"))
  if pRoomObject = 0 then
    return(error(me, "Cannot create roomobject wrapper!", #createRoomObject))
  end if
  return(pRoomObject.define(tDataStruct))
end

on removeRoomObject me 
  if not objectp(pRoomObject) then
    return(1)
  end if
  pRoomObject.deconstruct()
  pRoomObject = void()
  return(1)
end

on roomObjectAction me, tAction, tdata 
  if not objectp(pRoomObject) then
    return(0)
  end if
  return(pRoomObject.roomObjectAction(tAction, tdata))
end
