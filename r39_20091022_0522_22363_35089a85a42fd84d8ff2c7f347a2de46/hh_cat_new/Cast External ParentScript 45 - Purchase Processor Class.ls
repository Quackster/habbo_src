property pProps, pWndID, pPersistentCatalogData

on construct me
  pWndID = "Catalog Purchase Dialog"
  pProps = [:]
  pPersistentCatalogData = getThread(#catalogue).getComponent().getPersistentCatalogDataObject()
end

on deconstruct me
  if windowExists(pWndID) then
    removeWindow(pWndID)
  end if
end

on startPurchase me, tProps
  pProps = tProps
  if not windowExists(pWndID) then
    me.showPurchaseDialog()
  end if
end

on showPurchaseDialog me
  if not windowExists(pWndID) then
    if not createWindow(pWndID, "habbo_simple.window", VOID, VOID, #modal) then
      return error(me, "Unable to create purchase info dialog window", #showPurchaseDialog, #major)
    end if
  else
    getWindow(pWndID).removeProcedure(#eventProcKeyDown, me.getID())
    getWindow(pWndID).unmerge()
  end if
  tWndObj = getWindow(pWndID)
  if not tWndObj.merge("habbo_orderinfo_dialog.window") then
    tWndObj.close()
    return error(me, "Unable to perform merge to purchase info dialog", #showPurchaseDialog, #major)
  end if
  tOfferTypeText = [#credits: "catalog_costs_credits", #creditsandpixels: "catalog_costs_pixelsandcredits", #pixels: "catalog_costs_pixels"]
  tItemName = EMPTY
  tCatalogProps = pPersistentCatalogData.getProps(pProps[#item].getName())
  if not voidp(tCatalogProps) then
    tItemName = tCatalogProps[#name]
  else
    tItemName = pProps[#item].getName()
  end if
  if not voidp(pProps[#disableGift]) then
    tWndObj.getElement("buy_gift_ok").hide()
    tWndObj.getElement("shopping_asagift").hide()
  end if
  case pProps[#offerType] of
    #credits:
      tPrice = integer(value(pProps[#item].getPrice(#credits)))
      tWallet = integer(value(getObject(#session).GET("user_walletbalance")))
      tMsgA = getText(tOfferTypeText[pProps[#offerType]], "\x1 costs \x2 credits")
      tMsgA = replaceChunks(tMsgA, "\x1", tItemName)
      tMsgA = replaceChunks(tMsgA, "\x2", tPrice)
      tMsgB = replaceChunks(getText("catalog_credits", "You have \x credits in your purse."), "\x", tWallet)
    #creditsandpixels:
      tPriceX = integer(value(pProps[#item].getPrice(#credits)))
      tPriceY = integer(value(pProps[#item].getPrice(#pixels)))
      tWalletX = integer(value(getObject(#session).GET("user_walletbalance")))
      tWalletY = integer(value(getObject(#session).GET("user_pixelbalance")))
      tMsgA = getText(tOfferTypeText[pProps[#offerType]], "\x1 costs \x3 pixels and \x2 credits")
      tMsgA = replaceChunks(tMsgA, "\x1", tItemName)
      tMsgA = replaceChunks(tMsgA, "\x2", tPriceX)
      tMsgA = replaceChunks(tMsgA, "\x3", tPriceY)
      tMsgB = getText("catalog_creditsandpixels", "You have \x credits in your purse and \y pixels.")
      tMsgB = replaceChunks(tMsgB, "\x", tWalletX)
      tMsgB = replaceChunks(tMsgB, "\y", tWalletY)
    #pixels:
      tPrice = integer(value(pProps[#item].getPrice(#pixels)))
      tWallet = integer(value(getObject(#session).GET("user_pixelbalance")))
      tMsgA = getText(tOfferTypeText[pProps[#offerType]], "\x1 costs \x3 pixels")
      tMsgA = replaceChunks(tMsgA, "\x1", tItemName)
      tMsgA = replaceChunks(tMsgA, "\x3", tPrice)
      tMsgB = replaceChunks(getText("catalog_pixels", "You have \x pixels."), "\x", tWallet)
  end case
  activateWindowObj(pWndID)
  tWndObj.setProperty(#locZ, getWindowManager().pAvailableLocZ + 1)
  tWndObj.center()
  tWndObj.getElement("habbo_orderinfo_text_a").setText(tMsgA)
  tWndObj.getElement("habbo_orderinfo_text_b").setText(tMsgB)
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcPurchaseDialog, me.getID(), #mouseUp)
  tWndObj.setProperty(#locZ, 22000000)
  tWndObj.lock(1)
  if not getObject(#session).GET("user_rights").getOne("fuse_trade") then
    if tWndObj.elementExists("buy_gift_ok") then
      tWndObj.getElement("buy_gift_ok").setProperty(#blend, 30)
    end if
  end if
end

on showGiftDialog me
  if not windowExists(pWndID) then
    return error(me, "Cannot convert nonexisting purchase dialog", #showGiftDialog, #major)
  end if
  tWndObj = getWindow(pWndID)
  tMsgA = tWndObj.getElement("habbo_orderinfo_text_a").getText()
  tMsgB = tWndObj.getElement("habbo_orderinfo_text_b").getText()
  tWndObj.unmerge()
  if not tWndObj.merge("habbo_orderinfo_gift_dialog.window") then
    tWndObj.close()
    return error(me, "Unable to perform merge to purchase info dialog", #showPurchaseDialog, #major)
  end if
  activateWindowObj(pWndID)
  tWndObj.setProperty(#locZ, getWindowManager().pAvailableLocZ + 1)
  tWndObj.getElement("habbo_orderinfo_text_a").setText(tMsgA)
  tWndObj.getElement("habbo_orderinfo_text_b").setText(tMsgB)
  tWndObj.registerProcedure(#eventProcKeyDown, me.getID(), #keyDown)
end

on finishPurchase me
  if windowExists(pWndID) then
    removeWindow(pWndID)
  end if
  if me.pProps.getaProp(#closeCatalogue) then
    executeMessage(#hide_catalogue)
  end if
end

on eventProcPurchaseDialog me, tEvent, tSprID, tParam, tWndID
  case tSprID of
    "habbo_decision_ok", "habbo_message_ok", "button_ok":
      tWndObj = getWindow(pWndID)
      if tWndObj.elementExists("shopping_gift_target") then
        tGiftReceiver = tWndObj.getElement("shopping_gift_target").getText()
        tGiftMessage = convertSpecialChars(tWndObj.getElement("shopping_greeting_field").getText(), 1)
        tExtraParam = EMPTY
        if pProps[#item].getCount() > 0 then
          tExtraParam = convertSpecialChars(pProps[#item].getContent(1).getExtraParam(), 1)
        else
          tExtraParam = EMPTY
        end if
        call(pProps[#method], getThread(#catalogue).getHandler(), pProps[#pageid], pProps[#item].getCode(), tExtraParam, 1, tGiftReceiver, tGiftMessage)
      else
        tExtraParam = EMPTY
        if pProps[#item].getCount() > 0 then
          tExtraParam = convertSpecialChars(pProps[#item].getContent(1).getExtraParam(), 1)
        else
          tExtraParam = EMPTY
        end if
        call(pProps[#method], getThread(#catalogue).getHandler(), pProps[#pageid], pProps[#item].getCode(), tExtraParam, 0)
      end if
      tWndObj.close()
      me.finishPurchase()
    "habbo_decision_cancel", "button_cancel", "close":
      tWndObj = getWindow(pWndID)
      tWndObj.close()
      me.finishPurchase()
    "buy_gift_ok":
      me.showGiftDialog()
    "buy_gift_cancel":
      me.showPurchaseDialog()
    "nobalance_ok":
      if not textExists("url_nobalance") then
        return 0
      end if
      tSession = getObject(#session)
      tURL = getText("url_nobalance")
      tURL = tURL & urlEncode(tSession.GET(#userName))
      if tSession.exists("user_checksum") then
        tURL = tURL & "&sum=" & urlEncode(tSession.GET("user_checksum"))
      end if
      executeMessage(#externalLinkClick, the mouseLoc)
      openNetPage(tURL)
      tWndObj = getWindow(pWndID)
      tWndObj.close()
    "subscribe":
      tSession = getObject(#session)
      tOwnName = tSession.GET(#userName)
      tURL = getText("url_subscribe")
      tURL = tURL & urlEncode(tOwnName)
      if tSession.exists("user_checksum") then
        tURL = tURL & "&sum=" & urlEncode(tSession.GET("user_checksum"))
      end if
      executeMessage(#externalLinkClick, the mouseLoc)
      openNetPage(tURL, "_new")
      tWndObj = getWindow(pWndID)
      tWndObj.close()
  end case
end

on eventProcKeyDown me, tEvent, tSprID, tParam
  if the key = TAB then
    if not windowExists(pWndID) then
      return 0
    end if
    tWndObj = getWindow(pWndID)
    if tSprID = "shopping_greeting_field" then
      tElem = tWndObj.getElement("shopping_gift_target")
      if objectp(tElem) then
        tElem.setFocus(1)
      end if
    else
      tElem = tWndObj.getElement("shopping_greeting_field")
      if objectp(tElem) then
        tElem.setFocus(1)
      end if
    end if
  else
    pass()
  end if
end
