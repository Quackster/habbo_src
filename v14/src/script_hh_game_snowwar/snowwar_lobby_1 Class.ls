on construct me
  executeMessage(#gamesystem_getfacade, getVariable("snowwar.loungesystem.id"))
  return 1
end

on deconstruct me
  executeMessage(#gamesystem_removefacade, getVariable("snowwar.loungesystem.id"))
  return 1
end

on handle_users me, tMsg
  tConn = tMsg.connection
  return 1
end

on regMsgList me, tBool
  tMsgs = [:]
  tMsgs.setaProp(28, #handle_users)
  tCmds = [:]
  if tBool then
    registerListener(getVariable("connection.info.id", #info), me.getID(), tMsgs)
    registerCommands(getVariable("connection.info.id", #info), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.info.id", #info), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.info.id", #info), me.getID(), tCmds)
  end if
  return 1
end
