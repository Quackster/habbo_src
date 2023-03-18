property pWndObj, pProductStrip, pSelectedProduct, pPageItemDownloader, pImageElements, pTextElements, pPersistentFurniData, pPersistentCatalogData, pDealPreviewObj, pOfferTypesAvailable, pHideElements

on construct me
  pWndObj = VOID
  pProductStrip = VOID
  pSelectedProduct = VOID
  pOfferTypesAvailable = []
  pPageItemDownloader = getThread(#catalogue).getComponent().getPageItemDownloader()
  pDealPreviewObj = getObject("catalogue_deal_preview_object")
  pImageElements = getStructVariable("layout.fields.image.default")
  pTextElements = getStructVariable("layout.fields.text.default")
  pHideElements = getStructVariable("layout.hide.onclick.default")
  return callAncestor(#construct, [me])
end

on deconstruct me
  if not voidp(me.pProductStrip) then
    if objectExists(pProductStrip.getID()) then
      removeObject(pProductStrip.getID())
    end if
  end if
  pPageItemDownloader.removeCallback(me, #downloadCompleted)
  return callAncestor(#deconstruct, [me])
end

on define me, tdata
  callAncestor(#define, [me], tdata)
  if variableExists("layout.class." & me.pPageData[#layout] & ".productstrip") then
    tClass = getClassVariable("layout.class." & me.pPageData[#layout] & ".productstrip")
  else
    tClass = getClassVariable("layout.class.default.productstrip")
  end if
  if tClass.count > 1 then
    pProductStrip = createObject(getUniqueID(), tClass)
    pProductStrip.define(me.pPageData.offers)
  end if
  if voidp(pPersistentFurniData) then
    pPersistentFurniData = getThread("dynamicdownloader").getComponent().getPersistentFurniDataObject()
  end if
  if voidp(pPersistentCatalogData) then
    pPersistentCatalogData = getThread(#catalogue).getComponent().getPersistentCatalogDataObject()
  end if
  if variableExists("layout.fields.image." & me.pPageData[#layout]) then
    pImageElements = getStructVariable("layout.fields.image." & me.pPageData[#layout])
  end if
  if variableExists("layout.fields.text." & me.pPageData[#layout]) then
    pTextElements = getStructVariable("layout.fields.text." & me.pPageData[#layout])
  end if
  if variableExists("layout.hide.onclick." & me.pPageData[#layout]) then
    pHideElements = getStructVariable("layout.hide.onclick." & me.pPageData[#layout])
  end if
end

on mergeWindow me, tParentWndObj
  tLayoutMember = "ctlg_" & me.pPageData[#layout] & ".window"
  if not memberExists(tLayoutMember) then
    return error(me, "Layout member " & tLayoutMember & " missing.", #mergeWindow)
  end if
  tParentWndObj.merge(tLayoutMember)
  pWndObj = tParentWndObj
  tTextFields = me.pPageData[#localization][#texts]
  repeat with i = 1 to tTextFields.count
    if pTextElements.count >= i then
      me.setElementText(pWndObj, pTextElements[i], tTextFields[i])
    end if
  end repeat
  tBitmaps = me.pPageData[#localization][#images]
  tObjectLoadList = []
  repeat with i = 1 to tBitmaps.count
    if pImageElements.count >= i then
      tBitmap = tBitmaps[i]
      if tParentWndObj.elementExists(pImageElements[i]) and (tBitmap.length > 1) then
        if memberExists(tBitmap) then
          me.centerBlitImageToElement(getMember(tBitmap).image, tParentWndObj.getElement(pImageElements[i]))
          next repeat
        end if
        tObjectLoadList.add([#assetId: tBitmap, #type: #bitmap, #props: [#imagedownload: 1, #element: pImageElements[i], #assetId: tBitmap, #pageid: me.pPageData[#pageid]]])
      end if
    end if
  end repeat
  if tObjectLoadList.count > 0 then
    pPageItemDownloader.defineCallback(me, #downloadCompleted)
    repeat with tLoadObject in tObjectLoadList
      pPageItemDownloader.registerDownload(tLoadObject[#type], tLoadObject[#assetId], tLoadObject[#props])
    end repeat
  end if
  if objectp(pProductStrip) and tParentWndObj.elementExists("ctlg_productstrip") then
    pProductStrip.setTargetElement(tParentWndObj.getElement("ctlg_productstrip"), tParentWndObj.getElement("ctlg_products_scroll"))
  end if
  pOfferTypesAvailable = me.getPossibleBuyButtonTypes(tParentWndObj)
  me.hidePriceBox()
end

on unmergeWindow me, tParentWndObj
  tLayoutMember = "ctlg_" & me.pPageData[#layout] & ".window"
  if not memberExists(tLayoutMember) then
    return error(me, "Layout member " & tLayoutMember & " missing.", #mergeWindow)
  end if
  tParentWndObj.unmerge()
end

on hidePriceBox me
  repeat with i = 1 to pOfferTypesAvailable.count
    tElementList = pOfferTypesAvailable[i][#hideelements]
    repeat with j = 1 to tElementList.count
      if pWndObj.elementExists(tElementList[j]) then
        pWndObj.getElement(tElementList[j]).hide()
      end if
    end repeat
  end repeat
end

on showPriceBox me
  repeat with i = 1 to pOfferTypesAvailable.count
    tElementList = pOfferTypesAvailable[i][#hideelements]
    repeat with j = 1 to tElementList.count
      if pWndObj.elementExists(tElementList[j]) then
        pWndObj.getElement(tElementList[j]).show()
      end if
    end repeat
  end repeat
end

on setBuyButtonStates me, tOfferTypeList
  repeat with i = 1 to pOfferTypesAvailable.count
    if pWndObj.elementExists(pOfferTypesAvailable.getPropAt(i)) then
      pWndObj.getElement(pOfferTypesAvailable.getPropAt(i)).deactivate()
    end if
  end repeat
  repeat with j = 1 to tOfferTypeList.count
    repeat with i = 1 to pOfferTypesAvailable.count
      if pOfferTypesAvailable[i][#type] = tOfferTypeList[j] then
        if pWndObj.elementExists(pOfferTypesAvailable.getPropAt(i)) then
          pWndObj.getElement(pOfferTypesAvailable.getPropAt(i)).Activate()
        end if
      end if
    end repeat
  end repeat
end

on resolveLargePreview me, tOffer
  if not objectp(tOffer) then
    return error(me, "Invalid input format", #resolveLargePreview, #major)
  end if
  if tOffer.getCount() < 1 then
    return error(me, "Offer has no content", #resolveLargePreview, #major)
  end if
  tPrevMember = "ctlg_pic_"
  tOfferName = tOffer.getName()
  if memberExists(tPrevMember & tOfferName) then
    return getMember(tPrevMember & tOfferName).image
  end if
  if tOffer.getCount() = 1 then
    tFurniProps = pPersistentFurniData.getProps(tOffer.getContent(1).getType(), tOffer.getContent(1).getClassId())
    if not listp(tFurniProps) then
      return getMember("no_icon_small").image
    end if
    tClass = me.getClassAsset(tFurniProps.getaProp(#class))
    if tClass = "poster" then
      tClass = tClass && tOffer.getContent(1).getExtraParam()
    end if
    if getThread(#dynamicdownloader).getComponent().isAssetDownloaded(tClass) then
      tPrevProps = [:]
      tPrevProps["class"] = tFurniProps[#class]
      tPrevProps["objectType"] = tFurniProps[#type]
      tPrevProps["direction"] = tFurniProps[#defaultDir]
      tPrevProps["dimensions"] = tFurniProps[#xdim] & "," & tFurniProps[#ydim]
      tPrevProps["partColors"] = tFurniProps[#partColors]
      if tPrevProps["class"] = "poster" then
        tPrevProps["class"] = tPrevProps["class"] && tOffer.getContent(1).getExtraParam()
      end if
      return me.renderLargePreviewImage(tPrevProps)
    end if
  else
    if not objectp(pDealPreviewObj) then
      return error(me, "Deal preview renderer object missing.", #resolveLargePreview)
    end if
    tAssetsLoaded = 1
    repeat with k = 1 to tOffer.getCount()
      tItem = tOffer.getContent(k)
      tFurniProps = pPersistentFurniData.getProps(tItem.getType(), tItem.getClassId())
      tClass = me.getClassAsset(tFurniProps.getaProp(#class))
      if not getThread(#dynamicdownloader).getComponent().isAssetDownloaded(tClass) then
        tAssetsLoaded = 0
      end if
    end repeat
    pDealPreviewObj.define(me.convertOfferListToDeallist(tOffer))
    return pDealPreviewObj.getPicture()
  end if
end

on showPreview me, tOfferGroup
  if voidp(pWndObj) then
    return RETURN, error(me, "Missing handle to window object!", #showPreview, #major)
  end if
  if not objectp(tOfferGroup) then
    return error(me, "Invalid input format", #showPreview, #major)
  end if
  if tOfferGroup.getCount() < 1 then
    return error(me, "Offer group is empty", #showPreview, #major)
  end if
  if tOfferGroup.getOffer(1).getCount() < 1 then
    return error(me, "Offer group item at index 1 has no content", #showPreview, #major)
  end if
  tPrevImage = me.resolveLargePreview(tOfferGroup.getOffer(1))
  if ilk(tPrevImage) <> #image then
    return 0
  end if
  if pWndObj.elementExists(pImageElements[2]) then
    me.centerBlitImageToElement(tPrevImage, pWndObj.getElement(pImageElements[2]))
  end if
  tCatalogProps = pPersistentCatalogData.getProps(tOfferGroup.getOffer(1).getName())
  if listp(tCatalogProps) then
    tDesc = tCatalogProps[#description]
    tExp = tOfferGroup.getOffer(1).getContent(1).getExpiration()
    if tExp <> -1 then
      tHours = tExp / 60
      tMins = tExp mod 60
      tExpText = replaceChunks(getText("expiring_item_postfix", "Lasts %x% hours %y% minutes."), "%x%", tHours)
      tExpText = replaceChunks(tExpText, "%y%", tMins)
      tDesc = tDesc && tExpText
    end if
    me.setElementText(pWndObj, "ctlg_description", tDesc)
    me.setElementText(pWndObj, "ctlg_product_name", tCatalogProps[#name])
  else
    error(me, "Missing catalogprops for offer " & tOfferGroup.getOffer(1).getName(), #showPreview, #minor)
  end if
  repeat with i = 1 to pOfferTypesAvailable.count
    tElements = pOfferTypesAvailable[i].getaProp(#elements)
    tText = me.getOfferPriceTextByType(tOfferGroup, pOfferTypesAvailable[i].getaProp(#type))
    repeat with tElement in tElements
      me.setElementText(pWndObj, tElement, tText)
    end repeat
  end repeat
  if listp(tCatalogProps) and (pTextElements.count >= 3) then
    if chars(tCatalogProps[#specialText], 2, 2) = ":" then
      tNum = value(tCatalogProps[#specialText].char[1])
      tText = chars(tCatalogProps[#specialText], 3, tCatalogProps[#specialText].length)
    else
      tNum = VOID
      tText = tCatalogProps[#specialText]
    end if
    if pWndObj.elementExists(pTextElements[3]) then
      pWndObj.getElement(pTextElements[3]).show()
      pWndObj.getElement(pTextElements[3]).setText(tText)
    end if
    if pWndObj.elementExists(pImageElements[3]) then
      if not voidp(tNum) then
        pWndObj.getElement(pImageElements[3]).show()
        pWndObj.getElement(pImageElements[3]).feedImage(getMember("catalog_special_txtbg" & tNum).image)
      else
        pWndObj.getElement(pImageElements[3]).hide()
      end if
    end if
  end if
end

on downloadCompleted me, tProps
  if tProps[#props][#pageid] <> me.pPageData[#pageid] then
    return 
  end if
  tDlProps = tProps[#props]
  if tDlProps.getaProp(#imagedownload) then
    if voidp(pWndObj) then
      return RETURN, error(me, "Missing handle to window object!", #downloadCompleted, #major)
    end if
    if not pWndObj.elementExists(tDlProps[#element]) then
      return error(me, "Missing target element " & tDlProps[#element], #downloadCompleted, #minor)
    end if
    tmember = getMember(tProps.getaProp(#assetId))
    if tmember.type <> #bitmap then
      return error(me, "Downloaded member was of incorrect type!", #downloadCompleted, #major)
    end if
    me.centerBlitImageToElement(tmember.image, pWndObj.getElement(tDlProps[#element]))
  else
    tSelectedItem = me.getSelectedProduct()
    if not voidp(tSelectedItem) then
      tFurniProps = pPersistentFurniData.getProps(tSelectedItem.getOffer(1).getType(), tSelectedItem.getOffer(1).getClassId())
      if not voidp(tFurniProps) then
        if tProps[#assetId] = me.getClassAsset(tFurniProps[#class]) then
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
  if tEvent = #mouseUp then
    case tSprID of
      "ctlg_productstrip":
        if ilk(tProp) <> #point then
          return 
        end if
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
          me.showPriceBox()
          me.setBuyButtonStates(me.getOfferTypeList(tSelectedItem))
          me.showPreview(tSelectedItem)
        end if
      "ctlg_buy_button", "ctlg_buy_pixels_credits", "ctlg_buy_pixels", "ctlg_buy_andwear":
        if not objectp(pProductStrip) then
          return 
        end if
        tSelectedItem = pProductStrip.getSelectedItem()
        if not voidp(tSelectedItem) then
          tOfferType = pOfferTypesAvailable[tSprID].getaProp(#type)
          tOffer = me.getOfferByType(tSelectedItem, tOfferType)
          if voidp(tOffer) then
            return error(me, "Unable to find offer of type " & tOfferType & " check page offer configuration.", #handleClick, #major)
          end if
          tExtraProps = VOID
          if (tSprID = "ctlg_buy_pixels_credits") or (tSprID = "ctlg_buy_pixels") or (tSprID = "ctlg_buy_andwear") then
            tExtraProps = [#disableGift]
          end if
          getThread(#catalogue).getComponent().requestPurchase(tOfferType, me.pPageData[#pageid], tOffer, #sendPurchaseFromCatalog, tExtraProps)
        end if
      otherwise:
        if tSprID contains "ctlg_buy_" then
          tItemIndex = value(chars(tSprID, 10, 10))
          if not integerp(tItemIndex) then
            return 
          end if
          if tItemIndex > me.pPageData[#offers].count then
            return error(me, "No product to purchase at index : " & tItemIndex, #minor)
          end if
          tOffer = me.getOfferByType(me.pPageData[#offers][tItemIndex], #credits)
          getThread(#catalogue).getComponent().requestPurchase(#credits, me.pPageData[#pageid], tOffer, #sendPurchaseFromCatalog)
        end if
    end case
  end if
end
