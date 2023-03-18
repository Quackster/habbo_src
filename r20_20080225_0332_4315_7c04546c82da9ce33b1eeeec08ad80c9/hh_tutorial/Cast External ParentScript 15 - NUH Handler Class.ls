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
    tID = tConn.GetIntFrom()
    tKey = EMPTY
    case tID of
      1:
        tKey = "own_user"
      2:
        tKey = "messenger"
      3:
        tKey = "navigator"
      4:
        tKey = "chat"
      5:
        tKey = "hand"
      6:
        tKey = "invite"
    end case
    if tKey <> EMPTY then
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

on handleInvitationExpired me, tMsg
  me.getComponent().invitationExpired()
end

on handleInvitationExists me, tMsg
  me.getComponent().invitationExists()
end

on registerServerMessages me, tBool
  tMsgs = [:]
  tMsgs.setaProp(352, #handleHelpItems)
  tMsgs.setaProp(356, #handleTutorsAvailable)
  tMsgs.setaProp(357, #handleInvitationExpired)
  tMsgs.setaProp(358, #handleInvitationExists)
  tCmds = [:]
  tCmds.setaProp("MSG_REMOVE_ACCOUNT_HELP_TEXT", 313)
  tCmds.setaProp("MSG_GET_TUTORS_AVAILABLE", 355)
  tCmds.setaProp("MSG_INVITE_TUTORS", 356)
  if tBool then
    registerListener(getVariable("connection.info.id", #Info), me.getID(), tMsgs)
    registerCommands(getVariable("connection.info.id", #Info), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.info.id", #Info), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.info.id", #Info), me.getID(), tCmds)
  end if
  return 1
end
