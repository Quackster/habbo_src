property pBgImages, pSpacing, pRefreshTimeoutId, pItemsPerRow, pimage, pBgColor, pSelectedItem, pRotationQuad

on construct me 
  callAncestor(#construct, [me])
  pimage = image(0, 0, 32)
  pSelectedItem = 0
  pItemsPerRow = 0
  pBgImages = [#selected:getMember(getVariable("productstrip.itembg.selected")), #unselected:getMember(getVariable("productstrip.itembg.unselected"))]
  pSpacing = getVariableValue("productstrip.pixelfx.default.item.spacing")
  pBgColor = rgb(string(getVariable("productstrip.default.background.color")))
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
  pItemsPerRow = pBgImages.getAt(#unselected) / image.width + pSpacing
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
  if tOffer.getAt(#content).count <> 1 then
    return(callAncestor(#resolveSmallPreview, [me]))
  end if
  tPrefix = "ctlg_pic_small_fx_"
  tClassID = tOffer.getAt(#content).getAt(1).getAt(#classID)
  if memberExists(tPrefix & tClassID) then
    return(getMember(tPrefix & tClassID).image)
  end if
end

on renderStripBg me 
  tItemCount = me.count(#pStripData)
  tRowCount = tItemCount / pItemsPerRow + 1
  if tItemCount mod pItemsPerRow = 0 then
    tRowCount = tRowCount - 1
  end if
  tImageHeight = image.height + pSpacing * tRowCount
  pimage = image(me.pwidth, tImageHeight, 32)
  pimage.fill(pimage.rect, [#shapeType:#rect, #color:pBgColor])
end

on renderStripItem me, tItemIndex, tImageOverride 
  if me.pItemsPerRow = 0 then
    return(error(me, "Cannot render, strip items per row not resolved yet!", #renderStripItem))
  end if
  tRowHeight = image.height + pSpacing
  tItemWidth = image.width + pSpacing
  tItemCount = me.count(#pStripData)
  if tItemIndex > tItemCount then
    return(error(me, "Item index out of range", #renderStripItem))
  end if
  tOffsetY = tRowHeight * tItemIndex - 1 / pItemsPerRow
  tOffsetX = tItemIndex - 1 mod pItemsPerRow * tItemWidth
  if pSelectedItem = tItemIndex then
    tBgImg = pBgImages.getAt(#selected).image
  else
    tBgImg = pBgImages.getAt(#unselected).image
  end if
  tRect = tBgImg.rect
  pimage.copyPixels(tBgImg, tRect + rect(tOffsetX, tOffsetY, tOffsetX, tOffsetY), tRect, [#useFastQuads:1])
  if voidp(tImageOverride) then
    tPrevImage = me.getAt(tItemIndex).getaProp(#smallPreview)
    if not voidp(tPrevImage) then
      me.getAt(tItemIndex).deleteProp(#state)
    else
      tPrevImage = getMember("ctlg_loading_icon2").image
      me.getAt(tItemIndex).setaProp(#state, #downloading)
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
  tpoint.locH = tLargeRect.width - tSmallrect.width / 2
  tpoint.locV = tLargeRect.height - tSmallrect.height / 2
  return(tpoint)
end

on getItemIndexAt me, tloc 
  tRowHeight = image.height + pSpacing
  tItemWidth = image.width + pSpacing
  return(tloc.locV / tRowHeight * pItemsPerRow + tloc.locH / tItemWidth + 1)
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
    if tStripItem.getAt(#state) = #downloading then
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
  if pSelectedItem > 0 then
    return(me.getProp(#pStripData, pSelectedItem))
  else
    return(void())
  end if
end
