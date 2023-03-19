property pWndObj, pProductStrip, pSelectedProduct, pPageItemDownloader, pImageElements, pTextElements, pPersistentFurniData, pDealPreviewObj, pOfferTypesAvailable, pHideElements, pPrizes, pWriter, pStripImage, pFurnisPerRow, pRowHeight, pStripBg, pSlotRects

on construct me
  pSlotRects = []
  pFurnisPerRow = 3
  pRowHeight = 40
  pWndObj = VOID
  pProductStrip = VOID
  pSelectedProduct = VOID
  pOfferTypesAvailable = []
  pPageItemDownloader = getThread(#catalogue).getComponent().getPageItemDownloader()
  pDealPreviewObj = getObject("catalogue_deal_preview_object")
  pImageElements = getStructVariable("layout.fields.image.default")
  pTextElements = getStructVariable("layout.fields.text.default")
  pHideElements = getStructVariable("layout.hide.onclick.default")
  registerMessage(#recyclerPrizesReceived, me.getID(), #setPrizes)
  tWriterId = getUniqueID()
  createWriter(tWriterId, getStructVariable("struct.font.bold"))
  pWriter = getWriter(tWriterId)
  return callAncestor(#construct, [me])
end

on deconstruct me
  unregisterMessage(#recyclerPrizesReceived, me.getID())
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
  tConn = getConnection(getVariable("connection.info.id", #Info))
  if tConn <> 0 then
    tConn.send("GET_RECYCLER_PRIZES")
  end if
  if voidp(pPersistentFurniData) then
    pPersistentFurniData = getThread("dynamicdownloader").getComponent().getPersistentFurniDataObject()
  end if
end

on testPrizes me
  tPrizes = [:]
  tPrizes.setaProp(5, [#id: 5, #odds: 1000, #furniList: [["s", 2995], ["s", 2999]]])
  tPrizes.setaProp(4, [#id: 4, #odds: 500, #furniList: [["s", 1897], ["s", 2443], ["s", 2306], ["s", 2644]]])
  executeMessage(#recyclerPrizesReceived, tPrizes)
end

on setPrizes me, tPrizes
  if tPrizes.ilk <> #propList then
    return 0
  end if
  pPrizes = tPrizes
  me.renderStripBg()
  me.renderStripItems()
  me.downloadFurniCasts()
end

on downloadFurniCasts me
  if pPrizes.ilk <> #propList then
    return 0
  end if
  if voidp(pPersistentFurniData) then
    pPersistentFurniData = getThread("dynamicdownloader").getComponent().getPersistentFurniDataObject()
  end if
  pPageItemDownloader.defineCallback(me, #downloadCompleted)
  repeat with tCategory in pPrizes
    tFurniList = tCategory[#furniList]
    repeat with i = 1 to tFurniList.count
      ttype = tFurniList[i][1]
      tClassID = tFurniList[i][2]
      tFurniProps = pPersistentFurniData.getProps(ttype, tClassID)
      if tFurniProps.ilk <> #propList then
        return error(me, "Type not found in persistent furni data!" && ttype && tClassID, #downloadFurniCasts, #major)
      end if
      tClass = me.removeColorFromClassName(tFurniProps[#class])
      pPageItemDownloader.registerDownload(#furni, tClass, [#category: tCategory[#id], #item: i])
    end repeat
  end repeat
end

on removeColorFromClassName me, tClass
  if tClass contains "*" then
    tDelim = the itemDelimiter
    the itemDelimiter = "*"
    tClass = tClass.item[1]
    the itemDelimiter = tDelim
  end if
  return tClass
end

on renderStripItems me
  if pPrizes.ilk <> #propList then
    return 0
  end if
  repeat with i = 1 to pPrizes.count
    tFurniList = pPrizes[i][#furniList]
    repeat with j = 1 to tFurniList.count
      me.renderStripItem(pPrizes[i][#id], j)
    end repeat
  end repeat
  me.setImage(pStripBg, "ctlg_productstrip")
end

on renderStripItem me, tCategoryId, tIndex, tIsSelected
  if tIsSelected then
    tMemNum = getmemnum("stripitem.basic.bg.selected")
  else
    tMemNum = getmemnum("stripitem.basic.bg.unselected")
  end if
  if tMemNum <> 0 then
    tSlotBg = member(tMemNum).image
  end if
  tSlotRect = me.getSlotRect(tCategoryId, tIndex)
  if not tSlotRect then
    return 0
  end if
  if tSlotBg.ilk = #image then
    pStripBg.copyPixels(tSlotBg, tSlotRect, tSlotBg.rect)
  end if
  tCategoryData = pPrizes.getaProp(tCategoryId)
  tFurniList = tCategoryData.getaProp(#furniList)
  tProps = pPersistentFurniData.getProps(tFurniList[tIndex][1], tFurniList[tIndex][2])
  if tProps.ilk <> #propList then
    return error(me, "Type not found in persistent furni data!" && tFurniList[tIndex][1] && tFurniList[tIndex][2], #renderStripItem, #major)
  end if
  tClass = tProps[#class]
  tColors = tProps[#partColors]
  if getThread(#dynamicdownloader).getComponent().isAssetDownloaded(tClass) then
    tImage = getObject("Preview_renderer").renderPreviewImage(VOID, VOID, tColors, tClass)
  else
    tIconMem = member(getmemnum("ctlg_loading_icon2"))
    if tIconMem.type = #bitmap then
      tImage = tIconMem.image
    end if
  end if
  if tImage.ilk <> #image then
    return 0
  end if
  tOffsetX = tSlotRect[1] + ((tSlotRect.width - tImage.rect.width) / 2)
  tOffsetY = tSlotRect[2] + ((tSlotRect.height - tImage.rect.height) / 2)
  tRect = tImage.rect.offset(tOffsetX, tOffsetY)
  pStripBg.copyPixels(tImage, tRect, tImage.rect, [#ink: 36])
end

on renderStripBg me
  if pPrizes.ilk <> #propList then
    return 0
  end if
  if voidp(pWndObj) then
    return 0
  end if
  tStripElem = pWndObj.getElement("ctlg_productstrip")
  if not tStripElem then
    return 0
  end if
  tStripWidth = tStripElem.getProperty(#width)
  pStripBg = image(tStripWidth, 2000, 32)
  tMemNum = getmemnum("stripitem.basic.bg.unselected")
  if tMemNum <> 0 then
    tSlotBg = member(tMemNum).image
  else
    tSlotBg = image(38, 38, 32)
  end if
  tSlotSize = tSlotBg.width
  tTitleMargin = 5
  tOffsetY = 0
  pSlotRects = [:]
  repeat with i = 1 to pPrizes.count
    tFurniList = pPrizes[i][#furniList]
    if not listp(tFurniList) then
      next repeat
    end if
    if tFurniList.count = 0 then
      next repeat
    end if
    tID = pPrizes[i][#id]
    tTitle = getText("recycler_prize_category_" & tID)
    tTitleImage = pWriter.render(tTitle).duplicate()
    tTargetRect = rect(0, tOffsetY, tTitleImage.width, tOffsetY + tTitleImage.height)
    pStripBg.copyPixels(tTitleImage, tTargetRect, tTitleImage.rect)
    tOffsetY = tOffsetY + tTitleImage.height + tTitleMargin
    tRowCount = 1
    tOffsetX = 0
    repeat with j = 1 to tFurniList.count
      if (tOffsetX + tSlotBg.width) > tStripWidth then
        tOffsetX = 0
        tOffsetY = tOffsetY + tSlotBg.height
      end if
      tTargetRect = rect(tOffsetX, tOffsetY, tOffsetX + tSlotBg.width, tOffsetY + tSlotBg.height)
      pStripBg.copyPixels(tSlotBg, tTargetRect, tSlotBg.rect)
      me.setSlotRect(pPrizes[i][#id], j, tTargetRect)
      tOffsetX = tOffsetX + tSlotBg.width
    end repeat
    tOffsetY = tOffsetY + tSlotBg.height + tTitleMargin
  end repeat
  pStripBg = pStripBg.crop(rect(0, 0, tStripWidth, tOffsetY))
  me.setImage(pStripBg, "ctlg_productstrip")
  me.updateStripScroll()
end

on setSlotRect me, tCategoryId, tItem, tRect
  tCategory = pSlotRects.getaProp(tCategoryId)
  if voidp(tCategory) then
    tCategory = []
  end if
  tCategory[tItem] = tRect
  pSlotRects.setaProp(tCategoryId, tCategory)
end

on getSlotRect me, tCategoryId, tIndex
  if pSlotRects.ilk <> #propList then
    return 0
  end if
  tCategory = pSlotRects.getaProp(tCategoryId)
  if not listp(tCategory) then
    return 0
  end if
  if (tIndex < 1) or (tIndex > tCategory.count) then
    return 0
  end if
  return tCategory[tIndex]
end

on setImage me, tImage, tElemID
  if voidp(pWndObj) then
    return 0
  end if
  if not pWndObj.elementExists(tElemID) then
    return 0
  end if
  tElem = pWndObj.getElement(tElemID)
  tElem.feedImage(tImage)
end

on updateStripScroll me
  if voidp(pWndObj) then
    return 0
  end if
  tStrip = pWndObj.getElement("ctlg_productstrip")
  if not tStrip then
    return 0
  end if
  tScroll = pWndObj.getElement("ctlg_products_scroll")
  if not tScroll then
    return 0
  end if
  if pStripBg.ilk <> #image then
    return 0
  end if
  tShowScroll = pStripBg.height > tStrip.getProperty(#height)
  tScroll.setProperty(#visible, tShowScroll)
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
end

on setElementText me, tWndObj, tElemName, tText
  if voidp(tWndObj) then
    return 0
  end if
  if tWndObj.elementExists(tElemName) then
    tWndObj.getElement(tElemName).setText(tText)
  else
  end if
end

on unmergeWindow me, tParentWndObj
  tLayoutMember = "ctlg_" & me.pPageData[#layout] & ".window"
  if not memberExists(tLayoutMember) then
    return error(me, "Layout member " & tLayoutMember & " missing.", #mergeWindow)
  end if
  tParentWndObj.unmerge()
end

on showPreview me, tCategory, tItem
  if voidp(pWndObj) then
    return error(me, "Missing handle to window object!", #showPreview, #major)
  end if
  if voidp(pPersistentFurniData) then
    pPersistentFurniData = getThread("dynamicdownloader").getComponent().getPersistentFurniDataObject()
  end if
  tCategoryInfo = pPrizes.getaProp(tCategory)
  tFurniList = tCategoryInfo[#furniList]
  tFurni = tFurniList[tItem]
  tProps = pPersistentFurniData.getProps(tFurni[1], tFurni[2])
  tPreviewProps = [:]
  tPreviewProps["class"] = me.removeColorFromClassName(tProps[#class])
  tPreviewProps["direction"] = EMPTY
  tPreviewProps["dimensions"] = tProps[#xdim] & "," & tProps[#ydim]
  tPreviewProps["objectType"] = tProps[#type]
  tPreviewProps["partColors"] = tProps[#partColors]
  tPreviewImage = me.renderLargePreviewImage(tPreviewProps)
  if tPreviewImage.ilk <> #image then
    return 0
  end if
  if pWndObj.elementExists(pImageElements[2]) then
    me.centerBlitImageToElement(tPreviewImage, pWndObj.getElement(pImageElements[2]))
  end if
  tFurniName = tProps[#localizedName]
  tCatInfo = pPrizes.getaProp(tCategory)
  tOdds = tCatInfo.getaProp(#odds)
  tOddsText = getText("recycler_prize_odds_" & tCategory)
  tOddsText = replaceChunks(tOddsText, "%odds%", "1:" & tOdds)
  me.setElementText(me.pWndObj, "ctlg_description", tOddsText)
  me.setElementText(me.pWndObj, "ctlg_product_name", tFurniName)
end

on downloadCompleted me, tProps
  me.renderStripItems()
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
  if tEvent <> #mouseUp then
    return 0
  end if
  if tSprID <> "ctlg_productstrip" then
    return 0
  end if
  if ilk(tProp) <> #point then
    return 0
  end if
  repeat with i = 1 to pSlotRects.count
    tCategoryId = pSlotRects.getPropAt(i)
    tRects = pSlotRects[i]
    repeat with j = 1 to tRects.count
      tRect = tRects[j]
      if tRect.ilk <> #rect then
        next repeat
      end if
      if tProp.inside(tRect) then
        me.showPreview(tCategoryId, j)
        exit repeat
      end if
    end repeat
  end repeat
end
