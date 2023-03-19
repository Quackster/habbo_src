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

on createConnection tid, tHost, tPort
  return getConnectionManager().create(tid, tHost, tPort)
end

on removeConnection tid
  return getConnectionManager().Remove(tid)
end

on getConnection tid
  return getConnectionManager().get(tid)
end

on connectionExists tid
  return getConnectionManager().exists(tid)
end

on printConnections
  return getConnectionManager().print()
end

on registerListener tid, tObjID, tMsgList
  return getConnectionManager().registerListener(tid, tObjID, tMsgList)
end

on unregisterListener tid, tObjID, tMsgList
  return getConnectionManager().unregisterListener(tid, tObjID, tMsgList)
end

on registerCommands tid, tObjID, tCmdList
  return getConnectionManager().registerCommands(tid, tObjID, tCmdList)
end

on unregisterCommands tid, tObjID, tCmdList
  return getConnectionManager().unregisterCommands(tid, tObjID, tCmdList)
end
