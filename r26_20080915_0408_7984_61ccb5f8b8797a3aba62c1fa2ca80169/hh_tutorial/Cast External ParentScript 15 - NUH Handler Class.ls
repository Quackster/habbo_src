on construct me
  me.registerServerMessages(1)
  return 1
end

on deconstruct me
  return 1
end

on handleHelpItems me, tMsg
  tConn = tMsg.getaProp(#connection)
  tIdCount = tConn.GetIntFrom()
  tdata = [:]
  repeat with tNo = 1 to tIdCount
    tKeyId = tConn.GetIntFrom()
    tKey = me.getComponent().getHelpItemName(tKeyId)
    if tKey <> 0 then
      tdata[tKey] = 1
    end if
  end repeat
  me.getComponent().setHelpStatusData(tdata)
end

on handleTutorsAvailable me, tMsg
  tConn = tMsg.getaProp(#connection)
  tAreAvailable = tConn.GetIntFrom()
  if not tAreAvailable then
    return 0
  end if
  me.getComponent().showInviteWindow()
  return 1
end

on handleInvitingCompleted me, tMsg
  tConn = tMsg.getaProp(#connection)
  tAcceptCount = tConn.GetIntFrom()
  me.getComponent().invitingCompleted(tAcceptCount)
end

on handleInvitationExists me, tMsg
  me.getComponent().invitationExists()
end

on handleInvitationSent me
  me.getComponent().invitingStarted()
end

on handleGuideFound me
  me.getComponent().guideFound()
end

on handleInviterLeftRoom me, tMsg
  tConn = tMsg.getaProp(#connection)
  tRoomID = tConn.GetIntFrom()
  me.getComponent().inviterLeftRoom(string(tRoomID))
end

on registerServerMessages me, tBool
  tMsgs = [:]
  tMsgs.setaProp(352, #handleHelpItems)
  tMsgs.setaProp(356, #handleTutorsAvailable)
  tMsgs.setaProp(357, #handleInvitingCompleted)
  tMsgs.setaProp(358, #handleInvitationExists)
  tMsgs.setaProp(421, #handleInvitationSent)
  tMsgs.setaProp(423, #handleGuideFound)
  tMsgs.setaProp(424, #handleInviterLeftRoom)
  tCmds = [:]
  tCmds.setaProp("MSG_REMOVE_ACCOUNT_HELP_TEXT", 313)
  tCmds.setaProp("MSG_GET_TUTORS_AVAILABLE", 355)
  tCmds.setaProp("MSG_INVITE_TUTORS", 356)
  tCmds.setaProp("MSG_CANCEL_TUTOR_INVITATIONS", 359)
  if tBool then
    registerListener(getVariable("connection.info.id", #Info), me.getID(), tMsgs)
    registerCommands(getVariable("connection.info.id", #Info), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.info.id", #Info), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.info.id", #Info), me.getID(), tCmds)
  end if
  return 1
end
