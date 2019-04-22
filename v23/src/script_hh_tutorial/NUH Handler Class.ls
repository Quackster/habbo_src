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
    tID = tConn.GetIntFrom()
    tKey = ""
    if me = 1 then
      tKey = "own_user"
    else
      if me = 2 then
        tKey = "messenger"
      else
        if me = 3 then
          tKey = "navigator"
        else
          if me = 4 then
            tKey = "chat"
          else
            if me = 5 then
              tKey = "hand"
            else
              if me = 6 then
                tKey = "invite"
              end if
            end if
          end if
        end if
      end if
    end if
    if tKey <> "" then
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

on handleInvitationExpired(me, tMsg)
  me.getComponent().invitationExpired()
  exit
end

on handleInvitationExists(me, tMsg)
  me.getComponent().invitationExists()
  exit
end

on registerServerMessages(me, tBool)
  tMsgs = []
  tMsgs.setaProp(352, #handleHelpItems)
  tMsgs.setaProp(356, #handleTutorsAvailable)
  tMsgs.setaProp(357, #handleInvitationExpired)
  tMsgs.setaProp(358, #handleInvitationExists)
  tCmds = []
  tCmds.setaProp("MSG_REMOVE_ACCOUNT_HELP_TEXT", 313)
  tCmds.setaProp("MSG_GET_TUTORS_AVAILABLE", 355)
  tCmds.setaProp("MSG_INVITE_TUTORS", 356)
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