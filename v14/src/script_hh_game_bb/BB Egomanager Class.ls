property pConnectionId

on construct me 
  pConnectionId = getVariableValue("connection.info.id")
  registerMessage(#create_user, me.getID(), #handleUserCreated)
  return TRUE
end

on deconstruct me 
  unregisterMessage(#create_user, me.getID())
  return TRUE
end

on Refresh me, tTopic, tdata 
  if (tTopic = #send_set_target) then
    me.sendSetTarget(tdata)
  else
    if (tTopic = #gamestart) then
      me.hideArrowHiliter()
    end if
  end if
  return TRUE
end

on sendSetTarget me, tdata 
  tGameSystem = me.getGameSystem()
  if (tGameSystem = 0) then
    return FALSE
  end if
  if tGameSystem.getSpectatorModeFlag() then
    return FALSE
  end if
  tGameState = tGameSystem.getGamestatus()
  tConnection = me.getRoomConnection()
  if not objectp(tConnection) then
    return(error(me, "Info connection has disappeared!", #sendMoveGoal))
  end if
  if (tGameState = #game_started) then
    tGameObject = me.getGameObject()
    if (tGameObject = 0) then
      return(error(me, "Own user not found.", #sendSetTarget))
    end if
    if not tGameObject.checkStateAllowsMoving() then
      return TRUE
    end if
    return(tGameSystem.sendGameEventMessage([#integer:2, #integer:tdata.getAt(1), #integer:tdata.getAt(2)]))
  else
    return(tConnection.send("MOVE", [#short:tdata.getAt(1), #short:tdata.getAt(2)]))
  end if
end

on handleUserCreated me, tName, tUserStrId 
  if me.getGameSystem().getSpectatorModeFlag() then
    return TRUE
  end if
  if not getObject(#session).exists("user_index") then
    return FALSE
  end if
  if tUserStrId <> getObject(#session).GET("user_index") then
    return FALSE
  end if
  return(getObject(#room_interface).showArrowHiliter(tUserStrId))
end

on hideArrowHiliter me 
  if not objectExists(#room_interface) then
    return FALSE
  end if
  return(getObject(#room_interface).hideArrowHiliter())
end

on getGameObject me 
  tGameSystem = me.getGameSystem()
  if (tGameSystem = 0) then
    return FALSE
  end if
  tSession = getObject(#session)
  if (tSession = 0) then
    return FALSE
  end if
  if not tSession.exists("user_game_index") then
    return(error(me, "Own user not found.", #getGameObject))
  end if
  tUserIndex = tSession.GET("user_game_index")
  return(tGameSystem.getGameObject(tUserIndex))
end

on getRoomConnection me 
  if not connectionExists(pConnectionId) then
    return(error(me, "Info connection not found!", #getRoomConnection))
  end if
  return(getConnection(pConnectionId))
end
