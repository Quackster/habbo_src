property pimage, pSelectedItem, pItemsPerRow, pBgImages, pSpacing, pBgColor, pRefreshTimeoutId, pRotationQuad

on construct me
  callAncestor(#construct, [me])
  pimage = image(0, 0, 32)
  pSelectedItem = 0
  pItemsPerRow = 0
  pBgImages = [#selected: getMember(getVariable("productstrip.itembg.selected")), #unselected: getMember(getVariable("productstrip.itembg.unselected"))]
  pSpacing = getIntVariable("productstrip.default.item.spacing")
  pBgColor = rgb(getStringVariable("productstrip.default.background.color"))
  pRefreshTimeoutId = getUniqueID()
  tLoadImg = getMember("ctlg_loading_icon2").image
  pRotationQuad = [point(0, 0), point(tLoadImg.width, 0), point(tLoadImg.width, tLoadImg.height), point(0, tLoadImg.height)]
  me.pSmallItemWidth = getMember(getVariable("productstrip.itembg.selected")).width
  me.pSmallItemHeight = getMember(getVariable("productstrip.itembg.selected")).height
  return 1
end

on deconstruct me
  return callAncestor(#deconstruct, [me])
end

on setTargetElement me, tElement, tScroll
  callAncestor(#setTargetElement, [me], tElement, tScroll)
  pItemsPerRow = me.pwidth / (pBgImages[#unselected].image.width + pSpacing)
  if ilk(me.pStripData) <> #propList then
    return error(me, "Stripdata was invalid", #setTargetElement, #major)
  end if
  me.renderStripBg()
  pSelectedItem = 0
  repeat with i = 1 to me.pStripData.count
    me.renderStripItem(i)
  end repeat
  me.pushImage()
end

on enableRefreshTimeout me
  if not timeoutExists(pRefreshTimeoutId) then
    createTimeout(pRefreshTimeoutId, 500, #refreshDownloadingSlots, me.getID(), VOID, 0)
  end if
end

on disableRefreshTimeout me
  if timeoutExists(pRefreshTimeoutId) then
    removeTimeout(pRefreshTimeoutId)
  end if
end

on renderStripBg me
  if ilk(me.pStripData) <> #propList then
    return error(me, "Strip data invalid", #renderStripBg, #major)
  end if
  tItemCount = me.pStripData.count
  tRowCount = (tItemCount / pItemsPerRow) + 1
  if (tItemCount mod pItemsPerRow) = 0 then
    tRowCount = tRowCount - 1
  end if
  tImageHeight = (pBgImages[#unselected].image.height + pSpacing) * tRowCount
  pimage = image(me.pwidth, tImageHeight, 32)
  pimage.fill(pimage.rect, [#shapeType: #rect, #color: pBgColor])
end

on renderStripItem me, tItemIndex, tImageOverride
  if me.pItemsPerRow = 0 then
    return error(me, "Cannot render, strip items per row not resolved yet!", #renderStripItem)
  end if
  if ilk(me.pStripData) <> #propList then
    return error(me, "Strip data invalid", #renderStripItem, #major)
  end if
  tRowHeight = pBgImages[#unselected].image.height + pSpacing
  tItemWidth = pBgImages[#unselected].image.width + pSpacing
  tItemCount = me.pStripData.count
  if tItemIndex > tItemCount then
    return 
  end if
  tOffsetY = tRowHeight * ((tItemIndex - 1) / pItemsPerRow)
  tOffsetX = (tItemIndex - 1) mod pItemsPerRow * tItemWidth
  if pSelectedItem = tItemIndex then
    tBgImg = pBgImages[#selected].image
  else
    tBgImg = pBgImages[#unselected].image
  end if
  tRect = tBgImg.rect
  pimage.copyPixels(tBgImg, tRect + rect(tOffsetX, tOffsetY, tOffsetX, tOffsetY), tRect, [#useFastQuads: 1])
  if voidp(tImageOverride) then
    tPrevImage = me.pStripData[tItemIndex].getSmallPreview()
    if not voidp(tPrevImage) then
      me.pStripData[tItemIndex].setState(VOID)
    else
      tPrevImage = getMember("ctlg_loading_icon2").image
      me.pStripData[tItemIndex].setState(#downloading)
      me.enableRefreshTimeout()
    end if
  else
    tPrevImage = tImageOverride
  end if
  tItemRect = tPrevImage.rect
  tCenterOffset = me.centerRectInRect(tItemRect, tRect)
  pimage.copyPixels(tPrevImage, tItemRect + rect(tOffsetX, tOffsetY, tOffsetX, tOffsetY) + rect(tCenterOffset.locH, tCenterOffset.locV, tCenterOffset.locH, tCenterOffset.locV), tItemRect, [#useFastQuads: 1, #ink: 36])
end

on centerRectInRect me, tSmallrect, tLargeRect
  tpoint = point(0, 0)
  tpoint.locH = (tLargeRect.width - tSmallrect.width) / 2
  tpoint.locV = (tLargeRect.height - tSmallrect.height) / 2
  return tpoint
end

on getItemIndexAt me, tloc
  tRowHeight = pBgImages[#unselected].image.height + pSpacing
  tItemWidth = pBgImages[#unselected].image.width + pSpacing
  return (tloc.locV / tRowHeight * pItemsPerRow) + ((tloc.locH / tItemWidth) + 1)
end

on downloadCompleted me, tProps
  if tProps[#props].getaProp(#imagedownload) then
    return 
  end if
  if tProps[#props].getaProp(#pageid) <> me.pPageId then
    return 
  end if
  callAncestor(#downloadCompleted, [me], tProps)
  tItemIndex = tProps[#props][#itemIndex]
  if not tItemIndex then
    return 
  end if
  me.renderStripItem(tItemIndex)
  me.pushImage()
end

on refreshDownloadingSlots me
  if ilk(me.pStripData) <> #propList then
    return error(me, "Strip data invalid", #refreshDownloadingSlots, #major)
  end if
  tIcon = getMember("ctlg_loading_icon2")
  t1 = pRotationQuad[1]
  t2 = pRotationQuad[2]
  t3 = pRotationQuad[3]
  t4 = pRotationQuad[4]
  pRotationQuad = [t2, t3, t4, t1]
  tImage = tIcon.image.duplicate()
  tImage.copyPixels(tIcon.image, pRotationQuad, tIcon.rect)
  tDownloadingStuffs = 0
  repeat with i = 1 to me.pStripData.count
    tStripItem = me.pStripData[i]
    if tStripItem.getState() = #downloading then
      me.renderStripItem(i, tImage)
      tDownloadingStuffs = 1
    end if
  end repeat
  me.pushImage()
  if not tDownloadingStuffs then
    me.disableRefreshTimeout()
  end if
end

on pushImage me
  if not voidp(me.pTargetElement) then
    me.pTargetElement.feedImage(pimage)
    if not voidp(me.pTargetScroll) then
      if pimage.height <= me.pTargetElement.getProperty(#height) then
        me.pTargetScroll.hide()
      end if
    end if
  end if
end

on selectItemAt me, tloc
  if ilk(tloc) <> #point then
    return 
  end if
  if ilk(me.pStripData) <> #propList then
    return error(me, "Strip data invalid", #selectItemAt, #major)
  end if
  tItemIndex = me.getItemIndexAt(tloc)
  if (tItemIndex <> pSelectedItem) and (tItemIndex <= me.pStripData.count) then
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
    return VOID
  end if
  if pSelectedItem > me.pStripData.count then
    error(me, "Selected item index was larger than stripitem count!", #getSelectedItem, #major)
    return VOID
  end if
  if pSelectedItem > 0 then
    return me.pStripData[pSelectedItem]
  else
    return VOID
  end if
end
