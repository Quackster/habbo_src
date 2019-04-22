property pBubbles, pInvitationWindowID, pInvitationStatusWindowID, pInvitationStatusTimeoutID, pSearchAnimFrame

on construct me 
  pBubbles = [:]
  pUpdateOwnUserHelp = 0
  pInvitationWindowID = #NUH_invite_window_ID
  pInvitationStatusWindowID = #NUH_invite_status_window_ID
  pInvitationStatusTimeoutID = #NUH_invite_status_timeout_ID
  pSearchAnimFrame = 1
  registerMessage(#gamesystem_constructed, me.getID(), #hideInvitationStatusWindow)
  return(1)
end

on deconstruct me 
  me.removeAll()
  me.hideInvitationStatusWindow()
  unregisterMessage(#gamesystem_constructed, me.getID())
  return(1)
end

on removeAll me 
  tItemNo = 1
  repeat while tItemNo <= pBubbles.count
    tBubble = pBubbles.getAt(tItemNo)
    tBubble.deconstruct()
    tItemNo = 1 + tItemNo
  end repeat
  pBubbles = [:]
  me.hideInvitationWindow()
end

on showOwnUserHelp me 
  tRoomComponent = getThread("room").getComponent()
  tOwnRoomId = tRoomComponent.getUsersRoomId(getObject(#session).GET("user_name"))
  tHumanObj = tRoomComponent.getUserObject(tOwnRoomId)
  if tHumanObj = 0 then
    return(0)
  end if
  tRoomComponent = getThread("room").getComponent()
  if tRoomComponent = 0 then
    return(0)
  end if
  tBubble = createObject(#random, getVariableValue("update.bubble.class"))
  if tBubble = 0 then
    return(0)
  end if
  tHelpId = "own_user"
  tPointer = 7
  tText = getText("NUH_" & tHelpId)
  tBubble.setProperty(#bubbleId, tHelpId)
  tBubble.setText(tText)
  tBubble.selectPointerAndPosition(tPointer)
  tBubble.show()
  if objectp(pBubbles.getaProp(tHelpId)) then
    tPreviousBubble = pBubbles.getAt(tHelpId)
    tPreviousBubble.deconstruct()
  end if
  pBubbles.setAt(tHelpId, tBubble)
end

on showGenericHelp me, tHelpId, tTargetLoc, tPointerIndex 
  tRoomID = getThread(#room).getComponent().getRoomID()
  if tRoomID = "" or tRoomID = #game or tRoomID = "game" then
    return(0)
  end if
  tLocX = 0
  tLocY = 0
  tText = ""
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  if voidp(tTargetLoc) or not listp(tTargetLoc) then
    tLocX = getVariable("NUH." & tHelpId & ".bubble.loc").getProp(#item, 1)
    tLocY = getVariable("NUH." & tHelpId & ".bubble.loc").getProp(#item, 2)
  else
    tLocX = tTargetLoc.getAt(1)
    tLocY = tTargetLoc.getAt(2)
  end if
  the itemDelimiter = tDelim
  if voidp(tPointerIndex) then
    tPointer = getVariable("NUH." & tHelpId & ".pointer")
  else
    tPointer = tPointerIndex
  end if
  tText = getText("NUH_" & tHelpId)
  tBubble = createObject(#random, getVariableValue("static.bubble.class"))
  if tBubble = 0 then
    return(0)
  end if
  tBubble.setProperty(#bubbleId, tHelpId)
  tBubble.setText(tText)
  tBubble.setProperty(#targetX, tLocX)
  tBubble.setProperty(#targetY, tLocY)
  tBubble.selectPointerAndPosition(tPointer)
  tBubble.show()
  tBubble.hideCloseButton()
  if objectp(pBubbles.getaProp(tHelpId)) then
    tPreviousBubble = pBubbles.getAt(tHelpId)
    tPreviousBubble.deconstruct()
  end if
  pBubbles.setAt(tHelpId, tBubble)
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
  tLocX = getVariable("NUH.invitation.loc").getProp(#item, 1)
  tLocY = getVariable("NUH.invitation.loc").getProp(#item, 2)
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
  if tstate = #Search then
    tLayout = "nuh_invitation_status.window"
  else
    if tstate = #room_left then
      tLayout = "nuh_room_left.window"
    else
      if tstate = #success then
        tLayout = "nuh_invitation_success.window"
      else
        if tstate = #failure then
          tLayout = "nuh_invitation_failure.window"
        else
          return(0)
        end if
      end if
    end if
  end if
  createWindow(pInvitationStatusWindowID, tLayout)
  tWindow = getWindow(pInvitationStatusWindowID)
  tWindow.moveTo(10, 10)
  tWindow.registerProcedure(#eventProcInvitationStatus, me.getID(), #mouseUp)
  if timeoutExists(pInvitationStatusTimeoutID) then
    removeTimeout(pInvitationStatusTimeoutID)
  end if
  if tstate = #Search then
    createTimeout(pInvitationStatusTimeoutID, 250, #updateInvitationStatusWindow, me.getID(), void(), 0)
  else
    if tstate = #success then
      createTimeout(pInvitationStatusTimeoutID, 3000, #hideInvitationStatusWindow, me.getID(), void(), 1)
    end if
  end if
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
    return(0)
  end if
  tWindow = getWindow(pInvitationStatusWindowID)
  if tWindow.elementExists("nuh_search") then
    tElem = tWindow.getElement("nuh_search")
    pSearchAnimFrame = pSearchAnimFrame + 1
    if pSearchAnimFrame > 3 then
      pSearchAnimFrame = 1
    end if
    tMemName = "nuh_search_" & pSearchAnimFrame
    if memberExists(tMemName) then
      tElem.setProperty(#image, member(getmemnum(tMemName)).image)
    end if
  end if
  if tWindow.elementExists("nuh_invitation_status_counter") then
    tCount = me.getComponent().getGuideCount()
    tText = getText("NUH_invitation_guides_found") && tCount
    tElem = tWindow.getElement("nuh_invitation_status_counter")
    tElem.setText(tText)
  end if
end

on eventProcInvitation me, tEvent, tSprID 
  if tSprID = "nuh_invitation_yes" then
    me.getComponent().closeInvitation(#yes)
  else
    if tSprID = "nuh_invitation_no" then
      me.getComponent().closeInvitation(#no)
    else
      if tSprID = "nuh_invitation_never" then
        me.getComponent().closeInvitation(#never)
      end if
    end if
  end if
end

on eventProcInvitationStatus me, tEvent, tSprID 
  if tSprID contains "nuh_invitation_option" then
    tOption = tSprID.getProp(#char, tSprID.length)
    tVarName = "NUH.invitation.option." & tOption
    if variableExists(tVarName) then
      tMsg = value(getVariable(tVarName))
      executeMessage(tMsg)
      me.hideInvitationStatusWindow()
    end if
    return(1)
  end if
  if tSprID <> "nuh_invitation_status_cancel" then
    if tSprID = "nuh_invitation_status_close" then
      me.getComponent().cancelInvitations()
      me.hideInvitationStatusWindow()
    else
      if tSprID = "nuh_room_left_back" then
        me.getComponent().goToInvitationRoom()
      else
        if tSprID = "close_button" then
          me.hideInvitationStatusWindow()
        end if
      end if
    end if
  end if
end
