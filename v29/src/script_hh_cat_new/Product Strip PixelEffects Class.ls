property pBgImages, pSpacing, pRefreshTimeoutId, pItemsPerRow, pimage, pBgColor, pSelectedItem, pRotationQuad

on construct me 
  callAncestor(#construct, [me])
  pimage = image(0, 0, 32)
  pSelectedItem = 0
  pItemsPerRow = 0
  pBgImages = [#selected:getMember(getVariable("productstrip.itembg.selected")), #unselected:getMember(getVariable("productstrip.itembg.unselected"))]
  pSpacing = getIntVariable("productstrip.pixelfx.default.item.spacing")
  pBgColor = rgb(getStringVariable("productstrip.default.background.color"))
  pRefreshTimeoutId = getUniqueID()
  tLoadImg = getMember("ctlg_loading_icon2").image
  pRotationQuad = [point(0, 0), point(tLoadImg.width, 0), point(tLoadImg.width, tLoadImg.height), point(0, tLoadImg.height)]
  me.pSmallItemWidth = getMember(getVariable("productstrip.itembg.selected")).width
  me.pSmallItemHeight = getMember(getVariable("productstrip.itembg.selected")).height
  return(1)
end

on deconstruct me 
  return(callAncestor(#deconstruct, [me]))
end

on setTargetElement me, tElement, tScroll 
  callAncestor(#setTargetElement, [me], tElement, tScroll)
  pItemsPerRow = (pBgImages.getAt(#unselected) / image.width + pSpacing)
  if ilk(me.pStripData) <> #propList then
    return(error(me, "Stripdata was invalid", #setTargetElement, #major))
  end if
  me.renderStripBg()
  pSelectedItem = 0
  i = 1
  repeat while i <= me.count(#pStripData)
    me.renderStripItem(i)
    i = 1 + i
  end repeat
  me.pushImage()
end

on enableRefreshTimeout me 
  if not timeoutExists(pRefreshTimeoutId) then
    createTimeout(pRefreshTimeoutId, 500, #refreshDownloadingSlots, me.getID(), void(), 0)
  end if
end

on disableRefreshTimeout me 
  if timeoutExists(pRefreshTimeoutId) then
    removeTimeout(pRefreshTimeoutId)
  end if
end

on resolveSmallPreview me, tOffer 
  if not objectp(tOffer) then
    return(error(me, "Invalid input format", #resolveSmallPreview, #minor))
  end if
  if tOffer.getCount() <> 1 then
    return(callAncestor(#resolveSmallPreview, [me]))
  end if
  tPrefix = "ctlg_pic_small_fx_"
  tClassID = tOffer.getContent(1).getClassId()
  if memberExists(tPrefix & tClassID) then
    return(getMember(tPrefix & tClassID).image)
  end if
end

on renderStripBg me 
  if ilk(me.pStripData) <> #propList then
    return(error(me, "Strip data invalid", #renderStripBg, #major))
  end if
  tItemCount = me.count(#pStripData)
  tRowCount = (tItemCount / pItemsPerRow) + 1
  if (tItemCount mod pItemsPerRow) = 0 then
    tRowCount = tRowCount - 1
  end if
  tImageHeight = (image.height + pSpacing * tRowCount)
  pimage = image(me.pwidth, tImageHeight, 32)
  pimage.fill(pimage.rect, [#shapeType:#rect, #color:pBgColor])
end

on renderStripItem me, tItemIndex, tImageOverride 
  if me.pItemsPerRow = 0 then
    return(error(me, "Cannot render, strip items per row not resolved yet!", #renderStripItem))
  end if
  if ilk(me.pStripData) <> #propList then
    return(error(me, "Strip data invalid", #renderStripItem, #major))
  end if
  tRowHeight = image.height + pSpacing
  tItemWidth = image.width + pSpacing
  tItemCount = me.count(#pStripData)
  if tItemIndex > tItemCount then
    return()
  end if
  tOffsetY = (tRowHeight * (tItemIndex - 1 / pItemsPerRow))
  tOffsetX = ((tItemIndex - 1 mod pItemsPerRow) * tItemWidth)
  if pSelectedItem = tItemIndex then
    tBgImg = pBgImages.getAt(#selected).image
  else
    tBgImg = pBgImages.getAt(#unselected).image
  end if
  tRect = tBgImg.rect
  pimage.copyPixels(tBgImg, tRect + rect(tOffsetX, tOffsetY, tOffsetX, tOffsetY), tRect, [#useFastQuads:1])
  if voidp(tImageOverride) then
    tPrevImage = me.getAt(tItemIndex).getSmallPreview()
    if not voidp(tPrevImage) then
      me.getAt(tItemIndex).setState(void())
    else
      tPrevImage = getMember("ctlg_loading_icon2").image
      me.getAt(tItemIndex).setState(#downloading)
      me.enableRefreshTimeout()
    end if
  else
    tPrevImage = tImageOverride
  end if
  tItemRect = tPrevImage.rect
  tCenterOffset = me.centerRectInRect(tItemRect, tRect)
  pimage.copyPixels(tPrevImage, tItemRect + rect(tOffsetX, tOffsetY, tOffsetX, tOffsetY) + rect(tCenterOffset.locH, tCenterOffset.locV, tCenterOffset.locH, tCenterOffset.locV), tItemRect, [#useFastQuads:1, #ink:36])
end

on centerRectInRect me, tSmallrect, tLargeRect 
  tpoint = point(0, 0)
  tpoint.locH = (tLargeRect.width - tSmallrect.width / 2)
  tpoint.locV = (tLargeRect.height - tSmallrect.height / 2)
  return(tpoint)
end

on getItemIndexAt me, tloc 
  tRowHeight = image.height + pSpacing
  tItemWidth = image.width + pSpacing
  return(((tloc.locV / tRowHeight) * pItemsPerRow) + (tloc.locH / tItemWidth) + 1)
end

on downloadCompleted me, tProps 
  if tProps.getAt(#props).getaProp(#imagedownload) then
    return()
  end if
  if tProps.getAt(#props).getAt(#pageid) <> me.pPageId then
    return()
  end if
  callAncestor(#downloadCompleted, [me], tProps)
  tItemIndex = tProps.getAt(#props).getAt(#itemIndex)
  me.renderStripItem(tItemIndex)
  me.pushImage()
end

on refreshDownloadingSlots me 
  if ilk(me.pStripData) <> #propList then
    return(error(me, "Strip data invalid", #refreshDownloadingSlots, #major))
  end if
  tIcon = getMember("ctlg_loading_icon2")
  t1 = pRotationQuad.getAt(1)
  t2 = pRotationQuad.getAt(2)
  t3 = pRotationQuad.getAt(3)
  t4 = pRotationQuad.getAt(4)
  pRotationQuad = [t2, t3, t4, t1]
  tImage = image.duplicate()
  tImage.copyPixels(tIcon.image, pRotationQuad, tIcon.rect)
  tDownloadingStuffs = 0
  i = 1
  repeat while i <= me.count(#pStripData)
    tStripItem = me.getAt(i)
    if tStripItem.getState() = #downloading then
      me.renderStripItem(i, tImage)
      tDownloadingStuffs = 1
    end if
    i = 1 + i
  end repeat
  me.pushImage()
  if not tDownloadingStuffs then
    me.disableRefreshTimeout()
  end if
end

on pushImage me 
  if not voidp(me.pTargetElement) then
    me.feedImage(pimage)
    if not voidp(me.pTargetScroll) then
      if pimage.height <= me.getProperty(#height) then
        me.hide()
      end if
    end if
  end if
end

on selectItemAt me, tloc 
  if ilk(tloc) <> #point then
    return()
  end if
  if ilk(me.pStripData) <> #propList then
    return(error(me, "Strip data invalid", #selectItemAt, #major))
  end if
  tItemIndex = me.getItemIndexAt(tloc)
  if tItemIndex <> pSelectedItem and tItemIndex <= me.count(#pStripData) then
    tOldSelection = pSelectedItem
    pSelectedItem = tItemIndex
    if tOldSelection > 0 then
      me.renderStripItem(tOldSelection)
    end if
    me.renderStripItem(tItemIndex)
    me.pushImage()
  end if
end

on getSelectedItem me 
  if ilk(me.pStripData) <> #propList then
    error(me, "Strip data invalid", #getSelectedItem, #major)
    return(void())
  end if
  if pSelectedItem > me.count(#pStripData) then
    error(me, "Selected item index was larger than stripitem count!", #getSelectedItem, #major)
    return(void())
  end if
  if pSelectedItem > 0 then
    return(me.getProp(#pStripData, pSelectedItem))
  else
    return(void())
  end if
end
