property pProductStrip, pPageItemDownloader, pPersistentFurniData, pPersistentCatalogData, pTextElements, pWndObj, pImageElements, pOfferTypesAvailable, pHideElements

on construct me 
  pWndObj = void()
  pProductStrip = void()
  pSelectedProduct = void()
  pOfferTypesAvailable = []
  pPageItemDownloader = getThread(#catalogue).getComponent().getPageItemDownloader()
  pDealPreviewObj = getObject("catalogue_deal_preview_object")
  pImageElements = getVariableValue("layout.fields.image.default")
  pTextElements = getVariableValue("layout.fields.text.default")
  pHideElements = getVariableValue("layout.hide.onclick.default")
  return(callAncestor(#construct, [me]))
end

on deconstruct me 
  if objectExists(pProductStrip.getID()) then
    removeObject(pProductStrip.getID())
  end if
  pPageItemDownloader.removeCallback(me, #downloadCompleted)
  return(callAncestor(#deconstruct, [me]))
end

on define me, tdata 
  callAncestor(#define, [me], tdata)
  if variableExists("layout.class." & me.getProp(#pPageData, #layout) & ".productstrip") then
    tClass = getVariableValue("layout.class." & me.getProp(#pPageData, #layout) & ".productstrip")
  else
    tClass = getVariableValue("layout.class.default.productstrip")
  end if
  pProductStrip = createObject(getUniqueID(), tClass)
  me.define(pPageData.offers)
  if voidp(pPersistentFurniData) then
    pPersistentFurniData = getThread("dynamicdownloader").getComponent().getPersistentFurniDataObject()
  end if
  if voidp(pPersistentCatalogData) then
    pPersistentCatalogData = getThread(#catalogue).getComponent().getPersistentCatalogDataObject()
  end if
  if variableExists("layout.fields.image." & me.getProp(#pPageData, #layout)) then
    pImageElements = getVariableValue("layout.fields.image." & me.getProp(#pPageData, #layout))
  end if
  if variableExists("layout.fields.text." & me.getProp(#pPageData, #layout)) then
    pTextElements = getVariableValue("layout.fields.text." & me.getProp(#pPageData, #layout))
  end if
  if variableExists("layout.hide.onclick." & me.getProp(#pPageData, #layout)) then
    pHideElements = getVariableValue("layout.hide.onclick." & me.getProp(#pPageData, #layout))
  end if
end

on mergeWindow me, tParentWndObj 
  tLayoutMember = "ctlg_" & me.getProp(#pPageData, #layout) & ".window"
  if not memberExists(tLayoutMember) then
    return(error(me, "Layout member " & tLayoutMember & " missing.", #mergeWindow))
  end if
  tParentWndObj.merge(tLayoutMember)
  pWndObj = tParentWndObj
  tTextFields = me.getPropRef(#pPageData, #localization).getAt(#texts)
  i = 1
  repeat while i <= tTextFields.count
    if tParentWndObj.elementExists(pTextElements.getAt(i)) then
      pWndObj.getElement(pTextElements.getAt(i)).setText(tTextFields.getAt(i))
    end if
    i = 1 + i
  end repeat
  tBitmaps = me.getPropRef(#pPageData, #localization).getAt(#images)
  i = 1
  repeat while i <= tBitmaps.count
    tBitmap = tBitmaps.getAt(i)
    if tParentWndObj.elementExists(pImageElements.getAt(i)) and tBitmap.length > 1 then
      if memberExists(tBitmap) then
        me.centerBlitImageToElement(getMember(tBitmap).image, tParentWndObj.getElement(pImageElements.getAt(i)))
      else
        pPageItemDownloader.defineCallback(me, #downloadCompleted)
        pPageItemDownloader.registerDownload(#bitmap, tBitmap, [#imagedownload:1, #element:pImageElements.getAt(i), #assetId:tBitmap, #pageid:me.getProp(#pPageData, #pageid)])
      end if
    end if
    i = 1 + i
  end repeat
  if tParentWndObj.elementExists("ctlg_productstrip") then
    pProductStrip.setTargetElement(tParentWndObj.getElement("ctlg_productstrip"), tParentWndObj.getElement("ctlg_products_scroll"))
  end if
  pOfferTypesAvailable = me.getPossibleBuyButtonTypes(tParentWndObj)
  me.hidePriceBox()
end

on unmergeWindow me, tParentWndObj 
  tLayoutMember = "ctlg_" & me.getProp(#pPageData, #layout) & ".window"
  if not memberExists(tLayoutMember) then
    return(error(me, "Layout member " & tLayoutMember & " missing.", #mergeWindow))
  end if
  tParentWndObj.unmerge()
end

on hidePriceBox me 
  i = 1
  repeat while i <= pOfferTypesAvailable.count
    tElementList = pOfferTypesAvailable.getAt(i).getAt(#hideelements)
    j = 1
    repeat while j <= tElementList.count
      pWndObj.getElement(tElementList.getAt(j)).hide()
      j = 1 + j
    end repeat
    i = 1 + i
  end repeat
end

on showPriceBox me 
  i = 1
  repeat while i <= pOfferTypesAvailable.count
    tElementList = pOfferTypesAvailable.getAt(i).getAt(#hideelements)
    j = 1
    repeat while j <= tElementList.count
      pWndObj.getElement(tElementList.getAt(j)).show()
      j = 1 + j
    end repeat
    i = 1 + i
  end repeat
end

on setBuyButtonStates me, tOfferTypeList 
  i = 1
  repeat while i <= pOfferTypesAvailable.count
    pWndObj.getElement(pOfferTypesAvailable.getPropAt(i)).deactivate()
    i = 1 + i
  end repeat
  j = 1
  repeat while j <= tOfferTypeList.count
    i = 1
    repeat while i <= pOfferTypesAvailable.count
      if pOfferTypesAvailable.getAt(i).getAt(#type) = tOfferTypeList.getAt(j) then
        pWndObj.getElement(pOfferTypesAvailable.getPropAt(i)).Activate()
      end if
      i = 1 + i
    end repeat
    j = 1 + j
  end repeat
end

on convertOfferListToDeallist me, tOfferList 
  tDealList = []
  repeat while tOfferList <= undefined
    tOffer = getAt(undefined, tOfferList)
    tFurniProps = pPersistentFurniData.getProps(tOffer.getAt(#type), tOffer.getAt(#classID))
    if voidp(tFurniProps) then
      tDealList.add([#class:"", #partColors:"", #count:0])
    else
      tDealList.add([#class:tFurniProps.getAt(#class), #partColors:tFurniProps.getAt(#partColors), #count:tOffer.getAt(#productcount)])
    end if
  end repeat
  return(tDealList)
end

on resolveLargePreview me, tOffer 
  tPrevMember = "ctlg_pic_"
  tOfferName = tOffer.getAt(#offername)
  if memberExists(tPrevMember & tOfferName) then
    return(getMember(tPrevMember & tOfferName).image)
  end if
  tClassID = tOffer.getAt(#content).getAt(1).getAt(#classID)
  if memberExists("ctlg_fx_prev_" & tClassID) then
    return(getMember("ctlg_fx_prev_" & tClassID).image)
  end if
  return(getMember("no_icon_small").image)
end

on showPreview me, tOffer 
  if voidp(pWndObj) then
    return("\r", error(me, "Missing handle to window object!", #showPreview, #major))
  end if
  tPrevImage = me.resolveLargePreview(tOffer.getAt(#offerList).getAt(1))
  if ilk(tPrevImage) <> #image then
    return(error(me, "Could not resolve preview image", #showPreview, #major))
  end if
  me.centerBlitImageToElement(tPrevImage, pWndObj.getElement(pImageElements.getAt(2)))
  tCatalogProps = pPersistentCatalogData.getProps(tOffer.getAt(#offerList).getAt(1).getAt(#offername))
  if listp(tCatalogProps) then
    tDesc = tCatalogProps.getAt(#description)
    tExp = tOffer.getAt(#offerList).getAt(1).getAt(#content).getAt(1).getAt(#expiration)
    if tExp <> -1 then
      tHours = (tExp / 60)
      tMins = (tExp mod 60)
      tExpText = replaceChunks(getText("expiring_item_postfix", "Lasts %x% hours %y% minutes."), "%x%", tHours)
      tExpText = replaceChunks(tExpText, "%y%", tMins)
      tDesc = tDesc && tExpText
    end if
    pWndObj.getElement("ctlg_description").setText(tDesc)
  else
    error(me, "Missing catalogprops for offer " & tOffer.getAt(#offerList).getAt(1).getAt(#offername), #showPreview, #minor)
  end if
  i = 1
  repeat while i <= pOfferTypesAvailable.count
    tElements = pOfferTypesAvailable.getAt(i).getaProp(#elements)
    tText = me.getOfferPriceTextByType(tOffer.getAt(#offerList), pOfferTypesAvailable.getAt(i).getaProp(#type))
    repeat while tElements <= undefined
      tElement = getAt(undefined, tOffer)
      if pWndObj.elementExists(tElement) then
        pWndObj.getElement(tElement).setText(tText)
      end if
    end repeat
    i = 1 + i
  end repeat
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
    me.centerBlitImageToElement(getMember(tProps.getaProp(#assetId)).image, pWndObj.getElement(tDlProps.getAt(#element)))
  else
    tSelectedItem = me.getSelectedProduct()
    if not voidp(tSelectedItem) then
      tFurniProps = pPersistentFurniData.getProps(tSelectedItem.getAt(#offerList).getAt(1).getAt(#type), tSelectedItem.getAt(#offerList).getAt(1).getAt(#classID))
      if not voidp(tFurniProps) then
        if tProps.getAt(#assetId) = me.getClassAsset(tFurniProps.getAt(#class)) then
          me.showPreview(tSelectedItem)
        end if
      end if
    end if
  end if
end

on getSelectedProduct me 
  tSelectedItem = void()
  if objectp(pProductStrip) then
    tSelectedItem = pProductStrip.getSelectedItem()
  end if
  return(tSelectedItem)
end

on handleClick me, tEvent, tSprID, tProp 
  if tEvent = #mouseUp then
    if tSprID = "ctlg_productstrip" then
      tSelectedItem = void()
      if objectp(pProductStrip) then
        pProductStrip.selectItemAt(tProp)
        tSelectedItem = pProductStrip.getSelectedItem()
      end if
      if not voidp(tSelectedItem) then
        repeat while tSprID <= tSprID
          tElement = getAt(tSprID, tEvent)
          if pWndObj.elementExists(tElement) then
            pWndObj.getElement(tElement).hide()
          end if
        end repeat
        me.showPreview(tSelectedItem)
        me.showPriceBox()
        me.setBuyButtonStates(me.getOfferTypeList(tSelectedItem.getAt(#offerList)))
      end if
    else
      if tSprID <> "ctlg_buy_button" then
        if tSprID <> "ctlg_buy_pixels_credits" then
          if tSprID = "ctlg_buy_pixels" then
            tSelectedItem = pProductStrip.getSelectedItem()
            if not voidp(tSelectedItem) then
              tOfferType = pOfferTypesAvailable.getAt(tSprID).getaProp(#type)
              tOffer = me.getOfferByType(tSelectedItem.getAt(#offerList), tOfferType)
              if voidp(tOffer) then
                return(error(me, "Unable to find offer of type " & tOfferType & " check page offer configuration.", #handleClick, #major))
              end if
              tExtraProps = void()
              if tSprID = "ctlg_buy_pixels_credits" or tSprID = "ctlg_buy_pixels" then
                tExtraProps = [#disableGift]
              end if
              getThread(#catalogue).getComponent().requestPurchase(tOfferType, me.getProp(#pPageData, #pageid), tOffer, #sendPurchaseFromCatalog, tExtraProps)
            end if
          else
            if tSprID = "ctlg_buy_andwear" then
              tSelectedItem = pProductStrip.getSelectedItem()
              if not voidp(tSelectedItem) then
                tOfferType = pOfferTypesAvailable.getAt(tSprID).getaProp(#type)
                tOffer = me.getOfferByType(tSelectedItem.getAt(#offerList), tOfferType)
                if voidp(tOffer) then
                  return(error(me, "Unable to find offer of type " & tOfferType & " check page offer configuration.", #handleClick, #major))
                end if
                getThread(#catalogue).getComponent().requestPurchase(tOfferType, me.getProp(#pPageData, #pageid), tOffer, #sendPurchaseAndWear, [#disableGift, #closeCatalogue])
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
                tOffer = me.getOfferByType(me.getPropRef(#pPageData, #offers).getAt(tItemIndex).getAt(#offerList), #credits)
                getThread(#catalogue).getComponent().requestPurchase(tOfferType, me.getProp(#pPageData, #pageid), tOffer, #sendPurchaseFromCatalog)
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end
