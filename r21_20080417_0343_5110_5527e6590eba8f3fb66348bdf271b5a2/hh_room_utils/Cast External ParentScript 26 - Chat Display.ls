property pFreeChatItemList, pReservedChatItemList, pMarginFromScreenTop, pBalloonsVisible, pAutoScrollOn, pAutoScrollAmountPx, pAutoScrolledNow, pScrollDelayTime, pScrollDelayStartTime, pMessageBuffer, pUserCache, pChatItemCount, pMaximumChatBufferSize, pSpeedUpChatBufferLim, pForceScrollAmount, pScrollSpdMultiplier

on construct me
  pFreeChatItemList = []
  pReservedChatItemList = []
  pMarginFromScreenTop = 108
  pBalloonsVisible = 1
  pAutoScrollAmountPx = 18
  pAutoScrollOn = 0
  pScrollDelayTime = getVariableValue("chat.scroll.delay", 5000)
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
  registerMessage(#showObjectMessage, me.getID(), #insertObjectMessage)
end

on deconstruct me
  me.clearAll()
  unregisterMessage(#enterRoom, me.getID())
  unregisterMessage(#leaveRoom, me.getID())
  registerMessage(#changeRoom, me.getID())
  unregisterMessage(#showObjectMessage, me.getID())
end

on startUpdate me
  receiveUpdate(me.getID())
end

on clearAll me
  pMessageBuffer = []
  repeat with tItem in pReservedChatItemList
    tItem.deconstruct()
  end repeat
  pReservedChatItemList = []
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
  call(#showBalloon, pReservedChatItemList, tVisible)
  call(#showBalloon, pFreeChatItemList, tVisible)
end

on insertObjectMessage me, tMsgProps
  me.insertChatMessage(tMsgProps[#command], tMsgProps[#id], tMsgProps[#message])
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
  if voidp(tloc) then
    return 0
  end if
  tloc = point(tloc[1], pMarginFromScreenTop)
  tChatItem = me.getChatItem(tMessage[#mode], tMessage[#id], tMessage[#message])
  if tChatItem = 0 then
    return 0
  end if
  tChatItem.setLocation(tloc)
end

on getChatItem me, tChatMode, tObjID, tChatMessage
  if pFreeChatItemList.count = 0 then
    tChatItem = createObject(#random, "Chat Bubble Normal")
    pChatItemCount = pChatItemCount + 1
    tItemID = pChatItemCount
  else
    tChatItem = pFreeChatItemList[1]
    pFreeChatItemList.deleteAt(1)
    tItemID = tChatItem.getItemId()
  end if
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
  end if
  tChatItem.defineBalloon(tChatMode, tBalloonColor, tUserName, tChatMessage, tItemID, tUserImg, tUserID, tSourceLoc)
  pReservedChatItemList.add(tChatItem)
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
  repeat with tItemNo = 1 to pReservedChatItemList.count
    tItem = pReservedChatItemList[tItemNo]
    tLocV = tItem.moveVerticallyBy(tAmount)
    if tLocV < -50 then
      pReservedChatItemList.deleteAt(tItemNo)
      pFreeChatItemList.add(tItem)
    end if
  end repeat
end

on getLowestBalloonLocV me
  tLowestPoint = 0
  repeat with tItem in pReservedChatItemList
    tItemLoc = tItem.getLowPoint()
    if tItemLoc > tLowestPoint then
      tLowestPoint = tItemLoc
    end if
  end repeat
  return tLowestPoint
end

on update me
  if (pReservedChatItemList.count = 0) and (pMessageBuffer.count = 0) then
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
      if pReservedChatItemList.count > 0 then
        if me.getLowestBalloonLocV() <= (pMarginFromScreenTop - pAutoScrollAmountPx) then
          tSpaceAvailable = 1
        else
          tSpaceAvailable = 0
        end if
      else
        tSpaceAvailable = 1
      end if
      if not tSpaceAvailable and (pMessageBuffer.count > pMaximumChatBufferSize) then
        repeat with k = 1 to pMessageBuffer.count - pMaximumChatBufferSize
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
