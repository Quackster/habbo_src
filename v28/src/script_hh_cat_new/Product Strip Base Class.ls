property pPageItemDownloader, pStripData, pTargetElement, pPersistentFurniData, pDealPreviewObj, pDealNumber, pSmallItemWidth, pSmallItemHeight, pPersistentCatalogData

on construct me 
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
  pSmallItemWidth = 0
  pSmallItemHeight = 0
  pNumberPosX = getVariable("catalogue.deal.numberpos.x")
  pNumberPosY = getVariable("catalogue.deal.numberpos.y")
  pPageId = -1
  return TRUE
end

on deconstruct me 
  pPageItemDownloader.removeCallback(me, #downloadCompleted)
  pStripData = void()
  return TRUE
end

on define me, tdata, tWidth, tHeight, tPageID 
  me.pPageId = tPageID
  me.pStripData = tdata
  me.resolveMembers()
end

on setStripItemState me, tItemIndex, tstate 
  pStripData.getAt(tItemIndex).setAt(#state, tstate)
end

on setTargetElement me, tElement, tScroll 
  pTargetElement = tElement
  pwidth = pTargetElement.getProperty(#width)
  pheight = pTargetElement.getProperty(#height)
  pTargetScroll = tScroll
end

on selectItemAt me, tloc 
  return()
end

on getSelectedItem me 
  return()
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

on resolveSmallPreview me, tOffer 
  tPrevMember = "ctlg_pic_"
  tOfferName = tOffer.getAt(#offername)
  if memberExists(tPrevMember & "small_" & tOfferName) then
    return(getMember(tPrevMember & "small_" & tOfferName).image)
  end if
  if (tOffer.getAt(#content).count = 1) then
    tFurniProps = pPersistentFurniData.getProps(tOffer.getAt(#content).getAt(1).getAt(#type), tOffer.getAt(#content).getAt(1).getAt(#classID))
    if not listp(tFurniProps) then
      return(getMember("no_icon_small").image)
    end if
    tClass = me.getClassAsset(tFurniProps.getaProp(#class))
    if (tClass = "poster") then
      tClass = tClass && tOffer.getAt(#content).getAt(1).getAt(#extra_param)
    end if
    if getThread(#dynamicdownloader).getComponent().isAssetDownloaded(tClass) then
      tImage = getObject("Preview_renderer").renderPreviewImage(void(), void(), tFurniProps.getaProp(#partColors), tClass)
      if tOffer.getAt(#content).getAt(1).getAt(#productcount) > 1 then
        if not objectp(pDealPreviewObj) then
          error(me, "Deal preview renderer object missing.", #resolveSmallPreview)
          return(tImage)
        end if
        tCountImg = pDealPreviewObj.getNumberImage(tOffer.getAt(#content).getAt(1).getAt(#productcount))
        tImage.copyPixels(tCountImg, (tCountImg.rect + rect(2, 0, 2, 0)), tCountImg.rect, [#ink:36])
      end if
      return(tImage)
    end if
  else
    if not objectp(pDealPreviewObj) then
      return(error(me, "Deal preview renderer object missing.", #resolveSmallPreview))
    end if
    return(pDealPreviewObj.renderDealPreviewImage(pDealNumber, me.convertOfferListToDeallist(tOffer.getAt(#content)), pSmallItemWidth, pSmallItemHeight))
  end if
  return(void())
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
    return(error(me, "Stripdata missing", #resolveMembers))
  end if
  i = 0
  repeat while pStripData <= undefined
    tProduct = getAt(undefined, undefined)
    i = (i + 1)
    tOffer = tProduct.getAt(#offerList).getAt(1)
    pDealNumber = i
    tSmallPrev = me.resolveSmallPreview(tOffer)
    if (ilk(tSmallPrev) = #image) then
      tProduct.setaProp(#smallPreview, tSmallPrev)
    end if
    if (tOffer.getAt(#content).count = 1) then
      tFurniProps = pPersistentFurniData.getProps(tOffer.getAt(#content).getAt(1).getAt(#type), tOffer.getAt(#content).getAt(1).getAt(#classID))
      if not listp(tFurniProps) then
      else
        tClass = me.getClassAsset(tFurniProps.getaProp(#class))
        if (tClass = "poster") then
          tClass = tClass && tOffer.getAt(#content).getAt(1).getAt(#extra_param)
        end if
        if not getThread(#dynamicdownloader).getComponent().isAssetDownloaded(tClass) then
          tObjectLoadList.add([#assetId:tClass, #type:#furni, #props:[#itemIndex:i, #pageid:me.pPageId]])
        end if
        if tOffer.getAt(#content).count > 1 then
          repeat while pStripData <= undefined
            tDealItem = getAt(undefined, undefined)
            tFurniProps = pPersistentFurniData.getProps(tDealItem.getAt(#type), tDealItem.getAt(#classID))
            if not listp(tFurniProps) then
            else
              tClass = me.getClassAsset(tFurniProps.getaProp(#class))
              if (tClass = "poster") then
                tClass = tClass && tDealItem.getAt(#extra_param)
              end if
              if not getThread(#dynamicdownloader).getComponent().isAssetDownloaded(tClass) then
                tObjectLoadList.add([#assetId:tClass, #type:#furni, #props:[#itemIndex:i, #pageid:me.pPageId]])
              end if
            end if
          end repeat
        end if
      end if
      pPageItemDownloader.defineCallback(me, #downloadCompleted)
      repeat while pStripData <= undefined
        tLoadObject = getAt(undefined, undefined)
        pPageItemDownloader.registerDownload(tLoadObject.getAt(#type), tLoadObject.getAt(#assetId), tLoadObject.getAt(#props))
      end repeat
    end if
  end repeat
end

on getClassAsset me, tClassName 
  tClass = tClassName
  if tClass contains "*" then
    tClass = tClass.getProp(#char, 1, (offset("*", tClass) - 1))
  end if
  return(tClass)
end

on downloadCompleted me, tProps 
  if tProps.getAt(#props).getaProp(#imagedownload) then
    return()
  end if
  if tProps.getAt(#props).getaProp(#pageid) <> me.pPageId then
    return()
  end if
  tItemIndex = tProps.getAt(#props).getAt(#itemIndex)
  if pStripData.count < tItemIndex then
    return()
  end if
  pDealNumber = tItemIndex
  tSmallPrev = me.resolveSmallPreview(pStripData.getAt(tItemIndex).getAt(#offerList).getAt(1))
  if (ilk(tSmallPrev) = #image) then
    pStripData.getAt(tItemIndex).setaProp(#smallPreview, tSmallPrev)
  end if
  return()
end
