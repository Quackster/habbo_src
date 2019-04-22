on construct(me)
  return(me.regMsgList(1))
  exit
end

on deconstruct(me)
  return(me.regMsgList(0))
  exit
end

on handleInvitation(me, tMsg)
  tConn = tMsg.connection
  if tConn = 0 then
    return(0)
  end if
  tInvitationData = []
  tInvitationData.setaProp(#userID, tConn.GetStrFrom())
  tInvitationData.setaProp(#name, tConn.GetStrFrom())
  me.getComponent().setInvitation(tInvitationData)
  return(1)
  exit
end

on handleInvitationFollowFailed(me, tMsg)
  executeMessage(#alert, "invitation_follow_failed")
  exit
end

on handleInvitationCancelled(me, tMsg)
  me.getComponent().cancelInvitation()
  exit
end

on handleInitTutorServiceStatus(me, tMsg)
  tConn = tMsg.getaProp(#connection)
  tstate = tConn.GetIntFrom()
  if me = 1 then
    me.getComponent().setState(#enabled)
  else
    if me = 2 then
      me.getComponent().setState(#disabled)
    else
      if me = 3 then
        me.getComponent().setState(#disabled)
      end if
    end if
  end if
  exit
end

on handleEnableTutorServiceStatus(me, tMsg)
  tConn = tMsg.getaProp(#connection)
  tstate = tConn.GetIntFrom()
  if me = 2 then
    executeMessage(#alert, "guide_tool_friendlist_full")
    me.getComponent().setState(#enabled)
  else
    if me = 3 then
      executeMessage(#alert, "guide_tool_service_disabled")
      me.getComponent().setState(#disabled)
    else
      if me = 4 then
        executeMessage(#alert, "guide_tool_max_newbies")
        me.getComponent().setState(#disabled)
      end if
    end if
  end if
  tGuidePoints = tConn.GetIntFrom()
  exit
end

on regMsgList(me, tBool)
  tMsgs = []
  tMsgs.setaProp(355, #handleInvitation)
  tMsgs.setaProp(359, #handleInvitationFollowFailed)
  tMsgs.setaProp(360, #handleInvitationCancelled)
  tMsgs.setaProp(425, #handleInitTutorServiceStatus)
  tMsgs.setaProp(426, #handleEnableTutorServiceStatus)
  tCmds = []
  tCmds.setaProp("MSG_ACCEPT_TUTOR_INVITATION", 357)
  tCmds.setaProp("MSG_REJECT_TUTOR_INVITATION", 358)
  tCmds.setaProp("MSG_INIT_TUTORSERVICE", 360)
  tCmds.setaProp("MSG_WAIT_FOR_TUTOR_INVITATIONS", 362)
  tCmds.setaProp("MSG_CANCEL_WAIT_FOR_TUTOR_INVITATIONS", 363)
  if tBool then
    registerListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    registerCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  end if
  return(1)
  exit
end