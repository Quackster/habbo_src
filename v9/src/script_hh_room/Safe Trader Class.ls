property pTraderWndID, pTraderPal, pMaxTradeItms, pConfirmationWndID, pState, pAcceptFlagMe, pAcceptFlagHe, pItemListMe, pMySlotProps, pMyStripItems, pItemListHe, pHerSlotProps, pItemSlotRect

on construct me 
  pState = #closed
  pTraderWndID = getText("trading_title", "Safe Trading")
  pAcceptFlagMe = 0
  pAcceptFlagHe = 0
  pItemListMe = []
  pItemListHe = []
  pMyStripItems = []
  pMaxTradeItms = 0
  pItemSlotRect = rect(0, 0, 32, 32)
  pHerSlotCount = 0
  pMySlotProps = [:]
  pHerSlotProps = [:]
  pConfirmationWndID = "safetrading_confirmationdialog"
  return(1)
end

on deconstruct me 
  return(me.close())
end

on open me, tdata 
  getThread(#room).getInterface().cancelObjectMover()
  getThread(#room).getInterface().setProperty(#clickAction, "tradeItem")
  if windowExists(pTraderWndID) then
    return(0)
  end if
  if tdata.count > 1 then
    if tdata.getPropAt(1) <> getObject(#session).get("user_name") then
      pTraderPal = tdata.getPropAt(1)
    else
      pTraderPal = tdata.getPropAt(2)
    end if
  else
    pTraderPal = tdata.getPropAt(1)
  end if
  if voidp(pTraderPal) or pTraderPal = "" then
    pTraderPal = "He/she"
  end if
  if not createWindow(pTraderWndID, "habbo_basic.window") then
    return(0)
  end if
  tWndObj = getWindow(pTraderWndID)
  if not tWndObj.merge("habbo_trading.window") then
    return(tWndObj.close())
  end if
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcTrading, me.getID())
  tWndObj.getElement("trading_heoffers_text").setText(pTraderPal && getText("trading_offers", "offers"))
  tWndObj.getElement("trading_agrees_text").setText(pTraderPal && getText("trading_agrees", "agrees"))
  pMaxTradeItms = 0
  repeat while 1
    if not getWindow(pTraderWndID).elementExists("trading_mystuff_" & pMaxTradeItms + 1) then
    else
      pMaxTradeItms = pMaxTradeItms + 1
    end if
  end repeat
  i = 1
  repeat while i <= pMaxTradeItms
    tWndObj.getElement("trading_mystuff_" & i).draw(rgb(100, 100, 100))
    tWndObj.getElement("trading_herstuff_" & i).draw(rgb(200, 200, 200))
    i = 1 + i
  end repeat
  tWidth = tWndObj.getElement("trading_mystuff_1").getProperty(#width)
  tHeight = tWndObj.getElement("trading_mystuff_1").getProperty(#height)
  pItemSlotRect = rect(0, 0, tWidth, tHeight)
  pState = #open
  me.accept()
  return(1)
end

on close me, tdata 
  getThread(#room).getInterface().setProperty(#clickAction, "moveHuman")
  getThread(#room).getInterface().getObjectMover().clear()
  if windowExists(pTraderWndID) then
    pAcceptFlagMe = 0
    pAcceptFlagHe = 0
    pItemListMe = []
    pItemListHe = []
    pMyStripItems = []
    pMySlotProps = [:]
    pHerSlotProps = [:]
    removeWindow(pTraderWndID)
    removeWindow(pConfirmationWndID)
  end if
  pState = #closed
  return(1)
end

on accept me, tuser, tValue 
  if pState = #closed then
    return(0)
  end if
  if not voidp(tuser) and not voidp(tValue) then
    if tuser = pTraderPal then
      pAcceptFlagHe = tValue
    else
      if tuser = getObject(#session).get("user_name") then
        pAcceptFlagMe = tValue
        me.blendLockedSlots(tValue)
      end if
    end if
  end if
  if pAcceptFlagMe then
    tOnOff = "on"
  else
    tOnOff = "off"
  end if
  tWndObj = getWindow(pTraderWndID)
  if tWndObj = 0 then
    return(0)
  end if
  tImage = member(getmemnum("button.checkbox." & tOnOff)).image
  tWndObj.getElement("trading_confirm_check").feedImage(tImage)
  if pAcceptFlagHe then
    tOnOff = "on"
    tBlend = 255
  else
    tOnOff = "off"
    tBlend = 128
  end if
  tImageA = member(getmemnum("button.checkbox." & tOnOff)).image
  tImageB = image(tImageA.width, tImageA.height, tImageA.depth, tImageA.paletteRef)
  tImageB.copyPixels(tImageA, tImageA.rect, tImageA.rect, [#blendLevel:tBlend])
  tWndObj.getElement("trading_buddycheck_image").feedImage(tImageB)
  return(1)
end

on Refresh me, tdata 
  me.open(tdata)
  pMyStripItems = []
  tWndObj = getWindow(pTraderWndID)
  pItemListMe = tdata.getAt(getObject(#session).get("user_name")).getAt(#items)
  pMySlotProps = [:]
  i = 1
  repeat while i <= pItemListMe.count
    tClass = pItemListMe.getAt(i).getAt(#class)
    if not voidp(pItemListMe.getAt(i).getAt(#props)) then
      tClass = tClass & "_" & pItemListMe.getAt(i).getAt(#props)
    end if
    if voidp(pMySlotProps.getAt(tClass)) then
      tAddToSlot = pMySlotProps.count + 1
      if tWndObj.elementExists("trading_mystuff_" & tAddToSlot) then
        pMySlotProps.addProp(tClass, ["count":1, "slot":tAddToSlot, "name":pItemListMe.getAt(i).getAt(#name)])
        tWndObj.getElement("trading_mycount_" & tAddToSlot).setText(pMySlotProps.getAt(tClass).getAt("count"))
        tImage = me.createItemImg(pItemListMe.getAt(i), pItemListMe.getAt(i).getAt(#colors))
        tWndObj.getElement("trading_mystuff_" & tAddToSlot).feedImage(tImage)
        tWndObj.getElement("trading_mystuff_" & tAddToSlot).draw(rgb(64, 64, 64))
      end if
    else
      tCount = pMySlotProps.getAt(tClass).getAt("count")
      tSlot = pMySlotProps.getAt(tClass).getAt("slot")
      pMySlotProps.getAt(tClass).setAt("count", tCount + 1)
      tWndObj.getElement("trading_mycount_" & tSlot).setText(pMySlotProps.getAt(tClass).getAt("count"))
    end if
    pMyStripItems.add(pItemListMe.getAt(i).getAt(#stripId))
    i = 1 + i
  end repeat
  if tdata.getAt(pTraderPal) = void() then
    return(0)
  end if
  pItemListHe = tdata.getAt(pTraderPal).getAt(#items)
  pHerSlotProps = [:]
  i = 1
  repeat while i <= pItemListHe.count
    tClass = pItemListHe.getAt(i).getAt(#class)
    if not voidp(pItemListHe.getAt(i).getAt(#props)) then
      tClass = tClass & pItemListHe.getAt(i).getAt(#props)
    end if
    if voidp(pHerSlotProps.getAt(tClass)) then
      tAddToSlot = pHerSlotProps.count + 1
      if tWndObj.elementExists("trading_herstuff_" & tAddToSlot) then
        pHerSlotProps.addProp(tClass, ["count":1, "slot":tAddToSlot, "name":pItemListHe.getAt(i).getAt(#name)])
        tWndObj.getElement("trading_hercount_" & tAddToSlot).setText(pHerSlotProps.getAt(tClass).getAt("count"))
        tImage = me.createItemImg(pItemListHe.getAt(i), pItemListHe.getAt(i).getAt(#colors))
        tWndObj.getElement("trading_herstuff_" & tAddToSlot).feedImage(tImage)
        tWndObj.getElement("trading_herstuff_" & tAddToSlot).draw(rgb(64, 64, 64))
      end if
    else
      tCount = pHerSlotProps.getAt(tClass).getAt("count")
      tSlot = pHerSlotProps.getAt(tClass).getAt("slot")
      pHerSlotProps.getAt(tClass).setAt("count", tCount + 1)
      tWndObj.getElement("trading_hercount_" & tSlot).setText(pHerSlotProps.getAt(tClass).getAt("count"))
    end if
    i = 1 + i
  end repeat
  me.accept(tdata.getPropAt(1), value(tdata.getAt(1).getAt(#accept)))
  me.accept(tdata.getPropAt(2), value(tdata.getAt(2).getAt(#accept)))
end

on complete me, tdata 
  return(me.close())
end

on isUnderTrade me, tStripID 
  return(pMyStripItems.getPos(tStripID) > 0)
end

on createItemImg me, tProps 
  tImgProps = [#ink:8]
  if voidp(tProps.getAt(#props)) then
    tProps.setAt(#props, "")
  end if
  tClass = tProps.getAt(#class)
  if tProps.getAt(#class) contains "*" then
    tClass = tProps.getAt(#class).getProp(#char, 1, offset("*", tProps.getAt(#class)) - 1)
  end if
  if tClass contains "post.it" then
    tCount = integer((value(tProps.getAt(#props)) / (20 / 6)))
    if tCount > 6 then
      tCount = 6
    end if
    if tCount < 1 then
      tCount = 1
    end if
    if memberExists(tClass & "_" & tCount & "_" & "small") then
      tMemStr = tClass & "_" & tCount & "_" & "small"
    else
      error(me, "Couldn't define member for trade item!" & "\r" & tProps, #createItemImg)
    end if
  else
    if memberExists(tProps.getAt(#class) & "_" & tProps.getAt(#props) & "_small") then
      tMemStr = tProps.getAt(#class) & "_" & tProps.getAt(#props) & "_small"
    else
      if memberExists(tClass && tProps.getAt(#props) & "_small") then
        tMemStr = tClass && tProps.getAt(#props) & "_small"
      else
        if memberExists(tClass & "_small") then
          tMemStr = tClass & "_small"
        else
          if memberExists("rightwall" && tClass && tProps.getAt(#props)) then
            tMemStr = "rightwall" && tClass && tProps.getAt(#props)
          else
            error(me, "Couldn't define member for trade item!" & "\r" & tProps, #createItemImg)
          end if
        end if
      end if
    end if
  end if
  tImage = getObject("Preview_renderer").renderPreviewImage(tMemStr, void(), tProps.getAt(#colors), tProps.getAt(#class))
  tImgProps.setAt(#maskImage, tImage.createMatte())
  tNewImg = image(tImage.width, tImage.height, 32)
  tNewImg.copyPixels(tImage, tImage.rect, tImage.rect, tImgProps)
  return(me.cropToFit(tNewImg))
end

on cropToFit me, tImage 
  tOffset = rect(0, 0, 0, 0)
  if tImage.width < pItemSlotRect.width then
    tOffset.setAt(1, integer((pItemSlotRect.width - tImage.width / 2)))
    tOffset.setAt(3, tOffset.getAt(1))
  end if
  if tImage.height < pItemSlotRect.height then
    tOffset.setAt(2, integer((pItemSlotRect.height - tImage.height / 2)))
    tOffset.setAt(4, tOffset.getAt(2))
  end if
  tNewImg = image(pItemSlotRect.width, pItemSlotRect.height, 32)
  tNewImg.copyPixels(tImage, tImage.rect + tOffset, tImage.rect)
  return(tNewImg)
end

on showInfo me, tText 
  if pState = #closed then
    return(0)
  end if
  if voidp(tText) then
    tText = getText("trading_additems")
  end if
  return(getWindow(pTraderWndID).getElement("trading_instructions_text").setText(tText))
end

on blendLockedSlots me, tBoolean 
  if pState = #closed then
    return(0)
  end if
  if tBoolean then
    i = 1
    repeat while i <= pItemListMe.count
      getWindow(pTraderWndID).getElement("trading_mystuff_" & i).setProperty(#blend, 60)
      if i = pMaxTradeItms then
      else
        i = 1 + i
      end if
    end repeat
    exit repeat
  end if
  i = 1
  repeat while i <= pItemListMe.count
    getWindow(pTraderWndID).getElement("trading_mystuff_" & i).setProperty(#blend, 100)
    if i = pMaxTradeItms then
    else
      i = 1 + i
    end if
  end repeat
end

on eventProcTrading me, tEvent, tSprID, tParam 
  if pState = #closed then
    return(0)
  end if
  if tEvent = #mouseUp then
    if tEvent = "trading_confirm_check" then
      if pAcceptFlagMe then
        pAcceptFlagMe = 0
        return(getThread(#room).getComponent().getRoomConnection().send("TRADE_UNACCEPT"))
      else
        if pHerSlotProps.count = 0 then
          if not createWindow(pConfirmationWndID, void(), 0, 0, #modal) then
            return(0)
          end if
          tWinObj = getWindow(pConfirmationWndID)
          tWindowTitleStr = getText("win_error", "Notice!")
          tWinObj.setProperty(#title, tWindowTitleStr)
          if not tWinObj.merge("habbo_basic.window") then
            return(tWinObj.close())
          end if
          if not tWinObj.merge("habbo_tradingalert_dialog.window") then
            return(tWinObj.close())
          end if
          tWinObj.center()
          tWinObj.registerProcedure(#eventProcTradingConfirmation, me.getID(), #mouseUp)
          return(1)
        else
          pAcceptFlagMe = 1
          return(getThread(#room).getComponent().getRoomConnection().send("TRADE_ACCEPT"))
        end if
      end if
    else
      if tEvent <> "close" then
        if tEvent = "trading_cancel" then
          getThread(#room).getComponent().getRoomConnection().send("TRADE_CLOSE")
          return(me.close())
        end if
        if tSprID contains "trading_mystuff" then
          tObjMover = getThread(#room).getInterface().getObjectMover()
          if objectp(tObjMover) then
            tClientID = tObjMover.getProperty(#clientID)
            tStripID = tObjMover.getProperty(#stripId)
            if tStripID <> "" then
              if pAcceptFlagMe then
                getThread(#room).getComponent().getRoomConnection().send("TRADE_UNACCEPT")
              end if
              getThread(#room).getComponent().getRoomConnection().send("TRADE_ADDITEM", tStripID)
              return(tObjMover.clear())
            end if
          end if
        end if
        if tEvent = #mouseEnter then
          tObjMover = getThread(#room).getInterface().getObjectMover()
          if tObjMover <> 0 then
            tObjMover.moveTrade()
          end if
          if tEvent = "trading_confirm_check" then
            return(me.showInfo(getText("trading_youagree")))
          else
            if tEvent <> "close" then
              if tEvent = "trading_cancel" then
                return(me.showInfo(getText("trading_cancel")))
              end if
              if tSprID contains "trading_mystuff" and not pAcceptFlagMe then
                if integer(tSprID.getProp(#char, length(tSprID))) > pMySlotProps.count then
                  getWindow(pTraderWndID).getElement(tSprID).draw(rgb(200, 200, 200))
                else
                  me.showInfo(pMySlotProps.getAt(integer(tSprID.getProp(#char, length(tSprID)))).getAt(#name))
                end if
              else
                if tSprID contains "trading_herstuff" then
                  if integer(tSprID.getProp(#char, length(tSprID))) <= pHerSlotProps.count then
                    me.showInfo(pHerSlotProps.getAt(integer(tSprID.getProp(#char, length(tSprID)))).getAt(#name))
                  end if
                end if
              end if
              if tEvent = #mouseLeave then
                if tEvent = "trading_confirm_check" then
                  return(me.showInfo(void()))
                else
                  if tEvent <> "close" then
                    if tEvent = "trading_cancel" then
                      return(me.showInfo(void()))
                    end if
                    if tSprID contains "trading_mystuff" and not pAcceptFlagMe then
                      tObjMover = getThread(#room).getInterface().getObjectMover()
                      if tObjMover <> 0 then
                        tObjMover.moveTrade()
                      end if
                      if integer(tSprID.getProp(#char, length(tSprID))) <= pMySlotProps.count then
                        getWindow(pTraderWndID).getElement(tSprID).draw(rgb(50, 50, 50))
                      else
                        getWindow(pTraderWndID).getElement(tSprID).draw(rgb(100, 100, 100))
                      end if
                      me.showInfo(void())
                    else
                      if tSprID contains "trading_herstuff" then
                        me.showInfo(void())
                      end if
                    end if
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end

on eventProcTradingConfirmation me, tEvent, tElement, arg3, tWndName 
  if tElement = "habbo_tradingalert_ok" then
    pAcceptFlagMe = 1
    removeWindow(tWndName)
    return(getConnection(getVariable("connection.info.id")).send("TRADE_ACCEPT"))
  else
    if tElement = "habbo_tradingalert_cancel" then
      removeWindow(tWndName)
      return(1)
    end if
  end if
end
