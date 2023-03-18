property pPageItemDownloader, pPersistentFurniData, pPersistentCatalogData, pStripData, pwidth, pheight, pTargetElement, pTargetScroll, pDealPreviewObj, pDealNumber, pSmallItemWidth, pSmallItemHeight, pNumberPosX, pNumberPosY, pPageId

on construct me
  pPageItemDownloader = getThread(#catalogue).getComponent().getPageItemDownloader()
  pPersistentFurniData = VOID
  pPersistentCatalogData = VOID
  pStripData = VOID
  pwidth = VOID
  pheight = VOID
  pTargetElement = VOID
  pTargetScroll = VOID
  pDealPreviewObj = getObject("catalogue_deal_preview_object")
  pDealNumber = 0
  pSmallItemWidth = 0
  pSmallItemHeight = 0
  pNumberPosX = getVariable("catalogue.deal.numberpos.x")
  pNumberPosY = getVariable("catalogue.deal.numberpos.y")
  pPageId = -1
  return 1
end

on deconstruct me
  pPageItemDownloader.removeCallback(me, #downloadCompleted)
  pStripData = VOID
  return 1
end

on define me, tdata, tWidth, tHeight, tPageID
  me.pPageId = tPageID
  me.pStripData = tdata
  me.resolveMembers()
end

on setStripItemState me, tItemIndex, tstate
  pStripData[tItemIndex][#state] = tstate
end

on setTargetElement me, tElement, tScroll
  pTargetElement = tElement
  pwidth = pTargetElement.getProperty(#width)
  pheight = pTargetElement.getProperty(#height)
  pTargetScroll = tScroll
end

on selectItemAt me, tloc
  return 
end

on getSelectedItem me
  return 
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

on resolveSmallPreview me, tOffer
  tPrevMember = "ctlg_pic_"
  tOfferName = tOffer[#offername]
  if memberExists(tPrevMember & "small_" & tOfferName) then
    return getMember(tPrevMember & "small_" & tOfferName).image
  end if
  if tOffer[#content].count = 1 then
    tFurniProps = pPersistentFurniData.getProps(tOffer[#content][1][#type], tOffer[#content][1][#classID])
    if not listp(tFurniProps) then
      return getMember("no_icon_small").image
    end if
    tClass = me.getClassAsset(tFurniProps.getaProp(#class))
    if tClass = "poster" then
      tClass = tClass && tOffer[#content][1][#extra_param]
    end if
    if getThread(#dynamicdownloader).getComponent().isAssetDownloaded(tClass) then
      tImage = getObject("Preview_renderer").renderPreviewImage(VOID, VOID, tFurniProps.getaProp(#partColors), tClass)
      if tOffer[#content][1][#productcount] > 1 then
        if not objectp(pDealPreviewObj) then
          error(me, "Deal preview renderer object missing.", #resolveSmallPreview)
          return tImage
        end if
        tCountImg = pDealPreviewObj.getNumberImage(tOffer[#content][1][#productcount])
        tImage.copyPixels(tCountImg, tCountImg.rect + rect(2, 0, 2, 0), tCountImg.rect, [#ink: 36])
      end if
      return tImage
    end if
  else
    if not objectp(pDealPreviewObj) then
      return error(me, "Deal preview renderer object missing.", #resolveSmallPreview)
    end if
    return pDealPreviewObj.renderDealPreviewImage(pDealNumber, me.convertOfferListToDeallist(tOffer[#content]), pSmallItemWidth, pSmallItemHeight)
  end if
  return VOID
end

on resolveMembers me
  if voidp(pPersistentFurniData) then
    pPersistentFurniData = getThread("dynamicdownloader").getComponent().getPersistentFurniDataObject()
  end if
  if voidp(pPersistentCatalogData) then
    pPersistentCatalogData = getThread("catalogue").getComponent().getPersistentCatalogDataObject()
  end if
  tObjectLoadList = []
  if voidp(pStripData) then
    return error(me, "Stripdata missing", #resolveMembers)
  end if
  i = 0
  repeat with tProduct in pStripData
    i = i + 1
    tOffer = tProduct[#offerList][1]
    pDealNumber = i
    tSmallPrev = me.resolveSmallPreview(tOffer)
    if ilk(tSmallPrev) = #image then
      tProduct.setaProp(#smallPreview, tSmallPrev)
    end if
    if tOffer[#content].count = 1 then
      tFurniProps = pPersistentFurniData.getProps(tOffer[#content][1][#type], tOffer[#content][1][#classID])
      if not listp(tFurniProps) then
        next repeat
      end if
      tClass = me.getClassAsset(tFurniProps.getaProp(#class))
      if tClass = "poster" then
        tClass = tClass && tOffer[#content][1][#extra_param]
      end if
      if not getThread(#dynamicdownloader).getComponent().isAssetDownloaded(tClass) then
        tObjectLoadList.add([#assetId: tClass, #type: #furni, #props: [#itemIndex: i, #pageid: me.pPageId]])
      end if
    end if
    if tOffer[#content].count > 1 then
      repeat with tDealItem in tOffer[#content]
        tFurniProps = pPersistentFurniData.getProps(tDealItem[#type], tDealItem[#classID])
        if not listp(tFurniProps) then
          next repeat
        end if
        tClass = me.getClassAsset(tFurniProps.getaProp(#class))
        if tClass = "poster" then
          tClass = tClass && tDealItem[#extra_param]
        end if
        if not getThread(#dynamicdownloader).getComponent().isAssetDownloaded(tClass) then
          tObjectLoadList.add([#assetId: tClass, #type: #furni, #props: [#itemIndex: i, #pageid: me.pPageId]])
        end if
      end repeat
    end if
  end repeat
  pPageItemDownloader.defineCallback(me, #downloadCompleted)
  repeat with tLoadObject in tObjectLoadList
    pPageItemDownloader.registerDownload(tLoadObject[#type], tLoadObject[#assetId], tLoadObject[#props])
  end repeat
end

on getClassAsset me, tClassName
  tClass = tClassName
  if tClass contains "*" then
    tClass = tClass.char[1..offset("*", tClass) - 1]
  end if
  return tClass
end

on downloadCompleted me, tProps
  if tProps[#props].getaProp(#imagedownload) then
    return 
  end if
  if tProps[#props].getaProp(#pageid) <> me.pPageId then
    return 
  end if
  tItemIndex = tProps[#props][#itemIndex]
  if pStripData.count < tItemIndex then
    return 
  end if
  pDealNumber = tItemIndex
  tSmallPrev = me.resolveSmallPreview(pStripData[tItemIndex][#offerList][1])
  if ilk(tSmallPrev) = #image then
    pStripData[tItemIndex].setaProp(#smallPreview, tSmallPrev)
  end if
  return 
end
