property pHelpStatusData, pPostponedHelps, pOpenHelps, pInvitationRoomID, pInviting, pGuidesFoundCount

on construct me
  pHelpStatusData = [:]
  pPostponedHelps = []
  pOpenHelps = []
  pInvitationRoomID = 0
  pInviting = 0
  registerMessage(#roomReady, me.getID(), #initHelpOnRoomEntry)
  registerMessage(#leaveRoom, me.getID(), #removeHelp)
  registerMessage(#changeRoom, me.getID(), #removeHelp)
  registerMessage(#enterRoom, me.getID(), #removeHelp)
  registerMessage(#roomInterfaceHidden, me.getID(), #removeHelp)
  registerMessage(#NUH_close, me.getID(), #setHelpItemClosed)
  return 1
end

on deconstruct me
  unregisterMessage(#roomReady, me.getID())
  unregisterMessage(#leaveReady, me.getID())
  unregisterMessage(#changeReady, me.getID())
  unregisterMessage(#enterReady, me.getID())
  unregisterMessage(#roomInterfaceHidden, me.getID())
  unregisterMessage(#NUH_close, me.getID())
  return 1
end

on getHelpItemKeyId me, tHelpItemName
  if variableExists("NUH.ids") then
    tKeys = getVariableValue("NUH.ids")
    if (ilk(tKeys) = #propList) then
      tKey = tKeys.getaProp(tHelpItemName)
      return tKey
    end if
  end if
end

on getHelpItemName me, tKeyId
  if variableExists("NUH.ids") then
    tKeys = getVariableValue("NUH.ids")
    if (ilk(tKeys) = #propList) then
      tName = tKeys.getOne(tKeyId)
      return tName
    end if
  end if
end

on setHelpItemClosed me, tHelpItemName
  if (pOpenHelps.getPos(tHelpItemName) = 0) then
    return 0
  end if
  if (pHelpStatusData.getaProp(tHelpItemName) <> 1) then
    return 0
  end if
  pHelpStatusData[tHelpItemName] = 0
  tConn = getConnection(getVariableValue("connection.info.id"))
  tKey = EMPTY
  tKey = me.getHelpItemKeyId(tHelpItemName)
  if (tKey <> 0) then
    tConn.send("MSG_REMOVE_ACCOUNT_HELP_TEXT", [#integer: tKey])
  end if
  me.removeOpenHelp(tHelpItemName)
  me.getInterface().removeHelpBubble(tHelpItemName)
  if (pPostponedHelps.count > 0) then
    tHelpId = pPostponedHelps[1]
    pPostponedHelps.deleteAt(1)
    tTimeoutID = (("NUH_help_" & tHelpId) & "_postponed")
    createTimeout(tTimeoutID, 3000, #tryToShowHelp, me.getID(), tHelpId, 1)
  end if
end

on removeOpenHelp me, tHelpId
  tPos = pOpenHelps.findPos(tHelpId)
  if (tPos > 0) then
    pOpenHelps.deleteAt(tPos)
  end if
end

on setHelpStatusData me, tdata
  pHelpStatusData = tdata
end

on closeInvitation me, tResult
  case tResult of
    #yes:
      me.sendInvitations()
    #no:
      nothing()
    #never:
      me.setHelpItemClosed("invite")
  end case
  return 0
  me.removeOpenHelp("invite")
  me.getInterface().hideInvitationWindow()
end

on isChatHelpOn me
  if not voidp(pHelpStatusData["chat"]) then
    return pHelpStatusData["chat"]
  end if
  return 0
end

on initHelpOnRoomEntry me
  tRoomData = getThread(#room).getComponent().pSaveData
  tUserName = getObject(#session).GET(#userName)
  if (tRoomData[#owner] = tUserName) then
    me.showNewUserHelpItems()
  end if
end

on removeHelp me
  repeat with tItemNo = 1 to pHelpStatusData.count
    tItem = pHelpStatusData.getPropAt(tItemNo)
    tItemOn = pHelpStatusData[tItemNo]
    tTimeoutID = ("NUH_help_" & tItem)
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
      tTimeoutVarId = (("NUH." & tItem) & ".timeout")
      tDefaultTimeoutVarId = (("NUH." & tItem) & ".default.timeout")
      if variableExists(tTimeoutVarId) then
        tTimeout = getVariable(tTimeoutVarId)
      else
        tTimeout = getVariable(tDefaultTimeoutVarId)
      end if
      if not integerp(value(tTimeout)) then
        tTimeout = 0
      end if
      if (tTimeout = 0) then
        pOpenHelps.add(tItem)
        next repeat
      end if
      tTimeoutID = ("NUH_help_" & tItem)
      createTimeout(tTimeoutID, tTimeout, #tryToShowHelp, me.getID(), tItem, 1)
    end if
  end repeat
end

on tryToShowHelp me, tHelpId
  if ((pOpenHelps.count > 1) or pInviting) then
    me.postponeHelp(tHelpId)
    return 1
  end if
  case tHelpId of
    "friends":
      if not threadExists(#friend_list) then
        return 0
      end if
      tFriendListComponent = getThread(#friend_list).getComponent()
      tRequests = tFriendListComponent.getPendingFriendRequests()
      if (ilk(tRequests) = #propList) then
        tRequestCount = tRequests.count
        if (tRequestCount > 0) then
          me.getInterface().showGenericHelp(tHelpId)
          pOpenHelps.add(tHelpId)
        end if
      end if
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
      towner = getObject(#session).GET(#room_owner)
      if towner then
        me.checkHelpers()
      end if
    otherwise:
      me.getInterface().showGenericHelp(tHelpId)
      pOpenHelps.add(tHelpId)
  end case
end

on postponeHelp me, tHelpId
  tPos = pPostponedHelps.findPos(tHelpId)
  if (tPos > 0) then
    return 1
  end if
  pPostponedHelps.add(tHelpId)
  if (pOpenHelps.count = 0) then
    tTimeoutID = (("NUH_help_" & tHelpId) & "_reactivation")
    if not timeoutExists(tTimeoutID) then
      createTimeout(tTimeoutID, 3000, #tryToShowHelp, me.getID(), tHelpId, 1)
    end if
  end if
  return 1
end

on checkHelpers me
  tConn = getConnection(getVariable("connection.info.id"))
  if voidp(tConn) then
    return error(me, "Connection not found.", #checkHelpers, #major)
  end if
  tConn.send("MSG_GET_TUTORS_AVAILABLE")
end

on showInviteWindow me
  pOpenHelps.add("invite")
  me.getInterface().showInviteWindow()
end

on inviterLeftRoom me, tRoomID
  pInviting = 0
  pInvitationRoomID = tRoomID
  me.getInterface().showInvitationStatusWindow(#room_left)
end

on goToInvitationRoom me
  if (pInvitationRoomID > 0) then
    executeMessage(#roomForward, pInvitationRoomID, #private)
  end if
end

on sendInvitations me
  tConn = getConnection(getVariable("connection.info.id"))
  if voidp(tConn) then
    return error(me, "Connection not found.", #sendInvitations, #major)
  end if
  towner = getObject(#session).GET(#room_owner)
  if towner then
    tConn.send("MSG_INVITE_TUTORS")
  end if
end

on cancelInvitations me
  tConn = getConnection(getVariable("connection.info.id"))
  if voidp(tConn) then
    return error(me, "Connection not found.", #sendInvitations, #major)
  end if
  tConn.send("MSG_CANCEL_TUTOR_INVITATIONS")
  pInviting = 0
end

on invitingStarted me
  pInviting = 1
  pGuidesFoundCount = 0
  me.getInterface().showInvitationStatusWindow(#Search)
end

on invitingCompleted me, tAcceptCount
  pInviting = 0
  if (tAcceptCount = 0) then
    tstate = #failure
  else
    tstate = #success
  end if
  me.getInterface().showInvitationStatusWindow(tstate)
end

on invitationExists me
  executeMessage(#alert, "invitation_exists")
end

on getGuideCount me
  return pGuidesFoundCount
end

on guideFound me
  pGuidesFoundCount = (pGuidesFoundCount + 1)
end
