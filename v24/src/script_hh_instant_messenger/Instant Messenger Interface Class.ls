property pScaleEventAgentID, pFollowFlashTimeoutID, pRenderTimeoutID, pWindowID, pChatRenderers, pTabsObj, pNames, pCachedChatIDs, pCacheSize, pFollowFlashList, pFollowFlashState, pBatchInterval, pEntryBuffer, pBatchSize, pActiveChatID, pView, pScale, pOrigLocH, pOrigHeight, pMinHeight, pState, pInvitationWindowID

on construct me 
  pWindowID = "Instant Messenger"
  pInvitationWindowID = "Friend Invitation Window"
  pTabsObj = createObject(#temp, "IM Tabs Class")
  pChatRenderers = [:]
  pNames = [:]
  pCachedChatIDs = []
  pFollowFlashList = []
  pFollowFlashTimeoutID = "Flash Follow Button Timeout"
  pMinHeight = getIntVariable("im.window.height.min")
  pBatchSize = getIntVariable("im.batch.size")
  pBatchInterval = getIntVariable("im.batch.interval")
  pCacheSize = getIntVariable("im.cached.chats")
  pScaleEventAgentID = getUniqueID()
  pRenderTimeoutID = #IMRenderTimeout
  me.setState(#Active)
  createObject(pScaleEventAgentID, getClassVariable("event.agent.class"))
  registerMessage(#toggle_im, me.getID(), #toggleIMWindow)
  registerMessage(#gamesystem_constructed, me.getID(), #closeIMWindow)
  return(1)
end

on deconstruct me 
  if objectExists(pScaleEventAgentID) then
    removeObject(pScaleEventAgentID)
  end if
  if timeoutExists(pFollowFlashTimeoutID) then
    removeTimeout(pFollowFlashTimeoutID)
  end if
  if timeoutExists(pRenderTimeoutID) then
    removeTimeout(pRenderTimeoutID)
  end if
  unregisterMessage(#toggle_im, me.getID())
  unregisterMessage(#gamesystem_constructed, me.getID())
  return(1)
end

on createIMWindow me 
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
  end if
  tLocH = rect.width - getIntVariable("im.window.margin.right")
  tLocV = getIntVariable("im.window.margin.top")
  createWindow(pWindowID, "instant_message.window", tLocH, tLocV)
  pView = #normal
  tWnd = getWindow(pWindowID)
  tWnd.registerProcedure(#eventProcIM, me.getID(), #keyDown)
  tWnd.registerProcedure(#eventProcIM, me.getID(), #mouseUp)
  tWnd.registerProcedure(#eventProcIM, me.getID(), #mouseDown)
end

on openIMWindow me 
  if not windowExists(pWindowID) then
    me.createIMWindow()
  else
    tWnd = getWindow(pWindowID)
    tWnd.show()
    activateWindow(pWindowID)
  end if
  if pChatRenderers.count = 0 then
    me.ChangeWindowView(#empty)
  end if
  me.updateInterface()
  me.setState(#Active)
end

on closeIMWindow me 
  if windowExists(pWindowID) then
    tWnd = getWindow(pWindowID)
    if tWnd.elementExists("chat.input") then
      tWnd.getElement("chat.input").setFocus(0)
    end if
    tWnd.hide()
  end if
end

on toggleIMWindow me 
  if not windowExists(pWindowID) then
    return(me.openIMWindow())
  end if
  tWnd = getWindow(pWindowID)
  if tWnd.getProperty(#visible) then
    me.closeIMWindow()
  else
    me.openIMWindow()
  end if
end

on addChat me, tChatID, tFriend, tDontPlaySound 
  me.getChatRenderer(tChatID)
  if voidp(tFriend) then
    tFriend = me.getComponent().getFriend(tChatID)
  end if
  if voidp(tFriend) then
    return(0)
  end if
  pTabsObj.addTab(tChatID)
  if not tDontPlaySound then
    tSoundMemName = getVariable("im.new.tab.sound")
    tVolume = getIntVariable("im.sound.volume", 255)
    playSound(tSoundMemName, #cut, [#loopCount:1, #infiniteloop:0, #volume:tVolume])
  end if
  tName = tFriend.getaProp(#name)
  pNames.setaProp(tChatID, tName)
  if pChatRenderers.count = 1 then
    me.activateChat(tChatID)
    pTabsObj.showTab(tChatID)
  end if
  me.updateInterface()
  return(1)
end

on removeChat me, tChatID 
  tPos = pChatRenderers.findPos(tChatID)
  if voidp(tPos) then
    return(0)
  end if
  pActiveChatID = 0
  pChatRenderers.deleteProp(tChatID)
  pTabsObj.removeTab(tChatID)
  tCachePos = pCachedChatIDs.getPos(tChatID)
  if tCachePos > 0 then
    pCachedChatIDs.deleteAt(tCachePos)
  end if
  if pChatRenderers.count = 0 then
    me.ChangeWindowView(#empty)
    return(1)
  end if
  if tPos > pChatRenderers.count then
    tPos = pChatRenderers.count
  end if
  me.activateChat(pChatRenderers.getPropAt(tPos))
  return(1)
end

on removeAllChats me 
  repeat while pChatRenderers.count > 0
    tChatID = pChatRenderers.getPropAt(1)
    me.removeChat(tChatID)
  end repeat
  me.closeIMWindow()
end

on activateChat me, tChatID 
  if not tChatID then
    return(0)
  end if
  me.ChangeWindowView(#normal)
  if tChatID = #left then
    pTabsObj.scrollLeft()
  else
    if tChatID = #right then
      pTabsObj.scrollRight()
    else
      pActiveChatID = tChatID
      pTabsObj.activateTab(tChatID)
      if pCachedChatIDs.getPos(tChatID) = 0 then
        me.startRendering(tChatID)
        if pCachedChatIDs.count = pCacheSize then
          tRemoveID = pCachedChatIDs.getAt(1)
          pCachedChatIDs.deleteAt(1)
          me.getChatRenderer(tRemoveID).clearImage()
        end if
        pCachedChatIDs.add(tChatID)
      else
        tPos = pCachedChatIDs.getPos(tChatID)
        pCachedChatIDs.deleteAt(tPos)
        pCachedChatIDs.add(tChatID)
      end if
    end if
  end if
  tPos = pFollowFlashList.getPos(tChatID)
  if tPos > 0 then
    me.flashFollowButton(#start)
    pFollowFlashList.deleteAt(tPos)
  else
    me.flashFollowButton(#stop)
  end if
  me.updateInterface()
end

on flashFollowButton me, tstate 
  tWnd = getWindow(pWindowID)
  if not tWnd then
    return(0)
  end if
  if not tWnd.elementExists("button.follow") then
    if timeoutExists(pFollowFlashTimeoutID) then
      removeTimeout(pFollowFlashTimeoutID)
    end if
    return(0)
  end if
  tElem = tWnd.getElement("button.follow")
  if tstate = #start then
    if not timeoutExists(pFollowFlashTimeoutID) then
      createTimeout(pFollowFlashTimeoutID, 500, #flashFollowButton, me.getID(), #flash, 20)
    end if
    pFollowFlashState = 0
  else
    if tstate = #stop then
      if timeoutExists(pFollowFlashTimeoutID) then
        removeTimeout(pFollowFlashTimeoutID)
      end if
      tElem.setProperty(#member, "button.follow")
    else
      if tstate = #flash then
        if pFollowFlashState = 1 then
          tElem.setProperty(#member, "button.follow")
        else
          tElem.setProperty(#member, "button.follow.highlight")
        end if
        pFollowFlashState = not pFollowFlashState
      end if
    end if
  end if
end

on startRendering me, tChatID 
  tChat = me.getComponent().getChat(tChatID)
  if not listp(tChat) then
    return(error(me, "Can't render empty chat", #startRendering, #major))
  end if
  pEntryBuffer = tChat.duplicate()
  if timeoutExists(pRenderTimeoutID) then
    removeTimeout(pRenderTimeoutID)
  end if
  tChatRenderer = me.getChatRenderer(tChatID)
  tChatRenderer.clearImage()
  createTimeout(pRenderTimeoutID, pBatchInterval, #startBatchRender, me.getID(), tChatID, 0)
  me.startBatchRender(tChatID)
end

on startBatchRender me, tChatID 
  if not listp(pEntryBuffer) then
    return(error(me, "Can't render empty chat", #startBatchRender, #major))
  end if
  if pEntryBuffer.count = 0 then
    me.stopBatchRender()
    return(1)
  end if
  i = 1
  repeat while i <= pBatchSize
    tBufferSize = pEntryBuffer.count
    tEntry = pEntryBuffer.getAt(tBufferSize)
    tChatRenderer = me.getChatRenderer(tChatID)
    tSuccess = tChatRenderer.renderChatEntry(tEntry, #start)
    pEntryBuffer.deleteAt(tBufferSize)
    if tBufferSize = 1 or not tSuccess then
      me.stopBatchRender()
    else
      i = 1 + i
    end if
  end repeat
  me.updateInterface()
end

on stopBatchRender me 
  if timeoutExists(pRenderTimeoutID) then
    removeTimeout(pRenderTimeoutID)
  end if
end

on addMessage me, tChatID, tEntry 
  if voidp(pChatRenderers.findPos(tChatID)) then
    me.addChat(tChatID)
  else
    if pCachedChatIDs.getPos(tChatID) > 0 then
      tChatRenderer = me.getChatRenderer(tChatID)
      tChatRenderer.renderChatEntry(tEntry)
    end if
  end if
  ttype = tEntry.getaProp(#type)
  if ttype = #message or ttype = #invitation then
    pTabsObj.highlightTab(tChatID)
    if not windowExists(pWindowID) then
      me.setState(#highlighted)
    else
      tWnd = getWindow(pWindowID)
      tVisible = tWnd.getProperty(#visible)
      if not tVisible then
        me.setState(#highlighted)
      end if
    end if
  end if
  if ttype = #invitation then
    if tChatID = pActiveChatID then
      me.flashFollowButton(#start)
    else
      if pFollowFlashList.getPos(tChatID) = 0 then
        pFollowFlashList.add(tChatID)
      end if
    end if
  end if
  me.updateInterface()
end

on getChatRenderer me, tChatID 
  tChatRenderer = pChatRenderers.getaProp(tChatID)
  if voidp(tChatRenderer) then
    tChatRenderer = createObject(#temp, "IM Chat Renderer Class")
    pChatRenderers.setaProp(tChatID, tChatRenderer)
  end if
  return(tChatRenderer)
end

on updateInterface me 
  if pView = #empty then
    return(1)
  end if
  if not pActiveChatID then
    return(0)
  end if
  if not windowExists(pWindowID) then
    return(0)
  end if
  tWnd = getWindow(pWindowID)
  if not tWnd.elementExists("chat.output") then
    return(0)
  end if
  if not tWnd.elementExists("tabs") then
    return(0)
  end if
  if not tWnd.elementExists("tab.title") then
    return(0)
  end if
  if not tWnd.elementExists("button.follow") then
    return(0)
  end if
  tChatRenderer = me.getChatRenderer(pActiveChatID)
  tChatImage = tChatRenderer.getChatImage()
  tChatOutput = tWnd.getElement("chat.output")
  tChatOutput.feedImage(tChatImage)
  tTabImage = pTabsObj.getImage()
  tTabElement = tWnd.getElement("tabs")
  tTabElement.feedImage(tTabImage)
  tTitleElem = tWnd.getElement("tab.title")
  tName = pNames.getaProp(pActiveChatID)
  tTitleElem.setText(string(tName))
  tFriend = me.getComponent().getFriend(pActiveChatID)
  tCanFollow = tFriend.getaProp(#canfollow)
  if tCanFollow then
    tWnd.getElement("button.follow").show()
  else
    tWnd.getElement("button.follow").hide()
  end if
  tFigure = tFriend.getaProp(#figure)
  tGender = tFriend.getaProp(#sex)
  pTabsObj.updateHeadImage(pActiveChatID, tFigure, tGender)
  me.scrollBottom()
end

on startScaling me 
  pScale = 1
  pOrigLocH = the mouseV
  pOrigHeight = getWindow(pWindowID).getProperty(#height)
  receiveUpdate(me.getID())
  tAgent = getObject(pScaleEventAgentID)
  tAgent.registerEvent(me, #mouseUp, #stopScaling)
end

on stopScaling me 
  pScale = 0
  removeUpdate(me.getID())
  tAgent = getObject(pScaleEventAgentID)
  tAgent.unregisterEvent(#mouseUp)
  me.scrollBottom()
end

on update me 
  if not pScale then
    return(1)
  end if
  tWnd = getWindow(pWindowID)
  tLocOffset = the mouseV - pOrigLocH
  if tLocOffset + pOrigHeight < pMinHeight then
    tLocOffset = pMinHeight - pOrigHeight
  end if
  tHeightOffset = tWnd.getProperty(#height) - pOrigHeight
  tWnd.resizeBy(0, tLocOffset - tHeightOffset)
  me.scrollBottom()
end

on scrollBottom me 
  tWnd = getWindow(pWindowID)
  if not tWnd.elementExists("chat.scroll") then
    return(0)
  end if
  tScroll = tWnd.getElement("chat.scroll")
  tScroll.setScrollOffset(the maxinteger)
end

on setState me, tstate 
  pState = tstate
  executeMessage(#IMStateChanged)
end

on getState me 
  return(pState)
end

on showInvitationWindow me, tCount 
  if not windowExists(pInvitationWindowID) then
    createWindow(pInvitationWindowID, "friend_invitation.window")
    tWnd = getWindow(pInvitationWindowID)
    tWnd.registerProcedure(#eventProcInvitation, me.getID(), #mouseUp)
  end if
  activateWindow(pInvitationWindowID)
  tSummaryText = replaceChunks(getText("friend_invitation_summary"), "%count%", tCount)
  tWnd = getWindow(pInvitationWindowID)
  if not tWnd.elementExists("invitation.summary") then
    return(0)
  end if
  tWnd.getElement("invitation.summary").setText(tSummaryText)
end

on closeInvitationWindow me 
  if windowExists(pInvitationWindowID) then
    removeWindow(pInvitationWindowID)
  end if
end

on sendInvitation me 
  tSession = getObject(#session)
  if tSession.GET("lastroom") = "Entry" then
    executeMessage(#alert, getText("friend_invitation_cannot_send"))
    return(1)
  end if
  tWnd = getWindow(pInvitationWindowID)
  if not tWnd.elementExists("invitation.text") then
    return(0)
  end if
  tElem = tWnd.getElement("invitation.text")
  tText = tElem.getText()
  if tText = "" then
    executeMessage(#alert, getText("friend_invitation_empty_alert"))
    return(0)
  end if
  me.getComponent().sendInvitation(tText)
  me.closeInvitationWindow()
end

on ChangeWindowView me, tView 
  if tView = pView then
    return(1)
  end if
  if not windowExists(pWindowID) then
    return(0)
  end if
  tWnd = getWindow(pWindowID)
  if not tWnd.elementExists("button.close.window") then
    return(0)
  end if
  tVisible = tWnd.getProperty(#visible)
  if not tVisible then
    tWnd.show()
  end if
  if tView = #normal then
    tWnd.unmerge()
    tWnd.merge("instant_message.window")
  else
    if tView = #empty then
      tWnd.unmerge()
      tWnd.merge("empty_im.window")
    else
      pView = 0
      return(0)
    end if
  end if
  if not tVisible then
    tWnd.hide()
  end if
  pView = tView
  me.updateInterface()
  return(1)
end

on eventProcIM me, tEvent, tElemID, tParam 
  if tEvent = #keyDown and tElemID = "chat.input" then
    if the keyCode = 36 or the keyCode = 76 then
      tWnd = getWindow(pWindowID)
      tInput = tWnd.getElement("chat.input")
      tText = tInput.getText()
      if tText <> "" then
        me.getComponent().sendMessage(pActiveChatID, tText)
      end if
      tInput.setText("")
      return(1)
    end if
    return(0)
  end if
  if tEvent = #mouseDown and tElemID = "button.scale" then
    me.startScaling()
    return(1)
  end if
  if tEvent <> #mouseUp then
    return(1)
  end if
  if tElemID = "button.close.window" then
    me.closeIMWindow()
  else
    if tElemID = "button.close.chat" then
      me.getComponent().removeChat(pActiveChatID)
    else
      if tElemID = "tabs" then
        tChatID = pTabsObj.getIdAt(tParam)
        me.activateChat(tChatID)
      else
        if tElemID = "button.follow" then
          tConn = getConnection(getVariable("connection.info.id"))
          tConn.send("FOLLOW_FRIEND", [#integer:integer(pActiveChatID)])
        else
          if tElemID = "button.minimail" then
            if variableExists("link.format.mail.compose") then
              tID = string(pActiveChatID)
              tDestURL = replaceChunks(getVariable("link.format.mail.compose"), "%recipientid%", tID)
              executeMessage(#externalLinkClick, the mouseLoc)
              openNetPage(tDestURL)
            end if
          end if
        end if
      end if
    end if
  end if
end

on eventProcInvitation me, tEvent, tElemID, tParam 
  if tElemID = "button.send" then
    me.sendInvitation()
  else
    if tElemID = "button.cancel" then
      me.closeInvitationWindow()
    else
      if tElemID = "button.close.window" then
        me.closeInvitationWindow()
      end if
    end if
  end if
end
