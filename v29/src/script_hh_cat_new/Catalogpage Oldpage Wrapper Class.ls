property pPageItemDownloader, pPageImplObj, pTimeOutList, pPersistentFurniData, pPersistentCatalogData, pOldPageData, pDealPreviewObj, pDealNumber, pSmallItemWidth, pSmallItemHeight, pWndObj, pSelectedProduct, pCurrentPageData, pProductPerPage, pProductOffset, pLastProductNum

on construct me 
  pWndObj = void()
  pPageImplObj = void()
  pOldPageData = void()
  pPageItemDownloader = getThread(#catalogue).getComponent().getPageItemDownloader()
  pDealPreviewObj = getObject("catalogue_deal_preview_object")
  pDealNumber = 0
  pSmallItemWidth = getMember(getVariable("productstrip.itembg.selected")).width
  pSmallItemHeight = getMember(getVariable("productstrip.itembg.selected")).height
  pCurrentPageData = void()
  pProductOffset = 0
  pProductPerPage = 0
  pPageLinkList = void()
  pSelectedProduct = void()
  pTimeOutList = []
  return(callAncestor(#construct, [me]))
end

on deconstruct me 
  pPageItemDownloader.removeCallback(me, #downloadCompleted)
  if objectp(pPageImplObj) then
    removeObject(pPageImplObj.getID())
    tCatalogWindow = getThread(#catalogue).getInterface().getCatalogWindow()
    if objectp(tCatalogWindow) then
      tCatalogWindow.unmerge()
    end if
    pPageImplObj = void()
  end if
  repeat while pTimeOutList <= undefined
    tTimeOutName = getAt(undefined, undefined)
    removeTimeout(tTimeOutName)
  end repeat
  return(callAncestor(#deconstruct, [me]))
end

on define me, tdata 
  callAncestor(#define, [me], tdata)
  if voidp(pPersistentFurniData) then
    pPersistentFurniData = getThread("dynamicdownloader").getComponent().getPersistentFurniDataObject()
  end if
  if voidp(pPersistentCatalogData) then
    pPersistentCatalogData = getThread(#catalogue).getComponent().getPersistentCatalogDataObject()
  end if
  if variableExists("catalog.oldpage.impl." & me.getProp(#pPageData, #layout)) then
    tObjectLoadList = []
    i = 0
    repeat while me.offers <= undefined
      tProduct = getAt(undefined, tdata)
      i = i + 1
      if tProduct.getCount() < 1 then
        error(me, "Offer group contains no offers", #define, #minor)
      else
        tOffer = tProduct.getOffer(1)
        if tOffer.getCount() < 1 then
          error(me, "Offer has no content", #define, #minor)
        else
          if tOffer.getCount() = 1 then
            tFurniProps = pPersistentFurniData.getProps(tOffer.getContent(1).getType(), tOffer.getContent(1).getClassId())
            if not listp(tFurniProps) then
            else
              tClass = me.getClassAsset(tFurniProps.getaProp(#class))
              if not getThread(#dynamicdownloader).getComponent().isAssetDownloaded(tClass) then
                tObjectLoadList.add([#assetId:tClass, #type:#furni, #props:[#itemIndex:i, #pageid:me.getProp(#pPageData, #pageid)]])
              else
              end if
              i = 1
              repeat while i <= tOffer.getCount()
                tDealItem = tOffer.getContent(i)
                tFurniProps = pPersistentFurniData.getProps(tDealItem.getType(), tDealItem.getClassId())
                if not listp(tFurniProps) then
                else
                  tClass = me.getClassAsset(tFurniProps.getaProp(#class))
                  if not getThread(#dynamicdownloader).getComponent().isAssetDownloaded(tClass) then
                    tObjectLoadList.add([#assetId:tClass, #type:#furni, #props:[#itemIndex:i, #pageid:me.getProp(#pPageData, #pageid)]])
                  end if
                end if
                i = 1 + i
              end repeat
            end if
            if tObjectLoadList.count > 0 then
              pPageItemDownloader.defineCallback(me, #downloadCompleted)
            end if
            repeat while me.offers <= undefined
              tLoadObject = getAt(undefined, tdata)
              pPageItemDownloader.registerDownload(tLoadObject.getAt(#type), tLoadObject.getAt(#assetId), tLoadObject.getAt(#props))
            end repeat
            pOldPageData = me.convertPageData(tdata)
            tCatalogWindow = getThread(#catalogue).getInterface().getCatalogWindow()
            tLayout = "ctlg_" & tdata.getAt(#layout) & ".window"
            tCatalogWindow.merge(tLayout)
            if tCatalogWindow.elementExists("ctlg_buy_button") then
              tCatalogWindow.getElement("ctlg_buy_button").setProperty(#visible, 0)
            end if
            pPageImplObj = createObject(getUniqueID(), getVariable("catalog.oldpage.impl." & me.getProp(#pPageData, #layout)))
            if pPageImplObj.handler(#define) then
              pPageImplObj.define(pOldPageData)
            end if
          end if
        end if
      end if
    end repeat
  end if
end

on mergeWindow me, tParentWndObj 
  pWndObj = tParentWndObj
  me.feedPageData()
  if objectp(pPageImplObj) then
    if pPageImplObj.handler(#renderSmallIcons) then
      pPageImplObj.renderSmallIcons(void())
    end if
  end if
  me.showProductPageCounter()
end

on unmergeWindow me, tParentWndObj 
  nothing()
end

on convertPageData me, tdata 
  tProductList = []
  repeat while tdata.getAt(#offers) <= undefined
    tOfferGroup = getAt(undefined, tdata)
    if tOfferGroup.getCount() < 1 then
      error(me, "Offergroup contains no offers", #convertPageData, #minor)
    else
      if tOfferGroup.getOffer(1).getCount() < 1 then
        error(me, "Offer at index 1 has no content", #convertPageData, #minor)
      else
        tProduct = [:]
        tProduct.setAt("purchaseCode", tOfferGroup.getOffer(1).getName())
        tCatalogProps = pPersistentCatalogData.getProps(tOfferGroup.getOffer(1).getName())
        if voidp(tCatalogProps) then
          tCatalogProps = [:]
        end if
        tFurniProps = pPersistentFurniData.getProps(tOfferGroup.getOffer(1).getContent(1).getType(), tOfferGroup.getOffer(1).getContent(1).getClassId())
        if voidp(tFurniProps) then
          tFurniProps = [:]
        end if
        tProduct.setAt("name", tCatalogProps.getAt(#name))
        tProduct.setAt("description", tCatalogProps.getAt(#description))
        tProduct.setAt("specialText", tCatalogProps.getAt(#specialText))
        tProduct.setAt("class", tFurniProps.getAt(#class))
        if tOfferGroup.getOffer(1).getContent(1).getExtraParam() <> "" then
          tProduct.setAt("class", tProduct.getAt("class") && tOfferGroup.getOffer(1).getContent(1).getExtraParam())
        end if
        tProduct.setAt("objectType", tFurniProps.getAt(#type))
        tProduct.setAt("direction", tFurniProps.getAt(#defaultDir))
        tProduct.setAt("dimensions", tFurniProps.getAt(#xdim) & "," & tFurniProps.getAt(#ydim))
        tProduct.setAt("partColors", tFurniProps.getAt(#partColors))
        tProduct.setAt("price", tOfferGroup.getOffer(1).getPrice(#credits))
        if not voidp(tOfferGroup.getSmallPreview()) then
          tProduct.setAt("smallPrewImg", tOfferGroup.getSmallPreview())
        else
          if pPageItemDownloader.isAssetDownloading(me.getClassAsset(tFurniProps.getAt(#class))) then
            tProduct.setAt("smallPrewImg", getMember("ctlg_loading_icon2").image)
          else
            tProduct.setAt("smallPrewImg", getMember("no_icon_small").image)
          end if
        end if
        tProductList.add(tProduct)
      end if
    end if
  end repeat
  tOut = ["id":tdata.getAt(#pageid), "pageName":tdata.getAt(#layout), "productList":tProductList]
  i = 1
  repeat while i <= tdata.getAt(#localization).getAt(#texts).count
    if i = 1 then
      tOut.addProp("headerText", tdata.getAt(#localization).getAt(#texts).getAt(i))
    end if
    if i = 2 then
      tOut.addProp("teaserText", tdata.getAt(#localization).getAt(#texts).getAt(i))
    end if
    if i = 3 then
      tOut.addProp("teaserSpecialText", tdata.getAt(#localization).getAt(#texts).getAt(i))
    end if
    if i > 3 then
      if voidp(tOut.getaProp("textList")) then
        tOut.addProp("textList", [])
      end if
      tOut.getAt("textList").append(tdata.getAt(#localization).getAt(#texts).getAt(i))
    end if
    i = 1 + i
  end repeat
  i = 1
  repeat while i <= tdata.getAt(#localization).getAt(#images).count
    if i = 1 then
      tOut.addProp("headerImage", tdata.getAt(#localization).getAt(#images).getAt(i))
    end if
    if i > 1 then
      if voidp(tOut.getaProp("teaserImgList")) then
        tOut.addProp("teaserImgList", [])
      end if
      tOut.getAt("teaserImgList").append(tdata.getAt(#localization).getAt(#images).getAt(i))
    end if
    i = 1 + i
  end repeat
  return(tOut)
end

on resolveSmallPreview me, tOffer 
  if not objectp(tOffer) then
    return(error(me, "Invalid input format", #resolveSmallPreview, #major))
  end if
  if tOffer.getCount() < 1 then
    return(error(me, "Offer has no content", #resolveSmallPreview, #major))
  end if
  tPrevMember = "ctlg_pic_"
  tOfferName = tOffer.getName()
  if memberExists(tPrevMember & "small_" & tOfferName) then
    return(getMember(tPrevMember & "small_" & tOfferName).image)
  end if
  if tOffer.getCount() = 1 then
    tFurniProps = pPersistentFurniData.getProps(tOffer.getContent(1).getType(), tOffer.getContent(1).getClassId())
    if not listp(tFurniProps) then
      return(getMember("no_icon_small").image)
    end if
    tClass = me.getClassAsset(tFurniProps.getaProp(#class))
    if getThread(#dynamicdownloader).getComponent().isAssetDownloaded(tClass) then
      tImage = getObject("Preview_renderer").renderPreviewImage(void(), void(), tFurniProps.getaProp(#partColors), tFurniProps.getaProp(#class)).duplicate()
      if tOffer.getContent(1).getProductCount() > 1 then
        if not objectp(pDealPreviewObj) then
          error(me, "Deal preview renderer object missing.", #resolveSmallPreview)
          return(tImage)
        end if
        tCountImg = pDealPreviewObj.getNumberImage(tOffer.getContent(1).getProductCount())
        tNewImg = image(tImage.width, tImage.height, 32)
        tNewImg.copyPixels(tImage, tImage.rect, tImage.rect)
        tImage = tNewImg
        if tCountImg.width + 2 > tImage.width then
          tNewImg = image(tCountImg.width + 2, tImage.height, tImage.depth)
          tNewImg.copyPixels(tImage, tImage.rect, tImage.rect)
          tImage = tNewImg
        end if
        tImage.copyPixels(tCountImg, tCountImg.rect + rect(2, 0, 2, 0), tCountImg.rect, [#ink:36])
      end if
      return(tImage)
    end if
  else
    if not objectp(pDealPreviewObj) then
      return(error(me, "Deal preview renderer object missing.", #resolveSmallPreview))
    end if
    return(pDealPreviewObj.renderDealPreviewImage(pDealNumber, me.convertOfferListToDeallist(tOffer), pSmallItemWidth, pSmallItemHeight))
  end if
  return(void())
end

on downloadCompleted me, tProps 
  if tProps.getAt(#props).getAt(#pageid) <> me.getProp(#pPageData, #pageid) then
    return()
  end if
  tDlProps = tProps.getAt(#props)
  if tDlProps.getaProp(#imagedownload) then
    if voidp(pWndObj) then
      return("\r", error(me, "Missing handle to window object!", #downloadCompleted, #major))
    end if
    if not pWndObj.elementExists(tDlProps.getAt(#element)) then
      return(error(me, "Missing target element " & tDlProps.getAt(#element), #downloadCompleted, #minor))
    end if
    tmember = getMember(tProps.getaProp(#assetId))
    if tmember.type <> #bitmap then
      return(error(me, "Downloaded member was of incorrect type!", #downloadCompleted, #major))
    end if
    me.centerBlitImageToElement(tmember.image, pWndObj.getElement(tDlProps.getAt(#element)))
  else
    if ilk(me.pPageData) <> #propList then
      return(error(me, "Pagedata was invalid", #downloadCompleted, #major))
    end if
    if ilk(pOldPageData.getAt("productList")) <> #list then
      return()
    end if
    tItemIndex = tProps.getAt(#props).getaProp(#itemIndex)
    pDealNumber = tItemIndex
    if me.count(#offers) < tItemIndex then
      return()
    end if
    tPrev = me.resolveSmallPreview(offers.getAt(tItemIndex).getOffer(1))
    if ilk(tPrev) <> #image then
      return()
    end if
    pOldPageData.getAt("productList").getAt(tItemIndex).setaProp("smallPrewImg", tPrev)
    me.getPropRef(#pPageData, #offers).getAt(tItemIndex).setSmallPreview(tPrev)
    tTimeOutName = "RefreshSmallIcon-" & tItemIndex & "-" & me.getID()
    createTimeout(tTimeOutName, 10, #renderGridPreview, me.getID(), tItemIndex, 1)
    pTimeOutList.add(tTimeOutName)
  end if
end

on renderGridPreview me, tItemIndex 
  i = 1
  repeat while i <= pTimeOutList.count
    tTimeOutName = pTimeOutList.getAt(i)
    if tTimeOutName contains "RefreshSmallIcon-" & tItemIndex & me.getID() then
      pTimeOutList.deleteAt(i)
    else
      i = 1 + i
    end if
  end repeat
  if objectp(pPageImplObj) then
    if me.count(#offers) < tItemIndex then
      return()
    end if
    #furniLoaded.ShowSmallIcons(me, offers.getAt(tItemIndex).getOffer(1).getName())
    pPageImplObj.define(pOldPageData)
  end if
end

on handleClick me, tEvent, tSprID, tProp 
  tClickHandled = 0
  if objectp(pPageImplObj) then
    tClickHandled = pPageImplObj.eventProc(tEvent, tSprID, tProp)
  end if
  if not tClickHandled then
    tloc = the mouseLoc
    if tEvent = #mouseDown then
      if tSprID = "ctlg_next_button" then
        me.changeProductOffset(1)
      else
        if tSprID = "ctlg_prev_button" then
          me.changeProductOffset(-1)
        else
          if tSprID contains "ctlg_small_img_" then
            tItemDeLimiter = the itemDelimiter
            the itemDelimiter = "_"
            tProductOrderNum = integer(tSprID.getProp(#item, tSprID.count(#item)))
            the itemDelimiter = tItemDeLimiter
            me.selectProduct(tProductOrderNum, 1)
          else
            if tSprID = "ctlg_buy_button" then
              getThread(#catalogue).getComponent().checkProductOrder(pSelectedProduct)
            else
              if tSprID = "ctlg_collectibles_link" then
                if variableExists("link.format.collectibles") then
                  openNetPage(getVariable("link.format.collectibles"))
                  executeMessage(#externalLinkClick, the mouseLoc)
                end if
              else
                nothing()
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end

on feedPageData me 
  tWndObj = pWndObj
  pCurrentPageData = pOldPageData
  if ilk(pCurrentPageData) <> #propList then
    return(0)
  end if
  pProductOffset = 0
  pProductPerPage = 0
  pLastProductNum = void()
  tFeedDataFlag = 1
  pProductPerPage = 0
  tProducts = 1
  repeat while tProducts <= 50
    tID = "ctlg_small_img_" & tProducts
    if tWndObj.elementExists(tID) then
      pProductPerPage = pProductPerPage + 1
    else
    end if
    tProducts = 1 + tProducts
  end repeat
  if tWndObj.elementExists("ctlg_header_img") then
    if not voidp(pCurrentPageData.getAt("headerImage")) then
      if pCurrentPageData.getAt("headerImage") > 0 then
        tElem = tWndObj.getElement("ctlg_header_img")
        tDestImg = tElem.getProperty(#image)
        tmember = getMember(pCurrentPageData.getAt("headerImage"))
        if tmember.memberNum > 0 and pCurrentPageData.getAt("headerImage").length > 0 then
          tSourceImg = tmember.image
          tdestrect = tDestImg.rect - tSourceImg.rect
          tMargins = rect(0, 0, 0, 0)
          tdestrect = rect((tdestrect.width / 2), (tdestrect.height / 2), tSourceImg.width + (tdestrect.width / 2), (tdestrect.height / 2) + tSourceImg.height) + tMargins
          tDestImg.copyPixels(tSourceImg, tdestrect, tSourceImg.rect, [#ink:8])
          tElem.feedImage(tDestImg)
        else
          if not pPageItemDownloader.callbackExists(me, #downloadCompleted) then
            pPageItemDownloader.defineCallback(me, #downloadCompleted)
          end if
          pPageItemDownloader.registerDownload(#bitmap, pCurrentPageData.getAt("headerImage"), [#imagedownload:1, #element:"ctlg_header_img", #assetId:pCurrentPageData.getAt("headerImage"), #pageid:me.getProp(#pPageData, #pageid)])
        end if
      else
        tElem = tWndObj.getElement("ctlg_header_img")
        tImage = image(tElem.getProperty(#width), tElem.getProperty(#height), 32)
        tElem.feedImage(tImage)
      end if
    end if
  end if
  if tWndObj.elementExists("ctlg_header_text") then
    if not voidp(pCurrentPageData.getAt("headerText")) then
      tWndObj.getElement("ctlg_header_text").setText(pCurrentPageData.getAt("headerText"))
    else
      tWndObj.getElement("ctlg_header_text").setText("")
    end if
  end if
  if not voidp(pCurrentPageData.getAt("textList")) then
    tTextList = pCurrentPageData.getAt("textList")
    if tTextList.ilk = #list then
      t = 1
      repeat while tWndObj.elementExists("ctlg_text_" & t) or t < tTextList.count
        if tWndObj.elementExists("ctlg_text_" & t) then
          if tTextList.count >= t then
            tWndObj.getElement("ctlg_text_" & t).setText(tTextList.getAt(t))
          else
            tWndObj.getElement("ctlg_text_" & t).setText("")
          end if
        end if
        t = t + 1
      end repeat
    end if
  end if
  if voidp(pSelectedProduct) then
    if not voidp(pCurrentPageData.getAt("teaserImgList")) then
      tImgList = pCurrentPageData.getAt("teaserImgList")
      if tImgList.ilk = #list then
        t = 1
        repeat while tWndObj.elementExists("ctlg_teaserimg_" & t)
          if tImgList.count >= t then
            tElem = tWndObj.getElement("ctlg_teaserimg_" & t)
            tmember = tImgList.getAt(t)
            if memberExists(tmember) and tImgList.getAt(t).length > 0 then
              tDestImg = tElem.getProperty(#image)
              tSourceImg = member(tmember).image
              tdestrect = tDestImg.rect - tSourceImg.rect
              tMargins = rect(0, 0, 0, 0)
              tdestrect = rect((tdestrect.width / 2), (tdestrect.height / 2), tSourceImg.width + (tdestrect.width / 2), (tdestrect.height / 2) + tSourceImg.height) + tMargins
              tDestImg.copyPixels(tSourceImg, tdestrect, tSourceImg.rect, [#ink:36])
              tElem.feedImage(tDestImg)
            else
              if not pPageItemDownloader.callbackExists(me, #downloadCompleted) then
                pPageItemDownloader.defineCallback(me, #downloadCompleted)
              end if
              pPageItemDownloader.registerDownload(#bitmap, tImgList.getAt(t), [#imagedownload:1, #element:"ctlg_teaserimg_" & t, #assetId:tImgList.getAt(t), #pageid:me.getProp(#pPageData, #pageid)])
            end if
          else
            tElem = tWndObj.getElement("ctlg_teaserimg_" & t)
            tImage = image(tElem.getProperty(#width), tElem.getProperty(#height), 32)
            tElem.feedImage(tImage)
          end if
          t = t + 1
        end repeat
      end if
    end if
  end if
  if not voidp(pCurrentPageData.getAt("teaserSpecialText")) then
    me.showSpecialText(pCurrentPageData.getAt("teaserSpecialText"))
  end if
  if not voidp(pCurrentPageData.getAt("productList")) then
    if pCurrentPageData.getAt("productList").count > 0 then
      if pProductPerPage > 0 then
        ShowSmallIcons(me)
      else
        tNum = 1
        repeat while tNum <= 25
          tID = "ctlg_buy_" & tNum
          if tWndObj.elementExists(tID) then
            if tNum > pCurrentPageData.getAt("productList").count then
              tWndObj.getElement(tID).setProperty(#visible, 0)
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
end

on showSpecialText me, tSpecialText 
  tWndObj = pWndObj
  pCurrentPageData = pOldPageData
  if tSpecialText.ilk <> #string then
    return()
  end if
  if tSpecialText.length < 2 then
    return()
  end if
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
    tdestrect = rect((tdestrect.width / 2), (tdestrect.height / 2), tSourceImg.width + (tdestrect.width / 2), (tdestrect.height / 2) + tSourceImg.height) + tMargins
    tDestImg.copyPixels(tSourceImg, tdestrect, tSourceImg.rect, [#ink:8])
    tElem.feedImage(tDestImg)
  end if
  if tWndObj.elementExists("ctlg_special_txt") then
    tWndObj.getElement("ctlg_special_txt").setText(tText)
  end if
end

on ShowSmallIcons me, tstate, tPram 
  tWndObj = pWndObj
  if ilk(pCurrentPageData) <> #propList then
    return(0)
  end if
  if objectp(pPageImplObj) then
    if pPageImplObj.handler(#renderSmallIcons) then
      if pPageImplObj.renderSmallIcons(tstate, tPram) then
        return()
      end if
    end if
  end if
  if ilk(pCurrentPageData.getAt("productList")) <> #list then
    return()
  end if
  if tstate = void() then
    tFirst = pProductOffset + 1
    tLast = tFirst + pProductPerPage
    if tLast > pCurrentPageData.getAt("productList").count then
      tLast = pCurrentPageData.getAt("productList").count
    end if
    f = 1
    repeat while f <= pProductPerPage
      tID = "ctlg_small_img_" & f
      if tWndObj.elementExists(tID) then
        tElem = tWndObj.getElement(tID)
        tElem.clearImage()
        tElem.setProperty(#cursor, 0)
      end if
      f = 1 + f
    end repeat
    exit repeat
  end if
  if tstate <> #hilite then
    if tstate = #unhilite then
      tFirst = tPram
      tLast = tPram
    else
      if tstate = #furniLoaded then
        if voidp(pCurrentPageData) then
          return()
        end if
        tFurniName = tPram
        tFirst = pCurrentPageData.getAt("productList").count
        tLast = 1
        i = 1
        repeat while i <= pCurrentPageData.getAt("productList").count
          if pCurrentPageData.getAt("productList").getAt(i).getAt("purchaseCode") contains tFurniName then
            if tFirst > i then
              tFirst = i
            end if
            if tLast < i then
              tLast = i
            end if
          end if
          i = 1 + i
        end repeat
        exit repeat
      end if
      return(error(me, "unsupported mode", #ShowSmallIcons, #minor))
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
        tDealNumber = pCurrentPageData.getAt("productList").getAt(f).getAt("dealNumber")
        tDealList = pCurrentPageData.getAt("productList").getAt(f).getAt("dealList")
        tID = "ctlg_small_img_" & f - pProductOffset
        if tmember <> 0 or not voidp(tDealNumber) and listp(tDealList) then
          if tWndObj.elementExists(tID) then
            tElem = tWndObj.getElement(tID)
            if not voidp(tstate) then
              if tstate = #hilite and memberExists("ctlg_small_active_bg") then
                tBgImage = getMember("ctlg_small_active_bg").image
              end if
            end if
            tWid = tElem.getProperty(#width)
            tHei = tElem.getProperty(#height)
            if tClass <> "" then
              if pPageItemDownloader.isAssetDownloading(me.getClassAsset(tClass)) then
                tRenderedImage = member(getmemnum("ctlg_loading_icon2")).image
              else
                tRenderedImage = getObject("Preview_renderer").renderPreviewImage(void(), void(), tpartColors, tClass)
              end if
            else
              if tmember <> 0 then
                tRenderedImage = member(tmember).image
              else
                if not objectExists("ctlg_dealpreviewObj") then
                  tObj = createObject("ctlg_dealpreviewObj", ["Deal Preview Class"])
                  if tObj = 0 then
                    return(error(me, "Failed object creation!", #showHideDialog, #major))
                  end if
                else
                  tObj = getObject("ctlg_dealpreviewObj")
                end if
                tRenderedImage = tObj.renderDealPreviewImage(tDealNumber, tDealList, tWid, tHei)
              end if
            end if
            tCenteredImage = image(tWid, tHei, 32)
            if tBgImage <> void() then
              tCenteredImage.copyPixels(tBgImage, tBgImage.rect, tBgImage.rect)
            end if
            tMatte = tRenderedImage.createMatte()
            tXchange = (tCenteredImage.width - tRenderedImage.width / 2)
            tYchange = (tCenteredImage.height - tRenderedImage.height / 2)
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
  end if
end

on renderPreviewImage me, tProps 
  if not voidp(tProps.getAt("dealList")) then
    if not objectExists("ctlg_dealpreviewObj") then
      tObj = createObject("ctlg_dealpreviewObj", ["Deal Preview Class"])
      if tObj = 0 then
        return(error(me, "Failed object creation!", #showHideDialog, #major))
      end if
    else
      tObj = getObject("ctlg_dealpreviewObj")
    end if
    tObj.define(tProps.getAt("dealList"))
    tImage = tObj.getPicture()
  else
    if voidp(tProps.getAt("class")) then
      return(error(me, "Class property missing", #showPreviewImage, #minor))
    else
      tClass = tProps.getAt("class")
    end if
    if voidp(tProps.getAt("direction")) then
      return(error(me, "Direction property missing", #showPreviewImage, #minor))
    else
      tProps.setAt("direction", "2,2,2")
      tDirection = value("[" & tProps.getAt("direction") & "]")
      if tDirection.count < 3 then
        tDirection = [0, 0, 0]
      end if
    end if
    if voidp(tProps.getAt("dimensions")) then
      return(error(me, "Dimensions property missing", #showPreviewImage, #minor))
    else
      tDimensions = value("[" & tProps.getAt("dimensions") & "]")
      if tDimensions.count < 2 then
        tDimensions = [1, 1]
      end if
    end if
    if voidp(tProps.getAt("partColors")) then
      return(error(me, "PartColors property missing", #showPreviewImage, #minor))
    else
      tpartColors = tProps.getAt("partColors")
      if tpartColors = "" or tpartColors = "0,0,0" then
        tpartColors = "*ffffff"
      end if
    end if
    if voidp(tProps.getAt("objectType")) then
      return(error(me, "objectType property missing", #showPreviewImage, #minor))
    else
      tObjectType = tProps.getAt("objectType")
    end if
    tdata = [:]
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
        return(error(me, "Failed object creation!", #showHideDialog, #major))
      end if
    else
      tObj = getObject("ctlg_previewObj")
    end if
    tObj.define(tdata.duplicate())
    tImage = tObj.getPicture()
  end if
  return(tImage)
end

on showPreviewImage me, tProps, tElemID 
  tWndObj = pWndObj
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
    tImage = me.renderPreviewImage(tProps)
  end if
  if tImage.ilk = #image then
    tDestImg = tElem.getProperty(#image)
    tSourceImg = tImage
    tDestImg.fill(tDestImg.rect, rgb(255, 255, 255))
    tdestrect = tDestImg.rect - tSourceImg.rect
    tMargins = rect(0, 0, 0, 0)
    tdestrect = rect((tdestrect.width / 2), (tdestrect.height / 2), tSourceImg.width + (tdestrect.width / 2), (tdestrect.height / 2) + tSourceImg.height) + tMargins
    tDestImg.copyPixels(tSourceImg, tdestrect, tSourceImg.rect, [#ink:36])
    tElem.feedImage(tDestImg)
  end if
  return(1)
end

on refreshPreviewImage me, tClass, tdata 
  if not voidp(tdata) and not voidp(pCurrentPageData) then
    if ilk(pCurrentPageData) = #propList then
      if tdata.getAt("id") contains pCurrentPageData.getAt("id") then
        if ilk(tdata) = #propList then
          pCurrentPageData = tdata.duplicate()
        end if
      end if
    end if
  end if
  if voidp(pSelectedProduct) then
    return()
  else
    pSelectedProduct.setAt("prewImage", 0)
  end if
  if ilk(pCurrentPageData.getAt("productList")) <> #list then
    return()
  end if
  if pSelectedProduct.getAt("class") = tClass then
    i = 1
    repeat while i <= pCurrentPageData.getAt("productList").count
      if pCurrentPageData.getAt("productList").getAt(i).getAt("class") contains tClass then
        pSelectedProduct = pCurrentPageData.getAt("productList").getAt(i)
      end if
      i = 1 + i
    end repeat
    me.showPreviewImage(pSelectedProduct)
  end if
end

on selectProduct me, tOrderNum, tFeedFlag 
  tWndObj = pWndObj
  if not integerp(tOrderNum) then
    return(error(me, "Incorrect value", #selectProduct, #major))
  end if
  if ilk(pCurrentPageData) <> #propList then
    return(0)
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
    return(error(me, "Incorrect product data", #selectProduct, #major))
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
end

on changeProductOffset me, tDirection 
  if ilk(pCurrentPageData) <> #propList then
    return(0)
  end if
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
end

on hideSpecialText me 
  tWndObj = pWndObj
  if tWndObj.elementExists("ctlg_special_img") then
    tWndObj.getElement("ctlg_special_img").clearImage()
  end if
  if tWndObj.elementExists("ctlg_special_txt") then
    tWndObj.getElement("ctlg_special_txt").setText("")
  end if
end

on showProductPageCounter me 
  tWndObj = pWndObj
  if voidp(pCurrentPageData) then
    return()
  end if
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
        tCurrent = integer((pProductOffset / pProductPerPage)) + 1
        tTotalPages = (float(pCurrentPageData.getAt("productList").count) / float(pProductPerPage))
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
end
