property pMsgIds

on construct me
  return me.regMsgList(1)
end

on deconstruct me
  return me.regMsgList(0)
end

on defineClient me, tID
  return 1
end

on handle_message me, tMsg
  tIdStr = pMsgIds.getaProp(tMsg.getaProp(#subject))
  if tIdStr = VOID then
    return 0
  end if
  call(#distributeEvent, me.getProcManager(), symbol("msgstruct_" & tIdStr), tMsg)
  return 1
end

on regMsgList me, tBool
  pMsgIds = [:]
  pMsgIds.setaProp(28, #users)
  pMsgIds.setaProp(30, #objects)
  pMsgIds.setaProp(31, #heightmap)
  pMsgIds.setaProp(72, #numtickets)
  pMsgIds.setaProp(73, #notickets)
  pMsgIds.setaProp(124, #numtickets)
  pMsgIds.setaProp(231, #loungeinfo)
  pMsgIds.setaProp(232, #instancelist)
  pMsgIds.setaProp(233, #gameinstance)
  pMsgIds.setaProp(234, #instancenotavailable)
  pMsgIds.setaProp(235, #gameparameters)
  pMsgIds.setaProp(236, #createfailed)
  pMsgIds.setaProp(237, #gamedeleted)
  pMsgIds.setaProp(238, #joinparameters)
  pMsgIds.setaProp(239, #joinfailed)
  pMsgIds.setaProp(240, #watchfailed)
  pMsgIds.setaProp(241, #gamelocation)
  pMsgIds.setaProp(242, #startfailed)
  pMsgIds.setaProp(243, #fullgamestatus)
  pMsgIds.setaProp(244, #gamestatus)
  pMsgIds.setaProp(245, #playerrejoined)
  pMsgIds.setaProp(247, #gamestart)
  pMsgIds.setaProp(248, #gameend)
  pMsgIds.setaProp(249, #gamereset)
  pMsgIds.setaProp(250, #gameplayerinfo)
  pMsgIds.setaProp(251, #idlewarning)
  pMsgIds.setaProp(252, #skilllevelchanged)
  pMsgIds.setaProp(253, #gameinit)
  pMsgIds.setaProp(255, #leveleditornotification)
  tMsgs = [:]
  repeat with i = 1 to pMsgIds.count
    tMsgs.setaProp(pMsgIds.getPropAt(i), #handle_message)
  end repeat
  tCmds = [:]
  tCmds.setaProp("MOVE", 75)
  tCmds.setaProp("GETINSTANCELIST", 159)
  tCmds.setaProp("OBSERVEINSTANCE", 160)
  tCmds.setaProp("UNOBSERVEINSTANCE", 161)
  tCmds.setaProp("INITIATECREATEGAME", 162)
  tCmds.setaProp("GAMEPARAMETERVALUES", 163)
  tCmds.setaProp("DELETEGAME", 164)
  tCmds.setaProp("INITIATEJOINGAME", 165)
  tCmds.setaProp("JOINPARAMETERVALUES", 166)
  tCmds.setaProp("LEAVEGAME", 167)
  tCmds.setaProp("KICKPLAYER", 168)
  tCmds.setaProp("WATCHGAME", 169)
  tCmds.setaProp("STARTGAME", 170)
  tCmds.setaProp("GAMEEVENT", 171)
  tCmds.setaProp("REJOINGAME", 172)
  tCmds.setaProp("REQUESTFULLSTATUSUPDATE", 297)
  tCmds.setaProp("LEVELEDITORCOMMAND", 174)
  tCmds.setaProp("MSG_PLAYER_INPUT", 296)
  tCmds.setaProp("GAME_CHAT", 298)
  if tBool then
    registerListener(getVariable("connection.info.id", #Info), me.getID(), tMsgs)
    registerCommands(getVariable("connection.info.id", #Info), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.info.id", #Info), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.info.id", #Info), me.getID(), tCmds)
  end if
  return 1
end
