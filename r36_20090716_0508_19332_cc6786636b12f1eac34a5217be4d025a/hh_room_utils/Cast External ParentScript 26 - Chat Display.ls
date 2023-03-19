property pActiveItemList, pFreeChatItemList, pMarginFromScreenTop, pBalloonsVisible, pAutoScrollOn, pAutoScrollAmountPx, pAutoScrolledNow, pScrollDelayTime, pScrollDelayStartTime, pMessageBuffer, pUserCache, pChatItemCount, pMaximumChatBufferSize, pSpeedUpChatBufferLim, pForceScrollAmount, pScrollSpdMultiplier

on construct me
  pActiveItemList = []
  pFreeChatItemList = []
  pMarginFromScreenTop = 108
  pBalloonsVisible = 1
  pAutoScrollAmountPx = 18
  pAutoScrollOn = 0
  pScrollDelayTime = getIntVariable("chat.scroll.delay", 5000)
  pAutoScrolledNow = 0
  pChatItemCount = 0
  pMaximumChatBufferSize = 7
  if variableExists("chat.buffersize.maximum") then
    getVariableValue("chat.buffersize.maximum")
  end if
  pSpeedUpChatBufferLim = 2
  if variableExists("chat.buffersize.speedup") then
    getVariableValue("chat.buffersize.speedup")
  end if
  pScrollSpdMultiplier = 1.0
  pMessageBuffer = []
  pUserCache = []
  registerMessage(#enterRoom, me.getID(), #startUpdate)
  registerMessage(#leaveRoom, me.getID(), #clearAll)
  registerMessage(#changeRoom, me.getID(), #clearAll)
  registerMessage(#startChatDisplay, me.getID(), #startUpdate)
  registerMessage(#showChatMessage, me.getID(), #insertChatMessage)
  registerMessage(#showObjectMessage, me.getID(), #insertObjectMessage)
  registerMessage(#showCustomMessage, me.getID(), #insertCustomMessage)
  registerMessage(#showRespectInRoom, me.getID(), #insertRespectMessage)
end

on deconstruct me
  me.clearAll()
  unregisterMessage(#enterRoom, me.getID())
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#changeRoom, me.getID())
  unregisterMessage(#startChatDisplay, me.getID())
  unregisterMessage(#showChatMessage, me.getID())
  unregisterMessage(#showObjectMessage, me.getID())
  unregisterMessage(#showCustomMessage, me.getID())
  unregisterMessage(#showRespectInRoom, me.getID())
end

on startUpdate me
  receiveUpdate(me.getID())
end

on clearAll me
  pMessageBuffer = []
  repeat with tItem in pActiveItemList
    tItem.deconstruct()
  end repeat
  pActiveItemList = []
  repeat with tItem in pFreeChatItemList
    tItem.deconstruct()
  end repeat
  pFreeChatItemList = []
  me.clearUserCache()
  pChatItemCount = 0
end

on showBalloons me, tVisible
  if voidp(tVisible) then
    tVisible = 1
  end if
  pShowBalloons = tVisible
  call(#showBalloon, pActiveItemList, tVisible)
  call(#showBalloon, pFreeChatItemList, tVisible)
end

on insertObjectMessage me, tMsgProps
  me.insertChatMessage(tMsgProps[#command], tMsgProps[#id], tMsgProps[#message])
end

on insertCustomMessage me, tMsgProps
  if tMsgProps.findPos(#mode) = 0 then
    tMsgProps.setaProp(#mode, "CUSTOM")
  end if
  pMessageBuffer.add(tMsgProps)
end

on insertRespectMessage me, tUserID
  tUserObj = getThread(#room).getComponent().getUserObjectByWebID(tUserID)
  if not tUserObj then
    return 0
  end if
  tUserName = tUserObj.getInfo().getaProp(#name)
  tMessage = getText("chat.respect.bubble.message", "%username% was respected")
  tMessage = replaceChunks(tMessage, "%username%", tUserName)
  tMsgProps = [#mode: "CUSTOM", #message: tMessage, #class: "Chat Bubble Info Respect", #color: rgb("#cc3d13"), #loc: tUserObj.getScrLocation()]
  pMessageBuffer.add(tMsgProps)
end

on insertChatMessage me, tChatMode, tID, tChatMessage
  case tChatMode of
    "CHAT", "SHOUT", "WHISPER", "OBJECT":
      pMessageBuffer.add([#mode: tChatMode, #id: tID, #message: tChatMessage])
    "UNHEARD":
      me.showChatItemUnheard(tID)
  end case
end

on showNextChatMessage me
  if pMessageBuffer.count = 0 then
    return 0
  end if
  tMessage = pMessageBuffer[1]
  pMessageBuffer.deleteAt(1)
  if tMessage.findPos(#loc) > 0 then
    tloc = tMessage.getaProp(#loc)
  else
    if tMessage.findPos(#id) > 0 then
      if tMessage[#mode] = "OBJECT" then
        tObj = getThread(#room).getComponent().getActiveObject(tMessage[#id])
        if not tObj = 0 then
          tloc = tObj.getScreenLocation()
        end if
      else
        tObj = getThread(#room).getComponent().getUserObject(tMessage[#id])
        if not tObj = 0 then
          tloc = tObj.getPartLocation("hd")
        end if
      end if
    end if
  end if
  if voidp(tloc) then
    return 0
  end if
  tloc = point(tloc[1], pMarginFromScreenTop)
  tMode = tMessage.getaProp(#mode)
  case tMode of
    "CUSTOM":
      tChatItem = me.getCustomItem(tMessage)
    otherwise:
      tChatItem = me.getChatItem(tMessage[#mode], tMessage[#id], tMessage[#message])
  end case
  if tChatItem = 0 then
    return 0
  end if
  tChatItem.setLocation(tloc)
end

on getChatItem me, tChatMode, tObjID, tChatMessage
  tUserID = VOID
  if tChatMode = "OBJECT" then
    tObj = getThread(#room).getComponent().getActiveObject(tObjID)
    if not tObj then
      return 0
    end if
    tBalloonColor = rgb(232, 177, 55)
    tObjInfo = tObj.getInfo()
    tUserName = tObjInfo[#name]
    tUserImg = VOID
    tSourceLoc = tObj.getScreenLocation()
  else
    tUserObj = getThread(#room).getComponent().getUserObject(tObjID)
    if not tUserObj then
      return 0
    end if
    if tUserObj.getClass() = "pet" then
      tBalloonColor = tUserObj.getPartColor("hd")
      if ilk(tBalloonColor) <> #color then
        tBalloonColor = rgb(232, 177, 55)
      end if
      tUserName = tUserObj.getInfo().getaProp(#name)
      tUserImg = VOID
    else
      tBalloonColor = tUserObj.getPartColor("ch")
      if ilk(tBalloonColor) <> #color then
        tBalloonColor = rgb(232, 177, 55)
      end if
      tUserName = tUserObj.getInfo().getaProp(#name)
      if objectExists("Figure_Preview") then
        tPartList = tUserObj.pPartListSubSet[#head]
        tFigure = tUserObj.getRawFigure()
        tUserImg = getObject("Figure_Preview").getHumanPartImg(tPartList, tFigure, 2, "sh")
      end if
      tUserID = tObjID
    end if
    tSourceLoc = tUserObj.getScrLocation()
    tFXState = VOID
    if tUserObj.handler(#getCurrentEffectState) then
      tFXState = tUserObj.getCurrentEffectState()
    end if
    if not (tFXState = 0) then
      if tFXState.getaProp(16) then
        tChatItem = createObject("Sing-" & getUniqueID(), "Chat Bubble Sing")
        pChatItemCount = pChatItemCount + 1
        tItemID = pChatItemCount
      end if
    end if
  end if
  if not objectp(tChatItem) then
    if pFreeChatItemList.count = 0 then
      tChatItem = createObject(#random, "Chat Bubble Normal")
      pChatItemCount = pChatItemCount + 1
      tItemID = pChatItemCount
    else
      tChatItem = pFreeChatItemList[1]
      pFreeChatItemList.deleteAt(1)
      tItemID = tChatItem.getItemId()
    end if
  end if
  tChatItem.defineBalloon(tChatMode, tBalloonColor, tUserName, tChatMessage, tItemID, tUserImg, tUserID, tSourceLoc)
  pActiveItemList.add(tChatItem)
  return tChatItem
end

on getCustomItem me, tMessage
  if tMessage.findPos(#class) > 0 then
    tClass = ["Chat Bubble Info Basic", tMessage.getaProp(#class)]
  else
    tClass = "Chat Bubble Info Basic"
  end if
  tChatItem = createObject(#random, tClass)
  if tChatItem = 0 then
    return 0
  end if
  pChatItemCount = pChatItemCount + 1
  tItemID = pChatItemCount
  tMode = tMessage[#mode]
  tSourceLoc = tMessage.getaProp(#loc)
  tBalloonColor = tMessage.getaProp(#color)
  tText = tMessage.getaProp(#message)
  tChatItem.defineBalloon(tMode, tBalloonColor, tText, tItemID, tSourceLoc)
  pActiveItemList.add(tChatItem)
  return tChatItem
end

on clearUserCache me
  repeat with tUserName in pUserCache
    tUserMemName = "chat_item_user_" & tUserName
    if memberExists(tUserMemName) then
      removeMember(tUserMemName)
    end if
  end repeat
end

on showChatItemUnheard me, tRoomUserId
  tChatItem = createObject(#random, "Chat Bubble Unheard")
  tChatItem.define(tRoomUserId)
end

on moveAllItemsUpBy me, tAmount
  tItemNo = 1
  repeat while tItemNo <= pActiveItemList.count
    tItem = pActiveItemList[tItemNo]
    tLocV = tItem.moveVerticallyBy(tAmount)
    if tLocV < -50 then
      pActiveItemList.deleteAt(tItemNo)
      if tItem.handler(#getType) then
        if tItem.getType() = "NORMAL" then
          pFreeChatItemList.add(tItem)
        else
          tItem.deconstruct()
        end if
      else
        tItem.deconstruct()
      end if
      next repeat
    end if
    tItemNo = tItemNo + 1
  end repeat
end

on getLowestBalloonLocV me
  tLowestPoint = 0
  repeat with tItem in pActiveItemList
    tItemLoc = tItem.getLowPoint()
    if tItemLoc > tLowestPoint then
      tLowestPoint = tItemLoc
    end if
  end repeat
  return tLowestPoint
end

on update me
  if (pActiveItemList.count = 0) and (pMessageBuffer.count = 0) then
    return 0
  end if
  if pMessageBuffer.count > pSpeedUpChatBufferLim then
    pScrollSpdMultiplier = 1.0 + (float(pMessageBuffer.count - pSpeedUpChatBufferLim) * 0.5)
  else
    pScrollSpdMultiplier = 1.0
  end if
  if pAutoScrollOn then
    tOffV = integer(3.0 * pScrollSpdMultiplier)
    if (tOffV + pAutoScrolledNow) > pAutoScrollAmountPx then
      tOffV = pAutoScrollAmountPx - pAutoScrolledNow
    end if
    pAutoScrolledNow = pAutoScrolledNow + tOffV
    me.moveAllItemsUpBy(-1 * tOffV)
    if pAutoScrolledNow >= pAutoScrollAmountPx then
      pAutoScrolledNow = 0
      pAutoScrollOn = 0
      pScrollDelayStartTime = the milliSeconds
    end if
  else
    if pMessageBuffer.count > 0 then
      if pActiveItemList.count > 0 then
        if me.getLowestBalloonLocV() <= (pMarginFromScreenTop - pAutoScrollAmountPx) then
          tSpaceAvailable = 1
        else
          tSpaceAvailable = 0
        end if
      else
        tSpaceAvailable = 1
      end if
      if not tSpaceAvailable and (pMessageBuffer.count > pMaximumChatBufferSize) then
        tCount = pMessageBuffer.count
        repeat with k = 1 to tCount - pMaximumChatBufferSize
          me.moveAllItemsUpBy(-1 * pAutoScrollAmountPx)
          if k <> 1 then
            me.showNextChatMessage()
          end if
        end repeat
        tSpaceAvailable = 1
      end if
      if tSpaceAvailable then
        pAutoScrollOn = 0
        pScrollDelayStartTime = the milliSeconds
        me.showNextChatMessage()
      else
        pAutoScrollOn = 1
      end if
    else
      tMillis = the milliSeconds
      tTimeDiff = tMillis - pScrollDelayStartTime
      if tTimeDiff >= pScrollDelayTime then
        pAutoScrollOn = 1
      end if
    end if
  end if
end
