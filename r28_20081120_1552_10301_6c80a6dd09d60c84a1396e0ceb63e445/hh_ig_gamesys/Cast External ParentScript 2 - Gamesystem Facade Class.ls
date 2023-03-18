property pThread, pVarMgrObj

on construct me
  registerMessage(#gamesystem_sendevent, me.getID(), #sendGameSystemEvent)
  return 1
end

on deconstruct me
  unregisterMessage(#gamesystem_sendevent, me.getID())
  if objectp(pThread) then
    if objectp(pThread.getBaseLogic()) then
      pThread.getBaseLogic().initVariables()
    end if
    if objectp(pThread.getProcManager()) then
      pThread.getProcManager().removeAllProcessors()
    end if
  end if
  pThread = VOID
  return 1
end

on defineClient me, tSystemObj
  pThread = tSystemObj
  if pThread = 0 then
    return error(me, "Client game framework not found:" && me.getID(), #defineClient)
  end if
  if getmemnum(me.getID() & ".variable.index") then
    dumpVariableField(me.getID() & ".variable.index")
  end if
  pThread.getBaseLogic().defineClient(me.getID())
  pThread.getMessageHandler().defineClient(me.getID())
  pThread.getComponent().defineClient(me.getID())
  pThread.getProcManager().defineClient(me.getID())
  pThread.getProcManager().distributeEvent(#facadeok, me.getID())
  return 1
end

on getNumTickets me
  if getObject(#session) = 0 then
    return 0
  end if
  return getObject(#session).GET("user_ph_tickets")
end

on getSpectatorModeFlag me
  if me.getVarMgr() = 0 then
    return 0
  end if
  return me.getVarMgr().GET(#spectatormode_flag)
end

on getTournamentFlag me
  if me.getVarMgr() = 0 then
    return 0
  end if
  if not me.getVarMgr().exists(#tournament_flag) then
    return 0
  end if
  return me.getVarMgr().GET(#tournament_flag)
end

on getGameTicketsNotUsedFlag me
  if not variableExists("games.tickets.hide") then
    return 0
  end if
  return value(getVariable("games.tickets.hide"))
end

on getWorldReady me
  if pThread = 0 then
    return 0
  end if
  return pThread.getWorld().getWorldReady()
end

on getGamestatus me
  if pThread = 0 then
    return 0
  end if
  return pThread.getBaseLogic().getGamestatus()
end

on setGameStatus me, tStatus
  tVarMgr = me.getVarMgr()
  if tVarMgr = 0 then
    return 0
  end if
  return tVarMgr.set(#game_status, tStatus)
end

on getInstanceList me
  if me.getVarMgr() = 0 then
    return 0
  end if
  return me.getVarMgr().GET(#instancelist)
end

on getObservedInstance me
  if me.getVarMgr() = 0 then
    return 0
  end if
  return me.getVarMgr().GET(#observed_instance_data)
end

on getGameParameters me
  if me.getVarMgr() = 0 then
    return 0
  end if
  if not me.getVarMgr().exists(#gameparametervalues_format) then
    return 0
  end if
  return me.getVarMgr().GET(#gameparametervalues_format)
end

on getJoinParameters me
  if me.getVarMgr() = 0 then
    return 0
  end if
  if not me.getVarMgr().exists(#joinparametervalues_format) then
    return 0
  end if
  return me.getVarMgr().GET(#joinparametervalues_format)
end

on setInstanceListUpdates me, tBoolean
  if pThread = 0 then
    return 0
  end if
  return pThread.getMessageSender().setInstanceListUpdates(tBoolean)
end

on sendGetInstanceList me
  if pThread = 0 then
    return 0
  end if
  return pThread.getMessageSender().sendGetInstanceList()
end

on observeInstance me, tID
  if pThread = 0 then
    return 0
  end if
  return pThread.getMessageSender().sendObserveInstance(tID)
end

on unobserveInstance me
  if pThread = 0 then
    return 0
  end if
  return pThread.getMessageSender().sendUnobserveInstance()
end

on initiateCreateGame me, tTeamId
  if pThread = 0 then
    return 0
  end if
  return pThread.getMessageSender().sendInitiateCreateGame(tTeamId)
end

on cancelCreateGame me
  if pThread = 0 then
    return 0
  end if
  return pThread.getBaseLogic().cancelCreateGame()
end

on createGame me, tParamList, tTeamId
  if pThread = 0 then
    return 0
  end if
  return pThread.getMessageSender().sendGameParameterValues(tParamList, tTeamId)
end

on deleteGame me
  if pThread = 0 then
    return 0
  end if
  return pThread.getMessageSender().sendDeleteGame()
end

on initiateJoinGame me, tInstanceId, tTeamId
  if pThread = 0 then
    return 0
  end if
  pThread.getBaseLogic().store_joinparameters(me, [:])
  return pThread.getMessageSender().sendInitiateJoinGame(tInstanceId, tTeamId)
end

on joinGame me, tInstanceId, tTeamId, tParamList
  if pThread = 0 then
    return 0
  end if
  return pThread.getMessageSender().sendJoinParameterValues(tInstanceId, tTeamId, tParamList)
end

on leaveGame me
  if pThread = 0 then
    return 0
  end if
  return pThread.getMessageSender().sendLeaveGame()
end

on kickPlayer me, tPlayerId
  if pThread = 0 then
    return 0
  end if
  return pThread.getMessageSender().sendKickPlayer(tPlayerId)
end

on watchGame me, tInstanceId
  if pThread = 0 then
    return 0
  end if
  if tInstanceId = VOID then
    tInstance = me.getObservedInstance()
    if tInstance = 0 then
      return 0
    end if
    tInstanceId = tInstance[#id]
  end if
  return pThread.getMessageSender().sendWatchGame(tInstanceId)
end

on startGame
  if pThread = 0 then
    return 0
  end if
  return pThread.getMessageSender().sendStartGame()
end

on rejoinGame me
  if pThread = 0 then
    return 0
  end if
  return pThread.getMessageSender().sendRejoinGame()
end

on enterLounge me
  if pThread = 0 then
    return 0
  end if
  return pThread.getBaseLogic().enterLounge()
end

on sendGameEventMessage me, tdata
  if pThread = 0 then
    return 0
  end if
  return pThread.getMessageSender().sendGameEventMessage(tdata)
end

on sendLevelEditorCommand me, tdata
  if pThread = 0 then
    return 0
  end if
  return pThread.getMessageSender().sendLevelEditorCommand(tdata)
end

on sendGameSystemEvent me, tTopic, tdata
  if pThread = 0 then
    return 0
  end if
  return pThread.getProcManager().distributeEvent(tTopic, tdata)
end

on sendHabboRoomMove me, tLocX, tLocY
  if pThread = 0 then
    return 0
  end if
  return pThread.getMessageSender().sendHabboRoomMove(tLocX, tLocY)
end

on createGameObject me, tID, ttype, tDataToStore
  if pThread = 0 then
    return 0
  end if
  return pThread.getComponent().createGameObject(tID, ttype, tDataToStore)
end

on getGameObject me, tID
  if pThread = 0 then
    return 0
  end if
  return pThread.getComponent().getGameObject(tID)
end

on getGameObjectProperty me, tObjectId, tProp
  if pThread = 0 then
    return 0
  end if
  tObject = pThread.getComponent().getGameObject(tObjectId)
  if tObject = 0 then
    error(me, "Game object doesn't exist:" && tObjectId, #getGameObjectProperty)
    return VOID
  end if
  return tObject.getGameObjectProperty(tProp)
end

on getGameObjectIdsOfType me, ttype
  if pThread = 0 then
    return 0
  end if
  return pThread.getComponent().getGameObjectIdsOfType(ttype)
end

on setGameObjectProperty me, tObjectId, tProp, tValue
  if pThread = 0 then
    return 0
  end if
  tObject = pThread.getComponent().getGameObject(tObjectId)
  if tObject = 0 then
    return error(me, "Game object doesn't exist:" && tObjectId, #setGameObjectProperty)
  end if
  return tObject.setGameObjectProperty(tProp, tValue)
end

on updateGameObject me, tID, tdata
  if pThread = 0 then
    return 0
  end if
  return pThread.getComponent().updateGameObject(tID, tdata)
end

on removeGameObject me, tID
  if pThread = 0 then
    return 0
  end if
  return pThread.getComponent().removeGameObject(tID)
end

on getAllGameObjectIds me
  if pThread = 0 then
    return 0
  end if
  return pThread.getComponent().getAllGameObjectIds()
end

on setGameObjectInGroup me, tGameObjectId, tGroupId
  if pThread = 0 then
    return 0
  end if
  return pThread.getComponent().setGameObjectInGroup(tGameObjectId, tGroupId)
end

on removeGameObjectFromAllGroups me, tGameObjectId
  if pThread = 0 then
    return 0
  end if
  return pThread.getComponent().removeGameObjectFromAllGroups(tGameObjectId)
end

on removeGameObjectFromGroup me, tGameObjectId, tGroupId
  if pThread = 0 then
    return 0
  end if
  return pThread.getComponent().removeGameObjectFromGroup(tGameObjectId, tGroupId)
end

on getGameObjectGroup me, tGroupId
  if pThread = 0 then
    return 0
  end if
  return pThread.getComponent().getGameObjectGroup(tGroupId)
end

on dumpGameObjectGroups me
  if pThread = 0 then
    return 0
  end if
  return pThread.getComponent().dumpGameObjectGroups()
end

on clearTurnBuffer me
  if pThread = 0 then
    return 0
  end if
  return pThread.getTurnManager()._ClearTurnBuffer()
end

on executeGameObjectEvent me, tID, tEvent, tdata
  if pThread = 0 then
    return 0
  end if
  return pThread.getComponent().executeGameObjectEvent(tID, tEvent, tdata)
end

on defineSingleProcessor me, tProcId
  if pThread = 0 then
    return 0
  end if
  return pThread.getProcManager().defineSingleProcessor(tProcId)
end

on removeSingleProcessor me, tProcId
  if pThread = 0 then
    return 0
  end if
  return pThread.getProcManager().removeSingleProcessor(tProcId)
end

on getProcessor me, tProcId
  if pThread = 0 then
    return 0
  end if
  return pThread.getProcManager().getProcessor(tProcId)
end

on get360AngleFromComponents me, tX, tY
  if pThread = 0 then
    return 0
  end if
  return pThread.getWorld().getGeometry().getAngleFromComponents(tX, tY)
end

on get8AngleFromComponents me, tX, tY
  if pThread = 0 then
    return 0
  end if
  tAngle360 = pThread.getWorld().getGeometry().getAngleFromComponents(tX, tY)
  return pThread.getWorld().getGeometry().direction360to8(tAngle360)
end

on GetVelocityTable me
  if pThread = 0 then
    return 0
  end if
  return pThread.getWorld().getGeometry().GetVelocityTable()
end

on getCollisionDetection me
  if pThread = 0 then
    return 0
  end if
  return pThread.getComponent().getCollision()
end

on testForLineOfSightInTileMatrix me, tX1, tY1, tX2, tY2, tBlockingLevel, tExcludeFirst, tExcludeLast
  if pThread = 0 then
    return 0
  end if
  return pThread.getWorld().testForLineOfSightInTileMatrix(tX1, tY1, tX2, tY2, tBlockingLevel, tExcludeFirst, tExcludeLast)
end

on convertTileToWorldCoordinate me, tX, tY, tZ
  if pThread = 0 then
    return 0
  end if
  return pThread.getWorld().convertTileToWorldCoordinate(tX, tY, tZ)
end

on convertTileToScreenCoordinate me, tX, tY, tZ
  if pThread = 0 then
    return 0
  end if
  return pThread.getWorld().convertTileToScreenCoordinate(tX, tY, tZ)
end

on getTile me, tX, tY
  if pThread = 0 then
    return 0
  end if
  return pThread.getWorld().getTile(tX, tY)
end

on gettileatworldcoordinate me, tX, tY, tZ
  if pThread = 0 then
    return 0
  end if
  return pThread.getWorld().gettileatworldcoordinate(tX, tY, tZ)
end

on getTileAtScreenCoordinate me, tX, tY
  if pThread = 0 then
    return 0
  end if
  return pThread.getWorld().getTileAtScreenCoordinate(tX, tY)
end

on convertworldtotilecoordinate me, tX, tY, tZ
  if pThread = 0 then
    return 0
  end if
  return pThread.getWorld().convertworldtotilecoordinate(tX, tY, tZ)
end

on convertWorldToScreenCoordinate me, tX, tY, tZ
  if pThread = 0 then
    return 0
  end if
  return pThread.getWorld().convertWorldToScreenCoordinate(tX, tY, tZ)
end

on convertScreenToTileCoordinate me, tX, tY
  if pThread = 0 then
    return 0
  end if
  return pThread.getWorld().convertScreenToTileCoordinate(tX, tY)
end

on sqrt me, tInteger
  if pThread = 0 then
    return 0
  end if
  return pThread.getComponent().pSquareRoot.fast_sqrt(tInteger)
end

on getGeometry me
  if pThread = 0 then
    return 0
  end if
  return pThread.getWorld().getGeometry()
end

on getWorld me
  if pThread = 0 then
    return 0
  end if
  return pThread.getWorld()
end

on startTurnManager me
  if pThread = 0 then
    return 0
  end if
  return pThread.getBaseLogic().startTurnManager()
end

on stopTurnManager me
  if pThread = 0 then
    return 0
  end if
  return pThread.getBaseLogic().stopTurnManager()
end

on getNewTurnContainer me
  if pThread = 0 then
    return 0
  end if
  return pThread.getTurnManager().getNewTurnContainer()
end

on dump me
  if pThread = 0 then
    return 0
  end if
  return pThread.getComponent().dump()
end

on getVarMgr me
  if pThread = 0 then
    return 0
  end if
  return pThread.getVariableManager()
end
