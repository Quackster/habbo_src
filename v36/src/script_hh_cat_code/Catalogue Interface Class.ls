property pCatalogID, pWriterPages, pOpenWindow, pCurrentPageData, pPageListImg, pPagePropList, pPageLineHeight, pActivePageID, pProductPerPage, pSelectedProduct, pLastProductNum, pProductOffset, pPageLinkList, pSmallImg, pInfoWindowID, pPurchaseOkID, pPageProgramID, pLoaderObjID, pActiveOrderCode, pLoadingFlag

on construct me
  pCatalogID = "Catalogue_window"
  pPageLineHeight = 21
  pProductPerPage = 0
  pProductOffset = 0
  pSmallImg = image(32, 32, 32)
  pInfoWindowID = "Purchase info"
  pPurchaseOkID = getText("catalog_buyingSuccesfull")
  pPageProgramID = "Catalogue_page_prg"
  pLoaderObjID = "Catalogue_loader"
  tLoaderObj = createObject(pLoaderObjID, "Catalogue Loader Class")
  if (tLoaderObj = 0) then
    return error(me, "Failed to create LoaderObj", #construct, #major)
  end if
  pLoadingFlag = 1
  pWriterPages = getUniqueID()
  tPlain = getStructVariable("struct.font.plain")
  tBold = getStructVariable("struct.font.bold")
  tLink = getStructVariable("struct.font.link")
  tMetrics = [#font: tBold.getaProp(#font), #fontStyle: tBold.getaProp(#fontStyle), #color: rgb("#000000")]
  createWriter(pWriterPages, tMetrics)
  registerMessage(#enterRoom, me.getID(), #hideCatalogue)
  registerMessage(#leaveRoom, me.getID(), #hideCatalogue)
  registerMessage(#changeRoom, me.getID(), #hideCatalogue)
  registerMessage(#show_catalogue, me.getID(), #showCatalogue)
  registerMessage(#hide_catalogue, me.getID(), #hideCatalogue)
  registerMessage(#show_hide_catalogue, me.getID(), #showHideCatalogue)
  return 1
end

on deconstruct me
  removeUpdate(me.getID())
  if objectExists(pPageProgramID) then
    removeObject(pPageProgramID)
  end if
  me.hideAllWindows()
  removeWriter(pWriterPages)
  unregisterMessage(#enterRoom, me.getID())
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#changeRoom, me.getID())
  unregisterMessage(#show_catalogue, me.getID())
  unregisterMessage(#hide_catalogue, me.getID())
  unregisterMessage(#show_hide_catalogue, me.getID())
  return 1
end

on showHideCatalogue me
  if windowExists(pCatalogID) then
    return me.hideCatalogue()
  else
    return me.showCatalogue()
  end if
end

on showCatalogue me
  if not windowExists(pCatalogID) then
    tList = [:]
    tList["showDialog"] = 1
    executeMessage(#getHotelClosingStatus, tList)
    if (tList["retval"] <> 0) then
      return 1
    end if
    me.ChangeWindowView()
    return 1
  else
    return 0
  end if
end

on hideCatalogue me
  if objectExists(pLoaderObjID) then
    getObject(pLoaderObjID).hideLoadingScreen()
  end if
  tProgram = getObject(pPageProgramID)
  call(#closePage, [tProgram])
  if windowExists(pCatalogID) then
    return removeWindow(pCatalogID)
  else
    return 0
  end if
end

on getCatalogWindow me
  if not windowExists(pCatalogID) then
    return 0
  end if
  return getWindow(pCatalogID)
end

on getSelectedProduct me
  return pSelectedProduct
end

on getCurrentPageName me
  if voidp(pCurrentPageData) then
    return EMPTY
  else
    return pCurrentPageData["pageName"]
  end if
end

on showOrderInfo me, tstate, tInfo
  if windowExists(pInfoWindowID) then
    return 0
  end if
  if (tstate = "OK") then
    tPrice = integer(value(tInfo[#price]))
    tWallet = integer(value(getObject(#session).GET("user_walletbalance")))
    tMsgA = getText("catalog_costs", "\x1 costs \x2 credits")
    tMsgA = replaceChunks(tMsgA, "\x1", tInfo[#name])
    tMsgA = replaceChunks(tMsgA, "\x2", tPrice)
    tMsgB = replaceChunks(getText("catalog_credits"), "\x", tWallet)
    pActiveOrderCode = tInfo[#code]
    tWndType = "orderinfo"
    if (tWallet < value(tInfo[#price])) then
      return me.showNoBalance(tInfo)
    end if
  else
    if (tstate = "ERROR") then
      tMsgA = "Error occured!"
      tMsgB = string(tInfo)
      pActiveOrderCode = EMPTY
      tWndType = "message"
    end if
  end if
  if not memberExists((("habbo_" & tWndType) & "_dialog.window")) then
    return error(me, ((("Window description not found:" && "habbo_") & tWndType) & "_dialog.window"), #showOrderInfo, #major)
  end if
  if not createWindow(pInfoWindowID, "habbo_simple.window", VOID, VOID, #modal) then
    return error(me, "Couldn't create window to show purchase info!", #showOrderInfo, #major)
  end if
  tWndObj = getWindow(pInfoWindowID)
  if not tWndObj.merge((("habbo_" & tWndType) & "_dialog.window")) then
    tWndObj.close()
    return error(me, "Couldn't create window to show purchase info!", #showOrderInfo, #major)
  end if
  tWndObj.center()
  tWndObj.getElement((("habbo_" & tWndType) & "_text_a")).setText(tMsgA)
  tWndObj.getElement((("habbo_" & tWndType) & "_text_b")).setText(tMsgB)
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcInfoWnd, me.getID(), #mouseUp)
  tWndObj.setProperty(#locZ, 22000000)
  tWndObj.lock(1)
  if not getObject(#session).GET("user_rights").getOne("fuse_trade") then
    if tWndObj.elementExists("buy_gift_ok") then
      tWndObj.getElement("buy_gift_ok").setProperty(#blend, 30)
    end if
  end if
  return 1
end

on hideOrderInfo me
  if not windowExists(pInfoWindowID) then
    return 0
  end if
  removeWindow(pInfoWindowID)
  return 1
end

on showNoBalance me, tInfo, tGeneralText
  if windowExists(pInfoWindowID) then
    return 0
  end if
  if tGeneralText then
    tMsgA = getText("Alert_no_credits")
  else
    tPrice = integer(value(tInfo[#price]))
    tWallet = integer(value(getObject(#session).GET("user_walletbalance")))
    tMsgA = getText("catalog_costs", "\x1 costs \x2 credits")
    tMsgA = replaceChunks(tMsgA, "\x1", tInfo[#name])
    tMsgA = replaceChunks(tMsgA, "\x2", tPrice)
  end if
  if getObject(#session).GET("user_rights").getOne("fuse_buy_credits") then
    tWndFile = "habbo_orderinfo_nocredits.window"
  else
    tWndFile = "habbo_orderinfo_cantbuycredits.window"
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
  tWndObj.registerProcedure(#eventProcInfoWnd, me.getID(), #mouseUp)
  tWndObj.setProperty(#locZ, 22000000)
  tWndObj.lock(1)
  return 1
end

on showPurchaseOk me
  if not createWindow(pPurchaseOkID, "habbo_basic.window", VOID, VOID, #modal) then
    return 0
  end if
  tWndObj = getWindow(pPurchaseOkID)
  if not tWndObj.merge("habbo_message_dialog.window") then
    return tWndObj.close()
  end if
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#hidePurchaseOk, me.getID(), #mouseUp)
  tWndObj.center()
  tWndObj.setProperty(#locZ, 22000000)
  tWndObj.getElement("habbo_message_text_b").setText(getText("catalog_itsurs"))
  if threadExists(#room) then
    if (getThread(#room).getComponent().pRoomId = "private") then
      getThread(#room).getInterface().getContainer().open()
    end if
  end if
  return 1
end

on hidePurchaseOk me, tOptionalEvent, tOptionalSprID
  if (tOptionalEvent = #mouseUp) then
    if stringp(tOptionalSprID) then
      if ((tOptionalSprID <> "close") and (tOptionalSprID <> "habbo_message_ok")) then
        return 0
      end if
    end if
  end if
  if windowExists(pPurchaseOkID) then
    removeWindow(pPurchaseOkID)
  end if
  return 1
end

on showBuyAsGift me, tBoolean
  tWndObj = getWindow(pInfoWindowID)
  if (tWndObj = 0) then
    return 0
  end if
  tMsgA = tWndObj.getElement("habbo_orderinfo_text_a").getText()
  tMsgB = tWndObj.getElement("habbo_orderinfo_text_b").getText()
  tWndObj.unmerge()
  if tBoolean then
    if not tWndObj.merge("habbo_orderinfo_gift_dialog.window") then
      return tWndObj.close()
    end if
  else
    if not tWndObj.merge("habbo_orderinfo_dialog.window") then
      return tWndObj.close()
    end if
  end if
  tWndObj.setProperty(#locZ, 22000000)
  tWndObj.getElement("habbo_orderinfo_text_a").setText(tMsgA)
  tWndObj.getElement("habbo_orderinfo_text_b").setText(tMsgB)
  tWndObj.registerProcedure(#eventProcKeyDown, me.getID(), #keyDown)
end

on saveCatalogueIndex me, tdata
  if not windowExists(pCatalogID) then
    return 0
  end if
  pPagePropList = tdata
  renderPageList(me, pPagePropList)
  pActivePageID = VOID
  selectPage(me, 1)
  pLoadingFlag = 0
end

on cataloguePageData me, tdata, tForceDisplay
  if not windowExists(pCatalogID) then
    return 0
  end if
  if (tdata.ilk <> #propList) then
    return error(me, "Incorrect Catalogue page data", #cataloguePageData, #major)
  end if
  tChangeLayout = 1
  if not voidp(pCurrentPageData) then
    if (pCurrentPageData["id"] contains tdata["id"]) then
      tChangeLayout = 0
    end if
  end if
  pCurrentPageData = tdata.duplicate()
  tLayout = (pCurrentPageData["layout"] & ".window")
  if not memberExists(tLayout) then
    error(me, ("Catalogue page Layout not found: " & tLayout), #cataloguePageData, #minor)
    tLayout = "ctlg_layout1.window"
  end if
  if not voidp(pCurrentPageData["linkList"]) then
    if not voidp(pCurrentPageData["id"]) then
      if not voidp(pPagePropList[pCurrentPageData["id"]]) then
        pPageLinkList = pCurrentPageData["linkList"].duplicate()
        pPageLinkList.addAt(1, pCurrentPageData["id"])
      end if
    end if
  else
    if not voidp(pPageLinkList) then
      if not voidp(pCurrentPageData["id"]) then
        if (pPageLinkList.findPos(pCurrentPageData["id"]) = 0) then
          pPageLinkList = VOID
        end if
      end if
    end if
  end if
  if ((tChangeLayout or tForceDisplay) or objectExists(pPageProgramID)) then
    ChangeWindowView(me, tLayout)
  else
    me.feedPageData()
  end if
  pLoadingFlag = 0
end

on ChangeWindowView me, tWindowName
  tWndObj = getWindow(pCatalogID)
  if objectp(tWndObj) then
    if objectExists(pLoaderObjID) then
      getObject(pLoaderObjID).hideLoadingScreen()
    end if
    if not voidp(pOpenWindow) then
      tWndObj.unmerge()
    end if
  else
    if not createWindow(pCatalogID, "habbo_catalogue.window") then
      return error(me, "Failed to open Catalogue window!!!", #ChangeWindowView, #major)
    else
      tWndObj = getWindow(pCatalogID)
      tWndObj.center()
      tWndObj.moveBy(-60, -30)
      tWndObj.registerClient(me.getID())
      tWndObj.registerProcedure(#eventProcCatalogue, me.getID(), #mouseUp)
      tWndObj.registerProcedure(#eventProcCatalogue, me.getID(), #mouseDown)
      tWndObj.registerProcedure(#eventProcCatalogue, me.getID(), #keyDown)
    end if
  end if
  me.updatePurseSaldo()
  if not voidp(tWindowName) then
    tResult = tWndObj.merge(tWindowName)
    if (tResult = 0) then
      tWndObj.close()
      return error(me, "Incorrect Window Format", #ChangeWindowView, #major)
    end if
    pOpenWindow = tWindowName
  else
    pOpenWindow = VOID
  end if
  if voidp(pPagePropList) then
    tWindowName = "ctlg_loading.window"
  end if
  pProductOffset = 0
  pProductPerPage = 0
  pSelectedProduct = VOID
  pLastProductNum = VOID
  tFeedDataFlag = 1
  pProductPerPage = 0
  repeat with tProducts = 1 to 50
    tID = ("ctlg_small_img_" & tProducts)
    if tWndObj.elementExists(tID) then
      pProductPerPage = (pProductPerPage + 1)
      next repeat
    end if
    exit repeat
  end repeat
  if tWndObj.elementExists("ctlg_header_img") then
    tElement = tWndObj.getElement("ctlg_header_img")
    tElement.feedImage(image(tElement.getProperty(#width), tElement.getProperty(#height), 32))
  end if
  t = 1
  repeat while tWndObj.elementExists(("ctlg_teaserimg_" & t))
    tElement = tWndObj.getElement(("ctlg_teaserimg_" & t))
    tElement.feedImage(image(tElement.getProperty(#width), tElement.getProperty(#height), 32))
    t = (t + 1)
  end repeat
  case tWindowName of
    VOID, "ctlg_loading.window":
      renderPageList(me)
      me.getComponent().retrieveCatalogueIndex()
      return 1
    "frontpage.window":
      nothing()
    "ctlg_layout1.window", "ctlg_layout2.window", "ctlg_soundmachine.window":
      if not voidp(pCurrentPageData) then
        if not voidp(pCurrentPageData["teaserText"]) then
          tText = pCurrentPageData["teaserText"]
          if tWndObj.elementExists("ctlg_description") then
            tWndObj.getElement("ctlg_description").setText(tText)
          end if
        end if
      end if
      if tWndObj.elementExists("ctlg_buy_button") then
        tWndObj.getElement("ctlg_buy_button").setProperty(#visible, 0)
      end if
      if (tWndObj.elementExists("ctlg_select_product") and textExists("catalog_select_product")) then
        tWndObj.getElement("ctlg_select_product").setText(getText("catalog_select_product"))
      end if
      if (tWndObj.elementExists("ctlg_page_text") and textExists("catalog_page")) then
        tWndObj.getElement("ctlg_page_text").setText(getText("catalog_page"))
      end if
    "ctlg_productpage1.window", "ctlg_productpage2.window", "ctlg_productpage3.window", "ctlg_productpage4.window":
      if voidp(pCurrentPageData) then
        pCurrentPageData = [:]
      end if
      if (voidp(pCurrentPageData["teaserImgList"]) and not voidp(pCurrentPageData["productList"])) then
        if (pCurrentPageData["productList"].ilk = #list) then
          if (pCurrentPageData["productList"].count > 0) then
            repeat with tProductNum = 1 to pCurrentPageData["productList"].count
              tProps = pCurrentPageData["productList"][tProductNum]
              tElemID = ("ctlg_teaserimg_" & tProductNum)
              showPreviewImage(me, tProps, tElemID)
            end repeat
          end if
        end if
      end if
    "ctlg_collectibles.window":
      if voidp(pCurrentPageData) then
        pCurrentPageData = [:]
      end if
      if not voidp(pCurrentPageData["textList"]) then
        tTextList = pCurrentPageData["textList"]
        if (tTextList.ilk = #list) then
          tText = tTextList[1]
          if tWndObj.elementExists("ctlg_collectibles_link") then
            tWndObj.getElement("ctlg_collectibles_link").setText(tText)
          end if
        end if
      end if
  end case
  if tFeedDataFlag then
    feedPageData(me)
  end if
  if objectExists(pPageProgramID) then
    removeObject(pPageProgramID)
  end if
  if (pCurrentPageData.ilk = #propList) then
    if not voidp(pCurrentPageData["layout"]) then
      tDelim = the itemDelimiter
      the itemDelimiter = "_"
      tClassMem = (("Catalogue" && pCurrentPageData["layout"].item[2]) && "Class")
      the itemDelimiter = tDelim
      if memberExists(tClassMem) then
        tPageObj = createObject(pPageProgramID, tClassMem)
        if (tPageObj = 0) then
          return error(me, "Failed to create pageProgram", #ChangeWindowView, #major)
        end if
        if getObject(pPageProgramID).handler(#define) then
          getObject(pPageProgramID).define(pCurrentPageData)
        end if
      end if
    end if
  end if
  pLoadingFlag = 0
end

on feedPageData me
  if (pCurrentPageData.ilk <> #propList) then
    return error(me, "Incorrect Data Format", #feedPageData, #major)
  end if
  if not windowExists(pCatalogID) then
    return 
  end if
  tWndObj = getWindow(pCatalogID)
  if tWndObj.elementExists("ctlg_header_img") then
    if not voidp(pCurrentPageData["headerImage"]) then
      if (pCurrentPageData["headerImage"] > 0) then
        tElem = tWndObj.getElement("ctlg_header_img")
        tDestImg = tElem.getProperty(#image)
        tSourceImg = member(pCurrentPageData["headerImage"]).image
        tdestrect = (tDestImg.rect - tSourceImg.rect)
        tMargins = rect(0, 0, 0, 0)
        tdestrect = (rect((tdestrect.width / 2), (tdestrect.height / 2), (tSourceImg.width + (tdestrect.width / 2)), ((tdestrect.height / 2) + tSourceImg.height)) + tMargins)
        tDestImg.copyPixels(tSourceImg, tdestrect, tSourceImg.rect, [#ink: 8])
        tElem.feedImage(tDestImg)
      else
        tElem = tWndObj.getElement("ctlg_header_img")
        tImage = image(tElem.getProperty(#width), tElem.getProperty(#height), 32)
        tElem.feedImage(tImage)
      end if
    end if
  end if
  if tWndObj.elementExists("ctlg_header_text") then
    if not voidp(pCurrentPageData["headerText"]) then
      tWndObj.getElement("ctlg_header_text").setText(pCurrentPageData["headerText"])
    else
      tWndObj.getElement("ctlg_header_text").setText(EMPTY)
    end if
  end if
  if not voidp(pCurrentPageData["textList"]) then
    tTextList = pCurrentPageData["textList"]
    if (tTextList.ilk = #list) then
      t = 1
      repeat while (tWndObj.elementExists(("ctlg_text_" & t)) or (t < tTextList.count))
        if tWndObj.elementExists(("ctlg_text_" & t)) then
          if (tTextList.count >= t) then
            tWndObj.getElement(("ctlg_text_" & t)).setText(tTextList[t])
          else
            tWndObj.getElement(("ctlg_text_" & t)).setText(EMPTY)
          end if
        end if
        t = (t + 1)
      end repeat
    end if
  end if
  if voidp(pSelectedProduct) then
    if not voidp(pCurrentPageData["teaserImgList"]) then
      tImgList = pCurrentPageData["teaserImgList"]
      if (tImgList.ilk = #list) then
        t = 1
        repeat while tWndObj.elementExists(("ctlg_teaserimg_" & t))
          if (tImgList.count >= t) then
            tElem = tWndObj.getElement(("ctlg_teaserimg_" & t))
            tmember = tImgList[t]
            if (tmember <> 0) then
              tDestImg = tElem.getProperty(#image)
              tSourceImg = member(tmember).image
              tdestrect = (tDestImg.rect - tSourceImg.rect)
              tMargins = rect(0, 0, 0, 0)
              tdestrect = (rect((tdestrect.width / 2), (tdestrect.height / 2), (tSourceImg.width + (tdestrect.width / 2)), ((tdestrect.height / 2) + tSourceImg.height)) + tMargins)
              tDestImg.copyPixels(tSourceImg, tdestrect, tSourceImg.rect, [#ink: 36])
              tElem.feedImage(tDestImg)
            end if
          else
            tElem = tWndObj.getElement(("ctlg_teaserimg_" & t))
            tImage = image(tElem.getProperty(#width), tElem.getProperty(#height), 32)
            tElem.feedImage(tImage)
          end if
          t = (t + 1)
        end repeat
      end if
    end if
  end if
  if not voidp(pCurrentPageData["teaserSpecialText"]) then
    me.showSpecialText(pCurrentPageData["teaserSpecialText"])
  end if
  if not voidp(pCurrentPageData["productList"]) then
    if (pCurrentPageData["productList"].count > 0) then
      if (pProductPerPage > 0) then
        ShowSmallIcons(me)
        if voidp(pPageLinkList) then
          showProductPageCounter(me)
        end if
      else
        repeat with tNum = 1 to 25
          tID = ("ctlg_buy_" & tNum)
          if tWndObj.elementExists(tID) then
            if (tNum > pCurrentPageData["productList"].count) then
              tWndObj.getElement(tID).setProperty(#visible, 0)
            else
              tProduct = pCurrentPageData["productList"][tNum]
              if not voidp(tProduct["name"]) then
                if tWndObj.elementExists(("ctlg_product_name_" & tNum)) then
                  tWndObj.getElement(("ctlg_product_name_" & tNum)).setText(tProduct["name"])
                end if
              end if
              if not voidp(tProduct["description"]) then
                if tWndObj.elementExists(("ctlg_description_" & tNum)) then
                  tWndObj.getElement(("ctlg_description_" & tNum)).setText(tProduct["description"])
                end if
              end if
              if not voidp(tProduct["price"]) then
                if tWndObj.elementExists(("ctlg_price_" & tNum)) then
                  if (value(tProduct["price"]) > 1) then
                    tText = (tProduct["price"] && getText("credits", "credits"))
                  else
                    tText = (tProduct["price"] && getText("credit", "credit"))
                  end if
                  tWndObj.getElement(("ctlg_price_" & tNum)).setText(tText)
                end if
              end if
            end if
            next repeat
          end if
          exit repeat
        end repeat
      end if
    end if
  end if
  if tWndObj.elementExists("ctlg_price_box") then
    tWndObj.getElement("ctlg_price_box").setProperty(#visible, 0)
  end if
  if not voidp(pPageLinkList) then
    showSubPageCounter(me)
  else
    tID = "ctlg_nextpage_button"
    if tWndObj.elementExists(tID) then
      tWndObj.getElement(tID).setProperty(#visible, 0)
    end if
    tID = "ctlg_prevpage_button"
    if tWndObj.elementExists(tID) then
      tWndObj.getElement(tID).setProperty(#visible, 0)
    end if
  end if
  tID = "ctlg_loading_bg"
  if tWndObj.elementExists(tID) then
    tWndObj.getElement(tID).setProperty(#visible, 0)
  end if
  tID = "ctlg_loading_box"
  if tWndObj.elementExists(tID) then
    tWndObj.getElement(tID).setProperty(#visible, 0)
  end if
  tID = "ctlg_loading_anim"
  if tWndObj.elementExists(tID) then
    tWndObj.getElement(tID).setProperty(#visible, 0)
  end if
  tID = "ctlg_loading_text"
  if tWndObj.elementExists(tID) then
    tWndObj.getElement(tID).setProperty(#visible, 0)
  end if
end

on showSpecialText me, tSpecialText
  if not windowExists(pCatalogID) then
    return 
  end if
  if (tSpecialText.ilk <> #string) then
    return 
  end if
  if (tSpecialText.length < 2) then
    return 
  end if
  tWndObj = getWindow(pCatalogID)
  if not tWndObj.elementExists("ctlg_special_img") then
    return 
  end if
  tElem = tWndObj.getElement("ctlg_special_img")
  tDelim = the itemDelimiter
  the itemDelimiter = ":"
  ttype = integer(tSpecialText.item[1])
  tText = tSpecialText.item[tSpecialText.item.count]
  the itemDelimiter = tDelim
  if voidp(ttype) then
    ttype = 1
  end if
  tMem = ("catalog_special_txtbg" & ttype)
  if memberExists(tMem) then
    tDestImg = tElem.getProperty(#image)
    tSourceImg = member(getmemnum(tMem)).image
    tDestImg.fill(tDestImg.rect, rgb(255, 255, 255))
    tdestrect = (tDestImg.rect - tSourceImg.rect)
    tMargins = rect(0, 0, 0, 0)
    tdestrect = (rect((tdestrect.width / 2), (tdestrect.height / 2), (tSourceImg.width + (tdestrect.width / 2)), ((tdestrect.height / 2) + tSourceImg.height)) + tMargins)
    tDestImg.copyPixels(tSourceImg, tdestrect, tSourceImg.rect, [#ink: 8])
    tElem.feedImage(tDestImg)
  end if
  if tWndObj.elementExists("ctlg_special_txt") then
    tWndObj.getElement("ctlg_special_txt").setText(tText)
  end if
end

on hideSpecialText me
  if not windowExists(pCatalogID) then
    return 
  end if
  tWndObj = getWindow(pCatalogID)
  if tWndObj.elementExists("ctlg_special_img") then
    tWndObj.getElement("ctlg_special_img").clearImage()
  end if
  if tWndObj.elementExists("ctlg_special_txt") then
    tWndObj.getElement("ctlg_special_txt").setText(EMPTY)
  end if
end

on showProductPageCounter me
  if not windowExists(pCatalogID) then
    return 
  end if
  tWndObj = getWindow(pCatalogID)
  if voidp(pCurrentPageData) then
    return 0
  end if
  if not voidp(pCurrentPageData["productList"]) then
    if (pProductPerPage >= pCurrentPageData["productList"].count) then
      if tWndObj.elementExists("ctlg_next_button") then
        tWndObj.getElement("ctlg_next_button").setProperty(#visible, 0)
      end if
      if tWndObj.elementExists("ctlg_prev_button") then
        tWndObj.getElement("ctlg_prev_button").setProperty(#visible, 0)
      end if
      if tWndObj.elementExists("ctlg_page_counter") then
        tWndObj.getElement("ctlg_page_counter").setProperty(#visible, 0)
      end if
      if tWndObj.elementExists("ctlg_page_text") then
        tWndObj.getElement("ctlg_page_text").setProperty(#visible, 0)
      end if
    else
      if tWndObj.elementExists("ctlg_page_text") then
        tPage = getText("catalog_page", "page")
        tWndObj.getElement("ctlg_page_text").setText(tPage)
      end if
      if tWndObj.elementExists("ctlg_page_counter") then
        tCurrent = (integer((pProductOffset / pProductPerPage)) + 1)
        tTotalPages = (float(pCurrentPageData["productList"].count) / float(pProductPerPage))
        if ((tTotalPages - integer(tTotalPages)) > 0) then
          tTotalPages = (integer(tTotalPages) + 1)
        else
          tTotalPages = integer(tTotalPages)
        end if
        tCounterText = ((string(tCurrent) & "/") & string(integer(tTotalPages)))
        tWndObj.getElement("ctlg_page_counter").setText(tCounterText)
        if (tCurrent = 1) then
          tNextButton = 1
          tPrewButton = 0
        else
          if (tCurrent = tTotalPages) then
            tNextButton = 0
            tPrewButton = 1
          else
            if ((tCurrent > 1) and (tCurrent < tTotalPages)) then
              tNextButton = 1
              tPrewButton = 1
            end if
          end if
        end if
      end if
      if tWndObj.elementExists("ctlg_next_button") then
        tElem = tWndObj.getElement("ctlg_next_button")
        if tNextButton then
          tElem.Activate(me)
          tElem.setProperty(#cursor, "cursor.finger")
        else
          tElem.deactivate(me)
          tElem.setProperty(#cursor, 0)
        end if
      end if
      if tWndObj.elementExists("ctlg_prev_button") then
        tElem = tWndObj.getElement("ctlg_prev_button")
        if tPrewButton then
          tElem.Activate(me)
          tElem.setProperty(#cursor, "cursor.finger")
        else
          tElem.deactivate(me)
          tElem.setProperty(#cursor, 0)
        end if
      end if
      if tWndObj.elementExists("ctlg_next_button") then
        tWndObj.getElement("ctlg_next_button").setProperty(#visible, 1)
      end if
      if tWndObj.elementExists("ctlg_prev_button") then
        tWndObj.getElement("ctlg_prev_button").setProperty(#visible, 1)
      end if
      if tWndObj.elementExists("ctlg_page_counter") then
        tWndObj.getElement("ctlg_page_counter").setProperty(#visible, 1)
      end if
      if tWndObj.elementExists("ctlg_page_text") then
        tWndObj.getElement("ctlg_page_text").setProperty(#visible, 1)
      end if
    end if
  else
    if tWndObj.elementExists("ctlg_next_button") then
      tWndObj.getElement("ctlg_next_button").setProperty(#visible, 0)
    end if
    if tWndObj.elementExists("ctlg_prev_button") then
      tWndObj.getElement("ctlg_prev_button").setProperty(#visible, 0)
    end if
    if tWndObj.elementExists("ctlg_page_counter") then
      tWndObj.getElement("ctlg_page_counter").setProperty(#visible, 0)
    end if
    if tWndObj.elementExists("ctlg_page_text") then
      tWndObj.getElement("ctlg_page_text").setProperty(#visible, 0)
    end if
  end if
end

on showSubPageCounter me
  if not windowExists(pCatalogID) then
    return error(me, "Catalogue window not exists", #showSubPageCounter, #major)
  end if
  tWndObj = getWindow(pCatalogID)
  if not voidp(pPageLinkList) then
    tID = pCurrentPageData["id"]
    tPageNum = pPageLinkList.findPos(tID)
    if (tPageNum < 1) then
      tPageNum = 1
    end if
    if tWndObj.elementExists("ctlg_subpage_counter") then
      tCounterText = ((tPageNum & "/") & pPageLinkList.count)
      tWndObj.getElement("ctlg_subpage_counter").setText(tCounterText)
    end if
    if (tPageNum = 1) then
      tPrevButton = 0
    else
      tPrevButton = 1
    end if
    if (tPageNum = pPageLinkList.count) then
      tNextButton = 0
    else
      tNextButton = 1
    end if
  else
    tNextBlend = 40
    tPrevBlend = 40
  end if
  if tWndObj.elementExists("ctlg_page_text") then
    tPage = getText("catalog_page", "page")
    tWndObj.getElement("ctlg_page_text").setText(tPage)
  end if
  tID = "ctlg_nextpage_button"
  if tWndObj.elementExists(tID) then
    tElem = tWndObj.getElement(tID)
    if tNextButton then
      tElem.Activate(me)
      tElem.setProperty(#cursor, "cursor.finger")
    else
      tElem.deactivate(me)
      tElem.setProperty(#cursor, 0)
    end if
  end if
  tID = "ctlg_prevpage_button"
  if tWndObj.elementExists(tID) then
    tElem = tWndObj.getElement(tID)
    if tPrevButton then
      tElem.Activate(me)
      tElem.setProperty(#cursor, "cursor.finger")
    else
      tElem.deactivate(me)
      tElem.setProperty(#cursor, 0)
    end if
  end if
end

on ShowSmallIcons me, tstate, tPram
  if not windowExists(pCatalogID) then
    return 
  end if
  tWndObj = getWindow(pCatalogID)
  if objectExists(pPageProgramID) then
    if getObject(pPageProgramID).handler(#renderSmallIcons) then
      if getObject(pPageProgramID).renderSmallIcons(tstate, tPram) then
        return 
      end if
    end if
  end if
  if (ilk(pCurrentPageData) <> #propList) then
    return 0
  end if
  if (ilk(pCurrentPageData["productList"]) <> #list) then
    return 0
  end if
  case tstate of
    VOID:
      tFirst = (pProductOffset + 1)
      tLast = (tFirst + pProductPerPage)
      if (tLast > pCurrentPageData["productList"].count) then
        tLast = pCurrentPageData["productList"].count
      end if
      repeat with f = 1 to pProductPerPage
        tID = ("ctlg_small_img_" & f)
        if tWndObj.elementExists(tID) then
          tElem = tWndObj.getElement(tID)
          tElem.clearImage()
          tElem.setProperty(#cursor, 0)
        end if
      end repeat
    #hilite, #unhilite:
      tFirst = tPram
      tLast = tPram
    #furniLoaded:
      if voidp(pCurrentPageData) then
        return 0
      end if
      tFurniName = tPram
      tFirst = pCurrentPageData["productList"].count
      tLast = 1
      repeat with i = 1 to pCurrentPageData["productList"].count
        if (pCurrentPageData["productList"][i]["class"] contains tFurniName) then
          if (tFirst > i) then
            tFirst = i
          end if
          if (tLast < i) then
            tLast = i
          end if
        end if
      end repeat
  end case
  return error(me, "unsupported mode", #ShowSmallIcons, #minor)
  if (voidp(tFirst) or voidp(tLast)) then
    return 0
  end if
  if ((tFirst < 1) or (tLast < 1)) then
    return 0
  end if
  tCount = 1
  repeat with f = tFirst to tLast
    if (ilk(pCurrentPageData["productList"][f]) = #propList) then
      if not voidp(pCurrentPageData["productList"][f]["smallPrewImg"]) then
        tmember = pCurrentPageData["productList"][f]["smallPrewImg"]
        tClass = pCurrentPageData["productList"][f]["class"]
        tpartColors = pCurrentPageData["productList"][f]["partColors"]
        tDealNumber = pCurrentPageData["productList"][f]["dealNumber"]
        tDealList = pCurrentPageData["productList"][f]["dealList"]
        tID = ("ctlg_small_img_" & (f - pProductOffset))
        if ((tmember <> 0) or (not voidp(tDealNumber) and listp(tDealList))) then
          if tWndObj.elementExists(tID) then
            tElem = tWndObj.getElement(tID)
            if not voidp(tstate) then
              if ((tstate = #hilite) and memberExists("ctlg_small_active_bg")) then
                tBgImage = getMember("ctlg_small_active_bg").image
              end if
            end if
            tWid = tElem.getProperty(#width)
            tHei = tElem.getProperty(#height)
            if (tClass <> EMPTY) then
              if me.getComponent().isProductLoading(tClass, pCurrentPageData["pageName"]) then
                tRenderedImage = member(getmemnum("ctlg_loading_icon2")).image
              else
                tRenderedImage = getObject("Preview_renderer").renderPreviewImage(VOID, VOID, tpartColors, tClass)
              end if
            else
              if (tmember <> 0) then
                tRenderedImage = member(tmember).image
              else
                if not objectExists("ctlg_dealpreviewObj") then
                  tObj = createObject("ctlg_dealpreviewObj", ["Deal Preview Class"])
                  if (tObj = 0) then
                    return error(me, "Failed object creation!", #showHideDialog, #major)
                  end if
                else
                  tObj = getObject("ctlg_dealpreviewObj")
                end if
                tRenderedImage = tObj.renderDealPreviewImage(tDealNumber, tDealList, tWid, tHei)
              end if
            end if
            tCenteredImage = image(tWid, tHei, 32)
            if (tBgImage <> VOID) then
              tCenteredImage.copyPixels(tBgImage, tBgImage.rect, tBgImage.rect)
            end if
            tMatte = tRenderedImage.createMatte()
            tXchange = ((tCenteredImage.width - tRenderedImage.width) / 2)
            tYchange = ((tCenteredImage.height - tRenderedImage.height) / 2)
            tRect1 = (tRenderedImage.rect + rect(tXchange, tYchange, tXchange, tYchange))
            tCenteredImage.copyPixels(tRenderedImage, tRect1, tRenderedImage.rect, [#maskImage: tMatte, #ink: 41])
            tElem.feedImage(tCenteredImage)
            tElem.setProperty(#cursor, "cursor.finger")
            tCount = (tCount + 1)
          end if
        end if
      end if
    end if
  end repeat
end

on renderPreviewImage me, tProps
  if not voidp(tProps["dealList"]) then
    if not objectExists("ctlg_dealpreviewObj") then
      tObj = createObject("ctlg_dealpreviewObj", ["Deal Preview Class"])
      if (tObj = 0) then
        return error(me, "Failed object creation!", #renderPreviewImage, #major)
      end if
    else
      tObj = getObject("ctlg_dealpreviewObj")
    end if
    tObj.define(tProps["dealList"])
    tImage = tObj.getPicture()
  else
    if voidp(tProps["class"]) then
      return error(me, "Class property missing", #renderPreviewImage, #minor)
    else
      tClass = tProps["class"]
    end if
    if voidp(tProps["direction"]) then
      return error(me, "Direction property missing", #renderPreviewImage, #minor)
    else
      tProps["direction"] = "2,2,2"
      tDirection = value((("[" & tProps["direction"]) & "]"))
      if (tDirection.count < 3) then
        tDirection = [0, 0, 0]
      end if
    end if
    if voidp(tProps["dimensions"]) then
      return error(me, "Dimensions property missing", #renderPreviewImage, #minor)
    else
      tDimensions = value((("[" & tProps["dimensions"]) & "]"))
      if (tDimensions.count < 2) then
        tDimensions = [1, 1]
      end if
    end if
    if voidp(tProps["partColors"]) then
      return error(me, "PartColors property missing", #renderPreviewImage, #minor)
    else
      tpartColors = tProps["partColors"]
      if ((tpartColors = EMPTY) or (tpartColors = "0,0,0")) then
        tpartColors = "*ffffff"
      end if
    end if
    if voidp(tProps["objectType"]) then
      return error(me, "objectType property missing", #renderPreviewImage, #minor)
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
      if (tObj = 0) then
        return error(me, "Failed object creation!", #renderPreviewImage, #major)
      end if
    else
      tObj = getObject("ctlg_previewObj")
    end if
    tObj.define(tdata.duplicate())
    tImage = tObj.getPicture()
  end if
  return tImage
end

on showPreviewImage me, tProps, tElemID
  if not windowExists(pCatalogID) then
    return 0
  end if
  tWndObj = getWindow(pCatalogID)
  if voidp(tElemID) then
    tElemID = "ctlg_teaserimg_1"
  end if
  if not tWndObj.elementExists(tElemID) then
    return 
  end if
  if (tProps.ilk <> #propList) then
    return 
  end if
  tElem = tWndObj.getElement(tElemID)
  if voidp(tProps["prewImage"]) then
    tProps["prewImage"] = 0
  end if
  if (tProps["prewImage"] > 0) then
    tImage = member(tProps["prewImage"]).image
  else
    tImage = me.renderPreviewImage(tProps)
  end if
  if (tImage.ilk = #image) then
    tDestImg = tElem.getProperty(#image)
    tSourceImg = tImage
    tDestImg.fill(tDestImg.rect, rgb(255, 255, 255))
    tdestrect = (tDestImg.rect - tSourceImg.rect)
    tMargins = rect(0, 0, 0, 0)
    tdestrect = (rect((tdestrect.width / 2), (tdestrect.height / 2), (tSourceImg.width + (tdestrect.width / 2)), ((tdestrect.height / 2) + tSourceImg.height)) + tMargins)
    tDestImg.copyPixels(tSourceImg, tdestrect, tSourceImg.rect, [#ink: 36])
    tElem.feedImage(tDestImg)
  end if
  return 1
end

on refreshPreviewImage me, tClass, tdata
  if voidp(pCurrentPageData) then
    return 0
  end if
  if not voidp(tdata) then
    if (tdata["id"] contains pCurrentPageData["id"]) then
      pCurrentPageData = tdata.duplicate()
    end if
  end if
  if voidp(pSelectedProduct) then
    return 0
  else
    pSelectedProduct["prewImage"] = 0
  end if
  if (ilk(pCurrentPageData["productList"]) <> #list) then
    return 0
  end if
  if (pSelectedProduct["class"] = tClass) then
    repeat with i = 1 to pCurrentPageData["productList"].count
      if (pCurrentPageData["productList"][i]["class"] contains tClass) then
        pSelectedProduct = pCurrentPageData["productList"][i]
      end if
    end repeat
    me.showPreviewImage(pSelectedProduct)
  end if
end

on renderPageList me, tPages
  if variableExists("cat_index_marginv") then
    tIndexVertMargin = getVariable("cat_index_marginv")
  else
    tIndexVertMargin = 0
  end if
  if not windowExists(pCatalogID) then
    return error(me, "Failed to render the list of Catalogue pages!!!", #renderPageList, #major)
  end if
  tWndObj = getWindow(pCatalogID)
  if not tWndObj.elementExists("ctlg_pages") then
    return error(me, "Element not exists, failed to render Catalogue index!", #renderPageList, #major)
  end if
  tElem = tWndObj.getElement("ctlg_pages")
  tWidth = tElem.getProperty(#width)
  tHeight = tElem.getProperty(#height)
  tBgColor = rgb("#DDDDDD")
  tLeftMarg = 6
  tWriteObj = getWriter(pWriterPages)
  tVerticMarg = (((pPageLineHeight - tWriteObj.getFont()[#lineHeight]) / 2) + tIndexVertMargin)
  if (tPages.ilk = #propList) then
    tPageCounter = tPages.count
  else
    tPageCounter = 0
  end if
  tImgHeight = ((pPageLineHeight * tPageCounter) + 1)
  if (tImgHeight < tHeight) then
    tImgHeight = tHeight
  end if
  pPageListImg = image((tWidth - tLeftMarg), tImgHeight, 8)
  pPageListImg.fill(rect(0, 0, pPageListImg.width, pPageListImg.height), tBgColor)
  pPageListImg.draw(rect(0, 0, pPageListImg.width, 1), [#shapeType: #rect, #lineSize: 1, #color: rgb("#AAAAAA")])
  if (tPages.ilk = #propList) then
    repeat with f = 1 to tPages.count
      tText = tPages[f]
      tPageImg = tWriteObj.render(tText).duplicate()
      tX1 = tLeftMarg
      tX2 = (tX1 + tPageImg.width)
      tY1 = ((tVerticMarg + (pPageLineHeight * (f - 1))) + 1)
      tY2 = (tY1 + tPageImg.height)
      tDstRect = rect(tX1, tY1, tX2, tY2)
      pPageListImg.copyPixels(tPageImg, tDstRect, tPageImg.rect)
      pPageListImg.draw(rect(0, (pPageLineHeight * f), pPageListImg.width, ((pPageLineHeight * f) + 1)), [#shapeType: #rect, #lineSize: 1, #color: rgb("#AAAAAA")])
    end repeat
  end if
  tLeftImg = member(getmemnum("ctlg.pagelist.left")).image
  pPageListImg.copyPixels(tLeftImg, rect(0, 0, tLeftImg.width, pPageListImg.height), tLeftImg.rect)
  tElem.feedImage(pPageListImg.duplicate())
end

on renderSelectPage me, tClickLine, tLastSelectLine
  if not windowExists(pCatalogID) then
    return error(me, "Catalogue window not exists", #renderSelectPage, #major)
  end if
  tWndObj = getWindow(pCatalogID)
  tScrollOffset = 0
  if tWndObj.elementExists("ctlg_pages_scroll") then
    tScrollOffset = tWndObj.getElement("ctlg_pages_scroll").getScrollOffset()
  end if
  if variableExists("cat_index_marginv") then
    tIndexVertMargin = getVariable("cat_index_marginv")
  else
    tIndexVertMargin = 0
  end if
  tElem = tWndObj.getElement("ctlg_pages")
  tImg = tElem.getProperty(#image)
  tY1 = (((tClickLine - 1) * pPageLineHeight) + 1)
  tY2 = ((tY1 + pPageLineHeight) - 1)
  tImg.fill(rect(0, tY1, tImg.width, tY2), rgb("#EEEEEE"))
  tLeftImg = member(getmemnum("ctlg.pagelist.left.active")).image
  tImg.copyPixels(tLeftImg, rect(0, tY1, tLeftImg.width, tY2), tLeftImg.rect)
  tWriteObj = getWriter(pWriterPages)
  tVerticMarg = ((pPageLineHeight - tWriteObj.getFont()[#lineHeight]) / 2)
  tLeftMarg = 6
  tText = pPagePropList[tClickLine]
  tPageImg = tWriteObj.render(tText).duplicate()
  tX1 = tLeftMarg
  tX2 = (tX1 + tPageImg.width)
  tY1 = (((tVerticMarg + (pPageLineHeight * (tClickLine - 1))) + 1) + tIndexVertMargin)
  tY2 = (tY1 + tPageImg.height)
  tDstRect = rect(tX1, tY1, tX2, tY2)
  tImg.copyPixels(tPageImg, tDstRect, tPageImg.rect)
  if not voidp(tLastSelectLine) then
    tY1 = (((tLastSelectLine - 1) * pPageLineHeight) + 1)
    tY2 = ((tY1 + pPageLineHeight) - 1)
    tImg.copyPixels(pPageListImg, rect(0, tY1, tImg.width, tY2), rect(0, tY1, tImg.width, tY2))
  end if
  tElem.feedImage(tImg)
  if ((tScrollOffset > 0) and tWndObj.elementExists("ctlg_pages_scroll")) then
    tWndObj.getElement("ctlg_pages_scroll").setScrollOffset(tScrollOffset)
  end if
end

on selectPage me, tClickLine
  if (pPagePropList.ilk <> #propList) then
    return error(me, "Incorrect PagePropList", #selectPage, #major)
  end if
  if ((tClickLine > pPagePropList.count) or (tClickLine < 1)) then
    return error(me, "Failed to select Catalogue page!!!", #selectPage, #minor)
  end if
  tPageID = pPagePropList.getPropAt(tClickLine)
  if not voidp(pActivePageID) then
    if (tPageID = pActivePageID) then
      return 1
    end if
    tLastSelectLine = pPagePropList.findPos(pActivePageID)
  end if
  renderSelectPage(me, tClickLine, tLastSelectLine)
  pActivePageID = tPageID
  pLoadingFlag = 1
  tStatus = me.getComponent().retrieveCataloguePage(tPageID)
  if tStatus then
    if objectExists(pLoaderObjID) then
      getObject(pLoaderObjID).showLoadingScreen()
    end if
  end if
end

on changeProductOffset me, tDirection
  if voidp(pCurrentPageData) then
    return 0
  end if
  if voidp(pCurrentPageData["productList"].count) then
    return 0
  end if
  if (pProductPerPage >= pCurrentPageData["productList"].count) then
    return 0
  end if
  if (tDirection = 1) then
    if ((pProductOffset + pProductPerPage) < pCurrentPageData["productList"].count) then
      pProductOffset = (pProductOffset + pProductPerPage)
    end if
  else
    pProductOffset = (pProductOffset - pProductPerPage)
    if (pProductOffset < 0) then
      pProductOffset = 0
    end if
  end if
  ShowSmallIcons(me)
  showProductPageCounter(me)
end

on changeLinkPage me, tDirection
  if voidp(pCurrentPageData) then
    return 0
  end if
  if not voidp(pPageLinkList) then
    tID = pCurrentPageData["id"]
    tPos = pPageLinkList.findPos(tID)
    if (tPos > 0) then
      tPageNum = (tPos + tDirection)
      if (tPageNum < 1) then
        tPageNum = 1
      end if
      if (tPageNum > pPageLinkList.count) then
        tPageNum = pPageLinkList.count
      end if
      if (tPos <> tPageNum) then
        tPageID = pPageLinkList[tPageNum]
        pLoadingFlag = 1
        tStatus = me.getComponent().retrieveCataloguePage(tPageID)
        if tStatus then
          if objectExists(pLoaderObjID) then
            getObject(pLoaderObjID).showLoadingScreen()
          end if
        end if
      end if
    end if
  end if
end

on selectProduct me, tOrderNum, tFeedFlag
  if not windowExists(pCatalogID) then
    return error(me, "Catalogue window not exists", #selectProduct, #major)
  end if
  tWndObj = getWindow(pCatalogID)
  if not integerp(tOrderNum) then
    return error(me, "Incorrect value", #selectProduct, #major)
  end if
  if voidp(pCurrentPageData) then
    return 0
  end if
  if voidp(pCurrentPageData["productList"]) then
    return 0
  end if
  tProductNum = (tOrderNum + pProductOffset)
  if (tProductNum = pLastProductNum) then
    return 0
  end if
  if (tProductNum > pCurrentPageData["productList"].count) then
    return 0
  end if
  pSelectedProduct = pCurrentPageData["productList"][tProductNum]
  if (pSelectedProduct.ilk <> #propList) then
    return error(me, "Incorrect product data", #selectProduct, #major)
  end if
  if voidp(tFeedFlag) then
    tFeedFlag = 0
  end if
  if not tFeedFlag then
    return 1
  end if
  me.showPreviewImage(pSelectedProduct)
  if not voidp(pSelectedProduct["name"]) then
    if tWndObj.elementExists("ctlg_product_name") then
      tWndObj.getElement("ctlg_product_name").setText(pSelectedProduct["name"])
    end if
  end if
  if not voidp(pSelectedProduct["description"]) then
    if tWndObj.elementExists("ctlg_description") then
      tWndObj.getElement("ctlg_description").setText(pSelectedProduct["description"])
    end if
  end if
  if tWndObj.elementExists("ctlg_price_box") then
    tWndObj.getElement("ctlg_price_box").setProperty(#visible, 1)
  end if
  if not voidp(pSelectedProduct["price"]) then
    if tWndObj.elementExists("ctlg_price_1") then
      if (value(pSelectedProduct["price"]) > 1) then
        tText = (pSelectedProduct["price"] && getText("credits", "credits"))
      else
        tText = (pSelectedProduct["price"] && getText("credit", "credit"))
      end if
      tWndObj.getElement("ctlg_price_1").setText(tText)
    end if
  end if
  if tWndObj.elementExists("ctlg_buy_button") then
    tWndObj.getElement("ctlg_buy_button").setProperty(#visible, 1)
  end if
  ShowSmallIcons(me, #hilite, tProductNum)
  ShowSmallIcons(me, #unhilite, pLastProductNum)
  me.hideSpecialText()
  if not voidp(pSelectedProduct["specialText"]) then
    me.showSpecialText(pSelectedProduct["specialText"])
  end if
  pLastProductNum = tProductNum
  return 1
end

on hideAllWindows me
  me.hideCatalogue()
  me.hideOrderInfo()
  me.hidePurchaseOk()
end

on updatePurseSaldo me
  tWndObj = me.getCatalogWindow()
  if objectp(tWndObj) then
    if tWndObj.elementExists("catalog_credits_bottom") then
      if getObject(#session).exists("user_walletbalance") then
        tSaldo = getObject(#session).GET("user_walletbalance")
      else
        tSaldo = "-"
      end if
      tText = getText("catalog_coins_amount")
      tText = replaceChunks(tText, "%amount%", tSaldo)
      tWndObj.getElement("catalog_credits_bottom").setText(tText)
    end if
  end if
end

on eventProcCatalogue me, tEvent, tSprID, tParam
  tloc = the mouseLoc
  if ((tSprID <> "close") and pLoadingFlag) then
    return 0
  end if
  tClassEventFlag = 0
  if objectExists(pPageProgramID) then
    if getObject(pPageProgramID).handler(#eventProc) then
      tClassEventFlag = getObject(pPageProgramID).eventProc(tEvent, tSprID, tParam)
    end if
  end if
  if tClassEventFlag then
    return 0
  end if
  if (tEvent = #mouseUp) then
    if (tSprID = "close") then
      me.hideCatalogue()
    end if
  end if
  if (tEvent = #mouseDown) then
    if (tSprID = "ctlg_pages") then
      if (pPagePropList.ilk <> #propList) then
        return 
      end if
      if (not ilk(tParam, #point) or (pPagePropList.count = 0)) then
        return 
      end if
      tClickLine = (integer((tParam.locV / pPageLineHeight)) + 1)
      selectPage(me, tClickLine)
    else
      if (tSprID = "ctlg_next_button") then
        me.changeProductOffset(1)
      else
        if (tSprID = "ctlg_prev_button") then
          me.changeProductOffset(-1)
        else
          if (tSprID = "ctlg_nextpage_button") then
            me.changeLinkPage(1)
          else
            if (tSprID = "ctlg_prevpage_button") then
              me.changeLinkPage(-1)
            else
              if (tSprID contains "ctlg_small_img_") then
                tItemDeLimiter = the itemDelimiter
                the itemDelimiter = "_"
                tProductOrderNum = integer(tSprID.item[tSprID.item.count])
                the itemDelimiter = tItemDeLimiter
                selectProduct(me, tProductOrderNum, 1)
              else
                if (tSprID = "ctlg_buy_button") then
                  getThread(#catalogue).getComponent().checkProductOrder(pSelectedProduct)
                else
                  if (tSprID = "ctlg_collectibles_link") then
                    if variableExists("link.format.collectibles") then
                      openNetPage(getVariable("link.format.collectibles"))
                      executeMessage(#externalLinkClick, the mouseLoc)
                    end if
                  else
                    if (tSprID contains "ctlg_buy_") then
                      tItemDeLimiter = the itemDelimiter
                      the itemDelimiter = "_"
                      tProductOrderNum = integer(tSprID.item[tSprID.item.count])
                      the itemDelimiter = tItemDeLimiter
                      if me.selectProduct(tProductOrderNum, 0) then
                        getThread(#catalogue).getComponent().checkProductOrder(pSelectedProduct)
                      end if
                    else
                      if (tSprID contains "catalog_get_credits_bottom") then
                        executeMessage(#externalLinkClick, tloc)
                        openNetPage(getText("url_purselink"))
                      else
                        nothing()
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

on eventProcInfoWnd me, tEvent, tSprID, tParam, tWndID
  case tSprID of
    "habbo_decision_ok", "habbo_message_ok", "button_ok":
      if (pActiveOrderCode = EMPTY) then
        removeWindow(pInfoWindowID)
        return 1
      end if
      tWndObj = getWindow(pInfoWindowID)
      tGiftProps = [:]
      if tWndObj.elementExists("shopping_gift_target") then
        tGiftProps["gift"] = 1
        tGiftProps["gift_receiver"] = tWndObj.getElement("shopping_gift_target").getText()
        tGiftProps["gift_msg"] = tWndObj.getElement("shopping_greeting_field").getText()
        if (tGiftProps["gift_receiver"] = EMPTY) then
          return error(me, "User name missing!", #eventProcInfoWnd, #minor)
        end if
      else
        tGiftProps["gift"] = 0
        tGiftProps["gift_receiver"] = EMPTY
        tGiftProps["gift_msg"] = EMPTY
      end if
      me.getComponent().purchaseProduct(tGiftProps)
      me.hideOrderInfo()
      pActiveOrderCode = EMPTY
    "habbo_decision_cancel", "button_cancel", "close":
      me.hideOrderInfo()
      pActiveOrderCode = EMPTY
    "buy_gift_ok":
      if (getWindow(tWndID).getElement(tSprID).getProperty(#blend) = 100) then
        me.showBuyAsGift(1)
      else
      end if
    "buy_gift_cancel":
      me.showBuyAsGift(0)
    "nobalance_ok":
      if not textExists("url_nobalance") then
        return 0
      end if
      tSession = getObject(#session)
      tURL = getText("url_nobalance")
      tURL = (tURL & urlEncode(tSession.GET(#userName)))
      if tSession.exists("user_checksum") then
        tURL = ((tURL & "&sum=") & urlEncode(tSession.GET("user_checksum")))
      end if
      executeMessage(#externalLinkClick, the mouseLoc)
      openNetPage(tURL)
      me.hideOrderInfo()
      pActiveOrderCode = EMPTY
    "subscribe":
      tSession = getObject(#session)
      tOwnName = tSession.GET(#userName)
      tURL = getText("url_subscribe")
      tURL = (tURL & urlEncode(tOwnName))
      if tSession.exists("user_checksum") then
        tURL = ((tURL & "&sum=") & urlEncode(tSession.GET("user_checksum")))
      end if
      executeMessage(#externalLinkClick, the mouseLoc)
      openNetPage(tURL, "_new")
      me.hideOrderInfo()
  end case
  return 1
end

on eventProcKeyDown me, tEvent, tSprID, tParam
  if (the key = TAB) then
    if not windowExists(pInfoWindowID) then
      return 0
    end if
    tWndObj = getWindow(pInfoWindowID)
    if (tSprID = "shopping_greeting_field") then
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
