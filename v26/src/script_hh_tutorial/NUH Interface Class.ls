property pBubbles, pInvitationWindowID, pInvitationStatusWindowID, pInvitationStatusTimeoutID, pSearchAnimFrame

on construct me
  pBubbles = [:]
  pUpdateOwnUserHelp = 0
  pInvitationWindowID = #NUH_invite_window_ID
  pInvitationStatusWindowID = #NUH_invite_status_window_ID
  pInvitationStatusTimeoutID = #NUH_invite_status_timeout_ID
  pSearchAnimFrame = 1
  registerMessage(#gamesystem_constructed, me.getID(), #hideInvitationStatusWindow)
  return 1
end

on deconstruct me
  me.removeAll()
  me.hideInvitationStatusWindow()
  unregisterMessage(#gamesystem_constructed, me.getID())
  return 1
end

on removeAll me
  repeat with tItemNo = 1 to pBubbles.count
    tBubble = pBubbles[tItemNo]
    tBubble.deconstruct()
  end repeat
  pBubbles = [:]
  me.hideInvitationWindow()
end

on showOwnUserHelp me
  tRoomComponent = getThread("room").getComponent()
  tOwnRoomId = tRoomComponent.getUsersRoomId(getObject(#session).GET("user_name"))
  tHumanObj = tRoomComponent.getUserObject(tOwnRoomId)
  if (tHumanObj = 0) then
    return 0
  end if
  tRoomComponent = getThread("room").getComponent()
  if (tRoomComponent = 0) then
    return 0
  end if
  tBubble = createObject(#random, getVariableValue("update.bubble.class"))
  if (tBubble = 0) then
    return 0
  end if
  tHelpId = "own_user"
  tPointer = 7
  tText = getText(("NUH_" & tHelpId))
  tBubble.setProperty(#bubbleId, tHelpId)
  tBubble.setText(tText)
  tBubble.selectPointerAndPosition(tPointer)
  tBubble.show()
  if objectp(pBubbles.getaProp(tHelpId)) then
    tPreviousBubble = pBubbles[tHelpId]
    tPreviousBubble.deconstruct()
  end if
  pBubbles[tHelpId] = tBubble
end

on showGenericHelp me, tHelpId, tTargetLoc, tPointerIndex
  tRoomID = getThread(#room).getComponent().getRoomID()
  if (((tRoomID = EMPTY) or (tRoomID = #game)) or (tRoomID = "game")) then
    return 0
  end if
  tLocX = 0
  tLocY = 0
  tText = EMPTY
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  if (voidp(tTargetLoc) or not listp(tTargetLoc)) then
    tLocX = getVariable((("NUH." & tHelpId) & ".bubble.loc")).item[1]
    tLocY = getVariable((("NUH." & tHelpId) & ".bubble.loc")).item[2]
  else
    tLocX = tTargetLoc[1]
    tLocY = tTargetLoc[2]
  end if
  the itemDelimiter = tDelim
  if voidp(tPointerIndex) then
    tPointer = getVariable((("NUH." & tHelpId) & ".pointer"))
  else
    tPointer = tPointerIndex
  end if
  tText = getText(("NUH_" & tHelpId))
  tBubble = createObject(#random, getVariableValue("static.bubble.class"))
  if (tBubble = 0) then
    return 0
  end if
  tBubble.setProperty(#bubbleId, tHelpId)
  tBubble.setText(tText)
  tBubble.setProperty(#targetX, tLocX)
  tBubble.setProperty(#targetY, tLocY)
  tBubble.selectPointerAndPosition(tPointer)
  tBubble.show()
  tBubble.hideCloseButton()
  if objectp(pBubbles.getaProp(tHelpId)) then
    tPreviousBubble = pBubbles[tHelpId]
    tPreviousBubble.deconstruct()
  end if
  pBubbles[tHelpId] = tBubble
end

on removeHelpBubble me, tHelpItemName
  tBubble = pBubbles.getaProp(tHelpItemName)
  if objectp(tBubble) then
    tBubble.deconstruct()
  end if
end

on showInviteWindow me
  me.hideInvitationWindow()
  createWindow(pInvitationWindowID, "nuh_invitation.window")
  tWindow = getWindow(pInvitationWindowID)
  tLocX = getVariable("NUH.invitation.loc").item[1]
  tLocY = getVariable("NUH.invitation.loc").item[2]
  tHeader = getText("send_invitation_header")
  tWindow.getElement("nuh_invitation_header").setText(tHeader)
  tText = getText("send_invitation_text")
  tWindow.getElement("nuh_invitation_text").setText(tText)
  tWindow.moveTo(tLocX, tLocY)
  tWindow.registerProcedure(#eventProcInvitation, me.getID(), #mouseUp)
end

on hideInvitationWindow me
  if windowExists(pInvitationWindowID) then
    removeWindow(pInvitationWindowID)
  end if
end

on showInvitationStatusWindow me, tstate
  me.hideInvitationStatusWindow()
  case tstate of
    #Search:
      tLayout = "nuh_invitation_status.window"
    #room_left:
      tLayout = "nuh_room_left.window"
    #success:
      tLayout = "nuh_invitation_success.window"
    #failure:
      tLayout = "nuh_invitation_failure.window"
  end case
  return 0
  createWindow(pInvitationStatusWindowID, tLayout)
  tWindow = getWindow(pInvitationStatusWindowID)
  tWindow.moveTo(10, 10)
  tWindow.registerProcedure(#eventProcInvitationStatus, me.getID(), #mouseUp)
  if timeoutExists(pInvitationStatusTimeoutID) then
    removeTimeout(pInvitationStatusTimeoutID)
  end if
  case tstate of
    #Search:
      createTimeout(pInvitationStatusTimeoutID, 250, #updateInvitationStatusWindow, me.getID(), VOID, 0)
    #success:
      createTimeout(pInvitationStatusTimeoutID, 3000, #hideInvitationStatusWindow, me.getID(), VOID, 1)
  end case
end

on hideInvitationStatusWindow me
  if windowExists(pInvitationStatusWindowID) then
    removeWindow(pInvitationStatusWindowID)
  end if
  if timeoutExists(pInvitationStatusTimeoutID) then
    removeTimeout(pInvitationStatusTimeoutID)
  end if
end

on updateInvitationStatusWindow me
  if not windowExists(pInvitationStatusWindowID) then
    return 0
  end if
  tWindow = getWindow(pInvitationStatusWindowID)
  if tWindow.elementExists("nuh_search") then
    tElem = tWindow.getElement("nuh_search")
    pSearchAnimFrame = (pSearchAnimFrame + 1)
    if (pSearchAnimFrame > 3) then
      pSearchAnimFrame = 1
    end if
    tMemName = ("nuh_search_" & pSearchAnimFrame)
    if memberExists(tMemName) then
      tElem.setProperty(#image, member(getmemnum(tMemName)).image)
    end if
  end if
  if tWindow.elementExists("nuh_invitation_status_counter") then
    tCount = me.getComponent().getGuideCount()
    tText = (getText("NUH_invitation_guides_found") && tCount)
    tElem = tWindow.getElement("nuh_invitation_status_counter")
    tElem.setText(tText)
  end if
end

on eventProcInvitation me, tEvent, tSprID
  case tSprID of
    "nuh_invitation_yes":
      me.getComponent().closeInvitation(#yes)
    "nuh_invitation_no":
      me.getComponent().closeInvitation(#no)
    "nuh_invitation_never":
      me.getComponent().closeInvitation(#never)
  end case
end

on eventProcInvitationStatus me, tEvent, tSprID
  if (tSprID contains "nuh_invitation_option") then
    tOption = tSprID.char[tSprID.length]
    tVarName = ("NUH.invitation.option." & tOption)
    if variableExists(tVarName) then
      tMsg = value(getVariable(tVarName))
      executeMessage(tMsg)
      me.hideInvitationStatusWindow()
    end if
    return 1
  end if
  case tSprID of
    "nuh_invitation_status_cancel", "nuh_invitation_status_close":
      me.getComponent().cancelInvitations()
      me.hideInvitationStatusWindow()
    "nuh_room_left_back":
      me.getComponent().goToInvitationRoom()
    "close_button":
      me.hideInvitationStatusWindow()
  end case
end
