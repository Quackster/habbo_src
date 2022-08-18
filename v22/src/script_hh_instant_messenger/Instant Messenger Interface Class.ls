property pWindowID, pTabsObj, pChatRenderers, pActiveChatID, pNames, pScaleEventAgentID, pOrigLocH, pOrigHeight, pScale, pMinHeight, pCachedChatIDs, pCacheSize, pEntryBuffer, pRenderTimeoutID, pBatchSize, pBatchInterval, pFriends, pState

on construct me
  pWindowID = "Instant Messenger"
  pTabsObj = createObject(#temp, "IM Tabs Class")
  pChatRenderers = [:]
  pNames = [:]
  pCachedChatIDs = []
  pMinHeight = getIntVariable("im.window.height.min")
  pBatchSize = getIntVariable("im.batch.size")
  pBatchInterval = getIntVariable("im.batch.interval")
  pCacheSize = getIntVariable("im.cached.chats")
  pScaleEventAgentID = getUniqueID()
  pRenderTimeoutID = #IMRenderTimeout
  me.setState(#inactive)
  createObject(pScaleEventAgentID, getClassVariable("event.agent.class"))
  registerMessage(#toggle_im, me.getID(), #toggleIMWindow)
  return 1
end

on deconstruct me
  if objectExists(pScaleEventAgentID) then
    removeObject(pScaleEventAgentID)
  end if
  unregisterMessage(#toggle_im, me.getID())
  return 1
end

on createIMWindow me
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
  end if
  tLocH = (the stage.rect.width - getIntVariable("im.window.margin.right"))
  tLocV = getIntVariable("im.window.margin.top")
  createWindow(pWindowID, "instant_message.window", tLocH, tLocV)
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
  if (pState = #inactive) then
    return 0
  end if
  if not windowExists(pWindowID) then
    return me.openIMWindow()
  end if
  tWnd = getWindow(pWindowID)
  if tWnd.getProperty(#visible) then
    me.closeIMWindow()
  else
    me.openIMWindow()
  end if
end

on addChat me, tChatID, tFriend
  me.getChatRenderer(tChatID)
  pTabsObj.addTab(tChatID)
  tName = tFriend.getaProp(#name)
  pNames.setaProp(tChatID, tName)
  if (pChatRenderers.count = 1) then
    me.activateChat(tChatID)
    pTabsObj.showTab(tChatID)
  end if
  me.updateChat(tChatID, tFriend)
end

on updateChat me, tChatID, tFriend
  tFigure = tFriend.getaProp(#figure)
  pTabsObj.updateHeadImage(tChatID, tFigure)
  if not windowExists(pWindowID) then
    return 0
  end if
  tWnd = getWindow(pWindowID)
  tCanFollow = tFriend.getaProp(#canfollow)
  if tCanFollow then
    tWnd.getElement("button.follow").show()
  else
    tWnd.getElement("button.follow").hide()
  end if
  me.updateInterface()
end

on removeChat me, tChatID
  tPos = pChatRenderers.findPos(tChatID)
  pChatRenderers.deleteProp(tChatID)
  pTabsObj.removeTab(tChatID)
  tCachePos = pCachedChatIDs.getPos(tChatID)
  if (tCachePos > 0) then
    pCachedChatIDs.deleteAt(tCachePos)
  end if
  if (pChatRenderers.count = 0) then
    me.setState(#inactive)
    me.closeIMWindow()
    return 1
  end if
  if (tPos > pChatRenderers.count) then
    tPos = pChatRenderers.count
  end if
  me.activateChat(pChatRenderers.getPropAt(tPos))
  return 1
end

on removeAllChats me
  repeat while (pChatRenderers.count > 0)
    tChatID = pChatRenderers.getPropAt(1)
    me.removeChat(tChatID)
  end repeat
  me.closeIMWindow()
end

on activateChat me, tChatID
  if not tChatID then
    return 0
  end if
  case tChatID of
    #left:
      pTabsObj.scrollLeft()
    #right:
      pTabsObj.scrollRight()
    otherwise:
      pActiveChatID = tChatID
      pTabsObj.activateTab(tChatID)
      if (pCachedChatIDs.getPos(tChatID) = 0) then
        me.startRendering(tChatID)
        if (pCachedChatIDs.count = pCacheSize) then
          tRemoveID = pCachedChatIDs[1]
          pCachedChatIDs.deleteAt(1)
          me.getChatRenderer(tRemoveID).clearImage()
        end if
        pCachedChatIDs.add(tChatID)
      else
        tPos = pCachedChatIDs.getPos(tChatID)
        pCachedChatIDs.deleteAt(tPos)
        pCachedChatIDs.add(tChatID)
      end if
  end case
  me.updateInterface()
end

on startRendering me, tChatID
  pEntryBuffer = me.getComponent().getChat(tChatID).duplicate()
  if timeoutExists(pRenderTimeoutID) then
    removeTimeout(pRenderTimeoutID)
  end if
  tChatRenderer = me.getChatRenderer(tChatID)
  tChatRenderer.clearImage()
  createTimeout(pRenderTimeoutID, pBatchInterval, #startBatchRender, me.getID(), tChatID, 0)
  me.startBatchRender(tChatID)
end

on startBatchRender me, tChatID
  if (pEntryBuffer.count = 0) then
    me.stopBatchRender()
    return 1
  end if
  repeat with i = 1 to pBatchSize
    tBufferSize = pEntryBuffer.count
    tEntry = pEntryBuffer[tBufferSize]
    tChatRenderer = me.getChatRenderer(tChatID)
    tSuccess = tChatRenderer.renderChatEntry(tEntry, #start)
    pEntryBuffer.deleteAt(tBufferSize)
    if ((tBufferSize = 1) or not tSuccess) then
      me.stopBatchRender()
      exit repeat
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
  if (pCachedChatIDs.getPos(tChatID) > 0) then
    tChatRenderer = me.getChatRenderer(tChatID)
    tChatRenderer.renderChatEntry(tEntry)
  end if
  ttype = tEntry.getaProp(#userID)
  if ((ttype <> #notification) and (ttype <> #error)) then
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
  me.updateInterface()
end

on getChatRenderer me, tChatID
  tChatRenderer = pChatRenderers.getaProp(tChatID)
  if voidp(tChatRenderer) then
    tChatRenderer = createObject(#temp, "IM Chat Renderer Class")
    pChatRenderers.setaProp(tChatID, tChatRenderer)
  end if
  return tChatRenderer
end

on updateInterface me
  if not pActiveChatID then
    return 0
  end if
  if not windowExists(pWindowID) then
    return 0
  end if
  tWnd = getWindow(pWindowID)
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
    return 1
  end if
  tWnd = getWindow(pWindowID)
  tLocOffset = (the mouseV - pOrigLocH)
  if ((tLocOffset + pOrigHeight) < pMinHeight) then
    tLocOffset = (pMinHeight - pOrigHeight)
  end if
  tHeightOffset = (tWnd.getProperty(#height) - pOrigHeight)
  tWnd.resizeBy(0, (tLocOffset - tHeightOffset))
  me.scrollBottom()
end

on scrollBottom me
  tWnd = getWindow(pWindowID)
  tScroll = tWnd.getElement("chat.scroll")
  tScroll.setScrollOffset(the maxinteger)
end

on setState me, tstate
  pState = tstate
  executeMessage(#IMStateChanged)
end

on getState me
  return pState
end

on eventProcIM me, tEvent, tElemID, tParam
  if ((tEvent = #keyDown) and (tElemID = "chat.input")) then
    if ((the keyCode = 36) or (the keyCode = 76)) then
      tWnd = getWindow(pWindowID)
      tInput = tWnd.getElement("chat.input")
      tText = tInput.getText()
      if (tText <> EMPTY) then
        me.getComponent().sendMessage(pActiveChatID, tText)
      end if
      tInput.setText(EMPTY)
      return 1
    end if
    return 0
  end if
  if ((tEvent = #mouseDown) and (tElemID = "button.scale")) then
    me.startScaling()
    return 1
  end if
  if (tEvent <> #mouseUp) then
    return 1
  end if
  case tElemID of
    "button.close.window":
      me.getComponent().removeAllChats()
    "button.minimize.window":
      me.closeIMWindow()
    "button.close.chat":
      me.getComponent().removeChat(pActiveChatID)
    "tabs":
      tChatID = pTabsObj.getIdAt(tParam)
      me.activateChat(tChatID)
    "button.follow":
      tConn = getConnection(getVariable("connection.info.id"))
      tConn.send("FOLLOW_FRIEND", [#integer: integer(pActiveChatID)])
    "button.minimail":
      if variableExists("link.format.mailpage") then
        tID = string(pActiveChatID)
        tDestURL = replaceChunks(getVariable("link.format.mailpage"), "%recipientid%", tID)
        openNetPage(tDestURL)
      end if
  end case
end
