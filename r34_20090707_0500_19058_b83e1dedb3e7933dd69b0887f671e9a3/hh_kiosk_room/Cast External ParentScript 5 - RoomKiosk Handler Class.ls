on construct me
  tMessages = [:]
  tMessages.setaProp(59, #handle_flatcreated)
  tMessages.setaProp(33, #handle_error)
  tMessages.setaProp(353, #handle_webShortcut)
  registerListener(getVariable("connection.info.id"), me.getID(), tMessages)
  registerCommands(getVariable("connection.info.id"), me.getID(), ["CREATEFLAT": 29])
  return 1
end

on deconstruct me
  tMessages = [:]
  tMessages.setaProp(59, #handle_flatcreated)
  tMessages.setaProp(33, #handle_error)
  tMessages.setaProp(353, #handle_webShortcut)
  unregisterListener(getVariable("connection.info.id"), me.getID(), tMessages)
  unregisterCommands(getVariable("connection.info.id"), me.getID(), ["CREATEFLAT": 29])
  return 1
end

on handle_flatcreated me, tMsg
  tID = tMsg.connection.GetIntFrom()
  tName = tMsg.connection.GetStrFrom()
  me.getInterface().flatcreated(tName, tID)
end

on handle_error me, tMsg
end

on handle_webShortcut me, tMsg
  tConn = tMsg.getaProp(#connection)
  if not tConn then
    return error(me, "Connection not found.", #handle_webShortcut, #major)
  end if
  tRequestId = tConn.GetIntFrom()
  if tRequestId = 1 then
    executeMessage(#open_roomkiosk)
    return 1
  end if
  return 0
end
