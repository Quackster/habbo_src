property pListItemHeight, pPageMaxSize, pPageVisibleSize, pBackImages

on construct me 
  me.cacheBackImages()
  pPageVisibleSize = 11
  pPageMaxSize = 20
  pListItemHeight = 25
  return(me.ancestor.construct())
end

on deconstruct me 
  pBackImages = []
  return(me.ancestor.deconstruct())
end

on addWindows me 
  me.pWindowID = "cr"
  tWrapObjRef = me.getWindowWrapper(me)
  if (tWrapObjRef = 0) then
    return FALSE
  end if
  tWrapObjRef.moveTo(90, 70)
  tSetID = me.pWindowSetId & "_top"
  tWrapObjRef.initSet(tSetID, 1)
  tWrapObjRef.addOneWindow(me.getWindowId("top"), "ig_frame_create.window", tSetID, [#span_all_columns:1])
  tSetID = me.pWindowSetId & "_a"
  tWrapObjRef.initSet(tSetID, 1)
  tWrapObjRef.addOneWindow(me.getWindowId("w1"), "ig_title_choose_lvl.window", tSetID)
  tWrapObjRef.addOneWindow(me.getWindowId("list"), "ig_gamelist.window", tSetID)
  tWrapObjRef.addOneWindow(me.getWindowId("btm"), "ig_frame_blank_btm.window", tSetID)
  return TRUE
end

on render me 
  tWrapObjRef = me.getWindowWrapper(me)
  if (tWrapObjRef = 0) then
    return FALSE
  end if
  tElement = tWrapObjRef.getElement("ig_gamelist", me.getWindowId("list"))
  if tElement <> 0 then
    tImage = me.renderListImage()
    if (ilk(tImage) = #image) then
      tElement.feedImage(tImage)
    end if
  end if
  return TRUE
end

on getItemIndexFromPoint me, tpoint 
  tItemID = ((tpoint.locV / pListItemHeight) + 1)
  return(tItemID)
end

on renderListImage me 
  tService = me.getIGComponent("LevelList")
  if (tService = 0) then
    return FALSE
  end if
  tIDList = tService.getMainListIds(pPageMaxSize)
  tIdCount = tIDList.count
  tSelectedLevelId = tService.getSelectedLevelId()
  if tIdCount > pPageVisibleSize then
    tImageSize = tIdCount
  else
    tImageSize = pPageVisibleSize
  end if
  if tIdCount > pPageVisibleSize then
    tScrollBars = 1
    tWidth = 212
  else
    tWidth = 233
  end if
  me.setScrollBar(tScrollBars)
  tImage = image(tWidth, (pListItemHeight * tImageSize), 32)
  tBackImage = 0
  i = 1
  repeat while i <= tIdCount
    tID = tIDList.getAt(i)
    if (tID = tSelectedLevelId) then
      me.renderSlotBackground(tImage, pBackImages.getAt(3), i)
    else
      me.renderSlotBackground(tImage, pBackImages.getAt((tBackImage + 1)), i)
    end if
    tItemRef = tService.getListEntry(tID)
    me.renderShort(tImage, tItemRef, i)
    tBackImage = not tBackImage
    i = (1 + i)
  end repeat
  i = (tIdCount + 1)
  repeat while i <= pPageVisibleSize
    me.renderSlotBackground(tImage, pBackImages.getAt((tBackImage + 1)), i)
    tBackImage = not tBackImage
    i = (1 + i)
  end repeat
  return(tImage)
end

on renderShort me, tImage, tGameRef, tCount 
  tOffsetV = (pListItemHeight * (tCount - 1))
  tIcon = tGameRef.getProperty(#game_type_icon)
  if (ilk(tIcon) = #image) then
    tPicOffsetH = (((19 - tIcon.width) / 2) + 8)
    tPicOffsetV = (((20 - tIcon.height) / 3) + 3)
    tImage.copyPixels(tIcon, (tIcon.rect + rect(tPicOffsetH, (tOffsetV + tPicOffsetV), tPicOffsetH, (tOffsetV + tPicOffsetV))), tIcon.rect, [#ink:36])
  end if
  tGameNameWriter = me.getPlainWriter()
  tTextImage = tGameNameWriter.render(tGameRef.getProperty(#level_name))
  if (ilk(tTextImage) = #image) then
    tPicOffsetH = 35
    tPicOffsetV = 8
    tImage.copyPixels(tTextImage, (tTextImage.rect + rect(tPicOffsetH, (tPicOffsetV + tOffsetV), tPicOffsetH, (tPicOffsetV + tOffsetV))), tTextImage.rect)
  end if
  return TRUE
end

on renderSlotBackground me, tImage, tBackImage, tCount 
  tOffsetY = ((tCount - 1) * pListItemHeight)
  tTargetRect = rect(0, tOffsetY, tImage.width, (tOffsetY + pListItemHeight))
  tImage.copyPixels(tBackImage, tTargetRect, tBackImage.rect)
  return TRUE
end

on cacheBackImages me 
  pBackImages = []
  repeat while ["ig_list_px_lblue", "ig_list_px_lite", "ig_list_px_dblue"] <= undefined
    tMemName = getAt(undefined, undefined)
    tmember = member(getmemnum(tMemName))
    if ilk(tmember) <> #member then
      return(error(me, "Cannot find bitmap member" && tMemName, #renderList))
    end if
    pBackImages.append(tmember.image)
  end repeat
end

on setScrollBar me, tstate 
  tWndObj = getWindow(me.getWindowId("list"))
  if (tWndObj = 0) then
    return FALSE
  end if
  tElement = tWndObj.getElement("ig_scrollbar")
  if tElement <> 0 then
    tElement.setProperty(#visible, tstate)
  end if
  tElement = tWndObj.getElement("ig_scrollbar_bg")
  if tElement <> 0 then
    tElement.setProperty(#visible, tstate)
  end if
  return TRUE
end
