on construct(me)
  pCatalogID = "Catalogue_window"
  pPageLineHeight = 21
  pProductPerPage = 0
  pProductOffset = 0
  pSmallImg = image(32, 32, 24)
  pInfoWindowID = "Purchase info"
  pPurchaseOkID = getText("catalog_buyingSuccesfull")
  pPageProgramID = "Catalogue_page_prg"
  pLoaderObjID = "Catalogue_loader"
  tLoaderObj = createObject(pLoaderObjID, "Catalogue Loader Class")
  if tLoaderObj = 0 then
    return(error(me, "Failed to create LoaderObj", #construct))
  end if
  pLoadingFlag = 1
  pWriterPages = getUniqueID()
  tPlain = getStructVariable("struct.font.plain")
  tBold = getStructVariable("struct.font.bold")
  tLink = getStructVariable("struct.font.link")
  tMetrics = [#font:tBold.getaProp(#font), #fontStyle:tBold.getaProp(#fontStyle), #color:rgb("#000000")]
  createWriter(pWriterPages, tMetrics)
  registerMessage(#enterRoom, me.getID(), #hideCatalogue)
  registerMessage(#leaveRoom, me.getID(), #hideCatalogue)
  registerMessage(#changeRoom, me.getID(), #hideCatalogue)
  registerMessage(#show_catalogue, me.getID(), #showCatalogue)
  registerMessage(#hide_catalogue, me.getID(), #hideCatalogue)
  registerMessage(#show_hide_catalogue, me.getID(), #showHideCatalogue)
  return(1)
  exit
end

on deconstruct(me)
  removeUpdate(me.getID())
  if objectExists(pPageProgramID) then
    removeObject(pPageProgramID)
  end if
  me.hideCatalogue()
  me.hideOrderInfo()
  me.hidePurchaseOk()
  removeWriter(pWriterPages)
  unregisterMessage(#enterRoom, me.getID())
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#changeRoom, me.getID())
  unregisterMessage(#show_catalogue, me.getID())
  unregisterMessage(#hide_catalogue, me.getID())
  unregisterMessage(#show_hide_catalogue, me.getID())
  return(1)
  exit
end

on showHideCatalogue(me)
  if windowExists(pCatalogID) then
    return(me.hideCatalogue())
  else
    return(me.showCatalogue())
  end if
  exit
end

on showCatalogue(me)
  if not windowExists(pCatalogID) then
    me.ChangeWindowView()
    return(1)
  else
    return(0)
  end if
  exit
end

on hideCatalogue(me)
  if objectExists(pLoaderObjID) then
    getObject(pLoaderObjID).hideLoadingScreen()
  end if
  if windowExists(pCatalogID) then
    return(removeWindow(pCatalogID))
  else
    return(0)
  end if
  exit
end

on getCatalogWindow(me)
  if not windowExists(pCatalogID) then
    return(0)
  end if
  return(getWindow(pCatalogID))
  exit
end

on showOrderInfo(me, tstate, tInfo)
  if windowExists(pInfoWindowID) then
    return(0)
  end if
  if tstate = "OK" then
    tPrice = integer(value(tInfo.getAt(#price)))
    tWallet = integer(value(getObject(#session).get("user_walletbalance")))
    tMsgA = getText("catalog_costs", "\\x1 costs \\x2 credits")
    tMsgA = replaceChunks(tMsgA, "\\x1", tInfo.getAt(#name))
    tMsgA = replaceChunks(tMsgA, "\\x2", tPrice)
    tMsgB = replaceChunks(getText("catalog_credits"), "\\x", tWallet)
    pActiveOrderCode = tInfo.getAt(#code)
    tWndType = "orderinfo"
    if tWallet < value(tInfo.getAt(#price)) then
      return(me.showNoBalance(tInfo))
    end if
  else
    if tstate = "ERROR" then
      tMsgA = "Error occured!"
      tMsgB = string(tInfo)
      pActiveOrderCode = ""
      tWndType = "message"
    end if
  end if
  if not memberExists("habbo_" & tWndType & "_dialog.window") then
    return(error(me, "Window description not found:" && "habbo_" & tWndType & "_dialog.window"))
  end if
  if not createWindow(pInfoWindowID, "habbo_simple.window", void(), void(), #modal) then
    return(error(me, "Couldn't create window to show purchase info!"))
  end if
  tWndObj = getWindow(pInfoWindowID)
  if not tWndObj.merge("habbo_" & tWndType & "_dialog.window") then
    return(tWndObj.close())
  end if
  tWndObj.center()
  tWndObj.getElement("habbo_" & tWndType & "_text_a").setText(tMsgA)
  tWndObj.getElement("habbo_" & tWndType & "_text_b").setText(tMsgB)
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcInfoWnd, me.getID(), #mouseUp)
  -- UNK_80 16899
  tWndObj.lock(1)
  if not getObject(#session).get("user_rights").getOne("fuse_trade") then
    if tWndObj.elementExists("buy_gift_ok") then
      tWndObj.getElement("buy_gift_ok").setProperty(#blend, 30)
    end if
  end if
  return(1)
  exit
end

on hideOrderInfo(me)
  if not windowExists(pInfoWindowID) then
    return(0)
  end if
  removeWindow(pInfoWindowID)
  return(1)
  exit
end

on showNoBalance(me, tInfo)
  if windowExists(pInfoWindowID) then
    return(0)
  end if
  tPrice = integer(value(tInfo.getAt(#price)))
  tWallet = integer(value(getObject(#session).get("user_walletbalance")))
  tMsgA = getText("catalog_costs", "\\x1 costs \\x2 credits")
  tMsgA = replaceChunks(tMsgA, "\\x1", tInfo.getAt(#name))
  tMsgA = replaceChunks(tMsgA, "\\x2", tPrice)
  if getObject(#session).get("user_rights").getOne("fuse_buy_credits") then
    tWndFile = "habbo_orderinfo_nocredits.window"
  else
    tWndFile = "habbo_orderinfo_cantbuycredits.window"
  end if
  if not createWindow(pInfoWindowID, "habbo_simple.window", void(), void(), #modal) then
    return(error(me, "Couldn't create window to show purchase info!"))
  end if
  tWndObj = getWindow(pInfoWindowID)
  if not tWndObj.merge(tWndFile) then
    return(tWndObj.close())
  end if
  tWndObj.center()
  tWndObj.getElement("habbo_message_text_a").setText(tMsgA)
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcInfoWnd, me.getID(), #mouseUp)
  -- UNK_80 16899
  tWndObj.lock(1)
  return(1)
  exit
end

on showPurchaseOk(me)
  if not createWindow(pPurchaseOkID, "habbo_basic.window", void(), void(), #modal) then
    return(0)
  end if
  tWndObj = getWindow(pPurchaseOkID)
  if not tWndObj.merge("habbo_message_dialog.window") then
    return(tWndObj.close())
  end if
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#hidePurchaseOk, me.getID(), #mouseUp)
  tWndObj.center()
  -- UNK_80 16899
  tWndObj.getElement("habbo_message_text_b").setText(getText("catalog_itsurs"))
  if threadExists(#room) then
    getThread(#room).getInterface().getContainer().open()
  end if
  return(1)
  exit
end

on hidePurchaseOk(me, tOptionalEvent, tOptionalSprID)
  if tOptionalEvent = #mouseUp then
    if stringp(tOptionalSprID) then
      if tOptionalSprID <> "close" and tOptionalSprID <> "habbo_message_ok" then
        return(0)
      end if
    end if
  end if
  if windowExists(pPurchaseOkID) then
    removeWindow(pPurchaseOkID)
  end if
  return(1)
  exit
end

on showBuyAsGift(me, tBoolean)
  tWndObj = getWindow(pInfoWindowID)
  if tWndObj = 0 then
    return(0)
  end if
  tMsgA = tWndObj.getElement("habbo_orderinfo_text_a").getText()
  tMsgB = tWndObj.getElement("habbo_orderinfo_text_b").getText()
  tWndObj.unmerge()
  if tBoolean then
    if not tWndObj.merge("habbo_orderinfo_gift_dialog.window") then
      return(tWndObj.close())
    end if
  else
    if not tWndObj.merge("habbo_orderinfo_dialog.window") then
      return(tWndObj.close())
    end if
  end if
  -- UNK_80 16899
  tWndObj.getElement("habbo_orderinfo_text_a").setText(tMsgA)
  tWndObj.getElement("habbo_orderinfo_text_b").setText(tMsgB)
  exit
end

on saveCatalogueIndex(me, tdata)
  if not windowExists(pCatalogID) then
    return(0)
  end if
  pPagePropList = tdata
  renderPageList(me, pPagePropList)
  pActivePageID = void()
  selectPage(me, 1)
  pLoadingFlag = 0
  exit
end

on cataloguePageData(me, tdata)
  if not windowExists(pCatalogID) then
    return(0)
  end if
  if tdata.ilk <> #propList then
    return(error(me, "Incorrect Catalogue page data", #cataloguePageData))
  end if
  pCurrentPageData = tdata.duplicate()
  tLayout = pCurrentPageData.getAt("layout") & ".window"
  if not memberExists(tLayout) then
    error(me, "Catalogue page Layout not found!", #cataloguePageData)
    tLayout = "ctlg_layout1.window"
  end if
  if not voidp(pCurrentPageData.getAt("linkList")) then
    if not voidp(pCurrentPageData.getAt("id")) then
      if not voidp(pPagePropList.getAt(pCurrentPageData.getAt("id"))) then
        pPageLinkList = pCurrentPageData.getAt("linkList").duplicate()
        pPageLinkList.addAt(1, pCurrentPageData.getAt("id"))
      end if
    end if
  else
    if not voidp(pPageLinkList) then
      if not voidp(pCurrentPageData.getAt("id")) then
        if pPageLinkList.findPos(pCurrentPageData.getAt("id")) = 0 then
          pPageLinkList = void()
        end if
      end if
    end if
  end if
  ChangeWindowView(me, tLayout)
  exit
end

on ChangeWindowView(me, tWindowName)
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
      return(error(me, "Failed to open Catalogue window!!!", #ChangeWindowView))
    else
      tWndObj = getWindow(pCatalogID)
      tWndObj.center()
      tWndObj.moveBy(-30, -30)
      tWndObj.registerClient(me.getID())
      tWndObj.registerProcedure(#eventProcCatalogue, me.getID(), #mouseUp)
      tWndObj.registerProcedure(#eventProcCatalogue, me.getID(), #mouseDown)
      tWndObj.registerProcedure(#eventProcCatalogue, me.getID(), #keyDown)
    end if
  end if
  if not voidp(tWindowName) then
    try()
    tResult = tWndObj.merge(tWindowName)
    if catch() or tResult = 0 then
      tWndObj.close()
      return(error(me, "Incorrect Window Format", #ChangeWindowView))
    end if
    pOpenWindow = tWindowName
  else
    pOpenWindow = void()
  end if
  if voidp(pPagePropList) then
    tWindowName = "ctlg_loading.window"
  end if
  pProductOffset = 0
  pProductPerPage = 0
  pSelectedProduct = void()
  pLastProductNum = void()
  tFeedDataFlag = 1
  pProductPerPage = 0
  tProducts = 1
  repeat while tProducts <= 50
    tid = "ctlg_small_img_" & tProducts
    if tWndObj.elementExists(tid) then
      pProductPerPage = pProductPerPage + 1
    else
    end if
    tProducts = 1 + tProducts
  end repeat
  if me <> void() then
    if me = "ctlg_loading.window" then
      renderPageList(me)
      me.getComponent().retrieveCatalogueIndex()
      return(1)
    else
      if me = "frontpage.window" then
      else
        if me <> "ctlg_layout1.window" then
          if me = "ctlg_layout2.window" then
            if not voidp(pCurrentPageData.getAt("teaserText")) then
              tText = pCurrentPageData.getAt("teaserText")
              if tWndObj.elementExists("ctlg_description") then
                tWndObj.getElement("ctlg_description").setText(tText)
              end if
            end if
            if tWndObj.elementExists("ctlg_buy_button") then
              tWndObj.getElement("ctlg_buy_button").setProperty(#visible, 0)
            end if
            if tWndObj.elementExists("ctlg_select_product") and textExists("catalog_select_product") then
              tWndObj.getElement("ctlg_select_product").setText(getText("catalog_select_product"))
            end if
            if tWndObj.elementExists("ctlg_page_text") and textExists("catalog_page") then
              tWndObj.getElement("ctlg_page_text").setText(getText("catalog_page"))
            end if
          else
            if me <> "ctlg_productpage1.window" then
              if me <> "ctlg_productpage2.window" then
                if me <> "ctlg_productpage3.window" then
                  if me = "ctlg_productpage4.window" then
                    if voidp(pCurrentPageData.getAt("teaserImgList")) and not voidp(pCurrentPageData.getAt("productList")) then
                      if pCurrentPageData.getAt("productList").ilk = #list then
                        if pCurrentPageData.getAt("productList").count > 0 then
                          tProductNum = 1
                          repeat while tProductNum <= pCurrentPageData.getAt("productList").count
                            tProps = pCurrentPageData.getAt("productList").getAt(tProductNum)
                            tElemID = "ctlg_teaserimg_" & tProductNum
                            showPreviewImage(me, tProps, tElemID)
                            tProductNum = 1 + tProductNum
                          end repeat
                        end if
                      end if
                    end if
                    exit repeat
                  end if
                  if tFeedDataFlag then
                    feedPageData(me)
                  end if
                  if objectExists(pPageProgramID) then
                    removeObject(pPageProgramID)
                  end if
                  if pCurrentPageData.ilk = #propList then
                    if not voidp(pCurrentPageData.getAt("layout")) then
                      tDelim = the itemDelimiter
                      the itemDelimiter = "_"
                      tClassMem = "Catalogue" && pCurrentPageData.getAt("layout").getProp(#item, 2) && "Class"
                      the itemDelimiter = tDelim
                      if memberExists(tClassMem) then
                        tPageObj = createObject(pPageProgramID, tClassMem)
                        if tPageObj = 0 then
                          return(error(me, "Failed to create pageProgram", #ChangeWindowView))
                        end if
                        if getObject(pPageProgramID).handler(#define) then
                          getObject(pPageProgramID).define(pCurrentPageData)
                        end if
                      end if
                    end if
                  end if
                  pLoadingFlag = 0
                  exit
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end

on feedPageData(me)
  if pCurrentPageData.ilk <> #propList then
    return(error(me, "Incorrect Data Format", #feedPageData))
  end if
  if not windowExists(pCatalogID) then
    return()
  end if
  tWndObj = getWindow(pCatalogID)
  if tWndObj.elementExists("ctlg_header_img") then
    if not voidp(pCurrentPageData.getAt("headerImage")) then
      if pCurrentPageData.getAt("headerImage") > 0 then
        tElem = tWndObj.getElement("ctlg_header_img")
        tDestImg = tElem.getProperty(#image)
        tSourceImg = member(pCurrentPageData.getAt("headerImage")).image
        tdestrect = tDestImg.rect - tSourceImg.rect
        tMargins = rect(0, 0, 0, 0)
        tdestrect = rect(tdestrect.width / 2, tdestrect.height / 2, tSourceImg.width + tdestrect.width / 2, tdestrect.height / 2 + tSourceImg.height) + tMargins
        tDestImg.copyPixels(tSourceImg, tdestrect, tSourceImg.rect, [#ink:8])
        tElem.feedImage(tDestImg)
      end if
    end if
  end if
  if tWndObj.elementExists("ctlg_header_text") then
    if not voidp(pCurrentPageData.getAt("headerText")) then
      tWndObj.getElement("ctlg_header_text").setText(pCurrentPageData.getAt("headerText"))
    end if
  end if
  if not voidp(pCurrentPageData.getAt("textList")) then
    tTextList = pCurrentPageData.getAt("textList")
    if tTextList.ilk = #list then
      t = 1
      repeat while t <= tTextList.count
        if tWndObj.elementExists("ctlg_text_" & t) then
          tWndObj.getElement("ctlg_text_" & t).setText(tTextList.getAt(t))
        end if
        t = 1 + t
      end repeat
    end if
  end if
  if not voidp(pCurrentPageData.getAt("teaserImgList")) then
    tImgList = pCurrentPageData.getAt("teaserImgList")
    if tImgList.ilk = #list then
      t = 1
      repeat while t <= tImgList.count
        if tWndObj.elementExists("ctlg_teaserimg_" & t) then
          tElem = tWndObj.getElement("ctlg_teaserimg_" & t)
          tmember = tImgList.getAt(t)
          if tmember <> 0 then
            tDestImg = tElem.getProperty(#image)
            tSourceImg = member(tmember).image
            tdestrect = tDestImg.rect - tSourceImg.rect
            tMargins = rect(0, 0, 0, 0)
            tdestrect = rect(tdestrect.width / 2, tdestrect.height / 2, tSourceImg.width + tdestrect.width / 2, tdestrect.height / 2 + tSourceImg.height) + tMargins
            tDestImg.copyPixels(tSourceImg, tdestrect, tSourceImg.rect, [#ink:36])
            tElem.feedImage(tDestImg)
          end if
        end if
        t = 1 + t
      end repeat
    end if
  end if
  if not voidp(pCurrentPageData.getAt("teaserSpecialText")) then
    me.showSpecialText(pCurrentPageData.getAt("teaserSpecialText"))
  end if
  if not voidp(pCurrentPageData.getAt("productList")) then
    if pCurrentPageData.getAt("productList").count > 0 then
      if pProductPerPage > 0 then
        ShowSmallIcons(me)
        if voidp(pPageLinkList) then
          showProductPageCounter(me)
        end if
      else
        tNum = 1
        repeat while tNum <= 25
          tid = "ctlg_buy_" & tNum
          if tWndObj.elementExists(tid) then
            if tNum > pCurrentPageData.getAt("productList").count then
              tWndObj.getElement(tid).setProperty(#visible, 0)
            else
              tProduct = pCurrentPageData.getAt("productList").getAt(tNum)
              if not voidp(tProduct.getAt("name")) then
                if tWndObj.elementExists("ctlg_product_name_" & tNum) then
                  tWndObj.getElement("ctlg_product_name_" & tNum).setText(tProduct.getAt("name"))
                end if
              end if
              if not voidp(tProduct.getAt("description")) then
                if tWndObj.elementExists("ctlg_description_" & tNum) then
                  tWndObj.getElement("ctlg_description_" & tNum).setText(tProduct.getAt("description"))
                end if
              end if
              if not voidp(tProduct.getAt("price")) then
                if tWndObj.elementExists("ctlg_price_" & tNum) then
                  if value(tProduct.getAt("price")) > 1 then
                    tText = tProduct.getAt("price") && getText("credits", "credits")
                  else
                    tText = tProduct.getAt("price") && getText("credit", "credit")
                  end if
                  tWndObj.getElement("ctlg_price_" & tNum).setText(tText)
                end if
              end if
            end if
          else
          end if
          tNum = 1 + tNum
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
    tid = "ctlg_nextpage_button"
    if tWndObj.elementExists(tid) then
      tWndObj.getElement(tid).setProperty(#visible, 0)
    end if
    tid = "ctlg_prevpage_button"
    if tWndObj.elementExists(tid) then
      tWndObj.getElement(tid).setProperty(#visible, 0)
    end if
  end if
  tid = "ctlg_loading_bg"
  if tWndObj.elementExists(tid) then
    tWndObj.getElement(tid).setProperty(#visible, 0)
  end if
  tid = "ctlg_loading_box"
  if tWndObj.elementExists(tid) then
    tWndObj.getElement(tid).setProperty(#visible, 0)
  end if
  tid = "ctlg_loading_anim"
  if tWndObj.elementExists(tid) then
    tWndObj.getElement(tid).setProperty(#visible, 0)
  end if
  tid = "ctlg_loading_text"
  if tWndObj.elementExists(tid) then
    tWndObj.getElement(tid).setProperty(#visible, 0)
  end if
  exit
end

on showSpecialText(me, tSpecialText)
  if not windowExists(pCatalogID) then
    return()
  end if
  if tSpecialText.ilk <> #string then
    return()
  end if
  if tSpecialText.length < 2 then
    return()
  end if
  tWndObj = getWindow(pCatalogID)
  if not tWndObj.elementExists("ctlg_special_img") then
    return()
  end if
  tElem = tWndObj.getElement("ctlg_special_img")
  tDelim = the itemDelimiter
  the itemDelimiter = ":"
  ttype = integer(tSpecialText.getProp(#item, 1))
  tText = tSpecialText.getProp(#item, tSpecialText.count(#item))
  the itemDelimiter = tDelim
  if voidp(ttype) then
    ttype = 1
  end if
  tMem = "catalog_special_txtbg" & ttype
  if memberExists(tMem) then
    tDestImg = tElem.getProperty(#image)
    tSourceImg = member(getmemnum(tMem)).image
    tDestImg.fill(tDestImg.rect, rgb(255, 255, 255))
    tdestrect = tDestImg.rect - tSourceImg.rect
    tMargins = rect(0, 0, 0, 0)
    tdestrect = rect(tdestrect.width / 2, tdestrect.height / 2, tSourceImg.width + tdestrect.width / 2, tdestrect.height / 2 + tSourceImg.height) + tMargins
    tDestImg.copyPixels(tSourceImg, tdestrect, tSourceImg.rect, [#ink:8])
    tElem.feedImage(tDestImg)
  end if
  if tWndObj.elementExists("ctlg_special_txt") then
    tWndObj.getElement("ctlg_special_txt").setText(tText)
  end if
  exit
end

on hideSpecialText(me)
  if not windowExists(pCatalogID) then
    return()
  end if
  tWndObj = getWindow(pCatalogID)
  if tWndObj.elementExists("ctlg_special_img") then
    tWndObj.getElement("ctlg_special_img").clearImage()
  end if
  if tWndObj.elementExists("ctlg_special_txt") then
    tWndObj.getElement("ctlg_special_txt").setText("")
  end if
  exit
end

on showProductPageCounter(me)
  if not windowExists(pCatalogID) then
    return()
  end if
  tWndObj = getWindow(pCatalogID)
  if not voidp(pCurrentPageData.getAt("productList")) then
    if pProductPerPage >= pCurrentPageData.getAt("productList").count then
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
        tCurrent = integer(pProductOffset / pProductPerPage) + 1
        tTotalPages = float(pCurrentPageData.getAt("productList").count) / float(pProductPerPage)
        if tTotalPages - integer(tTotalPages) > 0 then
          tTotalPages = integer(tTotalPages) + 1
        else
          tTotalPages = integer(tTotalPages)
        end if
        tCounterText = string(tCurrent) & "/" & string(integer(tTotalPages))
        tWndObj.getElement("ctlg_page_counter").setText(tCounterText)
        if tCurrent = 1 then
          tNextButton = 1
          tPrewButton = 0
        else
          if tCurrent = tTotalPages then
            tNextButton = 0
            tPrewButton = 1
          else
            if tCurrent > 1 and tCurrent < tTotalPages then
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
  exit
end

on showSubPageCounter(me)
  if not windowExists(pCatalogID) then
    return(error(me, "Catalogue window not exists", #showSubPageCounter))
  end if
  tWndObj = getWindow(pCatalogID)
  if not voidp(pPageLinkList) then
    tid = pCurrentPageData.getAt("id")
    tPageNum = pPageLinkList.findPos(tid)
    if tPageNum < 1 then
      tPageNum = 1
    end if
    if tWndObj.elementExists("ctlg_subpage_counter") then
      tCounterText = tPageNum & "/" & pPageLinkList.count
      tWndObj.getElement("ctlg_subpage_counter").setText(tCounterText)
    end if
    if tPageNum = 1 then
      tPrevButton = 0
    else
      tPrevButton = 1
    end if
    if tPageNum = pPageLinkList.count then
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
  tid = "ctlg_nextpage_button"
  if tWndObj.elementExists(tid) then
    tElem = tWndObj.getElement(tid)
    if tNextButton then
      tElem.Activate(me)
      tElem.setProperty(#cursor, "cursor.finger")
    else
      tElem.deactivate(me)
      tElem.setProperty(#cursor, 0)
    end if
  end if
  tid = "ctlg_prevpage_button"
  if tWndObj.elementExists(tid) then
    tElem = tWndObj.getElement(tid)
    if tPrevButton then
      tElem.Activate(me)
      tElem.setProperty(#cursor, "cursor.finger")
    else
      tElem.deactivate(me)
      tElem.setProperty(#cursor, 0)
    end if
  end if
  exit
end

on ShowSmallIcons(me, tstate, tPram)
  if not windowExists(pCatalogID) then
    return()
  end if
  tWndObj = getWindow(pCatalogID)
  if me = void() then
    tFirst = pProductOffset + 1
    tLast = tFirst + pProductPerPage
    if tLast > pCurrentPageData.getAt("productList").count then
      tLast = pCurrentPageData.getAt("productList").count
    end if
    f = 1
    repeat while f <= pProductPerPage
      tid = "ctlg_small_img_" & f
      if tWndObj.elementExists(tid) then
        tElem = tWndObj.getElement(tid)
        tElem.clearImage()
        tElem.setProperty(#cursor, 0)
      end if
      f = 1 + f
    end repeat
    exit repeat
  end if
  if me <> #hilite then
    if me = #unhilite then
      tFirst = tPram
      tLast = tPram
    else
      return(error(me, "unsupported mode", #ShowSmallIcons))
    end if
    if voidp(tFirst) or voidp(tLast) then
      return()
    end if
    if tFirst < 1 or tLast < 1 then
      return()
    end if
    tCount = 1
    f = tFirst
    repeat while f <= tLast
      if not voidp(pCurrentPageData.getAt("productList").getAt(f).getAt("smallPrewImg")) then
        tmember = pCurrentPageData.getAt("productList").getAt(f).getAt("smallPrewImg")
        tClass = pCurrentPageData.getAt("productList").getAt(f).getAt("class")
        tpartColors = pCurrentPageData.getAt("productList").getAt(f).getAt("partColors")
        tid = "ctlg_small_img_" & f - pProductOffset
        if tmember <> 0 then
          if tWndObj.elementExists(tid) then
            tElem = tWndObj.getElement(tid)
            if not voidp(tstate) then
              if tstate = #hilite and memberExists("ctlg_small_active_bg") then
                tBgImage = getMember("ctlg_small_active_bg").image
              end if
            end if
            if tClass <> "" then
              tRenderedImage = getObject("Preview_renderer").renderPreviewImage(void(), void(), tpartColors, tClass)
            else
              tRenderedImage = member(tmember).image
            end if
            tWid = tElem.getProperty(#width)
            tHei = tElem.getProperty(#height)
            tCenteredImage = image(tWid, tHei, 32)
            if tBgImage <> void() then
              tCenteredImage.copyPixels(tBgImage, tBgImage.rect, tBgImage.rect)
            end if
            tMatte = tRenderedImage.createMatte()
            tXchange = tCenteredImage.width - tRenderedImage.width / 2
            tYchange = tCenteredImage.height - tRenderedImage.height / 2
            tRect1 = tRenderedImage.rect + rect(tXchange, tYchange, tXchange, tYchange)
            tCenteredImage.copyPixels(tRenderedImage, tRect1, tRenderedImage.rect, [#maskImage:tMatte, #ink:41])
            tElem.feedImage(tCenteredImage)
            tElem.setProperty(#cursor, "cursor.finger")
            tCount = tCount + 1
          end if
        end if
      end if
      f = 1 + f
    end repeat
    exit
  end if
end

on showPreviewImage(me, tProps, tElemID)
  if not windowExists(pCatalogID) then
    return(0)
  end if
  tWndObj = getWindow(pCatalogID)
  if voidp(tElemID) then
    tElemID = "ctlg_teaserimg_1"
  end if
  if not tWndObj.elementExists(tElemID) then
    return()
  end if
  if tProps.ilk <> #propList then
    return()
  end if
  tElem = tWndObj.getElement(tElemID)
  if voidp(tProps.getAt("prewImage")) then
    tProps.setAt("prewImage", 0)
  end if
  if tProps.getAt("prewImage") > 0 then
    tImage = member(tProps.getAt("prewImage")).image
  else
    if voidp(tProps.getAt("class")) then
      return(error(me, "Class property missing", #showPreviewImage))
    else
      tClass = tProps.getAt("class")
    end if
    if voidp(tProps.getAt("direction")) then
      return(error(me, "Direction property missing", #showPreviewImage))
    else
      tProps.setAt("direction", "2,2,2")
      tDirection = value("[" & tProps.getAt("direction") & "]")
      if tDirection.count < 3 then
        tDirection = [0, 0, 0]
      end if
    end if
    if voidp(tProps.getAt("dimensions")) then
      return(error(me, "Dimensions property missing", #showPreviewImage))
    else
      tDimensions = value("[" & tProps.getAt("dimensions") & "]")
      if tDimensions.count < 2 then
        tDimensions = [1, 1]
      end if
    end if
    if voidp(tProps.getAt("partColors")) then
      return(error(me, "PartColors property missing", #showPreviewImage))
    else
      tpartColors = tProps.getAt("partColors")
      if tpartColors = "" or tpartColors = "0,0,0" then
        tpartColors = "*ffffff"
      end if
    end if
    if voidp(tProps.getAt("objectType")) then
      return(error(me, "objectType property missing", #showPreviewImage))
    else
      tObjectType = tProps.getAt("objectType")
    end if
    tdata = []
    tdata.setAt(#id, "ctlg_previewObj")
    tdata.setAt(#class, tClass)
    tdata.setAt(#name, tClass)
    tdata.setAt(#custom, tClass)
    tdata.setAt(#direction, tDirection)
    tdata.setAt(#dimensions, tDimensions)
    tdata.setAt(#colors, tpartColors)
    tdata.setAt(#objectType, tObjectType)
    if not objectExists("ctlg_previewObj") then
      tObj = createObject("ctlg_previewObj", ["Product Preview Class"])
      if tObj = 0 then
        return(error(me, "Failed object creation!", #showHideDialog))
      end if
    else
      tObj = getObject("ctlg_previewObj")
    end if
    tObj.define(tdata.duplicate())
    tImage = tObj.getPicture()
  end if
  if tImage.ilk = #image then
    tDestImg = tElem.getProperty(#image)
    tSourceImg = tImage
    tDestImg.fill(tDestImg.rect, rgb(255, 255, 255))
    tdestrect = tDestImg.rect - tSourceImg.rect
    tMargins = rect(0, 0, 0, 0)
    tdestrect = rect(tdestrect.width / 2, tdestrect.height / 2, tSourceImg.width + tdestrect.width / 2, tdestrect.height / 2 + tSourceImg.height) + tMargins
    tDestImg.copyPixels(tSourceImg, tdestrect, tSourceImg.rect, [#ink:36])
    tElem.feedImage(tDestImg)
  end if
  return(1)
  exit
end

on renderPageList(me, tPages)
  if not windowExists(pCatalogID) then
    return(error(me, "Failed to render the list of Catalogue pages!!!", #renderPageList))
  end if
  tWndObj = getWindow(pCatalogID)
  if not tWndObj.elementExists("ctlg_pages") then
    return(error(me, "Element not exists, failed to render Catalogue index!", #f))
  end if
  tElem = tWndObj.getElement("ctlg_pages")
  tWidth = tElem.getProperty(#width)
  tHeight = tElem.getProperty(#height)
  tBgColor = rgb("#DDDDDD")
  tLeftMarg = 6
  tWriteObj = getWriter(pWriterPages)
  tVerticMarg = pPageLineHeight - tWriteObj.getFont().getAt(#lineHeight) / 2
  if tPages.ilk = #propList then
    tPageCounter = tPages.count
  else
    tPageCounter = 0
  end if
  tImgHeight = pPageLineHeight * tPageCounter + 1
  if tImgHeight < tHeight then
    tImgHeight = tHeight
  end if
  pPageListImg = image(tWidth - tLeftMarg, tImgHeight, 8)
  pPageListImg.fill(rect(0, 0, pPageListImg.width, pPageListImg.height), tBgColor)
  pPageListImg.draw(rect(0, 0, pPageListImg.width, 1), [#shapeType:#rect, #lineSize:1, #color:rgb("#AAAAAA")])
  if tPages.ilk = #propList then
    f = 1
    repeat while f <= tPages.count
      tText = tPages.getAt(f)
      tPageImg = tWriteObj.render(tText).duplicate()
      tX1 = tLeftMarg
      tX2 = tX1 + tPageImg.width
      tY1 = tVerticMarg + pPageLineHeight * f - 1 + 1
      tY2 = tY1 + tPageImg.height
      tDstRect = rect(tX1, tY1, tX2, tY2)
      pPageListImg.copyPixels(tPageImg, tDstRect, tPageImg.rect)
      pPageListImg.draw(rect(0, pPageLineHeight * f, pPageListImg.width, pPageLineHeight * f + 1), [#shapeType:#rect, #lineSize:1, #color:rgb("#AAAAAA")])
      f = 1 + f
    end repeat
  end if
  tLeftImg = member(getmemnum("ctlg.pagelist.left")).image
  pPageListImg.copyPixels(tLeftImg, rect(0, 0, tLeftImg.width, pPageListImg.height), tLeftImg.rect)
  tElem.feedImage(pPageListImg.duplicate())
  exit
end

on renderSelectPage(me, tClickLine, tLastSelectLine)
  if not windowExists(pCatalogID) then
    return(error(me, "Catalogue window not exists", #selectPage))
  end if
  tWndObj = getWindow(pCatalogID)
  tScrollOffset = 0
  if tWndObj.elementExists("ctlg_pages_scroll") then
    tScrollOffset = tWndObj.getElement("ctlg_pages_scroll").getScrollOffset()
  end if
  tElem = tWndObj.getElement("ctlg_pages")
  tImg = tElem.getProperty(#image)
  tY1 = tClickLine - 1 * pPageLineHeight + 1
  tY2 = tY1 + pPageLineHeight - 1
  tImg.fill(rect(0, tY1, tImg.width, tY2), rgb("#EEEEEE"))
  tLeftImg = member(getmemnum("ctlg.pagelist.left.active")).image
  tImg.copyPixels(tLeftImg, rect(0, tY1, tLeftImg.width, tY2), tLeftImg.rect)
  tWriteObj = getWriter(pWriterPages)
  tVerticMarg = pPageLineHeight - tWriteObj.getFont().getAt(#lineHeight) / 2
  tLeftMarg = 6
  tText = pPagePropList.getAt(tClickLine)
  tPageImg = tWriteObj.render(tText).duplicate()
  tX1 = tLeftMarg
  tX2 = tX1 + tPageImg.width
  tY1 = tVerticMarg + pPageLineHeight * tClickLine - 1 + 1
  tY2 = tY1 + tPageImg.height
  tDstRect = rect(tX1, tY1, tX2, tY2)
  tImg.copyPixels(tPageImg, tDstRect, tPageImg.rect)
  if not voidp(tLastSelectLine) then
    tY1 = tLastSelectLine - 1 * pPageLineHeight + 1
    tY2 = tY1 + pPageLineHeight - 1
    tImg.copyPixels(pPageListImg, rect(0, tY1, tImg.width, tY2), rect(0, tY1, tImg.width, tY2))
  end if
  tElem.feedImage(tImg)
  if tScrollOffset > 0 and tWndObj.elementExists("ctlg_pages_scroll") then
    tWndObj.getElement("ctlg_pages_scroll").setScrollOffset(tScrollOffset)
  end if
  exit
end

on selectPage(me, tClickLine)
  if pPagePropList.ilk <> #propList then
    return(error(me, "Incorrect PagePropList", #selectPage))
  end if
  if tClickLine > pPagePropList.count or tClickLine < 1 then
    return(error(me, "Failed to select Catalogue page!!!", #selectPage))
  end if
  tPageID = pPagePropList.getPropAt(tClickLine)
  if not voidp(pActivePageID) then
    if tPageID = pActivePageID then
      return(1)
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
  exit
end

on changeProductOffset(me, tDirection)
  if voidp(pCurrentPageData.getAt("productList").count) then
    return()
  end if
  if pProductPerPage >= pCurrentPageData.getAt("productList").count then
    return()
  end if
  if tDirection = 1 then
    if pProductOffset + pProductPerPage < pCurrentPageData.getAt("productList").count then
      pProductOffset = pProductOffset + pProductPerPage
    end if
  else
    pProductOffset = pProductOffset - pProductPerPage
    if pProductOffset < 0 then
      pProductOffset = 0
    end if
  end if
  ShowSmallIcons(me)
  showProductPageCounter(me)
  exit
end

on changeLinkPage(me, tDirection)
  if not voidp(pPageLinkList) then
    tid = pCurrentPageData.getAt("id")
    tPos = pPageLinkList.findPos(tid)
    if tPos > 0 then
      tPageNum = tPos + tDirection
      if tPageNum < 1 then
        tPageNum = 1
      end if
      if tPageNum > pPageLinkList.count then
        tPageNum = pPageLinkList.count
      end if
      if tPos <> tPageNum then
        tPageID = pPageLinkList.getAt(tPageNum)
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
  exit
end

on selectProduct(me, tOrderNum, tFeedFlag)
  if not windowExists(pCatalogID) then
    return(error(me, "Catalogue window not exists", #selectProduct))
  end if
  tWndObj = getWindow(pCatalogID)
  if not integerp(tOrderNum) then
    return(error(me, "Incorrect value", #selectProduct))
  end if
  if voidp(pCurrentPageData.getAt("productList")) then
    return(0)
  end if
  tProductNum = tOrderNum + pProductOffset
  if tProductNum = pLastProductNum then
    return(0)
  end if
  if tProductNum > pCurrentPageData.getAt("productList").count then
    return(0)
  end if
  pSelectedProduct = pCurrentPageData.getAt("productList").getAt(tProductNum)
  if pSelectedProduct.ilk <> #propList then
    return(error(me, "Incorrect product data", #selectProduct))
  end if
  if voidp(tFeedFlag) then
    tFeedFlag = 0
  end if
  if not tFeedFlag then
    return(1)
  end if
  me.showPreviewImage(pSelectedProduct)
  if not voidp(pSelectedProduct.getAt("name")) then
    if tWndObj.elementExists("ctlg_product_name") then
      tWndObj.getElement("ctlg_product_name").setText(pSelectedProduct.getAt("name"))
    end if
  end if
  if not voidp(pSelectedProduct.getAt("description")) then
    if tWndObj.elementExists("ctlg_description") then
      tWndObj.getElement("ctlg_description").setText(pSelectedProduct.getAt("description"))
    end if
  end if
  if tWndObj.elementExists("ctlg_price_box") then
    tWndObj.getElement("ctlg_price_box").setProperty(#visible, 1)
  end if
  if not voidp(pSelectedProduct.getAt("price")) then
    if tWndObj.elementExists("ctlg_price_1") then
      if value(pSelectedProduct.getAt("price")) > 1 then
        tText = pSelectedProduct.getAt("price") && getText("credits", "credits")
      else
        tText = pSelectedProduct.getAt("price") && getText("credit", "credit")
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
  if not voidp(pSelectedProduct.getAt("specialText")) then
    me.showSpecialText(pSelectedProduct.getAt("specialText"))
  end if
  pLastProductNum = tProductNum
  return(1)
  exit
end

on eventProcCatalogue(me, tEvent, tSprID, tParam)
  if tSprID <> "close" and pLoadingFlag then
    return(0)
  end if
  tClassEventFlag = 0
  if objectExists(pPageProgramID) then
    if getObject(pPageProgramID).handler(#eventProc) then
      tClassEventFlag = getObject(pPageProgramID).eventProc(tEvent, tSprID, tParam)
    end if
  end if
  if tClassEventFlag then
    return(0)
  end if
  if tEvent = #mouseUp then
    if tSprID = "close" then
      me.hideCatalogue()
    end if
  end if
  if tEvent = #mouseDown then
    if tSprID = "ctlg_pages" then
      if pPagePropList.ilk <> #propList then
        return()
      end if
      if not ilk(tParam, #point) or pPagePropList.count = 0 then
        return()
      end if
      tClickLine = integer(tParam.locV / pPageLineHeight) + 1
      selectPage(me, tClickLine)
    else
      if tSprID = "ctlg_next_button" then
        me.changeProductOffset(1)
      else
        if tSprID = "ctlg_prev_button" then
          me.changeProductOffset(-1)
        else
          if tSprID = "ctlg_nextpage_button" then
            me.changeLinkPage(1)
          else
            if tSprID = "ctlg_prevpage_button" then
              me.changeLinkPage(-1)
            else
              if tSprID contains "ctlg_small_img_" then
                tItemDeLimiter = the itemDelimiter
                the itemDelimiter = "_"
                tProductOrderNum = integer(tSprID.getProp(#item, tSprID.count(#item)))
                the itemDelimiter = tItemDeLimiter
                selectProduct(me, tProductOrderNum, 1)
              else
                if tSprID = "ctlg_buy_button" then
                  getThread(#catalogue).getComponent().checkProductOrder(pSelectedProduct)
                else
                  if tSprID contains "ctlg_buy_" then
                    tItemDeLimiter = the itemDelimiter
                    the itemDelimiter = "_"
                    tProductOrderNum = integer(tSprID.getProp(#item, tSprID.count(#item)))
                    the itemDelimiter = tItemDeLimiter
                    if me.selectProduct(tProductOrderNum, 0) then
                      getThread(#catalogue).getComponent().checkProductOrder(pSelectedProduct)
                    end if
                  else
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
  exit
end

on eventProcInfoWnd(me, tEvent, tSprID, tParam, tWndID)
  if me <> "habbo_decision_ok" then
    if me <> "habbo_message_ok" then
      if me = "button_ok" then
        if pActiveOrderCode = "" then
          removeWindow(pInfoWindowID)
          return(1)
        end if
        tWndObj = getWindow(pInfoWindowID)
        tGiftProps = []
        if tWndObj.elementExists("shopping_gift_target") then
          tGiftProps.setAt("gift", 1)
          tGiftProps.setAt("gift_receiver", tWndObj.getElement("shopping_gift_target").getText())
          tGiftProps.setAt("gift_msg", tWndObj.getElement("shopping_greeting_field").getText())
          if tGiftProps.getAt("gift_receiver") = "" then
            return(error(me, "User name missing!", #eventProcInfoWnd))
          end if
        else
          tGiftProps.setAt("gift", 0)
          tGiftProps.setAt("gift_receiver", "")
          tGiftProps.setAt("gift_msg", "")
        end if
        me.getComponent().purchaseProduct(tGiftProps)
        me.hideOrderInfo()
        pActiveOrderCode = ""
      else
        if me <> "habbo_decision_cancel" then
          if me <> "button_cancel" then
            if me = "close" then
              me.hideOrderInfo()
              pActiveOrderCode = ""
            else
              if me = "buy_gift_ok" then
                if getWindow(tWndID).getElement(tSprID).getProperty(#blend) = 100 then
                  me.showBuyAsGift(1)
                else
                end if
              else
                if me = "buy_gift_cancel" then
                  me.showBuyAsGift(0)
                else
                  if me = "nobalance_ok" then
                    if not textExists("url_nobalance") then
                      return(0)
                    end if
                    tSession = getObject(#session)
                    tURL = getText("url_nobalance")
                    tURL = tURL & urlEncode(tSession.get(#userName))
                    if tSession.exists("user_checksum") then
                      tURL = tURL & "&sum=" & urlEncode(tSession.get("user_checksum"))
                    end if
                    openNetPage(tURL, "_new")
                    me.hideOrderInfo()
                    pActiveOrderCode = ""
                  else
                    if me = "subscribe" then
                      tSession = getObject(#session)
                      tOwnName = tSession.get(#userName)
                      tURL = getText("url_subscribe")
                      tURL = tURL & urlEncode(tOwnName)
                      if tSession.exists("user_checksum") then
                        tURL = tURL & "&sum=" & urlEncode(tSession.get("user_checksum"))
                      end if
                      openNetPage(tURL, "_new")
                      me.hideOrderInfo()
                    end if
                  end if
                end if
              end if
            end if
            return(1)
            exit
          end if
        end if
      end if
    end if
  end if
end