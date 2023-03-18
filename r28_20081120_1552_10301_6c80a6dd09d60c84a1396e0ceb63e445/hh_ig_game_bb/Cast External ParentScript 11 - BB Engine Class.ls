on construct me
  return 1
end

on deconstruct me
  return 1
end

on Refresh me, tTopic, tdata
  case tTopic of
    #update_game_object:
      return me.updateGameObject(tdata)
    #bb_event_0:
      return me.createGameObject(tdata[#data])
    #create_game_object:
      return me.createGameObject(tdata)
    #bb_event_1:
      return me.removeGameObject(tdata[#id])
    #bb_event_3:
      me.sendGameSystemEvent(#soundeffect, "SFX-18-poweruppickup")
      return me.getGameSystem().executeGameObjectEvent(tdata[#powerupid], #pickup_powerup)
    #bb_event_5:
      me.sendGameSystemEvent(#soundeffect, "SFX-" & tdata[#powerupType])
      return me.powerupActivated(tdata)
    #gameend:
      return me.getGameSystem().executeGameObjectEvent(#all, #gameend)
    otherwise:
      return error(me, "Undefined event!" && tTopic && "for" && me.pID, #Refresh)
  end case
end

on createGameObject me, tDataObject
  tGameSystem = me.getGameSystem()
  if not tGameSystem.createGameObject(tDataObject[#id], tDataObject[#str_type], tDataObject[#objectDataStruct]) then
    return 1
  end if
  tGameObject = tGameSystem.getGameObject(tDataObject[#id])
  if tGameObject = 0 then
    return error(me, "Unable to create game object:" && tDataObject[#id], #createGameObject)
  end if
  tGameObject.setGameObjectProperty(tDataObject)
  tGameObject.define(tDataObject)
  return 1
end

on updateGameObject me, tDataObject
  tGameSystem = me.getGameSystem()
  if tGameSystem = 0 then
    return error(me, "Game object not found!" && tDataObject, #updateGameObject)
  end if
  if tDataObject[#str_type] = "player" then
    tGameSystem.executeGameObjectEvent(tDataObject[#id], #gameobject_update, tDataObject)
  end if
  return tGameSystem.updateGameObject(tDataObject[#id], tDataObject)
end

on removeGameObject me, tObjectId
  tGameSystem = me.getGameSystem()
  return tGameSystem.removeGameObject(tObjectId)
end

on powerupActivated me, tdata
  tGameSystem = me.getGameSystem()
  if tGameSystem = 0 then
    return 0
  end if
  tGameSystem.executeGameObjectEvent(tdata[#playerId], #activate_powerup, tdata)
  return 1
end
