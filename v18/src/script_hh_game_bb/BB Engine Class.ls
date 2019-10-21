on construct(me)
  return(1)
  exit
end

on deconstruct(me)
  return(1)
  exit
end

on Refresh(me, tTopic, tdata)
  if me = #update_game_object then
    return(me.updateGameObject(tdata))
  else
    if me = #bb_event_0 then
      return(me.createGameObject(tdata.getAt(#data)))
    else
      if me = #create_game_object then
        return(me.createGameObject(tdata))
      else
        if me = #bb_event_1 then
          return(me.removeGameObject(tdata.getAt(#id)))
        else
          if me = #bb_event_3 then
            me.sendGameSystemEvent(#soundeffect, "SFX-18-poweruppickup")
            return(me.getGameSystem().executeGameObjectEvent(tdata.getAt(#powerupid), #pickup_powerup))
          else
            if me = #bb_event_5 then
              me.sendGameSystemEvent(#soundeffect, "SFX-" & tdata.getAt(#powerupType))
              return(me.powerupActivated(tdata))
            else
              if me = #gameend then
                return(me.getGameSystem().executeGameObjectEvent(#all, #gameend))
              else
                return(error(me, "Undefined event!" && tTopic && "for" && me.pID, #Refresh))
              end if
            end if
          end if
        end if
      end if
    end if
  end if
  exit
end

on createGameObject(me, tDataObject)
  tGameSystem = me.getGameSystem()
  if not tGameSystem.createGameObject(tDataObject.getAt(#id), tDataObject.getAt(#str_type), tDataObject.getAt(#objectDataStruct)) then
    return(1)
  end if
  tGameObject = tGameSystem.getGameObject(tDataObject.getAt(#id))
  if tGameObject = 0 then
    return(error(me, "Unable to create game object:" && tDataObject.getAt(#id), #createGameObject))
  end if
  tGameObject.setGameObjectProperty(tDataObject)
  tGameObject.define(tDataObject)
  return(1)
  exit
end

on updateGameObject(me, tDataObject)
  tGameSystem = me.getGameSystem()
  if tGameSystem = 0 then
    return(error(me, "Game object not found!" && tDataObject, #updateGameObject))
  end if
  if tDataObject.getAt(#str_type) = "player" then
    tGameSystem.executeGameObjectEvent(tDataObject.getAt(#id), #gameobject_update, tDataObject)
  end if
  return(tGameSystem.updateGameObject(tDataObject.getAt(#id), tDataObject))
  exit
end

on removeGameObject(me, tObjectID)
  tGameSystem = me.getGameSystem()
  return(tGameSystem.removeGameObject(tObjectID))
  exit
end

on powerupActivated(me, tdata)
  tGameSystem = me.getGameSystem()
  if tGameSystem = 0 then
    return(0)
  end if
  tGameSystem.executeGameObjectEvent(tdata.getAt(#playerId), #activate_powerup, tdata)
  return(1)
  exit
end