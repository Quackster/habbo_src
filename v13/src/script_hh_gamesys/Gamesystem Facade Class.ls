on construct(me)
  return(1)
  exit
end

on deconstruct(me)
  if objectp(pThread) then
    if objectp(pThread.getBaseLogic()) then
      pThread.getBaseLogic().initVariables()
    end if
    if objectp(pThread.getProcManager()) then
      pThread.getProcManager().removeProcessors()
    end if
  end if
  pThread = void()
  return(1)
  exit
end

on defineClient(me, tSystemObj)
  pThread = tSystemObj
  if pThread = 0 then
    return(error(me, "Client game framework not found:" && me.getID(), #defineClient))
  end if
  if getmemnum(me.getID() & ".variable.index") then
    dumpVariableField(me.getID() & ".variable.index")
  end if
  pThread.getBaseLogic().defineClient(me.getID())
  pThread.getMessageHandler().defineClient(me.getID())
  pThread.getComponent().defineClient(me.getID())
  pThread.getProcManager().defineClient(me.getID())
  pThread.getProcManager().distributeEvent(#facadeok, me.getID())
  return(1)
  exit
end

on getNumTickets(me)
  if getObject(#session) = 0 then
    return(0)
  end if
  return(getObject(#session).get("user_ph_tickets"))
  exit
end

on getSpectatorModeFlag(me)
  if me.getVarMgr() = 0 then
    return(0)
  end if
  return(me.getVarMgr().get(#spectatormode_flag))
  exit
end

on getTournamentFlag(me)
  if me.getVarMgr() = 0 then
    return(0)
  end if
  if not me.getVarMgr().exists(#tournament_flag) then
    return(0)
  end if
  return(me.getVarMgr().get(#tournament_flag))
  exit
end

on getWorldReady(me)
  if pThread = 0 then
    return(0)
  end if
  return(pThread.getWorld().getWorldReady())
  exit
end

on getGamestatus(me)
  if pThread = 0 then
    return(0)
  end if
  return(pThread.getBaseLogic().getGamestatus())
  exit
end

on setGameStatus(me, tStatus)
  tVarMgr = me.getVarMgr()
  if tVarMgr = 0 then
    return(0)
  end if
  return(tVarMgr.set(#game_status, tStatus))
  exit
end

on getInstanceList(me)
  if me.getVarMgr() = 0 then
    return(0)
  end if
  return(me.getVarMgr().get(#instancelist))
  exit
end

on getObservedInstance(me)
  if me.getVarMgr() = 0 then
    return(0)
  end if
  return(me.getVarMgr().get(#observed_instance_data))
  exit
end

on getGameParameters(me)
  if me.getVarMgr() = 0 then
    return(0)
  end if
  if not me.getVarMgr().exists(#gameparametervalues_format) then
    return(0)
  end if
  return(me.getVarMgr().get(#gameparametervalues_format))
  exit
end

on getJoinParameters(me)
  if me.getVarMgr() = 0 then
    return(0)
  end if
  if not me.getVarMgr().exists(#joinparametervalues_format) then
    return(0)
  end if
  return(me.getVarMgr().get(#joinparametervalues_format))
  exit
end

on setInstanceListUpdates(me, tBoolean)
  if pThread = 0 then
    return(0)
  end if
  return(pThread.getMessageSender().setInstanceListUpdates(tBoolean))
  exit
end

on sendGetInstanceList(me)
  if pThread = 0 then
    return(0)
  end if
  return(pThread.getMessageSender().sendGetInstanceList())
  exit
end

on observeInstance(me, tid)
  if pThread = 0 then
    return(0)
  end if
  return(pThread.getMessageSender().sendObserveInstance(tid))
  exit
end

on unobserveInstance(me)
  if pThread = 0 then
    return(0)
  end if
  return(pThread.getMessageSender().sendUnobserveInstance())
  exit
end

on initiateCreateGame(me, tTeamId)
  if pThread = 0 then
    return(0)
  end if
  return(pThread.getMessageSender().sendInitiateCreateGame(tTeamId))
  exit
end

on cancelCreateGame(me)
  if pThread = 0 then
    return(0)
  end if
  return(pThread.getBaseLogic().cancelCreateGame())
  exit
end

on createGame(me, tParamList, tTeamId)
  if pThread = 0 then
    return(0)
  end if
  return(pThread.getMessageSender().sendGameParameterValues(tParamList, tTeamId))
  exit
end

on deleteGame(me)
  if pThread = 0 then
    return(0)
  end if
  return(pThread.getMessageSender().sendDeleteGame())
  exit
end

on initiateJoinGame(me, tInstanceId, tTeamId)
  if pThread = 0 then
    return(0)
  end if
  pThread.getBaseLogic().store_joinparameters(me, [])
  return(pThread.getMessageSender().sendInitiateJoinGame(tInstanceId, tTeamId))
  exit
end

on joinGame(me, tInstanceId, tTeamId, tParamList)
  if pThread = 0 then
    return(0)
  end if
  return(pThread.getMessageSender().sendJoinParameterValues(tInstanceId, tTeamId, tParamList))
  exit
end

on leaveGame(me)
  if pThread = 0 then
    return(0)
  end if
  return(pThread.getMessageSender().sendLeaveGame())
  exit
end

on kickPlayer(me, tPlayerId)
  if pThread = 0 then
    return(0)
  end if
  return(pThread.getMessageSender().sendKickPlayer(tPlayerId))
  exit
end

on watchGame(me, tInstanceId)
  if pThread = 0 then
    return(0)
  end if
  if tInstanceId = void() then
    tInstance = me.getObservedInstance()
    if tInstance = 0 then
      return(0)
    end if
    tInstanceId = tInstance.getAt(#id)
  end if
  return(pThread.getMessageSender().sendWatchGame(tInstanceId))
  exit
end

on startGame()
  if pThread = 0 then
    return(0)
  end if
  return(pThread.getMessageSender().sendStartGame())
  exit
end

on rejoinGame(me)
  if pThread = 0 then
    return(0)
  end if
  return(pThread.getMessageSender().sendRejoinGame())
  exit
end

on enterLounge(me)
  if pThread = 0 then
    return(0)
  end if
  return(pThread.getBaseLogic().enterLounge())
  exit
end

on sendGameEventMessage(me, tdata)
  if pThread = 0 then
    return(0)
  end if
  return(pThread.getMessageSender().sendGameEventMessage(tdata))
  exit
end

on sendGameSystemEvent(me, tTopic, tdata)
  if pThread = 0 then
    return(0)
  end if
  return(pThread.getProcManager().distributeEvent(tTopic, tdata))
  exit
end

on sendHabboRoomMove(me, tLocX, tLocY)
  if pThread = 0 then
    return(0)
  end if
  return(pThread.getMessageSender().sendHabboRoomMove(tLocX, tLocY))
  exit
end

on createGameObject(me, tid, ttype, tDataToStore)
  if pThread = 0 then
    return(0)
  end if
  return(pThread.getComponent().createGameObject(tid, ttype, tDataToStore))
  exit
end

on getGameObject(me, tid)
  if pThread = 0 then
    return(0)
  end if
  return(pThread.getComponent().getGameObject(tid))
  exit
end

on getGameObjectProperty(me, tid, tProp)
  if pThread = 0 then
    return(0)
  end if
  tObject = pThread.getComponent().getGameObject(tid)
  if tObject = 0 then
    return(error(me, "Game object doesn't exist:" && tid, #getGameObjectProperty))
  end if
  return(tObject.getGameObjectProperty(tProp))
  exit
end

on getGameObjectIdsOfType(me, ttype)
  if pThread = 0 then
    return(0)
  end if
  return(pThread.getComponent().getGameObjectIdsOfType(ttype))
  exit
end

on updateGameObject(me, tid, tdata)
  if pThread = 0 then
    return(0)
  end if
  return(pThread.getComponent().updateGameObject(tid, tdata))
  exit
end

on removeGameObject(me, tid)
  if pThread = 0 then
    return(0)
  end if
  return(pThread.getComponent().removeGameObject(tid))
  exit
end

on clearTurnBuffer(me)
  if pThread = 0 then
    return(0)
  end if
  return(pThread.getTurnManager()._ClearTurnBuffer())
  exit
end

on executeGameObjectEvent(me, tid, tEvent, tdata)
  if pThread = 0 then
    return(0)
  end if
  return(pThread.getComponent().executeGameObjectEvent(tid, tEvent, tdata))
  exit
end

on get360AngleFromComponents(me, tX, tY)
  if pThread = 0 then
    return(0)
  end if
  return(pThread.getWorld().getGeometry().getAngleFromComponents(tX, tY))
  exit
end

on get8AngleFromComponents(me, tX, tY)
  if pThread = 0 then
    return(0)
  end if
  tAngle360 = pThread.getWorld().getGeometry().getAngleFromComponents(tX, tY)
  return(pThread.getWorld().getGeometry().direction360to8(tAngle360))
  exit
end

on GetVelocityTable(me)
  if pThread = 0 then
    return(0)
  end if
  return(pThread.getWorld().getGeometry().GetVelocityTable())
  exit
end

on convertTileToWorldCoordinate(me, tX, tY, tZ)
  if pThread = 0 then
    return(0)
  end if
  return(pThread.getWorld().convertTileToWorldCoordinate(tX, tY, tZ))
  exit
end

on gettileatworldcoordinate(me, tX, tY, tZ)
  if pThread = 0 then
    return(0)
  end if
  return(pThread.getWorld().gettileatworldcoordinate(tX, tY, tZ))
  exit
end

on convertworldtotilecoordinate(me, tX, tY, tZ)
  if pThread = 0 then
    return(0)
  end if
  return(pThread.getWorld().convertworldtotilecoordinate(tX, tY, tZ))
  exit
end

on convertWorldToScreenCoordinate(me, tX, tY, tZ)
  if pThread = 0 then
    return(0)
  end if
  return(pThread.getWorld().convertWorldToScreenCoordinate(tX, tY, tZ))
  exit
end

on sqrt(me, tInteger)
  if pThread = 0 then
    return(0)
  end if
  return(pSquareRoot.fast_sqrt(tInteger))
  exit
end

on getGeometry(me)
  if pThread = 0 then
    return(0)
  end if
  return(pThread.getWorld().getGeometry())
  exit
end

on getWorld(me)
  if pThread = 0 then
    return(0)
  end if
  return(pThread.getWorld())
  exit
end

on startTurnManager(me)
  if pThread = 0 then
    return(0)
  end if
  return(pThread.getBaseLogic().startTurnManager())
  exit
end

on stopTurnManager(me)
  if pThread = 0 then
    return(0)
  end if
  return(pThread.getBaseLogic().stopTurnManager())
  exit
end

on getNewTurnContainer(me)
  if pThread = 0 then
    return(0)
  end if
  return(pThread.getTurnManager().getNewTurnContainer())
  exit
end

on dump(me)
  if pThread = 0 then
    return(0)
  end if
  return(pThread.getComponent().dump())
  exit
end

on getVarMgr(me)
  if pThread = 0 then
    return(0)
  end if
  return(pThread.getVariableManager())
  exit
end