on construct me 
  me.registerServerMessages(1)
  return TRUE
end

on deconstruct me 
  return TRUE
end

on handleHelpItems me, tMsg 
  tConn = tMsg.getaProp(#connection)
  tIdCount = tConn.GetIntFrom()
  tdata = [:]
  tNo = 1
  repeat while tNo <= tIdCount
    tID = tConn.GetIntFrom()
    tKey = ""
    if (tID = 1) then
      tKey = "own_user"
    else
      if (tID = 2) then
        tKey = "messenger"
      else
        if (tID = 3) then
          tKey = "navigator"
        else
          if (tID = 4) then
            tKey = "chat"
          else
            if (tID = 5) then
              tKey = "hand"
            else
              if (tID = 6) then
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
    tNo = (1 + tNo)
  end repeat
  me.getComponent().setHelpStatusData(tdata)
end

on handleTutorsAvailable me, tMsg 
  tConn = tMsg.getaProp(#connection)
  tAreAvailable = tConn.GetIntFrom()
  if not tAreAvailable then
    return FALSE
  end if
  me.getComponent().showInviteWindow()
  return TRUE
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
    registerListener(getVariable("connection.info.id", #info), me.getID(), tMsgs)
    registerCommands(getVariable("connection.info.id", #info), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.info.id", #info), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.info.id", #info), me.getID(), tCmds)
  end if
  return TRUE
end
