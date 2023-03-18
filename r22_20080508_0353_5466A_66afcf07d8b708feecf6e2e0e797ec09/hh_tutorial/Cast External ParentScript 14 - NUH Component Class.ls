property pHelpStatusData, pPostponedHelps, pOpenHelps

on construct me
  pHelpStatusData = [:]
  pPostponedHelps = []
  pOpenHelps = []
  registerMessage(#roomReady, me.getID(), #initHelpOnRoomEntry)
  registerMessage(#leaveRoom, me.getID(), #removeHelp)
  registerMessage(#changeRoom, me.getID(), #removeHelp)
  registerMessage(#enterRoom, me.getID(), #removeHelp)
  registerMessage(#roomInterfaceHidden, me.getID(), #removeHelp)
  return 1
end

on deconstruct me
  unregisterMessage(#roomReady, me.getID())
  unregisterMessage(#leaveReady, me.getID())
  unregisterMessage(#changeReady, me.getID())
  unregisterMessage(#enterReady, me.getID())
  unregisterMessage(#roomInterfaceHidden, me.getID())
  return 1
end

on setHelpItemClosed me, tHelpItemId
  if pHelpStatusData.getaProp(tHelpItemId) <> 1 then
    return 0
  end if
  pHelpStatusData[tHelpItemId] = 0
  tConn = getConnection(getVariableValue("connection.info.id"))
  tKey = EMPTY
  case tHelpItemId of
    "own_user":
      tKey = 1
    "messenger":
      tKey = 2
    "navigator":
      tKey = 3
    "chat":
      tKey = 4
    "hand":
      tKey = 5
    "invite":
      tKey = 6
  end case
  if tKey <> EMPTY then
    tConn.send("MSG_REMOVE_ACCOUNT_HELP_TEXT", [#integer: tKey])
  end if
  tPos = pOpenHelps.findPos(tHelpItemId)
  if tPos > 0 then
    pOpenHelps.deleteAt(tPos)
  end if
  if pPostponedHelps.count > 0 then
    tHelpId = pPostponedHelps[1]
    pPostponedHelps.deleteAt(1)
    tTimeoutID = "NUH_help_" & tHelpId & "_postponed"
    createTimeout(tTimeoutID, 3000, #tryToShowHelp, me.getID(), tHelpId, 1)
  end if
end

on setHelpStatusData me, tdata
  pHelpStatusData = tdata
end

on isChatHelpOn me
  if not voidp(pHelpStatusData["chat"]) then
    return pHelpStatusData["chat"]
  end if
  return 0
end

on initHelpOnRoomEntry me
  me.showNewUserHelpItems()
end

on removeHelp me
  repeat with tItemNo = 1 to pHelpStatusData.count
    tItem = pHelpStatusData.getPropAt(tItemNo)
    tItemOn = pHelpStatusData[tItemNo]
    tTimeoutID = "NUH_help_" & tItem
    if timeoutExists(tTimeoutID) then
      removeTimeout(tTimeoutID)
    end if
  end repeat
  me.getInterface().removeAll()
  pPostponedHelps = []
  pOpenHelps = []
end

on showNewUserHelpItems me
  repeat with tItemNo = 1 to pHelpStatusData.count
    tItem = pHelpStatusData.getPropAt(tItemNo)
    tItemOn = pHelpStatusData[tItemNo]
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
  end repeat
end

on tryToShowHelp me, tHelpId
  if pOpenHelps.count > 1 then
    tPos = pPostponedHelps.findPos(tHelpId)
    if tPos > 0 then
      return 1
    end if
    pPostponedHelps.add(tHelpId)
    return 1
  end if
  case tHelpId of
    "messenger":
      if not threadExists(#friend_list) then
        return 0
      end if
      tFriendListComponent = getThread(#friend_list).getComponent()
      tRequests = tFriendListComponent.getPendingFriendRequests()
      if ilk(tRequests) = #propList then
        tRequestCount = tRequests.count
        if tRequestCount > 0 then
          me.getInterface().showGenericHelp(tHelpId)
          pOpenHelps.add(tHelpId)
        end if
      end if
    "navigator":
      me.getInterface().showGenericHelp(tHelpId)
      pOpenHelps.add(tHelpId)
    "own_user":
      me.getInterface().showOwnUserHelp(tHelpId)
      pOpenHelps.add(tHelpId)
    "hand":
      towner = getObject(#session).GET(#room_owner)
      if towner then
        me.getInterface().showGenericHelp(tHelpId)
        pOpenHelps.add(tHelpId)
      end if
    "invite":
      me.checkHelpers()
  end case
end

on checkHelpers me
  tConn = getConnection(getVariable("connection.info.id"))
  if voidp(tConn) then
    return error(me, "Connection not found.", #checkHelpers, #major)
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
    return error(me, "Connection not found.", #sendInvitations, #major)
  end if
  tConn.send("MSG_INVITE_TUTORS")
end

on invitationExpired me
  executeMessage(#alert, "invitation_expired")
end

on invitationExists me
  executeMessage(#alert, "invitation_exists")
end
