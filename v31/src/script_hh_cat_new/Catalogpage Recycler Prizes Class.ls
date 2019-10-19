on construct(me)
  pSlotRects = []
  pFurnisPerRow = 3
  pRowHeight = 40
  pWndObj = void()
  pProductStrip = void()
  pSelectedProduct = void()
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
  return(callAncestor(#construct, [me]))
  exit
end

on deconstruct(me)
  unregisterMessage(#recyclerPrizesReceived, me.getID())
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
  tConn = getConnection(getVariable("connection.info.id", #info))
  if tConn <> 0 then
    tConn.send("GET_RECYCLER_PRIZES")
  end if
  if voidp(pPersistentFurniData) then
    pPersistentFurniData = getThread("dynamicdownloader").getComponent().getPersistentFurniDataObject()
  end if
  exit
end

on testPrizes(me)
  tPrizes = []
  tPrizes.setaProp(5, [#id:5, #odds:1000, #furniList:[["s", 2995], ["s", 2999]]])
  tPrizes.setaProp(4, [#id:4, #odds:500, #furniList:[["s", 1897], ["s", 2443], ["s", 2306], ["s", 2644]]])
  executeMessage(#recyclerPrizesReceived, tPrizes)
  exit
end

on setPrizes(me, tPrizes)
  if tPrizes.ilk <> #propList then
    return(0)
  end if
  pPrizes = tPrizes
  me.renderStripBg()
  me.renderStripItems()
  me.downloadFurniCasts()
  exit
end

on downloadFurniCasts(me)
  if pPrizes.ilk <> #propList then
    return(0)
  end if
  if voidp(pPersistentFurniData) then
    pPersistentFurniData = getThread("dynamicdownloader").getComponent().getPersistentFurniDataObject()
  end if
  pPageItemDownloader.defineCallback(me, #downloadCompleted)
  repeat while me <= undefined
    tCategory = getAt(undefined, undefined)
    tFurniList = tCategory.getAt(#furniList)
    i = 1
    repeat while i <= tFurniList.count
      ttype = tFurniList.getAt(i).getAt(1)
      tClassID = tFurniList.getAt(i).getAt(2)
      tFurniProps = pPersistentFurniData.getProps(ttype, tClassID)
      tClass = me.removeColorFromClassName(tFurniProps.getAt(#class))
      pPageItemDownloader.registerDownload(#furni, tClass, [#category:tCategory.getAt(#id), #item:i])
      i = 1 + i
    end repeat
  end repeat
  exit
end

on removeColorFromClassName(me, tClass)
  if tClass contains "*" then
    tDelim = the itemDelimiter
    the itemDelimiter = "*"
    tClass = tClass.getProp(#item, 1)
    the itemDelimiter = tDelim
  end if
  return(tClass)
  exit
end

on renderStripItems(me)
  if pPrizes.ilk <> #propList then
    return(0)
  end if
  i = 1
  repeat while i <= pPrizes.count
    tFurniList = pPrizes.getAt(i).getAt(#furniList)
    j = 1
    repeat while j <= tFurniList.count
      me.renderStripItem(pPrizes.getAt(i).getAt(#id), j)
      j = 1 + j
    end repeat
    i = 1 + i
  end repeat
  me.setImage(pStripBg, "ctlg_productstrip")
  exit
end

on renderStripItem(me, tCategoryID, tIndex, tIsSelected)
  if tIsSelected then
    tMemNum = getmemnum("stripitem.basic.bg.selected")
  else
    tMemNum = getmemnum("stripitem.basic.bg.unselected")
  end if
  if tMemNum <> 0 then
    tSlotBg = member(tMemNum).image
  end if
  tSlotRect = me.getSlotRect(tCategoryID, tIndex)
  if not tSlotRect then
    return(0)
  end if
  if tSlotBg.ilk = #image then
    pStripBg.copyPixels(tSlotBg, tSlotRect, tSlotBg.rect)
  end if
  tCategoryData = pPrizes.getaProp(tCategoryID)
  tFurniList = tCategoryData.getaProp(#furniList)
  tProps = pPersistentFurniData.getProps(tFurniList.getAt(tIndex).getAt(1), tFurniList.getAt(tIndex).getAt(2))
  tClass = tProps.getAt(#class)
  tColors = tProps.getAt(#partColors)
  if getThread(#dynamicdownloader).getComponent().isAssetDownloaded(tClass) then
    tImage = getObject("Preview_renderer").renderPreviewImage(void(), void(), tColors, tClass)
  else
    tIconMem = member(getmemnum("ctlg_loading_icon2"))
    if tIconMem.type = #bitmap then
      tImage = tIconMem.image
    end if
  end if
  if tImage.ilk <> #image then
    return(0)
  end if
  tOffsetX = tSlotRect.width + tImage - rect.width / 2
  tOffsetY = tSlotRect.height + tImage - rect.height / 2
  tRect = rect.offset(tOffsetX, tOffsetY)
  pStripBg.copyPixels(tImage, tRect, tImage.rect, [#ink:36])
  exit
end

on renderStripBg(me)
  if pPrizes.ilk <> #propList then
    return(0)
  end if
  if voidp(pWndObj) then
    return(0)
  end if
  tStripElem = pWndObj.getElement("ctlg_productstrip")
  if not tStripElem then
    return(0)
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
  pSlotRects = []
  i = 1
  repeat while i <= pPrizes.count
    tFurniList = pPrizes.getAt(i).getAt(#furniList)
    if not listp(tFurniList) then
    else
      if tFurniList.count = 0 then
      else
        tID = pPrizes.getAt(i).getAt(#id)
        tTitle = getText("recycler_prize_category_" & tID)
        tTitleImage = pWriter.render(tTitle).duplicate()
        tTargetRect = rect(0, tOffsetY, tTitleImage.width, tOffsetY + tTitleImage.height)
        pStripBg.copyPixels(tTitleImage, tTargetRect, tTitleImage.rect)
        tOffsetY = tOffsetY + tTitleImage.height + tTitleMargin
        tRowCount = 1
        tOffsetX = 0
        j = 1
        repeat while j <= tFurniList.count
          if tOffsetX + tSlotBg.width > tStripWidth then
            tOffsetX = 0
            tOffsetY = tOffsetY + tSlotBg.height
          end if
          tTargetRect = rect(tOffsetX, tOffsetY, tOffsetX + tSlotBg.width, tOffsetY + tSlotBg.height)
          pStripBg.copyPixels(tSlotBg, tTargetRect, tSlotBg.rect)
          me.setSlotRect(pPrizes.getAt(i).getAt(#id), j, tTargetRect)
          tOffsetX = tOffsetX + tSlotBg.width
          j = 1 + j
        end repeat
        tOffsetY = tOffsetY + tSlotBg.height + tTitleMargin
      end if
    end if
    i = 1 + i
  end repeat
  pStripBg = pStripBg.crop(rect(0, 0, tStripWidth, tOffsetY))
  me.setImage(pStripBg, "ctlg_productstrip")
  me.updateStripScroll()
  exit
end

on setSlotRect(me, tCategoryID, tItem, tRect)
  tCategory = pSlotRects.getaProp(tCategoryID)
  if voidp(tCategory) then
    tCategory = []
  end if
  tCategory.setAt(tItem, tRect)
  pSlotRects.setaProp(tCategoryID, tCategory)
  exit
end

on getSlotRect(me, tCategoryID, tIndex)
  if pSlotRects.ilk <> #propList then
    return(0)
  end if
  tCategory = pSlotRects.getaProp(tCategoryID)
  if not listp(tCategory) then
    return(0)
  end if
  if tIndex < 1 or tIndex > tCategory.count then
    return(0)
  end if
  return(tCategory.getAt(tIndex))
  exit
end

on setImage(me, tImage, tElemID)
  if voidp(pWndObj) then
    return(0)
  end if
  if not pWndObj.elementExists(tElemID) then
    return(0)
  end if
  tElem = pWndObj.getElement(tElemID)
  tElem.feedImage(tImage)
  exit
end

on updateStripScroll(me)
  if voidp(pWndObj) then
    return(0)
  end if
  tStrip = pWndObj.getElement("ctlg_productstrip")
  if not tStrip then
    return(0)
  end if
  tScroll = pWndObj.getElement("ctlg_products_scroll")
  if not tScroll then
    return(0)
  end if
  if pStripBg.ilk <> #image then
    return(0)
  end if
  tShowScroll = pStripBg.height > tStrip.getProperty(#height)
  tScroll.setProperty(#visible, tShowScroll)
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
  exit
end

on setElementText(me, tWndObj, tElemName, tText)
  if voidp(tWndObj) then
    return(0)
  end if
  if tWndObj.elementExists(tElemName) then
    tWndObj.getElement(tElemName).setText(tText)
  else
  end if
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

on showPreview(me, tCategory, tItem)
  if voidp(pWndObj) then
    return(error(me, "Missing handle to window object!", #showPreview, #major))
  end if
  if voidp(pPersistentFurniData) then
    pPersistentFurniData = getThread("dynamicdownloader").getComponent().getPersistentFurniDataObject()
  end if
  tCategoryInfo = pPrizes.getaProp(tCategory)
  tFurniList = tCategoryInfo.getAt(#furniList)
  tFurni = tFurniList.getAt(tItem)
  tProps = pPersistentFurniData.getProps(tFurni.getAt(1), tFurni.getAt(2))
  tPreviewProps = []
  tPreviewProps.setAt("class", me.removeColorFromClassName(tProps.getAt(#class)))
  tPreviewProps.setAt("direction", "")
  tPreviewProps.setAt("dimensions", tProps.getAt(#xdim) & "," & tProps.getAt(#ydim))
  tPreviewProps.setAt("objectType", tProps.getAt(#type))
  tPreviewProps.setAt("partColors", tProps.getAt(#partColors))
  tPreviewImage = me.renderLargePreviewImage(tPreviewProps)
  if tPreviewImage.ilk <> #image then
    return(0)
  end if
  if pWndObj.elementExists(pImageElements.getAt(2)) then
    me.centerBlitImageToElement(tPreviewImage, pWndObj.getElement(pImageElements.getAt(2)))
  end if
  tFurniName = tProps.getAt(#localizedName)
  tCatInfo = pPrizes.getaProp(tCategory)
  tOdds = tCatInfo.getaProp(#odds)
  tOddsText = getText("recycler_prize_odds_" & tCategory)
  tOddsText = replaceChunks(tOddsText, "%odds%", "1:" & tOdds)
  me.setElementText(me.pWndObj, "ctlg_description", tOddsText)
  me.setElementText(me.pWndObj, "ctlg_product_name", tFurniName)
  exit
end

on downloadCompleted(me, tProps)
  me.renderStripItems()
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
  if tEvent <> #mouseUp then
    return(0)
  end if
  if tSprID <> "ctlg_productstrip" then
    return(0)
  end if
  if ilk(tProp) <> #point then
    return(0)
  end if
  i = 1
  repeat while i <= pSlotRects.count
    tCategoryID = pSlotRects.getPropAt(i)
    tRects = pSlotRects.getAt(i)
    j = 1
    repeat while j <= tRects.count
      tRect = tRects.getAt(j)
      if tRect.ilk <> #rect then
      else
        if tProp.inside(tRect) then
          me.showPreview(tCategoryID, j)
        else
          j = 1 + j
        end if
        i = 1 + i
        exit
      end if
    end repeat
  end repeat
end