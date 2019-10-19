on construct(me)
  pState = #closed
  pTraderWndID = getText("trading_title", "Safe Trading")
  pAcceptFlagMe = 0
  pAcceptFlagHe = 0
  pItemListMe = []
  pItemListHe = []
  pMyStripItems = []
  pMaxTradeItems = 0
  pItemSlotRect = rect(0, 0, 32, 32)
  pHerSlotCount = 0
  pMySlotProps = []
  pHerSlotProps = []
  pConfirmationWndID = "safetrading_confirmationdialog"
  pIconPlaceholderName = "icon_placeholder"
  pRequiredDownloadsToTrade = []
  pDetailsBubbleId = #trade_item_details
  pProductPreviewObjId = #trade_product_preview
  pPreviewDefaultSize = 50
  return(1)
  exit
end

on deconstruct(me)
  return(me.close())
  exit
end

on startTrade(me, tIdA, tCanTradeA, tIdB, tCanTradeB)
  if not integerp(tIdA) or voidp(tCanTradeA) or not integerp(tIdB) or voidp(tCanTradeB) then
    return(0)
  end if
  if not tCanTradeA and not tCanTradeB then
    executeMessage(#alert, [#id:#trading_disabled_both, #Msg:getText("trading_disabled_both")])
    return(0)
  end if
  if tIdA = getObject(#session).GET("user_user_id") then
    pMyId = tIdA
    pCanTradeMe = tCanTradeA
    pHerId = tIdB
    pCanTradeShe = tCanTradeB
  else
    pMyId = tIdB
    pCanTradeMe = tCanTradeB
    pHerId = tIdA
    pCanTradeShe = tCanTradeA
  end if
  me.open()
  exit
end

on open(me)
  if windowExists(pTraderWndID) then
    return(0)
  end if
  pRequiredDownloadsToTrade = []
  tList = []
  tList.setAt("showDialog", 1)
  executeMessage(#getHotelClosingStatus, tList)
  if tList.getAt("retval") = 1 then
    return(1)
  end if
  getThread(#room).getInterface().cancelObjectMover()
  getThread(#room).getInterface().setProperty(#clickAction, "tradeItem")
  tHerUserObj = getThread(#room).getComponent().getUserObjectByWebID(pHerId)
  if not tHerUserObj then
    return(0)
  end if
  pHerName = tHerUserObj.getName()
  if not createWindow(pTraderWndID, "habbo_basic.window") then
    return(0)
  end if
  tWndObj = getWindow(pTraderWndID)
  if not tWndObj.merge("habbo_trading.window") then
    return(tWndObj.close())
  end if
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcTrading, me.getID())
  tElem = tWndObj.getElement("trading_heoffers_text")
  if tElem <> 0 then
    tElem.setText(pHerName && getText("trading_offers", "offers"))
  end if
  pMaxTradeItems = 0
  repeat while 1
    if not getWindow(pTraderWndID).elementExists("trading_mystuff_" & pMaxTradeItems + 1) then
    else
      pMaxTradeItems = pMaxTradeItems + 1
    end if
  end repeat
  me.clearSlots()
  tWidth = tWndObj.getElement("trading_mystuff_1").getProperty(#width)
  tHeight = tWndObj.getElement("trading_mystuff_1").getProperty(#height)
  pItemSlotRect = rect(0, 0, tWidth, tHeight)
  me.updateTradingDisabledTexts()
  pState = #open
  me.accept()
  return(1)
  exit
end

on updateTradingDisabledTexts(me)
  tWindow = getWindow(pTraderWndID)
  if not tWindow then
    return(0)
  end if
  tElements = []
  tElements.add("trading_lock_my")
  tElements.add("trading_myitems_bg")
  i = 1
  repeat while i <= pMaxTradeItems
    tElements.add("trading_mystuff_" & i)
    tElements.add("trading_mycount_" & i)
    i = 1 + i
  end repeat
  i = 1
  repeat while i <= tElements.count
    if tWindow.elementExists(tElements.getAt(i)) then
      tWindow.getElement(tElements.getAt(i)).setProperty(#visible, pCanTradeMe)
    end if
    i = 1 + i
  end repeat
  if tWindow.elementExists("trading_disabled_my") then
    tWindow.getElement("trading_disabled_my").setProperty(#visible, not pCanTradeMe)
  end if
  tElements = []
  tElements.add("trading_lock_his")
  tElements.add("trading_heritems_bg")
  i = 1
  repeat while i <= pMaxTradeItems
    tElements.add("trading_herstuff_" & i)
    tElements.add("trading_hercount_" & i)
    i = 1 + i
  end repeat
  i = 1
  repeat while i <= tElements.count
    if tWindow.elementExists(tElements.getAt(i)) then
      tWindow.getElement(tElements.getAt(i)).setProperty(#visible, pCanTradeShe)
    end if
    i = 1 + i
  end repeat
  if tWindow.elementExists("trading_disabled_her") then
    tWindow.getElement("trading_disabled_her").setProperty(#visible, not pCanTradeShe)
  end if
  exit
end

on showConfirmationView(me)
  tWindow = getWindow(pTraderWndID)
  if not tWindow then
    return(0)
  end if
  pState = #confirm
  tBold = getStructVariable("struct.font.bold")
  if tWindow.elementExists("trading_instructions_text") then
    tWindow.getElement("trading_instructions_text").setFont(tBold)
  end if
  me.showInfo(getText("trading_confirm_info"))
  if tWindow.elementExists("trading_lock_my") then
    tWindow.getElement("trading_lock_my").setProperty(#blend, 30)
  end if
  if tWindow.elementExists("trading_lock_his") then
    tWindow.getElement("trading_lock_his").setProperty(#blend, 30)
  end if
  pTimeLeft = 3
  if tWindow.elementExists("trading_accept") then
    tWindow.getElement("trading_accept").deactivate()
  end if
  me.updateConfirmButton()
  createTimeout(#trading_button_timeout, 1000, #updateConfirmButton, me.getID(), void(), pTimeLeft + 1)
  tWindow.registerProcedure(#eventProcTradingConfirmation, me.getID(), #mouseUp)
  exit
end

on updateConfirmButton(me)
  tWindow = getWindow(pTraderWndID)
  if not tWindow then
    return(0)
  end if
  if not tWindow.elementExists("trading_accept") then
    return(0)
  end if
  tButton = tWindow.getElement("trading_accept")
  if pTimeLeft > 0 then
    if tButton <> 0 then
      tButton.setText(getText("trading_wait") && pTimeLeft)
    end if
    pTimeLeft = pTimeLeft - 1
  else
    if tButton <> 0 then
      tButton.setText(getText("trading_confirm"))
    end if
    tWindow.getElement("trading_accept").Activate()
  end if
  exit
end

on showWaitingView(me)
  tWindow = getWindow(pTraderWndID)
  if not tWindow then
    return(error(me, "Trade window doesn't exist.", #showConfirmationView, #major))
  end if
  me.showInfo(getText("trading_waiting_info"))
  pState = #wait
  me.updateButtons()
  exit
end

on close(me, tdata)
  if threadExists(#room) then
    tRoomInterface = getThread(#room).getInterface()
    if tRoomInterface <> 0 then
      tRoomInterface.setProperty(#clickAction, "moveHuman")
      tObjMover = tRoomInterface.getObjectMover()
      if tObjMover <> 0 then
        tObjMover.clear()
      end if
    end if
  end if
  if windowExists(pTraderWndID) then
    pAcceptFlagMe = 0
    pAcceptFlagHe = 0
    pItemListMe = []
    pItemListHe = []
    pMyStripItems = []
    pMySlotProps = []
    pHerSlotProps = []
    removeWindow(pTraderWndID)
    removeWindow(pConfirmationWndID)
  end if
  me.removeDetailsBubble()
  pState = #closed
  return(1)
  exit
end

on updateButtons(me)
  tWindow = getWindow(pTraderWndID)
  if not tWindow then
    return(0)
  end if
  tAcceptButton = tWindow.getElement("trading_accept")
  if not tAcceptButton then
    return(0)
  end if
  if me = #closed then
    return(0)
  else
    if me = #open then
      if pAcceptFlagMe then
        tAcceptButton.setText(getText("trading_modify"))
      else
        tAcceptButton.setText(getText("trading_accept"))
      end if
      if pMySlotProps.count = 0 and pHerSlotProps.count = 0 then
        tAcceptButton.deactivate()
      else
        tAcceptButton.Activate()
      end if
    else
      if me = #confirm then
        tAcceptButton.setText(getText("trading_confirm"))
      else
        if me = #wait then
          tAcceptButton.setText(getText("trading_confirm"))
          tAcceptButton.deactivate()
        end if
      end if
    end if
  end if
  exit
end

on accept(me, tuser, tValue)
  if pState = #closed then
    return(0)
  end if
  if not voidp(tuser) and not voidp(tValue) then
    if tuser = pHerId then
      pAcceptFlagHe = tValue
    else
      if tuser = pMyId then
        pAcceptFlagMe = tValue
      end if
    end if
  end if
  tWndObj = getWindow(pTraderWndID)
  if tWndObj = 0 then
    return(0)
  end if
  tLockElements = ["trading_lock_"]
  repeat while me <= tValue
    tElemName = getAt(tValue, tuser)
    if tWndObj.elementExists(tElemName & "my") then
      tWndObj.getElement(tElemName & "my").setProperty(#visible, pAcceptFlagMe)
    end if
    if tWndObj.elementExists(tElemName & "his") then
      tWndObj.getElement(tElemName & "his").setProperty(#visible, pAcceptFlagHe)
    end if
  end repeat
  me.updateButtons()
  if tWndObj.elementExists("trading_lock_icon_my") then
    if pAcceptFlagMe then
      tmember = "trading_lock_closed"
    else
      tmember = "trading_lock_open"
    end if
    tWndObj.getElement("trading_lock_icon_my").setProperty(#member, tmember)
  end if
  if tWndObj.elementExists("trading_lock_icon_his") then
    if pAcceptFlagHe then
      tmember = "trading_lock_closed"
    else
      tmember = "trading_lock_open"
    end if
    tWndObj.getElement("trading_lock_icon_his").setProperty(#member, tmember)
  end if
  return(1)
  exit
end

on clearSlots(me)
  tWindow = getWindow(pTraderWndID)
  if not tWindow then
    return(0)
  end if
  tSlotNum = 1
  repeat while tSlotNum <= pMaxTradeItems
    tSlot = tWindow.getElement("trading_mystuff_" & tSlotNum)
    if tSlot <> 0 then
      tSlot.clearImage()
      tSlot.draw(rgb(100, 100, 100))
    end if
    tCount = tWindow.getElement("trading_mycount_" & tSlotNum)
    if tCount <> 0 then
      tCount.setText("")
    end if
    tSlot = tWindow.getElement("trading_herstuff_" & tSlotNum)
    if tSlot <> 0 then
      tSlot.clearImage()
      tSlot.draw(rgb(200, 200, 200))
    end if
    tCount = tWindow.getElement("trading_hercount_" & tSlotNum)
    if tCount <> 0 then
      tCount.setText("")
    end if
    tSlotNum = 1 + tSlotNum
  end repeat
  exit
end

on Refresh(me, tTradeItems)
  me.clearSlots()
  pMyStripItems = []
  tWndObj = getWindow(pTraderWndID)
  if tWndObj = 0 then
    return(0)
  end if
  if tTradeItems.ilk <> #propList then
    return(0)
  end if
  tCreditFurniPrice = [#me:0, #he:0]
  pItemListMe = tTradeItems.getaProp(pMyId)
  if not listp(pItemListMe) then
    return(0)
  end if
  pMySlotProps = []
  i = 1
  repeat while i <= pItemListMe.count
    tItemData = pItemListMe.getAt(i)
    tClass = tItemData.getAt(#class)
    if me = "poster" then
      tSlotID = tClass & "_" & tItemData.getAt(#data)
    else
      if me = "song_disk" then
        tSlotID = tClass & "_" & tItemData.getAt(#songID)
      else
        if me = "ecotron_box" then
          tSlotID = tClass & "_" & tItemData.getAt(#id)
        else
          tSlotID = tClass
        end if
      end if
    end if
    if voidp(pMySlotProps.getAt(tSlotID)) then
      tAddToSlot = pMySlotProps.count + 1
      if tWndObj.elementExists("trading_mystuff_" & tAddToSlot) then
        tSlotData = []
        tSlotData.setaProp(#count, 1)
        tSlotData.setaProp(#slot, tAddToSlot)
        tSlotData.setaProp(#name, tItemData.getAt(#name))
        tSlotData.setaProp(#class, tItemData.getAt(#class))
        tSlotData.setaProp(#stripId, tItemData.getAt(#stripId))
        if tSlotData.getAt(#class) = "ecotron_box" then
          if objectExists(#dateFormatter) then
            tDay = tItemData.getAt(#day)
            tMonth = tItemData.getAt(#month)
            tYear = tItemData.getAt(#year)
            tDate = getObject(#dateFormatter).getLocalDate(tDay, tMonth, tYear)
            tSlotData.setAt(#name, tSlotData.getAt(#name) & ", " & tDate)
          end if
        end if
        if not voidp(tItemData.getAt(#songID)) then
          tSlotData.setAt("songID", tItemData.getAt(#songID))
          if not voidp(tItemData.getAt(#data)) then
            tArray = [#source:tItemData.getAt(#data)]
            executeMessage(#get_disk_data, tArray)
            if not voidp(tArray.getAt(#author)) and not voidp(tArray.getAt(#songName)) then
              tText = getText("song_disk_trade_info")
              tText = replaceChunks(tText, "%author%", tArray.getAt(#author))
              tText = replaceChunks(tText, "%name%", tArray.getAt(#songName))
              tSlotData.setAt("name", tText)
            end if
          end if
        end if
        pMySlotProps.addProp(tSlotID, tSlotData)
        tWndObj.getElement("trading_mycount_" & tAddToSlot).setText(pMySlotProps.getAt(tSlotID).getAt("count"))
        tImage = me.createItemImg(pItemListMe.getAt(i))
        tWndObj.getElement("trading_mystuff_" & tAddToSlot).feedImage(tImage)
        tWndObj.getElement("trading_mystuff_" & tAddToSlot).draw(rgb(64, 64, 64))
      end if
    else
      tCount = pMySlotProps.getAt(tSlotID).getAt("count")
      tSlot = pMySlotProps.getAt(tSlotID).getAt("slot")
      pMySlotProps.getAt(tSlotID).setAt("count", tCount + 1)
      tWndObj.getElement("trading_mycount_" & tSlot).setText(pMySlotProps.getAt(tSlotID).getAt("count"))
    end if
    pMyStripItems.add(tItemData.getAt(#stripId))
    if getThread(#room).getComponent().isCreditFurniClass(tItemData.getAt(#class)) then
      tCreditFurniPrice.setAt(#me, tCreditFurniPrice.getAt(#me) + integer(tItemData.getAt(#data)))
    end if
    i = 1 + i
  end repeat
  pItemListHe = tTradeItems.getaProp(pHerId)
  if not listp(pItemListHe) then
    return(0)
  end if
  pHerSlotProps = []
  i = 1
  repeat while i <= pItemListHe.count
    tItemData = pItemListHe.getAt(i)
    tClass = tItemData.getAt(#class)
    if me = "poster" then
      tSlotID = tClass & "_" & tItemData.getAt(#data)
    else
      if me = "song_disk" then
        tSlotID = tClass & "_" & tItemData.getAt(#songID)
      else
        if me = "ecotron_box" then
          tSlotID = tClass & "_" & tItemData.getAt(#id)
        else
          tSlotID = tClass
        end if
      end if
    end if
    if voidp(pHerSlotProps.getAt(tSlotID)) then
      tAddToSlot = pHerSlotProps.count + 1
      if tWndObj.elementExists("trading_herstuff_" & tAddToSlot) then
        tSlotData = []
        tSlotData.setaProp(#count, 1)
        tSlotData.setaProp(#slot, tAddToSlot)
        tSlotData.setaProp(#name, tItemData.getAt(#name))
        tSlotData.setaProp(#class, tItemData.getAt(#class))
        tSlotData.setaProp(#stripId, tItemData.getAt(#stripId))
        if tSlotData.getAt(#class) = "ecotron_box" then
          if objectExists(#dateFormatter) then
            tDay = tItemData.getAt(#day)
            tMonth = tItemData.getAt(#month)
            tYear = tItemData.getAt(#year)
            tDate = getObject(#dateFormatter).getLocalDate(tDay, tMonth, tYear)
            tSlotData.setAt(#name, tSlotData.getAt(#name) & ", " & tDate)
          end if
        end if
        if not voidp(tItemData.getAt(#songID)) then
          tSlotData.setAt("songID", tItemData.getAt(#songID))
          if not voidp(tItemData.getAt(#data)) then
            tArray = [#source:tItemData.getAt(#data)]
            executeMessage(#get_disk_data, tArray)
            if not voidp(tArray.getAt(#author)) and not voidp(tArray.getAt(#songName)) then
              tText = getText("song_disk_trade_info")
              tText = replaceChunks(tText, "%author%", tArray.getAt(#author))
              tText = replaceChunks(tText, "%name%", tArray.getAt(#songName))
              tSlotData.setAt("name", tText)
              if not voidp(tArray.getAt(#playIcon)) then
                tSlotData.setAt(#hiliteImage, me.cropToFit(tArray.getAt(#playIcon)))
              end if
            end if
          end if
        end if
        pHerSlotProps.addProp(tSlotID, tSlotData)
        tWndObj.getElement("trading_hercount_" & tAddToSlot).setText(pHerSlotProps.getAt(tSlotID).getAt("count"))
        tImage = me.createItemImg(tItemData)
        tSlotData.setAt(#image, tImage.duplicate())
        tWndObj.getElement("trading_herstuff_" & tAddToSlot).feedImage(tImage)
        tWndObj.getElement("trading_herstuff_" & tAddToSlot).draw(rgb(200, 200, 200))
      end if
    else
      tCount = pHerSlotProps.getAt(tSlotID).getAt("count")
      tSlot = pHerSlotProps.getAt(tSlotID).getAt("slot")
      pHerSlotProps.getAt(tSlotID).setAt("count", tCount + 1)
      tWndObj.getElement("trading_hercount_" & tSlot).setText(pHerSlotProps.getAt(tSlotID).getAt("count"))
    end if
    if getThread(#room).getComponent().isCreditFurniClass(tItemData.getAt(#class)) then
      tCreditFurniPrice.setAt(#he, tCreditFurniPrice.getAt(#he) + integer(tItemData.getAt(#data)))
    end if
    i = 1 + i
  end repeat
  me.accept(tTradeItems.getPropAt(1), 0)
  me.accept(tTradeItems.getPropAt(2), 0)
  me.updateCreditFurniCount(tCreditFurniPrice)
  exit
end

on updateCreditFurniCount(me, tCreditFurniPrice)
  tWndObj = getWindow(pTraderWndID)
  if tWndObj = 0 then
    return(0)
  end if
  if tWndObj.elementExists("credit_count_1") then
    tPrice = tCreditFurniPrice.getAt(#he)
    if tPrice = 0 then
      tText = ""
    else
      tText = replaceChunks(getText("credit_trade_value"), "%value%", string(tPrice))
    end if
    tWndObj.getElement("credit_count_1").setText(tText)
  end if
  if tWndObj.elementExists("credit_count_2") then
    tPrice = tCreditFurniPrice.getAt(#me)
    if tPrice = 0 then
      tText = ""
    else
      tText = replaceChunks(getText("credit_trade_value"), "%value%", string(tPrice))
    end if
    tWndObj.getElement("credit_count_2").setText(tText)
  end if
  return(1)
  exit
end

on complete(me, tdata)
  return(me.close())
  exit
end

on isUnderTrade(me, tStripID)
  return(pMyStripItems.getPos(tStripID) > 0)
  exit
end

on getState(me)
  return(pState)
  exit
end

on createItemImg(me, tProps, tDownloadPrevented)
  sendProcessTracking(920)
  if voidp(tProps) then
    error(me, "Invalid props!", #createItemImg, #major)
    return(image(1, 1, 8))
  end if
  tImgProps = [#ink:8]
  if voidp(tProps.getAt(#data)) then
    tProps.setAt(#data, "")
  end if
  tClass = tProps.getAt(#class)
  if tProps.getAt(#class) contains "*" then
    tClass = tProps.getAt(#class).getProp(#char, 1, offset("*", tProps.getAt(#class)) - 1)
  end if
  if not tDownloadPrevented then
    tDynThread = getThread(#dynamicdownloader)
    if tDynThread = 0 then
      error(me, "Couldn't define member for trade item!" & "\r" & tProps, #createItemImg, #major)
      return(image(1, 18, 8))
    else
      tDynComponent = tDynThread.getComponent()
      tRoomSizePrefix = ""
      if tProps.getAt(#class) contains "poster" then
        tDownloadIdName = tClass & "_" & tProps.getAt(#data)
      else
        tDownloadIdName = tClass
      end if
      tDownloadIdName = tRoomSizePrefix & tDownloadIdName
      tDownloading = tDynComponent.downloadCastDynamically(tDownloadIdName, #unknown, me.getID(), #traderItemDownloadCallback, 1, tProps)
      if pRequiredDownloadsToTrade.getPos(tDownloadIdName) = 0 and tDownloading then
        pRequiredDownloadsToTrade.add(tDownloadIdName)
      end if
      tMemStr = pIconPlaceholderName
    end if
  end if
  sendProcessTracking(921)
  if tClass contains "post.it" then
    tCount = integer(value(tProps.getAt(#data)) / 0 / 0)
    if tCount > 6 then
      tCount = 6
    end if
    if tCount < 1 then
      tCount = 1
    end if
    if memberExists(tClass & "_" & tCount & "_" & "small") then
      tMemStr = tClass & "_" & tCount & "_" & "small"
    else
      error(me, "Couldn't define member for trade item!" & "\r" & tProps, #createItemImg, #major)
    end if
  else
    if memberExists(tProps.getAt(#class) & "_" & tProps.getAt(#data) & "_small") then
      tMemStr = tProps.getAt(#class) & "_" & tProps.getAt(#data) & "_small"
    else
      if memberExists(tProps.getAt(#class) & "_small") then
        tMemStr = tProps.getAt(#class) & "_small"
      else
        if memberExists(tClass && tProps.getAt(#data) & "_small") then
          tMemStr = tClass && tProps.getAt(#data) & "_small"
        else
          if memberExists(tClass & "_small") then
            tMemStr = tClass & "_small"
          else
            if memberExists("rightwall" && tClass && tProps.getAt(#data)) then
              tMemStr = "rightwall" && tClass && tProps.getAt(#data)
            else
              tMemStr = pIconPlaceholderName
            end if
          end if
        end if
      end if
    end if
  end if
  sendProcessTracking(922)
  tImage = getObject("Preview_renderer").renderPreviewImage(tMemStr, void(), tProps.getAt(#colors), tProps.getAt(#class))
  if voidp(tImage) then
    return(image(1, 18, 8))
  end if
  tImgProps.setAt(#maskImage, tImage.createMatte())
  tNewImg = image(tImage.width, tImage.height, 32)
  tNewImg.copyPixels(tImage, tImage.rect, tImage.rect, tImgProps)
  sendProcessTracking(923)
  return(me.cropToFit(tNewImg))
  exit
end

on traderItemDownloadCallback(me, tDownloadedId, tSuccess, tCallbackParams)
  if not tSuccess then
    return(0)
  end if
  sendProcessTracking(930)
  if pRequiredDownloadsToTrade.getPos(tDownloadedId) > 0 then
    pRequiredDownloadsToTrade.deleteOne(tDownloadedId)
  end if
  tWndObj = getWindow(pTraderWndID)
  if tWndObj = 0 then
    return(0)
  end if
  i = 1
  repeat while i <= pItemListHe.count
    tClass = pItemListHe.getAt(i).getAt(#class)
    tItemProps = pItemListHe.getAt(i).getAt(#data)
    if not voidp(tItemProps) and tItemProps <> "" then
      tClass = tClass & "_" & tItemProps
    end if
    if tClass = "song_disk" then
      tClass = tClass & pItemListHe.getAt(i).getAt(#songID)
    end if
    tSlotProps = pHerSlotProps.getAt(tClass)
    if voidp(tSlotProps) then
    else
      tCount = tSlotProps.getAt("count")
      tSlot = tSlotProps.getAt("slot")
      if tWndObj.elementExists("trading_mystuff_" & tSlot) then
        tImage = me.createItemImg(pItemListHe.getAt(i), 1)
        if tImage.ilk = #image then
          tElement = tWndObj.getElement("trading_herstuff_" & tSlot)
          tElement.feedImage(tImage)
          tElement.draw(rgb(200, 200, 200))
          tSlotProps.setaProp(#image, tImage.duplicate())
        end if
      end if
    end if
    i = 1 + i
  end repeat
  sendProcessTracking(931)
  exit
end

on cropToFit(me, tImage)
  if ilk(tImage) <> #image then
    return(image(1, 1, 8))
  end if
  tOffset = rect(0, 0, 0, 0)
  if tImage.width < pItemSlotRect.width then
    tOffset.setAt(1, integer(pItemSlotRect.width - tImage.width / 2))
    tOffset.setAt(3, tOffset.getAt(1))
  end if
  if tImage.height < pItemSlotRect.height then
    tOffset.setAt(2, integer(pItemSlotRect.height - tImage.height / 2))
    tOffset.setAt(4, tOffset.getAt(2))
  end if
  tNewImg = image(pItemSlotRect.width, pItemSlotRect.height, 32)
  tNewImg.copyPixels(tImage, tImage.rect + tOffset, tImage.rect)
  return(tNewImg)
  exit
end

on showInfo(me, tText)
  if pState = #closed then
    return(0)
  end if
  if voidp(tText) then
    tText = getText("trading_additems")
  end if
  if getWindow(pTraderWndID) = 0 then
    return(0)
  end if
  return(getWindow(pTraderWndID).getElement("trading_instructions_text").setText(tText))
  exit
end

on updateDetailsBubble(me, towner, tSlotNumber)
  sendProcessTracking(940)
  if me = #me then
    tElemPrefix = "trading_mystuff_"
    tSlotProps = pMySlotProps
    tItemList = pItemListMe
  else
    if me = #she then
      tElemPrefix = "trading_herstuff_"
      tSlotProps = pHerSlotProps
      tItemList = pItemListHe
    else
      return(0)
    end if
  end if
  if tSlotNumber > tSlotProps.count then
    return(0)
  end if
  if not windowExists(pTraderWndID) then
    return(0)
  end if
  tTradeWindow = getWindow(pTraderWndID)
  if tTradeWindow = 0 then
    return(0)
  end if
  if not tTradeWindow.elementExists(tElemPrefix & tSlotNumber) then
    return(0)
  end if
  tSlotElem = tTradeWindow.getElement(tElemPrefix & tSlotNumber)
  me.removeDetailsBubble()
  tBubbleObj = createObject(pDetailsBubbleId, "Details Bubble Class")
  tBubbleObj.createWithContent("habbo_trading_details.window", tSlotElem.getProperty(#rect), #right)
  tBubbleWindow = tBubbleObj.getWindowObj()
  if not objectp(tBubbleWindow) then
    return(0)
  end if
  if not objectExists(pProductPreviewObjId) then
    createObject(pProductPreviewObjId, ["Product Preview Class"])
  end if
  tPreviewObj = getObject(pProductPreviewObjId)
  sendProcessTracking(941)
  tClass = tSlotProps.getAt(tSlotNumber).getaProp("class")
  tSlotID = tSlotProps.getPropAt(tSlotNumber)
  repeat while me <= tSlotNumber
    tItem = getAt(tSlotNumber, towner)
    if tItem.getAt(#class) = tClass then
      if tClass = "poster" then
        if "poster_" & tItem.getAt(#data) <> tSlotID then
        else
          tItemData = tItem.duplicate()
        end if
        if voidp(tItemData) then
          return(0)
        end if
        tPreviewData = []
        if tClass = "poster" then
          tPreviewData.setaProp(#class, tClass && tItemData.getAt(#data))
        else
          tPreviewData.setaProp(#class, tClass)
        end if
        tPreviewData.setaProp(#name, tItemData.getAt(#name))
        tPreviewData.setaProp(#custom, tItemData.getAt(#custom))
        tPreviewData.setaProp(#direction, [2, 2, 2])
        tPreviewData.setaProp(#dimensions, tItemData.getAt(#dimensions))
        tPreviewData.setaProp(#colors, tItemData.getAt(#colors))
        if me = "s" then
          tPreviewData.setaProp(#objectType, "s")
        else
          if me = "i" then
            tPreviewData.setaProp(#objectType, "i")
          else
            return(0)
          end if
        end if
        if tPreviewObj = 0 then
          return(0)
        end if
        tPreviewObj.define(tPreviewData)
        tImage = tPreviewObj.getPicture()
        if tImage = 0 then
          return(0)
        end if
        tFurniName = tSlotProps.getAt(tSlotNumber).getAt(#name)
        tNameElem = tBubbleWindow.getElement("trading_details_name")
        tNameElem.setText(tFurniName)
        tMarginH = max(tNameElem.getProperty(#width) - tImage.width / 2, 10)
        tMarginV = 10
        tNewImage = image(tImage.width + tMarginH * 2, tImage.height + tMarginV * 2, 32)
        tNewImage.copyPixels(tImage, tImage.rect + [tMarginH, tMarginV, tMarginH, tMarginV], tImage.rect)
        tImage = tNewImage
        if not tBubbleWindow.elementExists("trading_details_image") then
          return(0)
        end if
        tImageElem = tBubbleWindow.getElement("trading_details_image")
        tOffsetX = tImage.width - tImageElem.getProperty(#width)
        tOffsetY = tImage.height - tImageElem.getProperty(#height)
        tBubbleWindow.getElement("trading_details_image").feedImage(tImage)
        tBubbleWindow.resizeBy(tOffsetX, tOffsetY)
        tBubbleObj.updateBubble()
        tBubbleWindow.getElement("trading_details_image").draw(rgb(0, 0, 0))
        sendProcessTracking(942)
        exit
      end if
    end if
  end repeat
end

on removeDetailsBubble(me)
  if objectExists(pDetailsBubbleId) then
    removeObject(pDetailsBubbleId)
  end if
  exit
end

on blendLockedSlots(me, tBoolean)
  if pState = #closed then
    return(0)
  end if
  tBlend = 100
  if tBoolean then
    tBlend = 60
  end if
  tWndObj = getWindow(pTraderWndID)
  if tWndObj = 0 then
    return(0)
  end if
  i = 1
  repeat while i <= pItemListMe.count
    tElement = tWndObj.getElement("trading_mystuff_" & i)
    if tElement <> 0 then
      tElement.setProperty(#blend, 60)
    end if
    if i = pMaxTradeItems then
    else
      i = 1 + i
    end if
  end repeat
  exit
end

on sendMessage(me, tMessageName, tMessage)
  if not stringp(tMessageName) then
    return(0)
  end if
  if not voidp(tMessage) and tMessage.ilk <> #propList then
    return(0)
  end if
  tConn = getConnection(getVariable("connection.info.id"))
  if not tConn then
    return(0)
  end if
  return(tConn.send(tMessageName, tMessage))
  exit
end

on eventProcTrading(me, tEvent, tSprID, tParam)
  sendProcessTracking(950)
  if pState = #closed then
    return(0)
  end if
  if me = #mouseUp then
    if me <> "trading_confirm_check" then
      if me = "trading_accept" then
        if pAcceptFlagMe then
          return(me.sendMessage("TRADE_UNACCEPT"))
        else
          if pHerSlotProps.count = 0 then
            if pRequiredDownloadsToTrade.count > 0 then
              return(1)
            end if
            if not createWindow(pConfirmationWndID, void(), 0, 0, #modal) then
              return(0)
            end if
            tWinObj = getWindow(pConfirmationWndID)
            if tWinObj = 0 then
              return(0)
            end if
            tWindowTitleStr = getText("win_error", "Notice!")
            tWinObj.setProperty(#title, tWindowTitleStr)
            if not tWinObj.merge("habbo_basic.window") then
              return(tWinObj.close())
            end if
            if not tWinObj.merge("habbo_tradingalert_dialog.window") then
              return(tWinObj.close())
            end if
            tWinObj.center()
            tWinObj.registerProcedure(#eventProcTradingWarning, me.getID(), #mouseUp)
            return(1)
          else
            if pRequiredDownloadsToTrade.count > 0 then
              return(1)
            end if
            return(me.sendMessage("TRADE_ACCEPT"))
          end if
        end if
      else
        if me <> "close" then
          if me = "trading_cancel" then
            me.sendMessage("TRADE_CLOSE")
            return(me.close())
          end if
          if tSprID contains "trading_mystuff" then
            tObjMover = getThread(#room).getInterface().getObjectMover()
            if objectp(tObjMover) then
              tClientID = tObjMover.getProperty(#clientID)
              tStripID = tObjMover.getProperty(#stripId)
              if tStripID <> "" then
                tAllow = 0
                if pMySlotProps.count < pMaxTradeItems then
                  tAllow = 1
                end if
                if not tAllow then
                  tObjProps = tObjMover.getProperty(#clientProps)
                  if tObjProps.ilk <> #propList then
                    return(0)
                  end if
                  tCurrentClass = tObjProps.getaProp(#class)
                  if tCurrentClass = "poster" then
                    tCurrentClass = "poster_" & tObjProps.getaProp(#data)
                  end if
                  repeat while me <= tSprID
                    tItem = getAt(tSprID, tEvent)
                    tTargetClass = tItem.getaProp(#class)
                    if tTargetClass = "poster" then
                      tTargetClass = "poster_" & tItem.getaProp(#data)
                    end if
                    if tCurrentClass = tTargetClass then
                      tAllow = 1
                    else
                    end if
                  end repeat
                  if tCurrentClass = "song_disk" then
                    tAllow = 0
                  end if
                end if
                if tAllow then
                  if pAcceptFlagMe then
                    me.sendMessage("TRADE_UNACCEPT")
                  end if
                  me.sendMessage("TRADE_ADDITEM", [#integer:integer(tStripID)])
                  getThread(#room).getInterface().cancelObjectMover()
                  getThread(#room).getInterface().setProperty(#clickAction, "tradeItem")
                  return(tObjMover.clear())
                end if
              else
                tSlotID = integer(tSprID.getProp(#char, tSprID.length))
                if tSlotID > 0 and tSlotID <= pMySlotProps.count then
                  tStripID = pMySlotProps.getAt(tSlotID).getaProp(#stripId)
                  me.sendMessage("TRADE_REMOVE_ITEM", [#integer:integer(tStripID)])
                  me.sendMessage("GETSTRIP", [#integer:4])
                  me.removeDetailsBubble()
                end if
              end if
            end if
          end if
          if tSprID contains "trading_herstuff" then
            if integer(tSprID.getProp(#char, length(tSprID))) <= pHerSlotProps.count then
              tSongID = pHerSlotProps.getAt(integer(tSprID.getProp(#char, length(tSprID)))).getAt(#songID)
              if not voidp(tSongID) then
                executeMessage(#listen_song, value(tSongID))
              end if
            end if
          end if
          if me = #mouseEnter then
            tObjMover = getThread(#room).getInterface().getObjectMover()
            if tObjMover <> 0 then
              tObjMover.moveTrade()
            end if
            if tSprID contains "trading_mystuff" then
              tSlotIndex = integer(tSprID.getProp(#char, length(tSprID)))
              if tSlotIndex > pMySlotProps.count and tObjMover.getProperty(#clientID) <> "" then
                getWindow(pTraderWndID).getElement(tSprID).draw(rgb(200, 200, 200))
              else
                me.updateDetailsBubble(#me, tSlotIndex)
              end if
            else
              if tSprID contains "trading_herstuff" then
                tSlotIndex = integer(tSprID.getProp(#char, length(tSprID)))
                if tSlotIndex <= pHerSlotProps.count then
                  me.updateDetailsBubble(#she, tSlotIndex)
                  if tSlotIndex <= pHerSlotProps.count then
                    tImage = pHerSlotProps.getAt(tSlotIndex).getAt(#hiliteImage)
                    if not voidp(tImage) then
                      getWindow(pTraderWndID).getElement(tSprID).feedImage(tImage)
                      getWindow(pTraderWndID).getElement(tSprID).draw(rgb(200, 200, 200))
                    end if
                  end if
                end if
              end if
            end if
          else
            if me = #mouseLeave then
              if tSprID contains "trading_mystuff" then
                tObjMover = getThread(#room).getInterface().getObjectMover()
                if tObjMover <> 0 then
                  tObjMover.moveTrade()
                end if
                if integer(tSprID.getProp(#char, length(tSprID))) <= pMySlotProps.count then
                  getWindow(pTraderWndID).getElement(tSprID).draw(rgb(50, 50, 50))
                else
                  getWindow(pTraderWndID).getElement(tSprID).draw(rgb(100, 100, 100))
                end if
                me.removeDetailsBubble()
              else
                if tSprID contains "trading_herstuff" then
                  me.removeDetailsBubble()
                  tSlotIndex = integer(tSprID.getProp(#char, length(tSprID)))
                  if tSlotIndex <= pHerSlotProps.count then
                    tSongID = pHerSlotProps.getAt(tSlotIndex).getAt(#songID)
                    if not voidp(tSongID) then
                      executeMessage(#do_not_listen_song, value(tSongID))
                    end if
                    tImage = pHerSlotProps.getAt(tSlotIndex).getAt(#image)
                    if not voidp(tImage) then
                      getWindow(pTraderWndID).getElement(tSprID).feedImage(tImage)
                      getWindow(pTraderWndID).getElement(tSprID).draw(rgb(200, 200, 200))
                    end if
                  end if
                end if
              end if
            end if
          end if
          exit
        end if
      end if
    end if
  end if
end

on eventProcTradingWarning(me, tEvent, tElement, arg3, tWndName)
  if tElement = "habbo_tradingalert_ok" then
    pAcceptFlagMe = 1
    removeWindow(tWndName)
    return(me.sendMessage("TRADE_ACCEPT"))
  else
    if tElement = "habbo_tradingalert_cancel" then
      removeWindow(tWndName)
      return(1)
    end if
  end if
  exit
end

on eventProcTradingConfirmation(me, tEvent, tElemID, tParam)
  if me = "trading_accept" then
    me.showWaitingView()
    return(me.sendMessage("TRADE_CONFIRM_ACCEPT"))
  else
    if me <> "trading_cancel" then
      if me = "close" then
        me.sendMessage("TRADE_CONFIRM_DECLINE")
        return(me.close())
      end if
      exit
    end if
  end if
end