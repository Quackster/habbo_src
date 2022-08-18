on constructConnectionManager
  return createManager(#connection_manager, getClassVariable("connection.manager.class"))
end

on deconstructConnectionManager
  return removeManager(#connection_manager)
end

on getConnectionManager
  tMgr = getObjectManager()
  if not tMgr.managerExists(#connection_manager) then
    return constructConnectionManager()
  end if
  return tMgr.getManager(#connection_manager)
end

on createConnection tID, tHost, tPort
  return getConnectionManager().create(tID, tHost, tPort)
end

on removeConnection tID
  return getConnectionManager().Remove(tID)
end

on getConnection tID
  return getConnectionManager().GET(tID)
end

on connectionExists tID
  return getConnectionManager().exists(tID)
end

on printConnections
  return getConnectionManager().print()
end

on registerListener tID, tObjID, tMsgList
  return getConnectionManager().registerListener(tID, tObjID, tMsgList)
end

on unregisterListener tID, tObjID, tMsgList
  return getConnectionManager().unregisterListener(tID, tObjID, tMsgList)
end

on registerCommands tID, tObjID, tCmdList
  return getConnectionManager().registerCommands(tID, tObjID, tCmdList)
end

on unregisterCommands tID, tObjID, tCmdList
  return getConnectionManager().unregisterCommands(tID, tObjID, tCmdList)
end
