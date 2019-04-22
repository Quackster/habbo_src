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

on createConnection(tID, tHost, tPort)
  return(getConnectionManager().create(tID, tHost, tPort))
  exit
end

on removeConnection(tID)
  return(getConnectionManager().Remove(tID))
  exit
end

on getConnection(tID)
  return(getConnectionManager().GET(tID))
  exit
end

on connectionExists(tID)
  return(getConnectionManager().exists(tID))
  exit
end

on printConnections()
  return(getConnectionManager().print())
  exit
end

on registerListener(tID, tObjID, tMsgList)
  return(getConnectionManager().registerListener(tID, tObjID, tMsgList))
  exit
end

on unregisterListener(tID, tObjID, tMsgList)
  return(getConnectionManager().unregisterListener(tID, tObjID, tMsgList))
  exit
end

on registerCommands(tID, tObjID, tCmdList)
  return(getConnectionManager().registerCommands(tID, tObjID, tCmdList))
  exit
end

on unregisterCommands(tID, tObjID, tCmdList)
  return(getConnectionManager().unregisterCommands(tID, tObjID, tCmdList))
  exit
end

on handlers()
  return([])
  exit
end