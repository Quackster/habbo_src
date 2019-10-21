on construct(me)
  me.registerServerMessages(1)
  return(1)
  exit
end

on deconstruct(me)
  return(1)
  exit
end

on handleHelpItems(me, tMsg)
  tConn = tMsg.getaProp(#connection)
  tIdCount = tConn.GetIntFrom()
  tdata = []
  tNo = 1
  repeat while tNo <= tIdCount
    tKeyId = tConn.GetIntFrom()
    tKey = me.getComponent().getHelpItemName(tKeyId)
    if tKey <> 0 then
      tdata.setAt(tKey, 1)
    end if
    tNo = 1 + tNo
  end repeat
  me.getComponent().setHelpStatusData(tdata)
  exit
end

on handleTutorsAvailable(me, tMsg)
  tConn = tMsg.getaProp(#connection)
  tAreAvailable = tConn.GetIntFrom()
  if not tAreAvailable then
    return(0)
  end if
  me.getComponent().showInviteWindow()
  return(1)
  exit
end

on handleInvitingCompleted(me, tMsg)
  tConn = tMsg.getaProp(#connection)
  tAcceptCount = tConn.GetIntFrom()
  me.getComponent().invitingCompleted(tAcceptCount)
  exit
end

on handleInvitationExists(me, tMsg)
  me.getComponent().invitationExists()
  exit
end

on handleInvitationSent(me)
  me.getComponent().invitingStarted()
  exit
end

on handleGuideFound(me)
  me.getComponent().guideFound()
  exit
end

on handleInviterLeftRoom(me, tMsg)
  tConn = tMsg.getaProp(#connection)
  tRoomID = tConn.GetIntFrom()
  me.getComponent().inviterLeftRoom(string(tRoomID))
  exit
end

on registerServerMessages(me, tBool)
  tMsgs = []
  tMsgs.setaProp(352, #handleHelpItems)
  tMsgs.setaProp(356, #handleTutorsAvailable)
  tMsgs.setaProp(357, #handleInvitingCompleted)
  tMsgs.setaProp(358, #handleInvitationExists)
  tMsgs.setaProp(421, #handleInvitationSent)
  tMsgs.setaProp(423, #handleGuideFound)
  tMsgs.setaProp(424, #handleInviterLeftRoom)
  tCmds = []
  tCmds.setaProp("MSG_REMOVE_ACCOUNT_HELP_TEXT", 313)
  tCmds.setaProp("MSG_GET_TUTORS_AVAILABLE", 355)
  tCmds.setaProp("MSG_INVITE_TUTORS", 356)
  tCmds.setaProp("MSG_CANCEL_TUTOR_INVITATIONS", 359)
  if tBool then
    registerListener(getVariable("connection.info.id", #info), me.getID(), tMsgs)
    registerCommands(getVariable("connection.info.id", #info), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.info.id", #info), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.info.id", #info), me.getID(), tCmds)
  end if
  return(1)
  exit
end