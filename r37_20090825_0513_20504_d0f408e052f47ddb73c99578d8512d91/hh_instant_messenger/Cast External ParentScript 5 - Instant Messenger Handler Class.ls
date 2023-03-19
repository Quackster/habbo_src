on construct me
  return me.regMsgList(1)
end

on deconstruct me
  return me.regMsgList(0)
end

on handleIMMessage me, tMsg
  tConn = tMsg.getaProp(#connection)
  if tConn = 0 then
    return 0
  end if
  tSenderId = string(tConn.GetIntFrom())
  tText = tConn.GetStrFrom()
  me.getComponent().receiveMessage(tSenderId, tText)
  return 1
end

on handleIMInvitation me, tMsg
  tConn = tMsg.getaProp(#connection)
  if tConn = 0 then
    return 0
  end if
  tSenderId = string(tConn.GetIntFrom())
  tText = tConn.GetStrFrom()
  me.getComponent().receiveInvitation(tSenderId, tText)
  return 1
end

on handleIMError me, tMsg
  tConn = tMsg.getaProp(#connection)
  if tConn = 0 then
    return 0
  end if
  tErrorCode = tConn.GetIntFrom()
  tChatID = tConn.GetIntFrom()
  me.getComponent().receiveError(tChatID, tErrorCode)
  return 1
end

on handleInvitationError me, tMsg
  tConn = tMsg.getaProp(#connection)
  if tConn = 0 then
    return 0
  end if
  tErrorCode = tConn.GetIntFrom()
  executeMessage(#alert, getText("friend_invitation_error"))
end

on regMsgList me, tBool
  tMsgs = [:]
  tMsgs.setaProp(134, #handleIMMessage)
  tMsgs.setaProp(135, #handleIMInvitation)
  tMsgs.setaProp(261, #handleIMError)
  tMsgs.setaProp(262, #handleInvitationError)
  tCmds = [:]
  tCmds.setaProp("MESSENGER_SENDMSG", 33)
  tCmds.setaProp("FRIEND_INVITE", 34)
  if tBool then
    registerListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    registerCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  end if
  return 1
end
