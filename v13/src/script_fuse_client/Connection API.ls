on constructConnectionManager()
  return(createManager(#connection_manager, getClassVariable("connection.manager.class")))
  exit
end

on deconstructConnectionManager()
  return(removeManager(#connection_manager))
  exit
end

on getConnectionManager()
  tMgr = getObjectManager()
  if not tMgr.managerExists(#connection_manager) then
    return(constructConnectionManager())
  end if
  return(tMgr.getManager(#connection_manager))
  exit
end

on createConnection(tid, tHost, tPort)
  return(getConnectionManager().create(tid, tHost, tPort))
  exit
end

on removeConnection(tid)
  return(getConnectionManager().Remove(tid))
  exit
end

on getConnection(tid)
  return(getConnectionManager().get(tid))
  exit
end

on connectionExists(tid)
  return(getConnectionManager().exists(tid))
  exit
end

on printConnections()
  return(getConnectionManager().print())
  exit
end

on registerListener(tid, tObjID, tMsgList)
  return(getConnectionManager().registerListener(tid, tObjID, tMsgList))
  exit
end

on unregisterListener(tid, tObjID, tMsgList)
  return(getConnectionManager().unregisterListener(tid, tObjID, tMsgList))
  exit
end

on registerCommands(tid, tObjID, tCmdList)
  return(getConnectionManager().registerCommands(tid, tObjID, tCmdList))
  exit
end

on unregisterCommands(tid, tObjID, tCmdList)
  return(getConnectionManager().unregisterCommands(tid, tObjID, tCmdList))
  exit
end