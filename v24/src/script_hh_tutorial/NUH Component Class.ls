property pOpenHelps, pHelpStatusData, pPostponedHelps, pInviting, pInvitationRoomID, pGuidesFoundCount

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
  return TRUE
end

on deconstruct me 
  unregisterMessage(#roomReady, me.getID())
  unregisterMessage(#leaveReady, me.getID())
  unregisterMessage(#changeReady, me.getID())
  unregisterMessage(#enterReady, me.getID())
  unregisterMessage(#roomInterfaceHidden, me.getID())
  unregisterMessage(#NUH_close, me.getID())
  return TRUE
end

on getHelpItemKeyId me, tHelpItemName 
  if variableExists("NUH.ids") then
    tKeys = getVariableValue("NUH.ids")
    if (ilk(tKeys) = #propList) then
      tKey = tKeys.getaProp(tHelpItemName)
      return(tKey)
    end if
  end if
end

on getHelpItemName me, tKeyId 
  if variableExists("NUH.ids") then
    tKeys = getVariableValue("NUH.ids")
    if (ilk(tKeys) = #propList) then
      tName = tKeys.getOne(tKeyId)
      return(tName)
    end if
  end if
end

on setHelpItemClosed me, tHelpItemName 
  if (pOpenHelps.getPos(tHelpItemName) = 0) then
    return FALSE
  end if
  if pHelpStatusData.getaProp(tHelpItemName) <> 1 then
    return FALSE
  end if
  pHelpStatusData.setAt(tHelpItemName, 0)
  tConn = getConnection(getVariableValue("connection.info.id"))
  tKey = ""
  tKey = me.getHelpItemKeyId(tHelpItemName)
  if tKey <> 0 then
    tConn.send("MSG_REMOVE_ACCOUNT_HELP_TEXT", [#integer:tKey])
  end if
  me.removeOpenHelp(tHelpItemName)
  me.getInterface().removeHelpBubble(tHelpItemName)
  if pPostponedHelps.count > 0 then
    tHelpId = pPostponedHelps.getAt(1)
    pPostponedHelps.deleteAt(1)
    tTimeoutID = "NUH_help_" & tHelpId & "_postponed"
    createTimeout(tTimeoutID, 3000, #tryToShowHelp, me.getID(), tHelpId, 1)
  end if
end

on removeOpenHelp me, tHelpId 
  tPos = pOpenHelps.findPos(tHelpId)
  if tPos > 0 then
    pOpenHelps.deleteAt(tPos)
  end if
end

on setHelpStatusData me, tdata 
  pHelpStatusData = tdata
end

on closeInvitation me, tResult 
  if (tResult = #yes) then
    me.sendInvitations()
  else
    if (tResult = #no) then
      nothing()
    else
      if (tResult = #never) then
        me.setHelpItemClosed("invite")
      else
        return FALSE
      end if
    end if
  end if
  me.removeOpenHelp("invite")
  me.getInterface().hideInvitationWindow()
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
      if (tTimeout = 0) then
        pOpenHelps.add(tItem)
      else
        tTimeoutID = "NUH_help_" & tItem
        createTimeout(tTimeoutID, tTimeout, #tryToShowHelp, me.getID(), tItem, 1)
      end if
    end if
    tItemNo = (1 + tItemNo)
  end repeat
end

on tryToShowHelp me, tHelpId 
  if pOpenHelps.count > 1 or pInviting then
    me.postponeHelp(tHelpId)
    return TRUE
  end if
  if (tHelpId = "friends") then
    if not threadExists(#friend_list) then
      return FALSE
    end if
    tFriendListComponent = getThread(#friend_list).getComponent()
    tRequests = tFriendListComponent.getPendingFriendRequests()
    if (ilk(tRequests) = #propList) then
      tRequestCount = tRequests.count
      if tRequestCount > 0 then
        me.getInterface().showGenericHelp(tHelpId)
        pOpenHelps.add(tHelpId)
      end if
    end if
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
          towner = getObject(#session).GET(#room_owner)
          if towner then
            me.checkHelpers()
          end if
        else
          me.getInterface().showGenericHelp(tHelpId)
          pOpenHelps.add(tHelpId)
        end if
      end if
    end if
  end if
end

on postponeHelp me, tHelpId 
  tPos = pPostponedHelps.findPos(tHelpId)
  if tPos > 0 then
    return TRUE
  end if
  pPostponedHelps.add(tHelpId)
  if (pOpenHelps.count = 0) then
    tTimeoutID = "NUH_help_" & tHelpId & "_reactivation"
    if not timeoutExists(tTimeoutID) then
      createTimeout(tTimeoutID, 3000, #tryToShowHelp, me.getID(), tHelpId, 1)
    end if
  end if
  return TRUE
end

on checkHelpers me 
  tConn = getConnection(getVariable("connection.info.id"))
  if voidp(tConn) then
    return(error(me, "Connection not found.", #checkHelpers, #major))
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
  if pInvitationRoomID > 0 then
    executeMessage(#roomForward, pInvitationRoomID, #private)
  end if
end

on sendInvitations me 
  tConn = getConnection(getVariable("connection.info.id"))
  if voidp(tConn) then
    return(error(me, "Connection not found.", #sendInvitations, #major))
  end if
  towner = getObject(#session).GET(#room_owner)
  if towner then
    tConn.send("MSG_INVITE_TUTORS")
  end if
end

on cancelInvitations me 
  tConn = getConnection(getVariable("connection.info.id"))
  if voidp(tConn) then
    return(error(me, "Connection not found.", #sendInvitations, #major))
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
  return(pGuidesFoundCount)
end

on guideFound me 
  pGuidesFoundCount = (pGuidesFoundCount + 1)
end
