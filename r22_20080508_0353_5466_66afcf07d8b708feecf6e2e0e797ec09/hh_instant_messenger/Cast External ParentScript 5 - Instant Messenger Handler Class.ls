on construct me
  return me.regMsgList(1)
end

on deconstruct me
  return me.regMsgList(0)
end

on handle_im_message me, tMsg
  tConn = tMsg.connection
  tSenderId = string(tConn.GetIntFrom())
  tText = tConn.GetStrFrom()
  me.getComponent().receiveMessage(tSenderId, tText)
  return 1
end

on handle_im_error me, tMsg
  tConn = tMsg.connection
  if tConn = 0 then
    return 0
  end if
  tErrorCode = tConn.GetIntFrom()
  tChatID = tConn.GetIntFrom()
  me.getComponent().receiveError(tChatID, tErrorCode)
  return 1
end

on regMsgList me, tBool
  tMsgs = [:]
  tMsgs.setaProp(134, #handle_im_message)
  tMsgs.setaProp(261, #handle_im_error)
  tCmds = [:]
  tCmds.setaProp("MESSENGER_SENDMSG", 33)
  if tBool then
    registerListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    registerCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  end if
  return 1
end
