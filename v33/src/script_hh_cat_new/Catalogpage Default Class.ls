on construct(me)
  pWndObj = void()
  pProductStrip = void()
  pSelectedProduct = void()
  pOfferTypesAvailable = []
  pPageItemDownloader = getThread(#catalogue).getComponent().getPageItemDownloader()
  pDealPreviewObj = getObject("catalogue_deal_preview_object")
  pImageElements = getStructVariable("layout.fields.image.default")
  pTextElements = getStructVariable("layout.fields.text.default")
  pHideElements = getStructVariable("layout.hide.onclick.default")
  return(callAncestor(#construct, [me]))
  exit
end

on deconstruct(me)
  if not voidp(me.pProductStrip) then
    if objectExists(pProductStrip.getID()) then
      removeObject(pProductStrip.getID())
    end if
  end if
  pPageItemDownloader.removeCallback(me, #downloadCompleted)
  return(callAncestor(#deconstruct, [me]))
  exit
end

on define(me, tdata)
  callAncestor(#define, [me], tdata)
  if variableExists("layout.class." & me.getProp(#pPageData, #layout) & ".productstrip") then
    tClass = getClassVariable("layout.class." & me.getProp(#pPageData, #layout) & ".productstrip")
  else
    tClass = getClassVariable("layout.class.default.productstrip")
  end if
  if tClass.count > 1 then
    pProductStrip = createObject(getUniqueID(), tClass)
    pProductStrip.define(me.offers)
  end if
  if voidp(pPersistentFurniData) then
    pPersistentFurniData = getThread("dynamicdownloader").getComponent().getPersistentFurniDataObject()
  end if
  if voidp(pPersistentCatalogData) then
    pPersistentCatalogData = getThread(#catalogue).getComponent().getPersistentCatalogDataObject()
  end if
  if variableExists("layout.fields.image." & me.getProp(#pPageData, #layout)) then
    pImageElements = getStructVariable("layout.fields.image." & me.getProp(#pPageData, #layout))
  end if
  if variableExists("layout.fields.text." & me.getProp(#pPageData, #layout)) then
    pTextElements = getStructVariable("layout.fields.text." & me.getProp(#pPageData, #layout))
  end if
  if variableExists("layout.hide.onclick." & me.getProp(#pPageData, #layout)) then
    pHideElements = getStructVariable("layout.hide.onclick." & me.getProp(#pPageData, #layout))
  end if
  exit
end

on mergeWindow(me, tParentWndObj)
  tLayoutMember = "ctlg_" & me.getProp(#pPageData, #layout) & ".window"
  if not memberExists(tLayoutMember) then
    return(error(me, "Layout member " & tLayoutMember & " missing.", #mergeWindow))
  end if
  tParentWndObj.merge(tLayoutMember)
  pWndObj = tParentWndObj
  tTextFields = me.getPropRef(#pPageData, #localization).getAt(#texts)
  i = 1
  repeat while i <= tTextFields.count
    if pTextElements.count >= i then
      me.setElementText(pWndObj, pTextElements.getAt(i), tTextFields.getAt(i))
    end if
    i = 1 + i
  end repeat
  tBitmaps = me.getPropRef(#pPageData, #localization).getAt(#images)
  tObjectLoadList = []
  i = 1
  repeat while i <= tBitmaps.count
    if pImageElements.count >= i then
      tBitmap = tBitmaps.getAt(i)
      if tParentWndObj.elementExists(pImageElements.getAt(i)) and tBitmap.length > 1 then
        if memberExists(tBitmap) then
          me.centerBlitImageToElement(getMember(tBitmap).image, tParentWndObj.getElement(pImageElements.getAt(i)))
        else
          tObjectLoadList.add([#assetId:tBitmap, #type:#bitmap, #props:[#imagedownload:1, #element:pImageElements.getAt(i), #assetId:tBitmap, #pageid:me.getProp(#pPageData, #pageid)]])
        end if
      end if
    end if
    i = 1 + i
  end repeat
  if tObjectLoadList.count > 0 then
    pPageItemDownloader.defineCallback(me, #downloadCompleted)
    repeat while me <= undefined
      tLoadObject = getAt(undefined, tParentWndObj)
      pPageItemDownloader.registerDownload(tLoadObject.getAt(#type), tLoadObject.getAt(#assetId), tLoadObject.getAt(#props))
    end repeat
  end if
  if objectp(pProductStrip) and tParentWndObj.elementExists("ctlg_productstrip") then
    pProductStrip.setTargetElement(tParentWndObj.getElement("ctlg_productstrip"), tParentWndObj.getElement("ctlg_products_scroll"))
  end if
  pOfferTypesAvailable = me.getPossibleBuyButtonTypes(tParentWndObj)
  me.hidePriceBox()
  exit
end

on unmergeWindow(me, tParentWndObj)
  tLayoutMember = "ctlg_" & me.getProp(#pPageData, #layout) & ".window"
  if not memberExists(tLayoutMember) then
    return(error(me, "Layout member " & tLayoutMember & " missing.", #mergeWindow))
  end if
  tParentWndObj.unmerge()
  exit
end

on hidePriceBox(me)
  i = 1
  repeat while i <= pOfferTypesAvailable.count
    tElementList = pOfferTypesAvailable.getAt(i).getAt(#hideelements)
    j = 1
    repeat while j <= tElementList.count
      if pWndObj.elementExists(tElementList.getAt(j)) then
        pWndObj.getElement(tElementList.getAt(j)).hide()
      end if
      j = 1 + j
    end repeat
    i = 1 + i
  end repeat
  exit
end

on showPriceBox(me)
  i = 1
  repeat while i <= pOfferTypesAvailable.count
    tElementList = pOfferTypesAvailable.getAt(i).getAt(#hideelements)
    j = 1
    repeat while j <= tElementList.count
      if pWndObj.elementExists(tElementList.getAt(j)) then
        pWndObj.getElement(tElementList.getAt(j)).show()
      end if
      j = 1 + j
    end repeat
    i = 1 + i
  end repeat
  exit
end

on setBuyButtonStates(me, tOfferTypeList)
  i = 1
  repeat while i <= pOfferTypesAvailable.count
    if pWndObj.elementExists(pOfferTypesAvailable.getPropAt(i)) then
      pWndObj.getElement(pOfferTypesAvailable.getPropAt(i)).deactivate()
    end if
    i = 1 + i
  end repeat
  j = 1
  repeat while j <= tOfferTypeList.count
    i = 1
    repeat while i <= pOfferTypesAvailable.count
      if pOfferTypesAvailable.getAt(i).getAt(#type) = tOfferTypeList.getAt(j) then
        if pWndObj.elementExists(pOfferTypesAvailable.getPropAt(i)) then
          pWndObj.getElement(pOfferTypesAvailable.getPropAt(i)).Activate()
        end if
      end if
      i = 1 + i
    end repeat
    j = 1 + j
  end repeat
  exit
end

on resolveLargePreview(me, tOffer)
  if not objectp(tOffer) then
    return(error(me, "Invalid input format", #resolveLargePreview, #major))
  end if
  if tOffer.getCount() < 1 then
    return(error(me, "Offer has no content", #resolveLargePreview, #major))
  end if
  tPrevMember = "ctlg_pic_"
  tOfferName = tOffer.getName()
  if memberExists(tPrevMember & tOfferName) then
    return(getMember(tPrevMember & tOfferName).image)
  end if
  if tOffer.getCount() = 1 then
    tFurniProps = pPersistentFurniData.getProps(tOffer.getContent(1).getType(), tOffer.getContent(1).getClassId())
    if not listp(tFurniProps) then
      return(getMember("no_icon_small").image)
    end if
    tClass = me.getClassAsset(tFurniProps.getaProp(#class))
    if tClass = "poster" then
      tClass = tClass && tOffer.getContent(1).getExtraParam()
    end if
    if getThread(#dynamicdownloader).getComponent().isAssetDownloaded(tClass) then
      tPrevProps = []
      tPrevProps.setAt("class", tFurniProps.getAt(#class))
      tPrevProps.setAt("objectType", tFurniProps.getAt(#type))
      tPrevProps.setAt("direction", tFurniProps.getAt(#defaultDir))
      tPrevProps.setAt("dimensions", tFurniProps.getAt(#xdim) & "," & tFurniProps.getAt(#ydim))
      tPrevProps.setAt("partColors", tFurniProps.getAt(#partColors))
      if tPrevProps.getAt("class") = "poster" then
        tPrevProps.setAt("class", tPrevProps.getAt("class") && tOffer.getContent(1).getExtraParam())
      end if
      return(me.renderLargePreviewImage(tPrevProps))
    end if
  else
    if not objectp(pDealPreviewObj) then
      return(error(me, "Deal preview renderer object missing.", #resolveLargePreview))
    end if
    tAssetsLoaded = 1
    k = 1
    repeat while k <= tOffer.getCount()
      tItem = tOffer.getContent(k)
      tFurniProps = pPersistentFurniData.getProps(tItem.getType(), tItem.getClassId())
      tClass = me.getClassAsset(tFurniProps.getaProp(#class))
      if not getThread(#dynamicdownloader).getComponent().isAssetDownloaded(tClass) then
        tAssetsLoaded = 0
      end if
      k = 1 + k
    end repeat
    pDealPreviewObj.define(me.convertOfferListToDeallist(tOffer))
    return(pDealPreviewObj.getPicture())
  end if
  exit
end

on showPreview(me, tOfferGroup)
  if voidp(pWndObj) then
    return("\r", error(me, "Missing handle to window object!", #showPreview, #major))
  end if
  if not objectp(tOfferGroup) then
    return(error(me, "Invalid input format", #showPreview, #major))
  end if
  if tOfferGroup.getCount() < 1 then
    return(error(me, "Offer group is empty", #showPreview, #major))
  end if
  if tOfferGroup.getOffer(1).getCount() < 1 then
    return(error(me, "Offer group item at index 1 has no content", #showPreview, #major))
  end if
  tPrevImage = me.resolveLargePreview(tOfferGroup.getOffer(1))
  if ilk(tPrevImage) <> #image then
    return(0)
  end if
  if pWndObj.elementExists(pImageElements.getAt(2)) then
    me.centerBlitImageToElement(tPrevImage, pWndObj.getElement(pImageElements.getAt(2)))
  end if
  tCatalogProps = pPersistentCatalogData.getProps(tOfferGroup.getOffer(1).getName())
  if listp(tCatalogProps) then
    tDesc = tCatalogProps.getAt(#description)
    tExp = tOfferGroup.getOffer(1).getContent(1).getExpiration()
    if tExp <> -1 then
      tHours = tExp / 60
      tMins = tExp mod 60
      tExpText = replaceChunks(getText("expiring_item_postfix", "Lasts %x% hours %y% minutes."), "%x%", tHours)
      tExpText = replaceChunks(tExpText, "%y%", tMins)
      tDesc = tDesc && tExpText
    end if
    me.setElementText(pWndObj, "ctlg_description", tDesc)
    me.setElementText(pWndObj, "ctlg_product_name", tCatalogProps.getAt(#name))
  else
    error(me, "Missing catalogprops for offer " & tOfferGroup.getOffer(1).getName(), #showPreview, #minor)
  end if
  i = 1
  repeat while i <= pOfferTypesAvailable.count
    tElements = pOfferTypesAvailable.getAt(i).getaProp(#elements)
    tText = me.getOfferPriceTextByType(tOfferGroup, pOfferTypesAvailable.getAt(i).getaProp(#type))
    repeat while me <= undefined
      tElement = getAt(undefined, tOfferGroup)
      me.setElementText(pWndObj, tElement, tText)
    end repeat
    i = 1 + i
  end repeat
  if listp(tCatalogProps) and pTextElements.count >= 3 then
    if chars(tCatalogProps.getAt(#specialText), 2, 2) = ":" then
      tNum = value(tCatalogProps.getAt(#specialText).getProp(#char, 1))
      tText = chars(tCatalogProps.getAt(#specialText), 3, tCatalogProps.getAt(#specialText).length)
    else
      tNum = void()
      tText = tCatalogProps.getAt(#specialText)
    end if
    if pWndObj.elementExists(pTextElements.getAt(3)) then
      pWndObj.getElement(pTextElements.getAt(3)).show()
      pWndObj.getElement(pTextElements.getAt(3)).setText(tText)
    end if
    if pWndObj.elementExists(pImageElements.getAt(3)) then
      if not voidp(tNum) then
        pWndObj.getElement(pImageElements.getAt(3)).show()
        pWndObj.getElement(pImageElements.getAt(3)).feedImage(getMember("catalog_special_txtbg" & tNum).image)
      else
        pWndObj.getElement(pImageElements.getAt(3)).hide()
      end if
    end if
  end if
  exit
end

on downloadCompleted(me, tProps)
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
    tSelectedItem = me.getSelectedProduct()
    if not voidp(tSelectedItem) then
      tFurniProps = pPersistentFurniData.getProps(tSelectedItem.getOffer(1).getType(), tSelectedItem.getOffer(1).getClassId())
      if not voidp(tFurniProps) then
        if tProps.getAt(#assetId) = me.getClassAsset(tFurniProps.getAt(#class)) then
          me.showPreview(tSelectedItem)
        end if
      end if
    end if
  end if
  exit
end

on getSelectedProduct(me)
  tSelectedItem = void()
  if objectp(pProductStrip) then
    tSelectedItem = pProductStrip.getSelectedItem()
  end if
  return(tSelectedItem)
  exit
end

on handleClick(me, tEvent, tSprID, tProp)
  if tEvent = #mouseUp then
    if me = "ctlg_productstrip" then
      if ilk(tProp) <> #point then
        return()
      end if
      tSelectedItem = void()
      if objectp(pProductStrip) then
        pProductStrip.selectItemAt(tProp)
        tSelectedItem = pProductStrip.getSelectedItem()
      end if
      if not voidp(tSelectedItem) then
        repeat while me <= tSprID
          tElement = getAt(tSprID, tEvent)
          if pWndObj.elementExists(tElement) then
            pWndObj.getElement(tElement).hide()
          end if
        end repeat
        me.showPriceBox()
        me.setBuyButtonStates(me.getOfferTypeList(tSelectedItem))
        me.showPreview(tSelectedItem)
      end if
    else
      if me <> "ctlg_buy_button" then
        if me <> "ctlg_buy_pixels_credits" then
          if me <> "ctlg_buy_pixels" then
            if me = "ctlg_buy_andwear" then
              if not objectp(pProductStrip) then
                return()
              end if
              tSelectedItem = pProductStrip.getSelectedItem()
              if not voidp(tSelectedItem) then
                tOfferType = pOfferTypesAvailable.getAt(tSprID).getaProp(#type)
                tOffer = me.getOfferByType(tSelectedItem, tOfferType)
                if voidp(tOffer) then
                  return(error(me, "Unable to find offer of type " & tOfferType & " check page offer configuration.", #handleClick, #major))
                end if
                tExtraProps = void()
                if tSprID = "ctlg_buy_pixels_credits" or tSprID = "ctlg_buy_pixels" or tSprID = "ctlg_buy_andwear" then
                  tExtraProps = [#disableGift]
                end if
                getThread(#catalogue).getComponent().requestPurchase(tOfferType, me.getProp(#pPageData, #pageid), tOffer, #sendPurchaseFromCatalog, tExtraProps)
              end if
            else
              if tSprID contains "ctlg_buy_" then
                tItemIndex = value(chars(tSprID, 10, 10))
                if not integerp(tItemIndex) then
                  return()
                end if
                if tItemIndex > me.getPropRef(#pPageData, #offers).count then
                  return(error(me, "No product to purchase at index : " & tItemIndex, #minor))
                end if
                tOffer = me.getOfferByType(me.getPropRef(#pPageData, #offers).getAt(tItemIndex), #credits)
                getThread(#catalogue).getComponent().requestPurchase(#credits, me.getProp(#pPageData, #pageid), tOffer, #sendPurchaseFromCatalog)
              end if
            end if
            exit
          end if
        end if
      end if
    end if
  end if
end