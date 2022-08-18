property pWndObj, pProductStrip, pSelectedProduct, pPageItemDownloader, pImageElements, pTextElements, pPersistentFurniData, pPersistentCatalogData, pDealPreviewObj, pOfferTypesAvailable, pHideElements

on construct me
  pWndObj = VOID
  pProductStrip = VOID
  pSelectedProduct = VOID
  pOfferTypesAvailable = []
  pPageItemDownloader = getThread(#catalogue).getComponent().getPageItemDownloader()
  pDealPreviewObj = getObject("catalogue_deal_preview_object")
  pImageElements = getVariableValue("layout.fields.image.default")
  pTextElements = getVariableValue("layout.fields.text.default")
  pHideElements = getVariableValue("layout.hide.onclick.default")
  return callAncestor(#construct, [me])
end

on deconstruct me
  if objectExists(pProductStrip.getID()) then
    removeObject(pProductStrip.getID())
  end if
  pPageItemDownloader.removeCallback(me, #downloadCompleted)
  return callAncestor(#deconstruct, [me])
end

on define me, tdata
  callAncestor(#define, [me], tdata)
  if variableExists((("layout.class." & me.pPageData[#layout]) & ".productstrip")) then
    tClass = getVariableValue((("layout.class." & me.pPageData[#layout]) & ".productstrip"))
  else
    tClass = getVariableValue("layout.class.default.productstrip")
  end if
  pProductStrip = createObject(getUniqueID(), tClass)
  pProductStrip.define(me.pPageData.offers)
  if voidp(pPersistentFurniData) then
    pPersistentFurniData = getThread("dynamicdownloader").getComponent().getPersistentFurniDataObject()
  end if
  if voidp(pPersistentCatalogData) then
    pPersistentCatalogData = getThread(#catalogue).getComponent().getPersistentCatalogDataObject()
  end if
  if variableExists(("layout.fields.image." & me.pPageData[#layout])) then
    pImageElements = getVariableValue(("layout.fields.image." & me.pPageData[#layout]))
  end if
  if variableExists(("layout.fields.text." & me.pPageData[#layout])) then
    pTextElements = getVariableValue(("layout.fields.text." & me.pPageData[#layout]))
  end if
  if variableExists(("layout.hide.onclick." & me.pPageData[#layout])) then
    pHideElements = getVariableValue(("layout.hide.onclick." & me.pPageData[#layout]))
  end if
end

on mergeWindow me, tParentWndObj
  tLayoutMember = (("ctlg_" & me.pPageData[#layout]) & ".window")
  if not memberExists(tLayoutMember) then
    return error(me, (("Layout member " & tLayoutMember) & " missing."), #mergeWindow)
  end if
  tParentWndObj.merge(tLayoutMember)
  pWndObj = tParentWndObj
  tTextFields = me.pPageData[#localization][#texts]
  repeat with i = 1 to tTextFields.count
    if tParentWndObj.elementExists(pTextElements[i]) then
      pWndObj.getElement(pTextElements[i]).setText(tTextFields[i])
    end if
  end repeat
  tBitmaps = me.pPageData[#localization][#images]
  repeat with i = 1 to tBitmaps.count
    tBitmap = tBitmaps[i]
    if (tParentWndObj.elementExists(pImageElements[i]) and (tBitmap.length > 1)) then
      if memberExists(tBitmap) then
        me.centerBlitImageToElement(getMember(tBitmap).image, tParentWndObj.getElement(pImageElements[i]))
        next repeat
      end if
      pPageItemDownloader.defineCallback(me, #downloadCompleted)
      pPageItemDownloader.registerDownload(#bitmap, tBitmap, [#imagedownload: 1, #element: pImageElements[i], #assetId: tBitmap, #pageid: me.pPageData[#pageid]])
    end if
  end repeat
  if tParentWndObj.elementExists("ctlg_productstrip") then
    pProductStrip.setTargetElement(tParentWndObj.getElement("ctlg_productstrip"), tParentWndObj.getElement("ctlg_products_scroll"))
  end if
  pOfferTypesAvailable = me.getPossibleBuyButtonTypes(tParentWndObj)
  me.hidePriceBox()
end

on unmergeWindow me, tParentWndObj
  tLayoutMember = (("ctlg_" & me.pPageData[#layout]) & ".window")
  if not memberExists(tLayoutMember) then
    return error(me, (("Layout member " & tLayoutMember) & " missing."), #mergeWindow)
  end if
  tParentWndObj.unmerge()
end

on hidePriceBox me
  repeat with i = 1 to pOfferTypesAvailable.count
    tElementList = pOfferTypesAvailable[i][#hideelements]
    repeat with j = 1 to tElementList.count
      pWndObj.getElement(tElementList[j]).hide()
    end repeat
  end repeat
end

on showPriceBox me
  repeat with i = 1 to pOfferTypesAvailable.count
    tElementList = pOfferTypesAvailable[i][#hideelements]
    repeat with j = 1 to tElementList.count
      pWndObj.getElement(tElementList[j]).show()
    end repeat
  end repeat
end

on setBuyButtonStates me, tOfferTypeList
  repeat with i = 1 to pOfferTypesAvailable.count
    pWndObj.getElement(pOfferTypesAvailable.getPropAt(i)).deactivate()
  end repeat
  repeat with j = 1 to tOfferTypeList.count
    repeat with i = 1 to pOfferTypesAvailable.count
      if (pOfferTypesAvailable[i][#type] = tOfferTypeList[j]) then
        pWndObj.getElement(pOfferTypesAvailable.getPropAt(i)).Activate()
      end if
    end repeat
  end repeat
end

on convertOfferListToDeallist me, tOfferList
  tDealList = []
  repeat with tOffer in tOfferList
    tFurniProps = pPersistentFurniData.getProps(tOffer[#type], tOffer[#classID])
    if voidp(tFurniProps) then
      tDealList.add([#class: EMPTY, #partColors: EMPTY, #count: 0])
      next repeat
    end if
    tDealList.add([#class: tFurniProps[#class], #partColors: tFurniProps[#partColors], #count: tOffer[#productcount]])
  end repeat
  return tDealList
end

on resolveLargePreview me, tOffer
  tPrevMember = "ctlg_pic_"
  tOfferName = tOffer[#offername]
  if memberExists((tPrevMember & tOfferName)) then
    return getMember((tPrevMember & tOfferName)).image
  end if
  tClassID = tOffer[#content][1][#classID]
  if memberExists(("ctlg_fx_prev_" & tClassID)) then
    return getMember(("ctlg_fx_prev_" & tClassID)).image
  end if
  return getMember("no_icon_small").image
end

on showPreview me, tOffer
  if voidp(pWndObj) then
    return RETURN, error(me, "Missing handle to window object!", #showPreview, #major)
  end if
  tPrevImage = me.resolveLargePreview(tOffer[#offerList][1])
  if (ilk(tPrevImage) <> #image) then
    return error(me, "Could not resolve preview image", #showPreview, #major)
  end if
  me.centerBlitImageToElement(tPrevImage, pWndObj.getElement(pImageElements[2]))
  tCatalogProps = pPersistentCatalogData.getProps(tOffer[#offerList][1][#offername])
  if listp(tCatalogProps) then
    tDesc = tCatalogProps[#description]
    tExp = tOffer[#offerList][1][#content][1][#expiration]
    if (tExp <> -1) then
      tHours = (tExp / 60)
      tMins = (tExp mod 60)
      tExpText = replaceChunks(getText("expiring_item_postfix", "Lasts %x% hours %y% minutes."), "%x%", tHours)
      tExpText = replaceChunks(tExpText, "%y%", tMins)
      tDesc = (tDesc && tExpText)
    end if
    pWndObj.getElement("ctlg_description").setText(tDesc)
  else
    error(me, ("Missing catalogprops for offer " & tOffer[#offerList][1][#offername]), #showPreview, #minor)
  end if
  repeat with i = 1 to pOfferTypesAvailable.count
    tElements = pOfferTypesAvailable[i].getaProp(#elements)
    tText = me.getOfferPriceTextByType(tOffer[#offerList], pOfferTypesAvailable[i].getaProp(#type))
    repeat with tElement in tElements
      if pWndObj.elementExists(tElement) then
        pWndObj.getElement(tElement).setText(tText)
      end if
    end repeat
  end repeat
end

on downloadCompleted me, tProps
  if (tProps[#props][#pageid] <> me.pPageData[#pageid]) then
    return 
  end if
  tDlProps = tProps[#props]
  if tDlProps.getaProp(#imagedownload) then
    if voidp(pWndObj) then
      return RETURN, error(me, "Missing handle to window object!", #downloadCompleted, #major)
    end if
    if not pWndObj.elementExists(tDlProps[#element]) then
      return error(me, ("Missing target element " & tDlProps[#element]), #downloadCompleted, #minor)
    end if
    me.centerBlitImageToElement(getMember(tProps.getaProp(#assetId)).image, pWndObj.getElement(tDlProps[#element]))
  else
    tSelectedItem = me.getSelectedProduct()
    if not voidp(tSelectedItem) then
      tFurniProps = pPersistentFurniData.getProps(tSelectedItem[#offerList][1][#type], tSelectedItem[#offerList][1][#classID])
      if not voidp(tFurniProps) then
        if (tProps[#assetId] = me.getClassAsset(tFurniProps[#class])) then
          me.showPreview(tSelectedItem)
        end if
      end if
    end if
  end if
end

on getSelectedProduct me
  tSelectedItem = VOID
  if objectp(pProductStrip) then
    tSelectedItem = pProductStrip.getSelectedItem()
  end if
  return tSelectedItem
end

on handleClick me, tEvent, tSprID, tProp
  if (tEvent = #mouseUp) then
    case tSprID of
      "ctlg_productstrip":
        tSelectedItem = VOID
        if objectp(pProductStrip) then
          pProductStrip.selectItemAt(tProp)
          tSelectedItem = pProductStrip.getSelectedItem()
        end if
        if not voidp(tSelectedItem) then
          repeat with tElement in pHideElements
            if pWndObj.elementExists(tElement) then
              pWndObj.getElement(tElement).hide()
            end if
          end repeat
          me.showPreview(tSelectedItem)
          me.showPriceBox()
          me.setBuyButtonStates(me.getOfferTypeList(tSelectedItem[#offerList]))
        end if
      "ctlg_buy_button", "ctlg_buy_pixels_credits", "ctlg_buy_pixels":
        tSelectedItem = pProductStrip.getSelectedItem()
        if not voidp(tSelectedItem) then
          tOfferType = pOfferTypesAvailable[tSprID].getaProp(#type)
          tOffer = me.getOfferByType(tSelectedItem[#offerList], tOfferType)
          if voidp(tOffer) then
            return error(me, (("Unable to find offer of type " & tOfferType) & " check page offer configuration."), #handleClick, #major)
          end if
          tExtraProps = VOID
          if ((tSprID = "ctlg_buy_pixels_credits") or (tSprID = "ctlg_buy_pixels")) then
            tExtraProps = [#disableGift]
          end if
          getThread(#catalogue).getComponent().requestPurchase(tOfferType, me.pPageData[#pageid], tOffer, #sendPurchaseFromCatalog, tExtraProps)
        end if
      "ctlg_buy_andwear":
        tSelectedItem = pProductStrip.getSelectedItem()
        if not voidp(tSelectedItem) then
          tOfferType = pOfferTypesAvailable[tSprID].getaProp(#type)
          tOffer = me.getOfferByType(tSelectedItem[#offerList], tOfferType)
          if voidp(tOffer) then
            return error(me, (("Unable to find offer of type " & tOfferType) & " check page offer configuration."), #handleClick, #major)
          end if
          getThread(#catalogue).getComponent().requestPurchase(tOfferType, me.pPageData[#pageid], tOffer, #sendPurchaseAndWear, [#disableGift, #closeCatalogue])
        end if
      otherwise:
        if (tSprID contains "ctlg_buy_") then
          tItemIndex = value(chars(tSprID, 10, 10))
          if not integerp(tItemIndex) then
            return 
          end if
          if (tItemIndex > me.pPageData[#offers].count) then
            return error(me, ("No product to purchase at index : " & tItemIndex), #minor)
          end if
          tOffer = me.getOfferByType(me.pPageData[#offers][tItemIndex][#offerList], #credits)
          getThread(#catalogue).getComponent().requestPurchase(tOfferType, me.pPageData[#pageid], tOffer, #sendPurchaseFromCatalog)
        end if
    end case
  end if
end
