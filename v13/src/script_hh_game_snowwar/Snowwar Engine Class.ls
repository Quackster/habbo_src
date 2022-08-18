property pObjectCache

on construct me
  return 1
end

on deconstruct me
  pObjectCache = VOID
  return 1
end

on Refresh me, tTopic, tdata
  case tTopic of
    #gameend:
      if getObject(#session).exists("user_game_index") then
        me.getGameSystem().executeGameObjectEvent(getObject(#session).GET("user_game_index"), #gameend)
      end if
    #update_game_object:
      return me.updateGameObject(tdata)
    #verify_game_object_id_list:
      return me.verifyGameObjectList(tdata)
    #snowwar_event_0, #create_game_object:
      return me.createGameObject(tdata)
    #snowwar_event_1, #remove_game_object:
      return me.removeGameObject(tdata[#id])
    #snowwar_event_8:
      playSound("LS-throw")
      return me.createSnowballGameObject(tdata)
    #world_ready:
      return me.createStoredObjects()
  end case
  return error(me, ((("Undefined event!" && tTopic) && "for") && me.pID), #Refresh)
end

on createStoredObjects me
  if (pObjectCache = VOID) then
    return 1
  end if
  repeat with tDataObject in pObjectCache
    me.createGameObject(tDataObject)
  end repeat
  pObjectCache = VOID
end

on createGameObject me, tDataObject
  tGameSystem = me.getGameSystem()
  if (tGameSystem.getWorldReady() = 0) then
    if (pObjectCache = VOID) then
      pObjectCache = []
    end if
    pObjectCache.add(tDataObject)
    return 1
  end if
  tGameSystem.createGameObject(tDataObject[#id], tDataObject[#str_type], tDataObject[#objectDataStruct])
  tGameObject = tGameSystem.getGameObject(tDataObject[#id])
  if (tGameObject = 0) then
    return error(me, ("Unable to create game object:" && tDataObject[#id]), #createGameObject)
  end if
  tGameObject.setGameObjectProperty(tDataObject)
  tGameObject.define(tDataObject)
  return 1
end

on updateGameObject me, tDataObject
  tGameSystem = me.getGameSystem()
  tGameObject = tGameSystem.getGameObject(tDataObject[#id])
  if (tGameObject = 0) then
    return error(me, ("Game object not found:" && tDataObject[#id]), #updateGameObject)
  end if
  tOldValues = tGameObject.pGameObjectSyncValues
  tNewValues = tDataObject[#objectDataStruct]
  repeat with i = 1 to tNewValues.count
    tKey = tNewValues.getPropAt(i)
    if (tOldValues[tKey] <> tNewValues[tKey]) then
      put (((((("** Obj" && tDataObject[#id]) && "NOT IN SYNC:") && tKey) && tOldValues[tKey]) & ", server says:") && tNewValues[tKey])
    end if
  end repeat
  tGameSystem.updateGameObject(tDataObject[#id], tDataObject[#objectDataStruct])
  return tGameObject.define(tDataObject)
end

on removeGameObject me, tObjectID
  tGameSystem = me.getGameSystem()
  return tGameSystem.removeGameObject(tObjectID)
end

on verifyGameObjectList me, tObjectIdList
  tGameSystem = me.getGameSystem()
  tAllGameObjectIds = tGameSystem.getGameObjectIdsOfType(#all)
  repeat with tObjectID in tAllGameObjectIds
    if (tObjectIdList.getPos(tObjectID) < 1) then
      tGameSystem.removeGameObject(tObjectID)
    end if
  end repeat
  return 1
end

on createSnowballGameObject me, tdata
  tGameSystem = me.getGameSystem()
  tThrowerObject = tGameSystem.getGameObject(string(tdata.int_thrower_id))
  tThrowerLoc = tThrowerObject.getLocation()
  tGameObjectStruct = [:]
  tGameObjectStruct.addProp(#type, 1)
  tGameObjectStruct.addProp(#int_id, tdata.int_id)
  tGameObjectStruct.addProp(#id, tdata.id)
  tGameObjectStruct.addProp(#x, tThrowerLoc.x)
  tGameObjectStruct.addProp(#y, tThrowerLoc.y)
  tGameObjectStruct.addProp(#z, tThrowerLoc.z)
  tGameObjectStruct.addProp(#movement_direction, 0)
  tGameObjectStruct.addProp(#trajectory, tdata.trajectory)
  tGameObjectStruct.addProp(#time_to_live, 0)
  tGameObjectStruct.addProp(#int_thrower_id, tdata.int_thrower_id)
  tGameObjectStruct.addProp(#parabola_offset, 0)
  tObject = tGameSystem.createGameObject(tdata[#id], "snowball", tGameObjectStruct)
  if (tObject = 0) then
    return error(me, "Cannot create snowball object!", #createSnowballGameObject)
  end if
  tObject.define(tGameObjectStruct)
  tObject.calculateFlightPath(tGameObjectStruct, tdata.targetX, tdata.targetY)
  return 1
end
