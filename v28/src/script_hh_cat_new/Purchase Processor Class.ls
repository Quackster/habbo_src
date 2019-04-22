on construct(me)
  pWndID = "Catalog Purchase Dialog"
  pProps = []
  pPersistentCatalogData = getThread(#catalogue).getComponent().getPersistentCatalogDataObject()
  exit
end

on deconstruct(me)
  if windowExists(pWndID) then
    removeWindow(pWndID)
  end if
  exit
end

on startPurchase(me, tProps)
  pProps = tProps
  if not windowExists(pWndID) then
    me.showPurchaseDialog()
  end if
  exit
end

on showPurchaseDialog(me)
  if not windowExists(pWndID) then
    if not createWindow(pWndID, "habbo_simple.window", void(), void(), #modal) then
      return(error(me, "Unable to create purchase info dialog window", #showPurchaseDialog, #major))
    end if
  else
    getWindow(pWndID).removeProcedure(#eventProcKeyDown, me.getID())
    getWindow(pWndID).unmerge()
  end if
  tWndObj = getWindow(pWndID)
  if not tWndObj.merge("habbo_orderinfo_dialog.window") then
    tWndObj.close()
    return(error(me, "Unable to perform merge to purchase info dialog", #showPurchaseDialog, #major))
  end if
  tOfferTypeText = [#credits:"catalog_costs_credits", #creditsandpixels:"catalog_costs_pixelsandcredits", #pixels:"catalog_costs_pixels"]
  tItemName = ""
  tCatalogProps = pPersistentCatalogData.getProps(pProps.getAt(#item).getAt(#offername))
  if not voidp(tCatalogProps) then
    tItemName = tCatalogProps.getAt(#name)
  else
    tItemName = pProps.getAt(#item).getAt(#offername)
  end if
  if not voidp(pProps.getAt(#disableGift)) then
    tWndObj.getElement("buy_gift_ok").hide()
    tWndObj.getElement("shopping_asagift").hide()
  end if
  if me = #credits then
    tPrice = integer(value(pProps.getAt(#item).getAt(#price).getAt(#credits)))
    tWallet = integer(value(getObject(#session).GET("user_walletbalance")))
    tMsgA = getText(tOfferTypeText.getAt(pProps.getAt(#offerType)), "\\x1 costs \\x2 credits")
    tMsgA = replaceChunks(tMsgA, "\\x1", tItemName)
    tMsgA = replaceChunks(tMsgA, "\\x2", tPrice)
    tMsgB = replaceChunks(getText("catalog_credits", "You have \\x credits in your purse."), "\\x", tWallet)
  else
    if me = #creditsandpixels then
      tPriceX = integer(value(pProps.getAt(#item).getAt(#price).getAt(#credits)))
      tPriceY = integer(value(pProps.getAt(#item).getAt(#price).getAt(#pixels)))
      tWalletX = integer(value(getObject(#session).GET("user_walletbalance")))
      tWalletY = integer(value(getObject(#session).GET("user_pixelbalance")))
      tMsgA = getText(tOfferTypeText.getAt(pProps.getAt(#offerType)), "\\x1 costs \\x3 pixels and \\x2 credits")
      tMsgA = replaceChunks(tMsgA, "\\x1", tItemName)
      tMsgA = replaceChunks(tMsgA, "\\x2", tPriceX)
      tMsgA = replaceChunks(tMsgA, "\\x3", tPriceY)
      tMsgB = getText("catalog_creditsandpixels", "You have \\x credits in your purse and \\y pixels.")
      tMsgB = replaceChunks(tMsgB, "\\x", tWalletX)
      tMsgB = replaceChunks(tMsgB, "\\y", tWalletY)
    else
      if me = #pixels then
        tPrice = integer(value(pProps.getAt(#item).getAt(#price).getAt(#pixels)))
        tWallet = integer(value(getObject(#session).GET("user_pixelbalance")))
        tMsgA = getText(tOfferTypeText.getAt(pProps.getAt(#offerType)), "\\x1 costs \\x3 pixels")
        tMsgA = replaceChunks(tMsgA, "\\x1", tItemName)
        tMsgA = replaceChunks(tMsgA, "\\x3", tPrice)
        tMsgB = replaceChunks(getText("catalog_pixels", "You have \\x pixels."), "\\x", tWallet)
      end if
    end if
  end if
  activateWindowObj(pWndID)
  tWndObj.setProperty(#locZ, getWindowManager().pAvailableLocZ + 1)
  tWndObj.center()
  tWndObj.getElement("habbo_orderinfo_text_a").setText(tMsgA)
  tWndObj.getElement("habbo_orderinfo_text_b").setText(tMsgB)
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcPurchaseDialog, me.getID(), #mouseUp)
  -- UNK_80 16899
  tWndObj.lock(1)
  if not getObject(#session).GET("user_rights").getOne("fuse_trade") then
    if tWndObj.elementExists("buy_gift_ok") then
      tWndObj.getElement("buy_gift_ok").setProperty(#blend, 30)
    end if
  end if
  exit
end

on showGiftDialog(me)
  if not windowExists(pWndID) then
    return(error(me, "Cannot convert nonexisting purchase dialog", #showGiftDialog, #major))
  end if
  tWndObj = getWindow(pWndID)
  tMsgA = tWndObj.getElement("habbo_orderinfo_text_a").getText()
  tMsgB = tWndObj.getElement("habbo_orderinfo_text_b").getText()
  tWndObj.unmerge()
  if not tWndObj.merge("habbo_orderinfo_gift_dialog.window") then
    tWndObj.close()
    return(error(me, "Unable to perform merge to purchase info dialog", #showPurchaseDialog, #major))
  end if
  activateWindowObj(pWndID)
  tWndObj.setProperty(#locZ, getWindowManager().pAvailableLocZ + 1)
  tWndObj.getElement("habbo_orderinfo_text_a").setText(tMsgA)
  tWndObj.getElement("habbo_orderinfo_text_b").setText(tMsgB)
  tWndObj.registerProcedure(#eventProcKeyDown, me.getID(), #keyDown)
  exit
end

on finishPurchase(me)
  if windowExists(pWndID) then
    removeWindow(pWndID)
  end if
  if me.getaProp(#closeCatalogue) then
    executeMessage(#hide_catalogue)
  end if
  exit
end

on eventProcPurchaseDialog(me, tEvent, tSprID, tParam, tWndID)
  if me <> "habbo_decision_ok" then
    if me <> "habbo_message_ok" then
      if me = "button_ok" then
        tWndObj = getWindow(pWndID)
        if tWndObj.elementExists("shopping_gift_target") then
          tGiftReceiver = tWndObj.getElement("shopping_gift_target").getText()
          tGiftMessage = convertSpecialChars(tWndObj.getElement("shopping_greeting_field").getText(), 1)
          tExtraParam = ""
          if listp(pProps.getAt(#item).getaProp(#content)) then
            if pProps.getAt(#item).getAt(#content).count > 0 then
              tExtraParam = convertSpecialChars(pProps.getAt(#item).getAt(#content).getAt(1).getAt(#extra_param), 1)
            else
              tExtraParam = ""
            end if
          end if
          call(pProps.getAt(#method), getThread(#catalogue).getHandler(), pProps.getAt(#pageid), pProps.getAt(#item).getAt(#offercode), tExtraParam, 1, tGiftReceiver, tGiftMessage)
        else
          tExtraParam = ""
          if listp(pProps.getAt(#item).getaProp(#content)) then
            if pProps.getAt(#item).getAt(#content).count > 0 then
              tExtraParam = convertSpecialChars(pProps.getAt(#item).getAt(#content).getAt(1).getAt(#extra_param), 1)
            else
              tExtraParam = ""
            end if
          end if
          call(pProps.getAt(#method), getThread(#catalogue).getHandler(), pProps.getAt(#pageid), pProps.getAt(#item).getAt(#offercode), tExtraParam, 0)
        end if
        tWndObj.close()
        me.finishPurchase()
      else
        if me <> "habbo_decision_cancel" then
          if me <> "button_cancel" then
            if me = "close" then
              tWndObj = getWindow(pWndID)
              tWndObj.close()
              me.finishPurchase()
            else
              if me = "buy_gift_ok" then
                me.showGiftDialog()
              else
                if me = "buy_gift_cancel" then
                  me.showPurchaseDialog()
                else
                  if me = "nobalance_ok" then
                    if not textExists("url_nobalance") then
                      return(0)
                    end if
                    tSession = getObject(#session)
                    tURL = getText("url_nobalance")
                    tURL = tURL & urlEncode(tSession.GET(#userName))
                    if tSession.exists("user_checksum") then
                      tURL = tURL & "&sum=" & urlEncode(tSession.GET("user_checksum"))
                    end if
                    executeMessage(#externalLinkClick, the mouseLoc)
                    openNetPage(tURL)
                    me.hideOrderInfo()
                  else
                    if me = "subscribe" then
                      tSession = getObject(#session)
                      tOwnName = tSession.GET(#userName)
                      tURL = getText("url_subscribe")
                      tURL = tURL & urlEncode(tOwnName)
                      if tSession.exists("user_checksum") then
                        tURL = tURL & "&sum=" & urlEncode(tSession.GET("user_checksum"))
                      end if
                      executeMessage(#externalLinkClick, the mouseLoc)
                      openNetPage(tURL, "_new")
                      me.hideOrderInfo()
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
  end if
end

on eventProcKeyDown(me, tEvent, tSprID, tParam)
  if the key = "\t" then
    if not windowExists(pWndID) then
      return(0)
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
  exit
end