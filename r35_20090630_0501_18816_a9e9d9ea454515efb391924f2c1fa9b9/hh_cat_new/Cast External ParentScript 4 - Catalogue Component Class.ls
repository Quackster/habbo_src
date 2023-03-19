property pPageCache, pCatalogIndex, pWaitingForData, pWaitingForNodeName, pWaitingForFrontPage, pPersistentCatalogDataId, pPageItemDownloader, pCreditInfoPageID, pPixelInfoPageID, pCreditInfoNodeName, pPixelInfoNodeName, pPurchaseProcessor

on construct me
  pPageCache = [:]
  pCatalogIndex = VOID
  pWaitingForData = -1
  pWaitingForFrontPage = 0
  pPersistentCatalogDataId = "Persistent Catalog Data"
  createObject(pPersistentCatalogDataId, ["Persistent Product Data Container"])
  pPageItemDownloader = createObject(getUniqueID(), "Page Item Downloader Class")
  pCreditInfoNodeName = "magic.credits"
  pPixelInfoNodeName = "magic.pixels"
  pCreditInfoPageID = VOID
  pPixelInfoPageID = VOID
  pPurchaseProcessor = VOID
  pWaitingForNodeName = EMPTY
  registerMessage(#refresh_catalogue, me.getID(), #refreshCatalogue)
end

on deconstruct me
  if objectExists(pPersistentCatalogDataId) then
    removeObject(pPersistentCatalogDataId)
  end if
  unregisterMessage(#refresh_catalogue, me.getID())
end

on updatePageData me, tPageID, tdata
  if ilk(tdata) <> #propList then
    return 0
  end if
  tGroups = me.createOfferGroups(tdata.duplicate())
  sendProcessTracking(503)
  if ilk(tGroups) <> #propList then
    return 0
  end if
  if ilk(pPageCache) <> #propList then
    return 0
  end if
  pPageCache.setaProp(tPageID, tGroups)
  sendProcessTracking(504)
  if tPageID = pWaitingForData then
    me.getInterface().displayPage(tPageID)
  end if
end

on updateCatalogIndex me, tdata
  pPageCache = [:]
  pCatalogIndex = tdata
  if pWaitingForFrontPage then
    tNode = me.getFirstNavigateableNode(pCatalogIndex)
    if voidp(tNode) then
      return 
    else
      me.preparePage(tNode[#pageid])
      pWaitingForFrontPage = 0
    end if
    tCreditInfoNode = me.getNodeByName(pCreditInfoNodeName, pCatalogIndex)
    tPixelInfoNode = me.getNodeByName(pPixelInfoNodeName, pCatalogIndex)
    if not voidp(tCreditInfoNode) then
      pCreditInfoPageID = tCreditInfoNode[#pageid]
    end if
    if not voidp(tPixelInfoNode) then
      pPixelInfoPageID = tPixelInfoNode[#pageid]
    end if
  end if
  if pWaitingForNodeName <> EMPTY then
    tNode = me.getFirstNodeByName(pWaitingForNodeName, pCatalogIndex)
    if voidp(tNode) then
      return 
    else
      me.preparePage(tNode[#pageid])
      pWaitingForNodeName = EMPTY
    end if
    tCreditInfoNode = me.getNodeByName(pCreditInfoNodeName, pCatalogIndex)
    tPixelInfoNode = me.getNodeByName(pPixelInfoNodeName, pCatalogIndex)
    if not voidp(tCreditInfoNode) then
      pCreditInfoPageID = tCreditInfoNode[#pageid]
    end if
    if not voidp(tPixelInfoNode) then
      pPixelInfoPageID = tPixelInfoNode[#pageid]
    end if
  end if
end

on preparePage me, tPageID
  if voidp(pPageCache.getaProp(tPageID)) then
    me.initCatalogData()
    me.getHandler().requestPage(tPageID)
    pWaitingForData = tPageID
  else
    me.getInterface().displayPage(tPageID)
  end if
end

on prepareFrontPage me
  if not voidp(pCatalogIndex) then
    tNode = me.getFirstNavigateableNode(pCatalogIndex)
    if tNode.ilk <> #propList then
      return 0
    end if
    me.preparePage(tNode[#pageid])
    pWaitingForFrontPage = 0
  else
    pWaitingForFrontPage = 1
    me.initCatalogData()
  end if
end

on preparePageByName me, tLocalizedName
  if not voidp(pCatalogIndex) then
    tNode = me.getFirstNodeByName(tLocalizedName, pCatalogIndex)
    if voidp(tNode) then
      return 
    else
      me.preparePage(tNode[#pageid])
      pWaitingForNodeName = EMPTY
    end if
  else
    pWaitingForNodeName = tLocalizedName
    me.initCatalogData()
  end if
end

on prepareCreditsInfoPage me
  if voidp(pCreditInfoPageID) then
    return error(me, "Credits info page not found in node tree.", #prepareCreditsInfoPage, #major)
  end if
  me.preparePage(pCreditInfoPageID)
end

on preparePixelsInfoPage me
  if voidp(pPixelInfoPageID) then
    return error(me, "Pixels info page not found in node tree.", #preparePixelsInfoPage, #major)
  end if
  me.preparePage(pPixelInfoPageID)
end

on getPageData me, tPageID
  if ilk(pPageCache) <> #propList then
    return 0
  end if
  return pPageCache.getaProp(tPageID)
end

on getPageDataByLayout me, tLayout
  repeat with tPage in pPageCache
    if tPage[#layout] = tLayout then
      return tPage
    end if
  end repeat
  return [:]
end

on getCatalogIndex me
  return pCatalogIndex
end

on getPersistentCatalogDataObject me
  if voidp(getObject(pPersistentCatalogDataId)) then
    error(me, "Persistent Catalog Data Missing!", #getPersistentCatalogDataObject, #major)
  end if
  return getObject(pPersistentCatalogDataId)
end

on getPageItemDownloader me
  return pPageItemDownloader
end

on getFirstNavigateableNode me, tNode
  if ilk(tNode) <> #propList then
    error(me, "Node type was invalid.", #getFirstNavigateableNode, #critical)
    return VOID
  end if
  if tNode[#navigateable] and (tNode[#pageid] <> -1) then
    return tNode
  else
    if not voidp(tNode.getaProp(#subnodes)) then
      repeat with tSubNode in tNode[#subnodes]
        tResult = me.getFirstNavigateableNode(tSubNode)
        if not voidp(tResult) then
          return tResult
        end if
      end repeat
    end if
  end if
end

on getNodeByName me, tName
  return me.getFirstNodeByName(tName, pCatalogIndex)
end

on getFirstNodeByName me, tName, tNode
  if ilk(tNode) <> #propList then
    error(me, "Node type was invalid.", #getNodeByName, #major)
    return VOID
  end if
  if tNode[#nodename] = tName then
    return tNode
  else
    if not voidp(tNode.getaProp(#subnodes)) then
      repeat with tSubNode in tNode[#subnodes]
        tResult = me.getFirstNodeByName(tName, tSubNode)
        if not voidp(tResult) then
          return tResult
        end if
      end repeat
    end if
  end if
end

on initCatalogData me
  if voidp(pCatalogIndex) then
    me.getHandler().requestCatalogIndex()
  end if
end

on createOfferGroups me, tPageData
  if ilk(tPageData) <> #propList then
    error(me, "Page data was not a property list", #createOfferGroups, #major)
    return 0
  end if
  tGroupedOffers = [:]
  if ilk(tPageData[#offers]) <> #list then
    error(me, "Offers was not a list", #createOfferGroups, #major)
    return 0
  end if
  repeat with tOffer in tPageData[#offers]
    tProductCode = tOffer[#offername]
    if voidp(tGroupedOffers.getaProp(tProductCode)) then
      tOfferGroup = createObject(#random, ["Offergroup Class"])
      tGroupedOffers.setaProp(tProductCode, tOfferGroup)
    end if
    tGroupedOffers[tProductCode].add(tOffer)
  end repeat
  tPageData[#offers] = tGroupedOffers
  return tPageData
end

on findOfferByOldpageSelection me, tSelectedProduct, tPageID
  tPageData = me.pPageCache.getaProp(tPageID)
  tOffer = VOID
  repeat with i = 1 to tPageData[#offers].count
    if tSelectedProduct["purchaseCode"] = tPageData[#offers].getPropAt(i) then
      tOffer = tPageData[#offers][i].getOffer(1)
      exit repeat
    end if
  end repeat
  if voidp(tOffer) then
    error(me, "Could not map old page's product code to a current product id", #findOfferByOldpageSelection, #major)
    return VOID
  else
    tRemappedOffer = createObject(#random, ["Offer Class"])
    tRemappedOffer.copy(tOffer)
    tRemappedOffer.getContent(1).setExtraParam(tSelectedProduct["extra_parm"])
    return tRemappedOffer
  end if
end

on checkProductOrder me, tSelectedProduct
  if not listp(tSelectedProduct) then
    return error(me, "Selected product was not valid", #checkProductOrder, #major)
  end if
  tPageID = me.getInterface().getLastOpenedPage()
  tOffer = me.findOfferByOldpageSelection(tSelectedProduct, tPageID)
  if voidp(tOffer) then
    return error(me, "Could not reference an offer by selected product", #checkProductOrder, #major)
  end if
  if not objectp(pPurchaseProcessor) or (pPurchaseProcessor = 0) then
    pPurchaseProcessor = createObject(getUniqueID(), "Purchase Processor Class")
  end if
  pPurchaseProcessor.startPurchase([#offerType: #credits, #pageid: tPageID, #item: tOffer, #method: #sendPurchaseFromCatalog])
end

on requestPurchase me, tOfferType, tPageID, tSelectedItem, tMethod, tExtraProps
  if not objectp(pPurchaseProcessor) or (pPurchaseProcessor = 0) then
    pPurchaseProcessor = createObject(getUniqueID(), "Purchase Processor Class")
  end if
  tProps = [#offerType: tOfferType, #pageid: tPageID, #item: tSelectedItem, #method: tMethod]
  if listp(tExtraProps) then
    repeat with tProp in tExtraProps
      tProps.setaProp(tProp, 1)
    end repeat
  end if
  pPurchaseProcessor.startPurchase(tProps)
end

on getArePixelsEnabled me
  if getStringVariable("pixels.enabled") = "true" then
    return 1
  else
    return 0
  end if
end

on refreshCatalogue me, tMode
  if tMode = #club then
    me.getInterface().hideCatalogue()
  else
    if me.getInterface().isVisible() then
      me.getInterface().hideCatalogue()
      me.getInterface().showCatalogWasPublishedDialog()
    end if
  end if
  me.getHandler().requestCatalogIndex()
end
