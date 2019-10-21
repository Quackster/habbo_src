on construct(me)
  pHelpStatusData = []
  pPostponedHelps = []
  pOpenHelps = []
  registerMessage(#roomReady, me.getID(), #initHelpOnRoomEntry)
  registerMessage(#leaveRoom, me.getID(), #removeHelp)
  registerMessage(#changeRoom, me.getID(), #removeHelp)
  registerMessage(#enterRoom, me.getID(), #removeHelp)
  registerMessage(#roomInterfaceHidden, me.getID(), #removeHelp)
  return(1)
  exit
end

on deconstruct(me)
  unregisterMessage(#roomReady, me.getID())
  unregisterMessage(#leaveReady, me.getID())
  unregisterMessage(#changeReady, me.getID())
  unregisterMessage(#enterReady, me.getID())
  unregisterMessage(#roomInterfaceHidden, me.getID())
  return(1)
  exit
end

on setHelpItemClosed(me, tHelpItemId)
  pHelpStatusData.setAt(tHelpItemId, 0)
  tConn = getConnection(getVariableValue("connection.info.id"))
  tKey = ""
  if me = "own_user" then
    tKey = 1
  else
    if me = "messenger" then
      tKey = 2
    else
      if me = "navigator" then
        tKey = 3
      else
        if me = "chat" then
          tKey = 4
        else
          if me = "hand" then
            tKey = 5
          else
            if me = "invite" then
              tKey = 6
            end if
          end if
        end if
      end if
    end if
  end if
  if tKey <> "" then
    tConn.send("MSG_REMOVE_ACCOUNT_HELP_TEXT", [#integer:tKey])
  end if
  tPos = pOpenHelps.findPos(tHelpItemId)
  if tPos > 0 then
    pOpenHelps.deleteAt(tPos)
  end if
  if pPostponedHelps.count > 0 then
    tHelpId = pPostponedHelps.getAt(1)
    pPostponedHelps.deleteAt(1)
    tTimeoutID = "NUH_help_" & tHelpId & "_postponed"
    createTimeout(tTimeoutID, 3000, #tryToShowHelp, me.getID(), tHelpId, 1)
  end if
  exit
end

on setHelpStatusData(me, tdata)
  pHelpStatusData = tdata
  exit
end

on isChatHelpOn(me)
  if not voidp(pHelpStatusData.getAt("chat")) then
    return(pHelpStatusData.getAt("chat"))
  end if
  return(0)
  exit
end

on initHelpOnRoomEntry(me)
  me.showNewUserHelpItems()
  exit
end

on removeHelp(me)
  tItemNo = 1
  repeat while tItemNo <= pHelpStatusData.count
    tItem = pHelpStatusData.getPropAt(tItemNo)
    tItemOn = pHelpStatusData.getAt(tItemNo)
    tTimeoutID = "NUH_help_" & tItem
    if timeoutExists(tTimeoutID) then
      removeTimeout(tTimeoutID)
    end if
    tItemNo = 1 + tItemNo
  end repeat
  me.getInterface().removeAll()
  pPostponedHelps = []
  pOpenHelps = []
  exit
end

on showNewUserHelpItems(me)
  tItemNo = 1
  repeat while tItemNo <= pHelpStatusData.count
    tItem = pHelpStatusData.getPropAt(tItemNo)
    tItemOn = pHelpStatusData.getAt(tItemNo)
    if tItemOn then
      tTimeoutVarId = "NUH." & tItem & ".timeout"
      tDefaultTimeoutVarId = "NUH." & tItem & ".default.timeout"
      if variableExists(tTimeoutVarId) then
        tTimeout = getVariable(tTimeoutVarId)
      else
        tTimeout = getVariable(tDefaultTimeoutVarId)
      end if
      if not integerp(value(tTimeout)) then
        tTimeout = 0
      end if
      tTimeoutID = "NUH_help_" & tItem
      createTimeout(tTimeoutID, tTimeout, #tryToShowHelp, me.getID(), tItem, 1)
    end if
    tItemNo = 1 + tItemNo
  end repeat
  exit
end

on tryToShowHelp(me, tHelpId)
  if pOpenHelps.count > 1 then
    tPos = pPostponedHelps.findPos(tHelpId)
    if tPos > 0 then
      return(1)
    end if
    pPostponedHelps.add(tHelpId)
    return(1)
  end if
  if me = "messenger" then
    if not threadExists("messenger") then
      return(0)
    end if
    tMessengerComponent = getThread("messenger").getComponent()
    tMsgCount = tMessengerComponent.getNumOfMessages()
    tRequestCount = tMessengerComponent.getPendingRequestCount()
    if tMsgCount > 0 or tRequestCount > 0 then
      me.getInterface().showGenericHelp(tHelpId)
      pOpenHelps.add(tHelpId)
    end if
  else
    if me = "navigator" then
      me.getInterface().showGenericHelp(tHelpId)
      pOpenHelps.add(tHelpId)
    else
      if me = "own_user" then
        me.getInterface().showOwnUserHelp(tHelpId)
        pOpenHelps.add(tHelpId)
      else
        if me = "hand" then
          towner = getObject(#session).GET(#room_owner)
          if towner then
            me.getInterface().showGenericHelp(tHelpId)
            pOpenHelps.add(tHelpId)
          end if
        else
          if me = "invite" then
            me.checkHelpers()
          end if
        end if
      end if
    end if
  end if
  exit
end

on checkHelpers(me)
  tConn = getConnection(getVariable("connection.info.id"))
  if voidp(tConn) then
    return(error(me, "Connection not found.", #checkHelpers, #major))
  end if
  tConn.send("MSG_GET_TUTORS_AVAILABLE")
  exit
end

on showInviteWindow(me)
  pOpenHelps.add("invite")
  me.getInterface().showInviteWindow()
  exit
end

on sendInvitations(me)
  tConn = getConnection(getVariable("connection.info.id"))
  if voidp(tConn) then
    return(error(me, "Connection not found.", #sendInvitations, #major))
  end if
  tConn.send("MSG_INVITE_TUTORS")
  exit
end

on invitationExpired(me)
  executeMessage(#alert, "invitation_expired")
  exit
end

on invitationExists(me)
  executeMessage(#alert, "invitation_exists")
  exit
end