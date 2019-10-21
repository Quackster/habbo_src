property pHelpStatusData, pOpenHelps, pPostponedHelps

on construct me 
  pHelpStatusData = [:]
  pPostponedHelps = []
  pOpenHelps = []
  registerMessage(#roomReady, me.getID(), #initHelpOnRoomEntry)
  registerMessage(#leaveRoom, me.getID(), #removeHelp)
  registerMessage(#changeRoom, me.getID(), #removeHelp)
  registerMessage(#enterRoom, me.getID(), #removeHelp)
  registerMessage(#roomInterfaceHidden, me.getID(), #removeHelp)
  return TRUE
end

on deconstruct me 
  unregisterMessage(#roomReady, me.getID())
  unregisterMessage(#leaveReady, me.getID())
  unregisterMessage(#changeReady, me.getID())
  unregisterMessage(#enterReady, me.getID())
  unregisterMessage(#roomInterfaceHidden, me.getID())
  return TRUE
end

on setHelpItemClosed me, tHelpItemId 
  if pHelpStatusData.getaProp(tHelpItemId) <> 1 then
    return FALSE
  end if
  pHelpStatusData.setAt(tHelpItemId, 0)
  tConn = getConnection(getVariableValue("connection.info.id"))
  tKey = ""
  if (tHelpItemId = "own_user") then
    tKey = 1
  else
    if (tHelpItemId = "messenger") then
      tKey = 2
    else
      if (tHelpItemId = "navigator") then
        tKey = 3
      else
        if (tHelpItemId = "chat") then
          tKey = 4
        else
          if (tHelpItemId = "hand") then
            tKey = 5
          else
            if (tHelpItemId = "invite") then
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
end

on setHelpStatusData me, tdata 
  pHelpStatusData = tdata
end

on isChatHelpOn me 
  if not voidp(pHelpStatusData.getAt("chat")) then
    return(pHelpStatusData.getAt("chat"))
  end if
  return FALSE
end

on initHelpOnRoomEntry me 
  me.showNewUserHelpItems()
end

on removeHelp me 
  tItemNo = 1
  repeat while tItemNo <= pHelpStatusData.count
    tItem = pHelpStatusData.getPropAt(tItemNo)
    tItemOn = pHelpStatusData.getAt(tItemNo)
    tTimeoutID = "NUH_help_" & tItem
    if timeoutExists(tTimeoutID) then
      removeTimeout(tTimeoutID)
    end if
    tItemNo = (1 + tItemNo)
  end repeat
  me.getInterface().removeAll()
  pPostponedHelps = []
  pOpenHelps = []
end

on showNewUserHelpItems me 
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
    tItemNo = (1 + tItemNo)
  end repeat
end

on tryToShowHelp me, tHelpId 
  if pOpenHelps.count > 1 then
    tPos = pPostponedHelps.findPos(tHelpId)
    if tPos > 0 then
      return TRUE
    end if
    pPostponedHelps.add(tHelpId)
    return TRUE
  end if
  if (tHelpId = "messenger") then
    if not threadExists("messenger") then
      return FALSE
    end if
    tMessengerComponent = getThread("messenger").getComponent()
    tMsgCount = tMessengerComponent.getNumOfMessages()
    tRequestCount = tMessengerComponent.getPendingRequestCount()
    if tMsgCount > 0 or tRequestCount > 0 then
      me.getInterface().showGenericHelp(tHelpId)
      pOpenHelps.add(tHelpId)
    end if
  else
    if (tHelpId = "navigator") then
      me.getInterface().showGenericHelp(tHelpId)
      pOpenHelps.add(tHelpId)
    else
      if (tHelpId = "own_user") then
        me.getInterface().showOwnUserHelp(tHelpId)
        pOpenHelps.add(tHelpId)
      else
        if (tHelpId = "hand") then
          towner = getObject(#session).GET(#room_owner)
          if towner then
            me.getInterface().showGenericHelp(tHelpId)
            pOpenHelps.add(tHelpId)
          end if
        else
          if (tHelpId = "invite") then
            me.checkHelpers()
          end if
        end if
      end if
    end if
  end if
end

on checkHelpers me 
  tConn = getConnection(getVariable("connection.info.id"))
  if voidp(tConn) then
    return(error(me, "Connection not found.", #checkHelpers, #major))
  end if
  tConn.send("MSG_GET_TUTORS_AVAILABLE")
end

on showInviteWindow me 
  me.pOpenHelps.add("invite")
  me.getInterface().showInviteWindow()
end

on sendInvitations me 
  tConn = getConnection(getVariable("connection.info.id"))
  if voidp(tConn) then
    return(error(me, "Connection not found.", #sendInvitations, #major))
  end if
  tConn.send("MSG_INVITE_TUTORS")
end

on invitationExpired me 
  executeMessage(#alert, "invitation_expired")
end

on invitationExists me 
  executeMessage(#alert, "invitation_exists")
end
