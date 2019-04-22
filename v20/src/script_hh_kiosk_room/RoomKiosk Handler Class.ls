on construct(me)
  tMessages = []
  tMessages.setaProp(59, #handle_flatcreated)
  tMessages.setaProp(33, #handle_error)
  tMessages.setaProp(353, #handle_webShortcut)
  registerListener(getVariable("connection.info.id"), me.getID(), tMessages)
  registerCommands(getVariable("connection.info.id"), me.getID(), ["CREATEFLAT":29])
  return(1)
  exit
end

on deconstruct(me)
  tMessages = []
  tMessages.setaProp(59, #handle_flatcreated)
  tMessages.setaProp(33, #handle_error)
  tMessages.setaProp(353, #handle_webShortcut)
  unregisterListener(getVariable("connection.info.id"), me.getID(), tMessages)
  unregisterCommands(getVariable("connection.info.id"), me.getID(), ["CREATEFLAT":29])
  return(1)
  exit
end

on handle_flatcreated(me, tMsg)
  tID = content.getPropRef(#line, 1).getProp(#word, 1)
  tName = content.getProp(#line, 2)
  me.getInterface().flatcreated(tName, tID)
  exit
end

on handle_error(me, tMsg)
  tErr = tMsg.content
  if me = "Error creating a private room" then
    executeMessage(#alert, [#Msg:getText("roomatic_create_error")])
    return(me.getInterface().showHideRoomKiosk())
  end if
  return(1)
  exit
end

on handle_webShortcut(me, tMsg)
  tConn = tMsg.getaProp(#connection)
  if not tConn then
    return(error(me, "Connection not found.", #handle_webShortcut, #major))
  end if
  tRequestId = tConn.GetIntFrom()
  if tRequestId = 1 then
    executeMessage(#open_roomkiosk)
    return(1)
  end if
  return(0)
  exit
end