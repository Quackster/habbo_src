property pTutorialStructName, pOpenHelps, pHelpStatusData, pPostponedHelps, pAskingForSkip, pInviting, pInvitationRoomID, pGuidesFoundCount, pGuidelist, pAutoSelectGuide

on construct me 
  pHelpStatusData = [:]
  pPostponedHelps = []
  pOpenHelps = []
  pGuidelist = []
  pTutorialStructName = "NUH.ids"
  pInvitationRoomID = 0
  pInviting = 0
  pAutoSelectGuide = 1
  pAskingForSkip = 0
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
  if variableExists(pTutorialStructName) then
    tKeys = getVariableValue(pTutorialStructName)
    if (ilk(tKeys) = #propList) then
      tKey = tKeys.getaProp(tHelpItemName)
      return(tKey)
    end if
  end if
end

on getHelpItemName me, tKeyId 
  if variableExists(pTutorialStructName) then
    tKeys = getVariableValue(pTutorialStructName)
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
  tConn = getConnection(getVariable("connection.info.id"))
  tKey = ""
  tKey = me.getHelpItemKeyId(tHelpItemName)
  if tKey <> 0 then
    tConn.send("MSG_REMOVE_ACCOUNT_HELP_TEXT", [#integer:tKey])
  end if
  me.removeOpenHelp(tHelpItemName)
  me.getInterface().removeHelpBubble(tHelpItemName)
  if pPostponedHelps.count > 0 then
    i = 0
    repeat while pPostponedHelps <= undefined
      tHelpId = getAt(undefined, tHelpItemName)
      tTimeoutID = "NUH_help_" & tHelpId & "_postponed"
      createTimeout(tTimeoutID, (1000 + (100 * i)), #tryToShowHelp, me.getID(), tHelpId, 1)
      i = (i + 1)
    end repeat
    pPostponedHelps = []
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
  tRoomData = getThread(#room).getComponent().pSaveData
  tUserName = getObject(#session).GET(#userName)
  if (tRoomData.getAt(#owner) = tUserName) then
    me.showNewUserHelpItems()
  end if
  getThread("infofeed").getComponent().registerButtonCallback(#next, #nextInfofeedItemCallback, me)
  getThread("infofeed").getComponent().registerButtonCallback(#prev, #prevInfofeedItemCallback, me)
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
  unregisterMessage(#create_user, me.getID())
  getThread("infofeed").getComponent().removeButtonCallback(#next, #nextInfofeedItemCallback, me)
  getThread("infofeed").getComponent().registerButtonCallback(#prev, #prevInfofeedItemCallback, me)
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
  if pAskingForSkip or pInviting or pOpenHelps.getPos("own_user") then
    me.postponeHelp(tHelpId)
    return TRUE
  end if
  if (tHelpId = "asktoshowhelp") then
    me.getInterface().showSkipOrNotWindow(tHelpId)
    pAskingForSkip = 1
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
  tInfoFeedHelps = pOpenHelps.duplicate()
  tInfoFeedHelps.deleteOne("own_user")
  tInfoFeedHelps.deleteOne("asktoshowhelp")
  tInfoFeedHelps.deleteOne("chat")
  if (tInfoFeedHelps.count = 1) then
    me.getInterface().hideHighlighters()
    me.getInterface().showHighlighter(tHelpId)
    tKey = me.getHelpItemKeyId(tHelpId)
    if tKey <> 0 then
      tConn = getConnection(getVariable("connection.info.id"))
      tConn.send("MSG_REMOVE_ACCOUNT_HELP_TEXT", [#integer:tKey])
    end if
    if (tHelpId = "achievements") then
      me.handleAchievementsSelection()
    end if
  end if
end

on postponeHelp me, tHelpId 
  tPos = pPostponedHelps.findPos(tHelpId)
  if tPos > 0 then
    return TRUE
  end if
  pPostponedHelps.add(tHelpId)
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
  me.getInterface().showInvitationStatusWindow(#search)
end

on invitingCompleted me, tAcceptCount 
  pInviting = 0
  if (tAcceptCount = 0) then
    tstate = #failure
  else
    tstate = #success
  end if
  me.getInterface().showInvitationStatusWindow(tstate)
  unregisterMessage(#create_user, me.getID())
end

on invitationExists me 
  executeMessage(#alert, "invitation_exists")
end

on getGuideCount me 
  return(pGuidesFoundCount)
end

on guideFound me, tAccountID 
  pGuidesFoundCount = (pGuidesFoundCount + 1)
  pGuidelist.add(tAccountID)
  registerMessage(#create_user, me.getID(), #createUserListerner)
end

on selectUserInRoom me, tUserObj 
  tRoomInterface = getThread(#room).getInterface()
  tUserObj.select()
  tRoomInterface.setSelectedObject(tUserObj.getID())
  tRoomInterface.showArrowHiliter(tUserObj.getID())
  tSelectedType = tUserObj.getClass()
  executeMessage(#showObjectInfo, tSelectedType)
  executeMessage(#updateInfostandAvatar)
end

on createUserListerner me, tName, tID 
  tRoomComponent = getThread("room").getComponent()
  tUserObj = tRoomComponent.getUserObject(tID)
  if (tUserObj = 0) then
    return()
  end if
  tWebID = value(tUserObj.getWebID())
  i = 1
  repeat while i <= pGuidelist.count
    tUserID = pGuidelist.getAt(i)
    if (tWebID = tUserID) then
      me.getInterface().showGuideArrivedBubble(tUserID, pAutoSelectGuide)
      pGuidelist.deleteOne(tUserID)
      if pAutoSelectGuide then
        me.selectUserInRoom(tUserObj)
        pAutoSelectGuide = 0
      end if
      next repeat
    end if
    i = (i + 1)
  end repeat
end

on nextInfofeedItemCallback me, tItemObj 
  me.getInterface().hideHighlighters()
  tHelpId = tItemObj.getData().getaProp(#helpId)
  if not voidp(tHelpId) then
    me.setHelpItemClosed(tHelpId)
  end if
  tItemPointer = getThread("infofeed").getInterface().getItemPointer()
  tID = getThread("infofeed").getComponent().getNextFrom(tItemPointer)
  tNextItem = getThread("infofeed").getComponent().getItem(tID)
  tHelpId = tNextItem.getData().getaProp(#helpId)
  if voidp(tHelpId) then
    return()
  end if
  me.setHelpItemClosed(tHelpId)
  me.getInterface().showHighlighter(tHelpId)
  if (tHelpId = "achievements") then
    me.handleAchievementsSelection()
  end if
  tLastItem = getThread("infofeed").getComponent().getItemCount()
  if (getThread("infofeed").getComponent().getItemPos(tID) = tLastItem) then
    me.setTutorialFinished()
  end if
end

on prevInfofeedItemCallback me, tItemObj 
  me.getInterface().hideHighlighters()
  tItemPointer = getThread("infofeed").getInterface().getItemPointer()
  tID = getThread("infofeed").getComponent().getPreviousFrom(tItemPointer)
  tPrevItem = getThread("infofeed").getComponent().getItem(tID)
  tHelpId = tPrevItem.getData().getaProp(#helpId)
  if voidp(tHelpId) then
    return()
  end if
  me.getInterface().showHighlighter(tHelpId)
  if (tHelpId = "achievements") then
    me.handleAchievementsSelection()
  end if
end

on handleAchievementsSelection me 
  tRoomComponent = getThread("room").getComponent()
  tUserObj = tRoomComponent.getUserObject(getObject(#session).GET("own_user_id"))
  if objectp(tUserObj) then
    me.selectUserInRoom(tUserObj)
  end if
end

on setAskingSkip me, tVal 
  pAskingForSkip = tVal
  if (tVal = 0) then
    me.setHelpItemClosed("asktoshowhelp")
  end if
end

on setTutorialFinished me 
  if (pTutorialStructName = "NUH.finish") then
    return()
  end if
  pPostponedHelps = []
  if pAskingForSkip then
    me.setHelpItemClosed("asktoshowhelp")
    pAskingForSkip = 0
  end if
  tKeys = getStructVariable(pTutorialStructName)
  i = 1
  repeat while i <= tKeys.count
    me.setHelpItemClosed(tKeys.getPropAt(i))
    tTimeoutID = "NUH_help_" & tKeys.getPropAt(i)
    if timeoutExists(tTimeoutID) then
      removeTimeout(tTimeoutID)
    end if
    i = (1 + i)
  end repeat
  pTutorialStructName = "NUH.finish"
  pHelpStatusData = [:]
  tKeys = getStructVariable(pTutorialStructName)
  i = 1
  repeat while i <= tKeys.count
    pHelpStatusData.addProp(tKeys.getPropAt(i), 1)
    i = (1 + i)
  end repeat
  me.showNewUserHelpItems()
end
