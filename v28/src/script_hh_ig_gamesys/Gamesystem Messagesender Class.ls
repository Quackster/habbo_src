on construct(me)
  pConnectionId = getVariableValue("connection.info.id")
  pUpdateInterval = getIntVariable("gamesystem.instancelist.updatetime", 15000)
  return(1)
  exit
end

on deconstruct(me)
  me.setInstanceListUpdates(0)
  return(1)
  exit
end

on setInstanceListUpdates(me, tBoolean)
  tTimeoutID = #gamesystem_update
  tVarMgrObj = me.getVariableManager()
  if not tVarMgrObj.exists(#instancelist_timestamp) then
    tVarMgrObj.set(#instancelist_timestamp, 0)
  end if
  if tBoolean then
    if abs(the milliSeconds - tVarMgrObj.GET(#instancelist_timestamp)) > pUpdateInterval then
      me.getMessageSender().sendGetInstanceList()
    end if
    if timeoutExists(tTimeoutID) then
      return(1)
    end if
    return(createTimeout(tTimeoutID, pUpdateInterval, #sendGetInstanceList, me.getID()))
  else
    tVarMgrObj.set(#instancelist_timestamp, 0)
    if timeoutExists(tTimeoutID) then
      removeTimeout(tTimeoutID)
    end if
    return(1)
  end if
  exit
end

on sendGetInstanceList(me)
  if not connectionExists(pConnectionId) then
    return(error(me, "Connection not found:" && pConnectionId, #sendGetInstanceList))
  end if
  me.getVariableManager().set(#game_status, #none)
  return(getConnection(pConnectionId).send("GETINSTANCELIST"))
  exit
end

on sendObserveInstance(me, tID)
  if not connectionExists(pConnectionId) then
    return(error(me, "Connection not found:" && pConnectionId, #sendObserveInstance))
  end if
  return(getConnection(pConnectionId).send("OBSERVEINSTANCE", [#integer:tID]))
  exit
end

on sendUnobserveInstance(me)
  if not connectionExists(pConnectionId) then
    return(error(me, "Connection not found:" && pConnectionId, #sendUnobserveInstance))
  end if
  me.getVariableManager().set(#observed_instance_data, [])
  me.getVariableManager().set(#game_status, #none)
  me.setInstanceListUpdates(1)
  return(getConnection(pConnectionId).send("UNOBSERVEINSTANCE"))
  exit
end

on sendInitiateCreateGame(me, tTeamId)
  if not connectionExists(pConnectionId) then
    return(error(me, "Connection not found:" && pConnectionId, #sendInitiateCreateGame))
  end if
  me.setInstanceListUpdates(0)
  me.getVariableManager().set(#game_status, #none)
  if tTeamId <> void() then
    tTeamId = tTeamId - 1
    return(getConnection(pConnectionId).send("INITIATECREATEGAME", [#integer:integer(tTeamId)]))
  else
    return(getConnection(pConnectionId).send("INITIATECREATEGAME"))
  end if
  exit
end

on sendGameParameterValues(me, tParamList, tTeamId)
  if me.getBaseLogic().getGamestatus() = #create_requested then
    return(0)
  end if
  tTeamId = tTeamId - 1
  if not connectionExists(pConnectionId) then
    return(error(me, "Connection not found:" && pConnectionId, #sendGameParameterValues))
  end if
  me.setInstanceListUpdates(0)
  tStruct = me.getVariableManager().GET(#gameparametervalues_format)
  tCount = tStruct.count
  tOutput = [#integer:tCount]
  i = 1
  repeat while i <= tCount
    tValueData = tStruct.getAt(i)
    if tParamList.findPos(tValueData.getAt(#name)) = 0 then
      return(error(me, "Invalid game parameter values!", #sendGameParameterValues))
    end if
    tValue = tParamList.getAt(tValueData.getAt(#name))
    tOutput.addProp(#string, tValueData.getAt(#name))
    if tValueData.getAt(#type) = #integer then
      tOutput.addProp(#integer, 0)
      tOutput.addProp(#integer, tValue)
    else
      if tValueData.getAt(#type) = #string then
        tOutput.addProp(#integer, 1)
        tOutput.addProp(#string, string(tValue))
      end if
    end if
    i = 1 + i
  end repeat
  me.getVariableManager().set(#game_status, #create_requested)
  tOutput.addProp(#integer, tTeamId)
  return(getConnection(pConnectionId).send("GAMEPARAMETERVALUES", tOutput))
  exit
end

on sendDeleteGame(me)
  if not connectionExists(pConnectionId) then
    return(error(me, "Connection not found:" && pConnectionId, #sendDeleteGame))
  end if
  me.getVariableManager().set(#observed_instance_data, [])
  me.getVariableManager().set(#game_status, #none)
  me.setInstanceListUpdates(1)
  return(getConnection(pConnectionId).send("DELETEGAME"))
  exit
end

on sendInitiateJoinGame(me, tInstanceId, tTeamId)
  if not connectionExists(pConnectionId) then
    return(error(me, "Connection not found:" && pConnectionId, #sendInitiateJoinGame))
  end if
  tdata = me.getVariableManager().GET(#observed_instance_data)
  if tdata.findPos(#id) = 0 then
    return(0)
  end if
  if tInstanceId = void() then
    tInstanceId = tdata.getAt(#id)
  end if
  if tTeamId = void() then
    return(0)
  end if
  tTeamId = tTeamId - 1
  me.setInstanceListUpdates(0)
  me.getVariableManager().set(#game_status, #none)
  return(getConnection(pConnectionId).send("INITIATEJOINGAME", [#integer:tInstanceId, #integer:tTeamId]))
  exit
end

on sendJoinParameterValues(me, tInstanceId, tTeamId, tParamList)
  if me.getBaseLogic().getGamestatus() = #join_requested then
    return(0)
  end if
  if not connectionExists(pConnectionId) then
    return(error(me, "Connection not found:" && pConnectionId, #sendJoinParameterValues))
  end if
  tdata = me.getVariableManager().GET(#observed_instance_data)
  if tInstanceId = void() then
    tInstanceId = tdata.getAt(#id)
  end if
  if tInstanceId = void() then
    return(0)
  end if
  if tTeamId = void() then
    return(0)
  end if
  tTeamId = tTeamId - 1
  tCount = tParamList.count
  tOutput = [#integer:tInstanceId, #integer:tTeamId, #integer:tCount]
  i = 1
  repeat while i <= tCount
    tOutput.addProp(#string, tParamList.getPropAt(i))
    if ilk(tParamList.getAt(i)) = #integer then
      tOutput.addProp(#integer, 0)
      tOutput.addProp(#integer, tParamList.getAt(i))
    else
      tOutput.addProp(#integer, 1)
      tOutput.addProp(#string, tParamList.getAt(i))
    end if
    i = 1 + i
  end repeat
  me.setInstanceListUpdates(0)
  me.getVariableManager().set(#game_status, #join_requested)
  return(getConnection(pConnectionId).send("JOINPARAMETERVALUES", tOutput))
  exit
end

on sendLeaveGame(me)
  if not connectionExists(pConnectionId) then
    return(error(me, "Connection not found:" && pConnectionId, #sendLeaveGame))
  end if
  me.getVariableManager().set(#game_status, #none)
  return(getConnection(pConnectionId).send("LEAVEGAME"))
  exit
end

on sendKickPlayer(me, tPlayerId)
  tPlayerId = integer(tPlayerId)
  if not integerp(tPlayerId) then
    return(error(me, "Integer expected!", #sendKickPlayer))
  end if
  if not connectionExists(pConnectionId) then
    return(error(me, "Connection not found:" && pConnectionId, #sendNavigate))
  end if
  return(getConnection(pConnectionId).send("KICKPLAYER", [#integer:tPlayerId]))
  exit
end

on sendWatchGame(me, tInstanceId)
  if not connectionExists(pConnectionId) then
    return(error(me, "Connection not found:" && pConnectionId, #sendWatchGame))
  end if
  me.setInstanceListUpdates(0)
  me.getVariableManager().set(#game_status, #watch_requested)
  return(getConnection(pConnectionId).send("WATCHGAME", [#integer:tInstanceId]))
  exit
end

on sendStartGame(me)
  if not connectionExists(pConnectionId) then
    return(error(me, "Connection not found:" && pConnectionId, #sendStartGame))
  end if
  return(getConnection(pConnectionId).send("STARTGAME"))
  exit
end

on sendRejoinGame(me)
  if not connectionExists(pConnectionId) then
    return(error(me, "Connection not found:" && pConnectionId, #sendRejoinGame))
  end if
  return(getConnection(pConnectionId).send("REJOINGAME"))
  exit
end

on sendRequestFullStatusUpdate(me)
  if not connectionExists(pConnectionId) then
    return(error(me, "Connection not found:" && pConnectionId, #sendRequestFullStatusUpdate))
  end if
  return(getConnection(pConnectionId).send("REQUESTFULLSTATUSUPDATE"))
  exit
end

on sendGameEventMessage(me, tdata)
  if not connectionExists(pConnectionId) then
    return(error(me, "Connection not found:" && pConnectionId, #sendGameEventMessage))
  end if
  if not listp(tdata) then
    return(error(me, "Message struct in wrong format", #sendGameEventMessage))
  end if
  if tdata.getPropAt(1) <> #integer then
    return(error(me, "Message struct in wrong format", #sendGameEventMessage))
  end if
  return(getConnection(pConnectionId).send("MSG_PLAYER_INPUT", tdata))
  exit
end

on sendLevelEditorCommand(me, tdata)
  if not connectionExists(pConnectionId) then
    return(error(me, "Connection not found:" && pConnectionId, #sendLevelEditorCommand))
  end if
  if not listp(tdata) then
    return(error(me, "Message struct in wrong format", #sendLevelEditorCommand))
  end if
  if tdata.getPropAt(1) <> #integer then
    return(error(me, "Message struct in wrong format", #sendLevelEditorCommand))
  end if
  return(getConnection(pConnectionId).send("LEVELEDITORCOMMAND", tdata))
  exit
end

on sendHabboRoomMove(me, tLocX, tLocY)
  if not connectionExists(pConnectionId) then
    return(error(me, "Connection not found:" && pConnectionId, #sendHabboRoomMove))
  end if
  return(getConnection(pConnectionId).send("MOVE", [#short:tLocX, #short:tLocY]))
  exit
end