property pWndObj, pWndID, pCurrentPageObj, pTreeView, pDealPreviewObject, pLastOpenedPage, pInfoWindowID

on construct me
  pWndObj = VOID
  pCurrentPageObj = VOID
  pTreeView = VOID
  pWndID = "Catalogue"
  pDealPreviewObject = createObject("catalogue_deal_preview_object", ["Deal Preview Class"])
  pLastOpenedPage = -1
  pInfoWindowID = getText("catalog_info_window")
  registerMessage(#enterRoom, me.getID(), #hideCatalogue)
  registerMessage(#leaveRoom, me.getID(), #hideCatalogue)
  registerMessage(#changeRoom, me.getID(), #hideCatalogue)
  registerMessage(#show_catalogue, me.getID(), #showCatalogue)
  registerMessage(#hide_catalogue, me.getID(), #hideCatalogue)
  registerMessage(#show_hide_catalogue, me.getID(), #showHideCatalogue)
  registerMessage(#updateCatalogPurse, me.getID(), #updatePurseSaldo)
  registerMessage(#playPixelPurchaseSound, me.getID(), #playPixelPurchaseSound)
end

on deconstruct me
  me.destroyWindow()
  if objectExists("catalogue_deal_preview_object") then
    removeObject("catalogue_deal_preview_object")
  end if
  unregisterMessage(#enterRoom, me.getID())
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#changeRoom, me.getID())
  unregisterMessage(#show_catalogue, me.getID())
  unregisterMessage(#hide_catalogue, me.getID())
  unregisterMessage(#show_hide_catalogue, me.getID())
  unregisterMessage(#updateCatalogPurse, me.getID())
  unregisterMessage(#playPixelPurchaseSound, me.getID())
end

on displayPage me, tPageID
  sendProcessTracking(505)
  tPageData = me.getComponent().getPageData(tPageID)
  sendProcessTracking(510)
  me.showWindow()
  me.showPage(tPageData)
  me.updateTreeView()
  pLastOpenedPage = tPageID
end

on updateTreeView me
  if not (windowExists(pWndID) and objectp(pWndObj)) then
    return error(me, "Catalogue Window does not exist!", #updateTreeView, #major)
  end if
  if not objectp(pTreeView) then
    return 0
  end if
  tTreeviewImage = pTreeView.getInterface().getImage()
  if ilk(tTreeviewImage) <> #image then
    return 0
  end if
  tDestElement = pWndObj.getElement("ctlg_pages")
  if voidp(tDestElement) or (tDestElement = 0) then
    return error(me, "ctlg_pages element missing from window!", #updateTreeView, #major)
  end if
  if tTreeviewImage.height > tDestElement.getProperty(#height) then
    if pWndObj.elementExists("back_hide") then
      pWndObj.getElement("back_hide").show()
    end if
    if pWndObj.elementExists("ctlg_pages_scroll") then
      pWndObj.getElement("ctlg_pages_scroll").show()
    end if
  else
    if pWndObj.elementExists("ctlg_pages_scroll") then
      pWndObj.getElement("ctlg_pages_scroll").setScrollOffset(0)
    end if
    if pWndObj.elementExists("back_hide") then
      pWndObj.getElement("back_hide").hide()
    end if
    if pWndObj.elementExists("ctlg_pages_scroll") then
      pWndObj.getElement("ctlg_pages_scroll").hide()
    end if
  end if
  tDestElement.feedImage(tTreeviewImage)
end

on showCatalogue me
  me.getComponent().prepareFrontPage()
end

on hideCatalogue me
  me.destroyWindow()
end

on showHideCatalogue me
  if voidp(pWndObj) then
    me.showCatalogue()
  else
    me.hideCatalogue()
  end if
end

on updatePurseSaldo me
  if windowExists(pWndID) and objectp(pWndObj) then
    tSaldo = getObject(#session).GET("user_walletbalance")
    if integerp(tSaldo) then
      tElement = pWndObj.getElement("catalog_credits_bottom")
      if objectp(tElement) then
        tElement.setText(tSaldo && getText("credits", "Credits"))
      end if
    end if
    if getObject(#session).exists("user_pixelbalance") then
      tPixels = getObject(#session).GET("user_pixelbalance")
      tElement = pWndObj.getElement("catalog_pixels_bottom")
      if objectp(tElement) then
        tElement.setText(tPixels && getText("pixels", "Pixels"))
      end if
    end if
  end if
end

on getLastOpenedPage me
  return pLastOpenedPage
end

on showVoucherRedeemOk me, tProductName, tProductDesc
  if not createWindow(pInfoWindowID, "habbo_simple.window", VOID, VOID, #modal) then
    return error(me, "Couldn't create window to show purchase info!", #showNoBalance, #major)
  end if
  tWndObj = getWindow(pInfoWindowID)
  if not tWndObj.merge("habbo_message_dialog.window") then
    tWndObj.close()
    return error(me, "Couldn't create window to show purchase info!", #showNoBalance, #major)
  end if
  if tProductName <> EMPTY then
    tMsgA = getText("purse_vouchers_furni_success")
    tMsgA = tMsgA & RETURN && tProductName && tProductDesc
  else
    tMsgA = getText("purse_vouchers_success")
  end if
  tWndObj.getElement("habbo_message_text_a").setText(getText("purse_voucherbutton"))
  tWndObj.getElement("habbo_message_text_b").setText(tMsgA)
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#hidePurchaseOk, me.getID(), #mouseUp)
  tWndObj.setProperty(#locZ, 22000000)
  tWndObj.lock(1)
  if objectp(pCurrentPageObj) then
    if pCurrentPageObj.handler(#clearVoucherCodeField) then
      pCurrentPageObj.clearVoucherCodeField()
    end if
  end if
  return 1
end

on showVoucherRedeemError me, tError
  if not createWindow(pInfoWindowID, "habbo_simple.window", VOID, VOID, #modal) then
    return error(me, "Couldn't create window to show purchase info!", #showNoBalance, #major)
  end if
  tWndFile = "habbo_message_dialog.window"
  if textExists("purse_vouchers_error" & tError & "_url") then
    tWndFile = "habbo_alert_c.window"
  end if
  tWndObj = getWindow(pInfoWindowID)
  if not tWndObj.merge(tWndFile) then
    tWndObj.close()
    return error(me, "Couldn't create window to show purchase info!", #showNoBalance, #major)
  end if
  if not textExists("purse_vouchers_error" & tError & "_url") then
    tMsgA = getText("purse_vouchers_error" & tError)
    tWndObj.getElement("habbo_message_text_b").setText(tMsgA)
    tWndObj.getElement("habbo_message_text_a").setText(getText("purse_voucherbutton"))
  else
    tMsgA = getText("purse_vouchers_error" & tError)
    tLink = getSpecialServices().getPredefinedURL(getText("purse_vouchers_error" & tError & "_url"))
    tWndObj.getElement("alert_text").setText(tMsgA)
    tWndObj.getElement("alert_link").setText(tLink)
    tWndObj.getElement("alert_title").setText(getText("purse_voucherbutton"))
  end if
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#hidePurchaseOk, me.getID(), #mouseUp)
  tWndObj.setProperty(#locZ, 22000000)
  tWndObj.lock(1)
  return 1
end

on showCatalogWasPublishedDialog me
  if not createWindow(pInfoWindowID, "habbo_simple.window", VOID, VOID, #modal) then
    return error(me, "Couldn't create window to show purchase info!", #showNoBalance, #major)
  end if
  tWndFile = "habbo_alert_c.window"
  tWndObj = getWindow(pInfoWindowID)
  if not tWndObj.merge(tWndFile) then
    tWndObj.close()
  end if
  tWndObj.getElement("alert_text").setText(getText("catalog_published", "Catalog was published! Catalog data became invalid and you'll have to reopen it."))
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#hidePurchaseOk, me.getID(), #mouseUp)
  tWndObj.lock(1)
  return 1
end

on isVisible me
  return objectp(pWndObj) and windowExists(pWndID)
end

on playPixelPurchaseSound me
  playSound("plim_2", #queue, [#loopCount: 1, #infiniteloop: 0, #volume: 255])
end

on followLink me, tLinkContent
  if (tLinkContent contains "http://") or (tLinkContent contains "https://") then
    executeMessage(#externalLinkClick, the mouseLoc)
    openNetPage(getPredefinedURL(tLinkContent))
    return 
  end if
  tNodeName = tLinkContent
  tNode = me.getComponent().getNodeByName(tNodeName)
  if voidp(tNode) then
    return error(me, "Node by name '" & tNodeName & "' not found!", #handleClick)
  end if
  me.getComponent().preparePage(tNode[#pageid])
  me.activateTreeviewNodeByName(tNodeName)
end

on showWindow me
  if voidp(pWndObj) or (pWndObj = 0) then
    if not createWindow(pWndID, "habbo_catalogue.window") then
      return error(me, "Unable to create catalogue window.", #showWindow, #major)
    end if
    pWndObj = getWindow(pWndID)
    pWndObj.center()
    pWndObj.moveBy(-60, -30)
    pWndObj.registerClient(me.getID())
    pWndObj.registerProcedure(#eventProcCatalogue, me.getID(), #mouseUp)
    pWndObj.registerProcedure(#eventProcCatalogue, me.getID(), #mouseDown)
    pWndObj.registerProcedure(#eventProcCatalogue, me.getID(), #keyUp)
    pWndObj.registerProcedure(#eventProcCatalogue, me.getID(), #keyDown)
  end if
  sendProcessTracking(511)
  if not objectp(pWndObj) then
    return error(me, "No window object in catalogue!", #showWindow, #critical)
  end if
  if voidp(pTreeView) or (pTreeView = 0) then
    sendProcessTracking(512)
    pTreeView = createObject(getUniqueID(), ["Treeview Class"])
    if voidp(pTreeView) or (pTreeView = 0) then
      return error(me, "Could not create tree view", #showWindow, #critical)
    end if
    tDestElement = pWndObj.getElement("ctlg_pages")
    if tDestElement = 0 then
      return error(me, "No destination element for treeview", #showWindow, #critical)
    end if
    tIndex = me.getComponent().getCatalogIndex()
    if not voidp(tIndex) and (tIndex <> 0) then
      pTreeView.define(me.getComponent().getCatalogIndex(), tDestElement.getProperty(#width), tDestElement.getProperty(#height))
    end if
    sendProcessTracking(513)
  end if
  if not me.getComponent().getArePixelsEnabled() then
    pWndObj.getElement("pixel_icon").hide()
    pWndObj.getElement("catalog_pixels_bottom").hide()
    pWndObj.getElement("catalog_get_pixels_bottom").hide()
  end if
  sendProcessTracking(514)
  me.updatePurseSaldo()
end

on destroyWindow me
  if objectp(pWndObj) then
    if windowExists(pWndID) then
      removeWindow(pWndID)
    end if
  end if
  pWndObj = VOID
  if objectp(pCurrentPageObj) then
    if objectExists(pCurrentPageObj.getID()) then
      removeObject(pCurrentPageObj.getID())
    end if
  end if
  pCurrentPageObj = VOID
  if objectp(pTreeView) then
    if objectExists(pTreeView.getID()) then
      removeObject(pTreeView.getID())
    end if
  end if
  pTreeView = VOID
end

on showPage me, tPageData
  if not windowExists(pWndID) then
    return error(me, "Catalogue Window does not exist!", #showPage, #major)
  end if
  if objectp(pCurrentPageObj) then
    pCurrentPageObj.unmergeWindow(pWndObj)
    removeObject(pCurrentPageObj.getID())
  end if
  if variableExists("layout.class." & tPageData[#layout]) then
    tClass = getClassVariable("layout.class." & tPageData[#layout])
  else
    tClass = getClassVariable("layout.class.default")
  end if
  pCurrentPageObj = createObject("Current Catalog Page", tClass)
  if not objectp(pCurrentPageObj) or (pCurrentPageObj = 0) then
    return error(me, "Unable to create catalogpage object for page " & tPageData[#layout])
  end if
  pCurrentPageObj.define(tPageData)
  pCurrentPageObj.mergeWindow(pWndObj)
end

on activateTreeviewNodeByName me, tNodeName
  if windowExists(pWndID) then
    pTreeView.getInterface().simulateClickByName(tNodeName)
    me.updateTreeView()
  end if
end

on eventProcCatalogue me, tEvent, tSprID, tProp
  if tEvent = #mouseUp then
    case tSprID of
      "ctlg_pages":
        pTreeView.getInterface().handleClick(tProp)
        me.updateTreeView()
      "close":
        me.destroyWindow()
      "catalog_get_pixels_bottom":
        me.getComponent().preparePixelsInfoPage()
      "catalog_get_credits_bottom":
        me.getComponent().prepareCreditsInfoPage()
    end case
  end if
  if objectp(pCurrentPageObj) then
    pCurrentPageObj.handleClick(tEvent, tSprID, tProp)
  end if
end

on getCatalogWindow me
  return pWndObj
end

on getSelectedProduct me
  if objectp(pCurrentPageObj) then
    return pCurrentPageObj.pSelectedProduct
  end if
  return [:]
end

on showPreviewImage me, tProps, tElemID
  if not windowExists(pWndID) then
    error(me, "Catalogue Window does not exist!", #showPreviewImage, #major)
  end if
  tWndObj = pWndObj
  if voidp(tElemID) then
    tElemID = "ctlg_teaserimg_1"
  end if
  if not tWndObj.elementExists(tElemID) then
    return 
  end if
  if tProps.ilk <> #propList then
    return 
  end if
  tElem = tWndObj.getElement(tElemID)
  if voidp(tProps["prewImage"]) then
    tProps["prewImage"] = 0
  end if
  if tProps["prewImage"] > 0 then
    tImage = member(tProps["prewImage"]).image
  else
    tImage = me.renderPreviewImage(tProps)
  end if
  if tImage.ilk = #image then
    tDestImg = tElem.getProperty(#image)
    tSourceImg = tImage
    tDestImg.fill(tDestImg.rect, rgb(255, 255, 255))
    tdestrect = tDestImg.rect - tSourceImg.rect
    tMargins = rect(0, 0, 0, 0)
    tdestrect = rect(tdestrect.width / 2, tdestrect.height / 2, tSourceImg.width + (tdestrect.width / 2), (tdestrect.height / 2) + tSourceImg.height) + tMargins
    tDestImg.copyPixels(tSourceImg, tdestrect, tSourceImg.rect, [#ink: 36])
    tElem.feedImage(tDestImg)
  end if
  return 1
end

on renderPreviewImage me, tProps
  if not voidp(tProps["dealList"]) then
    if not objectExists("ctlg_dealpreviewObj") then
      tObj = createObject("ctlg_dealpreviewObj", ["Deal Preview Class"])
      if tObj = 0 then
        return error(me, "Failed object creation!", #showHideDialog, #major)
      end if
    else
      tObj = getObject("ctlg_dealpreviewObj")
    end if
    tObj.define(tProps["dealList"])
    tImage = tObj.getPicture()
  else
    if voidp(tProps["class"]) then
      return error(me, "Class property missing", #showPreviewImage, #minor)
    else
      tClass = tProps["class"]
    end if
    if me.getComponent().getPageItemDownloader().isAssetDownloading(me.getClassAsset(tClass)) then
      return member("ctlg_loading_icon2").image
    end if
    if voidp(tProps["direction"]) then
      return error(me, "Direction property missing", #showPreviewImage, #minor)
    else
      tProps["direction"] = "2,2,2"
      tDirection = value("[" & tProps["direction"] & "]")
      if tDirection.count < 3 then
        tDirection = [0, 0, 0]
      end if
    end if
    if voidp(tProps["dimensions"]) then
      return error(me, "Dimensions property missing", #showPreviewImage, #minor)
    else
      tDimensions = value("[" & tProps["dimensions"] & "]")
      if tDimensions.count < 2 then
        tDimensions = [1, 1]
      end if
    end if
    if voidp(tProps["partColors"]) then
      return error(me, "PartColors property missing", #showPreviewImage, #minor)
    else
      tpartColors = tProps["partColors"]
      if (tpartColors = EMPTY) or (tpartColors = "0,0,0") then
        tpartColors = "*ffffff"
      end if
    end if
    if voidp(tProps["objectType"]) then
      return error(me, "objectType property missing", #showPreviewImage, #minor)
    else
      tObjectType = tProps["objectType"]
    end if
    tdata = [:]
    tdata[#id] = "ctlg_previewObj"
    tdata[#class] = tClass
    tdata[#name] = tClass
    tdata[#custom] = tClass
    tdata[#direction] = tDirection
    tdata[#dimensions] = tDimensions
    tdata[#colors] = tpartColors
    tdata[#objectType] = tObjectType
    if not objectExists("ctlg_previewObj") then
      tObj = createObject("ctlg_previewObj", ["Product Preview Class"])
      if tObj = 0 then
        return error(me, "Failed object creation!", #showHideDialog, #major)
      end if
    else
      tObj = getObject("ctlg_previewObj")
    end if
    tObj.define(tdata.duplicate())
    tImage = tObj.getPicture()
  end if
  return tImage
end

on showNoBalance me, tNotEnoughCredits, tNotEnoughPixels
  if windowExists(pInfoWindowID) then
    return 0
  end if
  tMsgA = EMPTY
  if tNotEnoughCredits and not tNotEnoughPixels then
    tMsgA = getText("Alert_no_credits")
  else
    if tNotEnoughCredits and tNotEnoughPixels then
      tMsgA = getText("Alert_no_credits_and_pixels")
    else
      if not tNotEnoughCredits and tNotEnoughPixels then
        tMsgA = getText("Alert_no_pixels")
      end if
    end if
  end if
  if tNotEnoughCredits then
    if getObject(#session).GET("user_rights").getOne("fuse_buy_credits") then
      tWndFile = "habbo_orderinfo_nocredits.window"
    else
      tWndFile = "habbo_orderinfo_cantbuycredits.window"
    end if
  else
    tWndFile = "habbo_message_dialog.window"
  end if
  if not createWindow(pInfoWindowID, "habbo_simple.window", VOID, VOID, #modal) then
    return error(me, "Couldn't create window to show purchase info!", #showNoBalance, #major)
  end if
  tWndObj = getWindow(pInfoWindowID)
  if not tWndObj.merge(tWndFile) then
    tWndObj.close()
    return error(me, "Couldn't create window to show purchase info!", #showNoBalance, #major)
  end if
  tWndObj.center()
  tWndObj.getElement("habbo_message_text_a").setText(tMsgA)
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#hidePurchaseOk, me.getID(), #mouseUp)
  tWndObj.setProperty(#locZ, 22000000)
  tWndObj.lock(1)
  return 1
end

on showPurchaseOk me
  if not createWindow(pInfoWindowID, "habbo_basic.window", VOID, VOID, #modal) then
    return 0
  end if
  tWndObj = getWindow(pInfoWindowID)
  if not tWndObj.merge("habbo_message_dialog.window") then
    return tWndObj.close()
  end if
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#hidePurchaseOk, me.getID(), #mouseUp)
  tWndObj.center()
  tWndObj.setProperty(#locZ, 22000000)
  tWndObj.getElement("habbo_message_text_b").setText(getText("catalog_itsurs"))
  return 1
end

on hidePurchaseOk me, tOptionalEvent, tOptionalSprID
  if tOptionalEvent = #mouseUp then
    if stringp(tOptionalSprID) then
      if (tOptionalSprID = "close") or (tOptionalSprID = "habbo_message_ok") or (tOptionalSprID = "button_cancel") or (tOptionalSprID = "alert_ok") then
        if windowExists(pInfoWindowID) then
          removeWindow(pInfoWindowID)
        end if
      end if
      if tOptionalSprID = "nobalance_ok" then
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
        if windowExists(pInfoWindowID) then
          removeWindow(pInfoWindowID)
        end if
      end if
      if tOptionalSprID = "alert_link" then
        tURL = getWindow(pInfoWindowID).getElement("alert_link").getText()
        executeMessage(#externalLinkClick, the mouseLoc)
        openNetPage(tURL)
      end if
    end if
  end if
  return 1
end

on getClassAsset me, tClassName
  if ilk(tClassName) <> #string then
    return EMPTY
  end if
  tClass = tClassName
  if tClass contains "*" then
    tClass = tClass.char[1..offset("*", tClass) - 1]
  end if
  return tClass
end
