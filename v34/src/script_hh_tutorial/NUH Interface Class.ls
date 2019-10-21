on construct(me)
  pBubbles = []
  pUpdateOwnUserHelp = 0
  pInvitationWindowID = #NUH_invite_window_ID
  pInvitationStatusWindowID = #NUH_invite_status_window_ID
  pInvitationStatusTimeoutID = #NUH_invite_status_timeout_ID
  pSkipWindowID = #NUH_skip_window_ID
  pHighlighterList = void()
  pHighlighterActive = 0
  pHighlighterBlinkTimeoutID = #NUH_hiliter_blink_timeout
  pHighlighterBlinkPhase = 1
  pSearchAnimFrame = 1
  registerMessage(#gamesystem_constructed, me.getID(), #hideInvitationStatusWindow)
  registerMessage(#roomReady, me.getID(), #hideHighlighters)
  return(1)
  exit
end

on deconstruct(me)
  me.removeAll()
  me.hideInvitationStatusWindow()
  unregisterMessage(#gamesystem_constructed, me.getID())
  unregisterMessage(#roomReady, me.getID())
  return(1)
  exit
end

on removeAll(me)
  me.removeBlinkTimeout()
  tItemNo = 1
  repeat while tItemNo <= pBubbles.count
    tBubble = pBubbles.getAt(tItemNo)
    tBubble.deconstruct()
    tItemNo = 1 + tItemNo
  end repeat
  pBubbles = []
  me.hideInvitationWindow()
  me.hideSkipOrNotWindow()
  exit
end

on showOwnUserHelp(me)
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
  tBubble.setTargetHumanObj(tHumanObj)
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
  exit
end

on showSkipOrNotWindow(me, tHelpId)
  tRoomID = getThread(#room).getComponent().getRoomID()
  if tRoomID = "" or tRoomID = #game or tRoomID = "game" then
    return(0)
  end if
  createWindow(pSkipWindowID, "bubble.window")
  tWindow = getWindow(pSkipWindowID)
  if not objectp(tWindow) then
    return(error(me, "Error creating tutorial skip dialog window", #showSkipOrNotWindow, #major))
  end if
  i = 1
  repeat while i <= 8
    if i <> 4 then
      tElemName = "pointer_" & i
      tWindow.getElement(tElemName).hide()
      tElemName = "pointer_" & i & "_shadow"
      if tWindow.elementExists(tElemName) then
        tWindow.getElement(tElemName).hide()
      end if
    end if
    i = 1 + i
  end repeat
  tWindow.merge("habbo_decision_plain.window")
  tWindow.registerProcedure(#eventProcSkipTutorial, me.getID(), #mouseUp)
  tWindow.getElement("habbo_decision_text_a").setText(getText("NUH_asktoshowhelp_title"))
  tWindow.getElement("habbo_decision_text_b").setText(getText("NUH_asktoshowhelp_text"))
  tWindow.getElement("habbo_decision_cancel").setText(getText("NUH_asktoshowhelp_decision_cancel"))
  tWindow.getElement("habbo_decision_ok").setText(getText("NUH_asktoshowhelp_decision_ok"))
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  tLocString = getStringVariable("NUH.asktoshowhelp.loc")
  tLocH = tLocString.getProp(#item, 1)
  tLocV = tLocString.getProp(#item, 2)
  tWindow.moveTo(tLocH, tLocV)
  the itemDelimiter = tDelim
  exit
end

on hideSkipOrNotWindow(me)
  tWindow = getWindow(pSkipWindowID)
  if not objectp(tWindow) then
    return()
  end if
  removeWindow(pSkipWindowID)
  exit
end

on showGenericHelp(me, tHelpId, tTargetLoc, tPointerIndex)
  tRoomID = getThread(#room).getComponent().getRoomID()
  if tRoomID = "" or tRoomID = #game or tRoomID = "game" then
    return(0)
  end if
  tText = ""
  tText = getText("NUH_" & tHelpId)
  tTopic = getText("NUH_" & tHelpId & "_topic")
  tItem = []
  tItem.setaProp(#type, #help)
  tItem.setaProp(#value, tText)
  tItem.setaProp(#helpId, tHelpId)
  tItem.setaProp(#topic, tTopic)
  tItem.setaProp(#autoOpen, getIntVariable("NUH." & tHelpId & ".auto-open"))
  if variableExists("NUH." & tHelpId & ".bg.color") then
    tItem.setaProp(#bgColor, rgb(getStringVariable("NUH." & tHelpId & ".bg.color")))
  end if
  if variableExists("NUH." & tHelpId & ".txt.color") then
    tItem.setaProp(#txtColor, rgb(getStringVariable("NUH." & tHelpId & ".txt.color")))
  end if
  getThread("infofeed").getComponent().createItem(tItem)
  exit
end

on showGuideArrivedBubble(me, tAccountID, tAutoSelected)
  tRoomComponent = getThread("room").getComponent()
  tHumanObj = tRoomComponent.getUserObjectByWebID(tAccountID)
  if tHumanObj = 0 then
    return(0)
  end if
  tRoomComponent = getThread("room").getComponent()
  if tRoomComponent = 0 then
    return(0)
  end if
  tBubble = createObject(#random, getVariableValue("tutor.bubble.class"))
  if tBubble = 0 then
    return(0)
  end if
  tBubble.setTargetHumanObj(tHumanObj)
  tHelpId = "guide_info"
  if tAutoSelected then
    tHelpId = tHelpId & "_autoselected"
  end if
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
  exit
end

on removeHelpBubble(me, tHelpItemName)
  tBubble = pBubbles.getaProp(tHelpItemName)
  if objectp(tBubble) then
    tBubble.deconstruct()
  end if
  exit
end

on showInviteWindow(me)
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
  exit
end

on hideInvitationWindow(me)
  if windowExists(pInvitationWindowID) then
    removeWindow(pInvitationWindowID)
  end if
  exit
end

on showInvitationStatusWindow(me, tstate)
  me.hideInvitationStatusWindow()
  if me = #search then
    tLayout = "nuh_invitation_status.window"
  else
    if me = #room_left then
      tLayout = "nuh_room_left.window"
    else
      if me = #success then
        tLayout = "nuh_invitation_success.window"
      else
        if me = #failure then
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
  if me = #search then
    createTimeout(pInvitationStatusTimeoutID, 250, #updateInvitationStatusWindow, me.getID(), void(), 0)
  else
    if me = #success then
      createTimeout(pInvitationStatusTimeoutID, 3000, #hideInvitationStatusWindow, me.getID(), void(), 1)
    end if
  end if
  exit
end

on hideInvitationStatusWindow(me)
  if windowExists(pInvitationStatusWindowID) then
    removeWindow(pInvitationStatusWindowID)
  end if
  if timeoutExists(pInvitationStatusTimeoutID) then
    removeTimeout(pInvitationStatusTimeoutID)
  end if
  exit
end

on updateInvitationStatusWindow(me)
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
  exit
end

on getHighlighterList(me)
  tRoomBar = getWindow("RoomBarID")
  if voidp(tRoomBar) or tRoomBar = 0 then
    return([])
  end if
  if voidp(pHighlighterList) then
    pHighlighterList = []
    tKeys = getStructVariable("NUH.ids")
    i = 1
    repeat while i <= tKeys.count
      tVarName = "NUH." & tKeys.getPropAt(i) & ".highlighter"
      if variableExists(tVarName) then
        tElementName = getStringVariable(tVarName)
        if tRoomBar.elementExists(tElementName) then
          pHighlighterList.setaProp(tKeys.getPropAt(i), tElementName)
        end if
      end if
      i = 1 + i
    end repeat
  end if
  return(pHighlighterList)
  exit
end

on hideHighlighters(me)
  tRoomBar = getWindow("RoomBarID")
  if voidp(tRoomBar) or tRoomBar = 0 then
    return()
  end if
  tHighlighters = me.getHighlighterList()
  i = 1
  repeat while i <= tHighlighters.count
    tElementName = tHighlighters.getAt(i)
    if tRoomBar.elementExists(tElementName) then
      tRoomBar.getElement(tElementName).hide()
    end if
    i = 1 + i
  end repeat
  me.removeBlinkTimeout()
  exit
end

on showHighlighter(me, tHelpId)
  tRoomBar = getWindow("RoomBarID")
  if voidp(tRoomBar) or tRoomBar = 0 then
    return()
  end if
  tHighlighters = me.getHighlighterList()
  tElementName = tHighlighters.getAt(tHelpId)
  if voidp(tElementName) then
    return()
  end if
  if tRoomBar.elementExists(tElementName) then
    tRoomBar.getElement(tElementName).show()
    tRoomBar.getElement(tElementName).setProperty(#member, getMember("bar_hilite_icon_" & pHighlighterBlinkPhase))
  end if
  me.createBlinkTimeout()
  exit
end

on createBlinkTimeout(me)
  if not timeoutExists(pHighlighterBlinkTimeoutID) then
    createTimeout(pHighlighterBlinkTimeoutID, 750, #blinkHighlighters, me.getID(), void(), 0)
  end if
  exit
end

on removeBlinkTimeout(me)
  if timeoutExists(pHighlighterBlinkTimeoutID) then
    removeTimeout(pHighlighterBlinkTimeoutID)
  end if
  exit
end

on blinkHighlighters(me)
  tRoomBar = getWindow("RoomBarID")
  if voidp(tRoomBar) or tRoomBar = 0 then
    return()
  end if
  tHighlighters = me.getHighlighterList()
  i = 1
  repeat while i <= tHighlighters.count
    tElementName = tHighlighters.getAt(i)
    if tRoomBar.elementExists(tElementName) then
      if tRoomBar.getElement(tElementName).getProperty(#visible) then
        tRoomBar.getElement(tElementName).setProperty(#member, getMember("bar_hilite_icon_" & pHighlighterBlinkPhase))
      end if
    end if
    i = 1 + i
  end repeat
  pHighlighterBlinkPhase = pHighlighterBlinkPhase + 1
  if pHighlighterBlinkPhase > 2 then
    pHighlighterBlinkPhase = 1
  end if
  exit
end

on eventProcInvitation(me, tEvent, tSprID)
  if me = "nuh_invitation_yes" then
    me.getComponent().closeInvitation(#yes)
  else
    if me = "nuh_invitation_no" then
      me.getComponent().closeInvitation(#no)
    else
      if me = "nuh_invitation_never" then
        me.getComponent().closeInvitation(#never)
      end if
    end if
  end if
  exit
end

on eventProcInvitationStatus(me, tEvent, tSprID)
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
  if me <> "nuh_invitation_status_cancel" then
    if me = "nuh_invitation_status_close" then
      me.getComponent().cancelInvitations()
      me.hideInvitationStatusWindow()
    else
      if me = "nuh_room_left_back" then
        me.getComponent().goToInvitationRoom()
      else
        if me = "close_button" then
          me.hideInvitationStatusWindow()
        end if
      end if
    end if
    exit
  end if
end

on eventProcSkipTutorial(me, tEvent, tSprID)
  if me = "habbo_decision_ok" then
    me.getComponent().setAskingSkip(0)
    me.hideSkipOrNotWindow()
  else
    if me = "habbo_decision_cancel" then
      me.getComponent().setTutorialFinished()
      me.hideSkipOrNotWindow()
    end if
  end if
  exit
end