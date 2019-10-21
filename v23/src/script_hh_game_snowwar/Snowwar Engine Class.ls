property pObjectCache

on construct me 
  return TRUE
end

on deconstruct me 
  pObjectCache = void()
  return TRUE
end

on Refresh me, tTopic, tdata 
  if (tTopic = #gameend) then
    if getObject(#session).exists("user_game_index") then
      me.getGameSystem().executeGameObjectEvent(getObject(#session).GET("user_game_index"), #gameend)
    end if
  else
    if (tTopic = #update_game_object) then
      return(me.updateGameObject(tdata))
    else
      if (tTopic = #verify_game_object_id_list) then
        return(me.verifyGameObjectList(tdata))
      else
        if tTopic <> #snowwar_event_0 then
          if (tTopic = #create_game_object) then
            return(me.createGameObject(tdata))
          else
            if tTopic <> #snowwar_event_1 then
              if (tTopic = #remove_game_object) then
                return(me.removeGameObject(tdata.getAt(#id)))
              else
                if (tTopic = #snowwar_event_8) then
                  playSound("LS-throw")
                  return(me.createSnowballGameObject(tdata))
                else
                  if (tTopic = #world_ready) then
                    return(me.createStoredObjects())
                  else
                    return(error(me, "Undefined event!" && tTopic && "for" && me.pID, #Refresh))
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end

on createStoredObjects me 
  if (pObjectCache = void()) then
    return TRUE
  end if
  repeat while pObjectCache <= undefined
    tDataObject = getAt(undefined, undefined)
    me.createGameObject(tDataObject)
  end repeat
  pObjectCache = void()
end

on createGameObject me, tDataObject 
  tGameSystem = me.getGameSystem()
  if (tGameSystem.getWorldReady() = 0) then
    if (pObjectCache = void()) then
      pObjectCache = []
    end if
    pObjectCache.add(tDataObject)
    return TRUE
  end if
  tGameSystem.createGameObject(tDataObject.getAt(#id), tDataObject.getAt(#str_type), tDataObject.getAt(#objectDataStruct))
  tGameObject = tGameSystem.getGameObject(tDataObject.getAt(#id))
  if (tGameObject = 0) then
    return(error(me, "Unable to create game object:" && tDataObject.getAt(#id), #createGameObject))
  end if
  tGameObject.setGameObjectProperty(tDataObject)
  tGameObject.define(tDataObject)
  return TRUE
end

on updateGameObject me, tDataObject 
  tGameSystem = me.getGameSystem()
  tGameObject = tGameSystem.getGameObject(tDataObject.getAt(#id))
  if (tGameObject = 0) then
    return(error(me, "Game object not found:" && tDataObject.getAt(#id), #updateGameObject))
  end if
  tOldValues = tGameObject.pGameObjectSyncValues
  tNewValues = tDataObject.getAt(#objectDataStruct)
  i = 1
  repeat while i <= tNewValues.count
    tKey = tNewValues.getPropAt(i)
    if tOldValues.getAt(tKey) <> tNewValues.getAt(tKey) then
      put("** Obj" && tDataObject.getAt(#id) && "NOT IN SYNC:" && tKey && tOldValues.getAt(tKey) & ", server says:" && tNewValues.getAt(tKey))
    end if
    i = (1 + i)
  end repeat
  tGameSystem.updateGameObject(tDataObject.getAt(#id), tDataObject.getAt(#objectDataStruct))
  return(tGameObject.define(tDataObject))
end

on removeGameObject me, tObjectID 
  tGameSystem = me.getGameSystem()
  return(tGameSystem.removeGameObject(tObjectID))
end

on verifyGameObjectList me, tObjectIdList 
  tGameSystem = me.getGameSystem()
  tAllGameObjectIds = tGameSystem.getGameObjectIdsOfType(#all)
  repeat while tAllGameObjectIds <= undefined
    tObjectID = getAt(undefined, tObjectIdList)
    if tObjectIdList.getPos(tObjectID) < 1 then
      tGameSystem.removeGameObject(tObjectID)
    end if
  end repeat
  return TRUE
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
  tObject = tGameSystem.createGameObject(tdata.getAt(#id), "snowball", tGameObjectStruct)
  if (tObject = 0) then
    return(error(me, "Cannot create snowball object!", #createSnowballGameObject))
  end if
  tObject.define(tGameObjectStruct)
  tObject.calculateFlightPath(tGameObjectStruct, tdata.targetX, tdata.targetY)
  return TRUE
end
