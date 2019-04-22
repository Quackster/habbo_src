on construct(me)
  pPageItemDownloader = getThread(#catalogue).getComponent().getPageItemDownloader()
  pPersistentFurniData = void()
  pPersistentCatalogData = void()
  pStripData = void()
  pwidth = void()
  pheight = void()
  pTargetElement = void()
  pTargetScroll = void()
  pDealPreviewObj = getObject("catalogue_deal_preview_object")
  pDealNumber = 0
  pDealNumbers = []
  pSmallItemWidth = 0
  pSmallItemHeight = 0
  pNumberPosX = getVariable("catalogue.deal.numberpos.x")
  pNumberPosY = getVariable("catalogue.deal.numberpos.y")
  pPageId = -1
  return(1)
  exit
end

on deconstruct(me)
  pPageItemDownloader.removeCallback(me, #downloadCompleted)
  pStripData = void()
  return(1)
  exit
end

on define(me, tdata, tWidth, tHeight, tPageID)
  me.pPageId = tPageID
  me.pStripData = tdata
  me.resolveMembers()
  exit
end

on setStripItemState(me, tItemIndex, tstate)
  if ilk(pStripData) <> #propList then
    return(error(me, "Strip data invalid", #setStripItemState, #major))
  end if
  pStripData.getAt(tItemIndex).setAt(#state, tstate)
  exit
end

on setTargetElement(me, tElement, tScroll)
  pTargetElement = tElement
  pwidth = pTargetElement.getProperty(#width)
  pheight = pTargetElement.getProperty(#height)
  pTargetScroll = tScroll
  exit
end

on selectItemAt(me, tloc)
  return()
  exit
end

on getSelectedItem(me)
  return(void())
  exit
end

on resolveSmallPreview(me, tOffer)
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
    if tClass = "poster" then
      tClass = tClass && tOffer.getContent(1).getExtraParam()
    end if
    if getThread(#dynamicdownloader).getComponent().isAssetDownloaded(tClass) then
      tImage = getObject("Preview_renderer").renderPreviewImage(void(), void(), tFurniProps.getaProp(#partColors), tClass).duplicate()
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
    if voidp(pDealNumbers.getaProp(tOfferName)) then
      pDealNumbers.setaProp(tOfferName, pDealNumber)
      pDealNumber = pDealNumber + 1
    end if
    return(pDealPreviewObj.renderDealPreviewImage(pDealNumbers.getAt(tOfferName), me.convertOfferListToDeallist(tOffer), pSmallItemWidth, pSmallItemHeight))
  end if
  return(void())
  exit
end

on resolveMembers(me)
  if voidp(pPersistentFurniData) then
    pPersistentFurniData = getThread("dynamicdownloader").getComponent().getPersistentFurniDataObject()
  end if
  if voidp(pPersistentCatalogData) then
    pPersistentCatalogData = getThread("catalogue").getComponent().getPersistentCatalogDataObject()
  end if
  tObjectLoadList = []
  if voidp(pStripData) then
    return(error(me, "Stripdata missing", #resolveMembers))
  end if
  pDealNumber = 1
  i = 0
  repeat while me <= undefined
    tProduct = getAt(undefined, undefined)
    i = i + 1
    if tProduct.getCount() < 1 then
      error(me, "Offer group contains no offers", #resolveMembers, #minor)
    else
      if tProduct.getOffer(1).getCount() < 1 then
        error(me, "Offer at index 1 has no content", #resolveMembers, #minor)
      else
        tOffer = tProduct.getOffer(1)
        tSmallPrev = me.resolveSmallPreview(tOffer)
        if ilk(tSmallPrev) = #image then
          tProduct.setSmallPreview(tSmallPrev)
        end if
        if tOffer.getCount() = 1 then
          tFurniProps = pPersistentFurniData.getProps(tOffer.getContent(1).getType(), tOffer.getContent(1).getClassId())
          if not listp(tFurniProps) then
          else
            tClass = me.getClassAsset(tFurniProps.getaProp(#class))
            if tClass = "poster" then
              tClass = tClass && tOffer.getContent(1).getExtraParam()
            end if
            if not getThread(#dynamicdownloader).getComponent().isAssetDownloaded(tClass) then
              tObjectLoadList.add([#assetId:tClass, #type:#furni, #props:[#itemIndex:i, #pageid:me.pPageId]])
            end if
            if tOffer.getCount() > 1 then
              i = 1
              repeat while i <= tOffer.getCount()
                tDealItem = tOffer.getContent(i)
                tFurniProps = pPersistentFurniData.getProps(tDealItem.getType(), tDealItem.getClassId())
                if not listp(tFurniProps) then
                else
                  tClass = me.getClassAsset(tFurniProps.getaProp(#class))
                  if tClass = "poster" then
                    tClass = tClass && tDealItem.getExtraParam()
                  end if
                  if not getThread(#dynamicdownloader).getComponent().isAssetDownloaded(tClass) then
                    tObjectLoadList.add([#assetId:tClass, #type:#furni, #props:[#itemIndex:i, #pageid:me.pPageId]])
                  end if
                end if
                i = 1 + i
              end repeat
            end if
          end if
          if tObjectLoadList.count > 0 then
            pPageItemDownloader.defineCallback(me, #downloadCompleted)
          end if
          repeat while me <= undefined
            tLoadObject = getAt(undefined, undefined)
            pPageItemDownloader.registerDownload(tLoadObject.getAt(#type), tLoadObject.getAt(#assetId), tLoadObject.getAt(#props))
          end repeat
          exit
        end if
      end if
    end if
  end repeat
end

on getClassAsset(me, tClassName)
  if ilk(tClassName) <> #string then
    return("")
  end if
  tClass = tClassName
  if tClass contains "*" then
    tClass = tClass.getProp(#char, 1, offset("*", tClass) - 1)
  end if
  return(tClass)
  exit
end

on downloadCompleted(me, tProps)
  if tProps.getAt(#props).getaProp(#imagedownload) then
    return()
  end if
  if tProps.getAt(#props).getaProp(#pageid) <> me.pPageId then
    return()
  end if
  if ilk(pStripData) <> #propList then
    return()
  end if
  tItemIndex = tProps.getAt(#props).getAt(#itemIndex)
  if pStripData.count < tItemIndex then
    return()
  end if
  if pStripData.getAt(tItemIndex).getCount() < 1 then
    return(error(me, "Offergroup contains no offers", #downloadCompleted, #major))
  end if
  tSmallPrev = me.resolveSmallPreview(pStripData.getAt(tItemIndex).getOffer(1))
  if ilk(tSmallPrev) = #image then
    pStripData.getAt(tItemIndex).setSmallPreview(tSmallPrev)
  end if
  return()
  exit
end

on convertOfferListToDeallist(me, tOffer)
  if not objectp(tOffer) then
    return(error(me, "Invalid input format", #convertOfferListToDeallist, #major))
  end if
  if tOffer.getCount() < 1 then
    error(me, "Offer has no content", #convertOfferListToDeallist, #minor)
  end if
  if not objectp(me.pPersistentFurniData) then
    error(me, "Persistent furnidata object is missing", #convertOfferListToDeallist, #major)
    return([])
  end if
  tDealList = []
  i = 1
  repeat while i <= tOffer.getCount()
    tFurniProps = me.getProps(tOffer.getContent(i).getType(), tOffer.getContent(i).getClassId())
    if voidp(tFurniProps) then
      tDealList.add([#class:"", #partColors:"", #count:0])
    else
      tDealList.add([#class:tFurniProps.getAt(#class), #partColors:tFurniProps.getAt(#partColors), #count:tOffer.getContent(i).getProductCount()])
    end if
    i = 1 + i
  end repeat
  return(tDealList)
  exit
end