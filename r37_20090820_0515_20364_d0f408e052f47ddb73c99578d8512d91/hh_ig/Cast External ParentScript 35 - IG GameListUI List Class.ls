property pListItemHeight, pPageVisibleSize, pPageMaxSize, pVisibleIdList, pBackImages, pTeamSizeImages

on construct me
  me.cacheBackImages()
  me.cacheTeamSizeImages()
  pPageVisibleSize = 11
  pPageMaxSize = 20
  pListItemHeight = 25
  pVisibleIdList = []
  return me.ancestor.construct()
end

on deconstruct me
  pBackImages = []
  pTeamSizeImages = []
  pVisibleIdList = []
  return me.ancestor.deconstruct()
end

on addWindows me
  me.pWindowID = "ig_list"
  tWrapObjRef = me.getWindowWrapper(me)
  if tWrapObjRef = 0 then
    return 0
  end if
  tWrapObjRef.moveTo(90, 70)
  tSetID = me.pWindowSetId & "_top"
  tWrapObjRef.initSet(tSetID, 1)
  tWrapObjRef.addOneWindow(me.getWindowId("top"), "ig_frame_join.window", tSetID, [#span_all_columns: 1])
  tSetID = me.pWindowSetId & "_a"
  tWrapObjRef.initSet(tSetID, 1)
  tWrapObjRef.addOneWindow(me.getWindowId("w1"), "ig_title_starting_gms.window", tSetID)
  tWrapObjRef.addOneWindow(me.getWindowId("list"), "ig_gamelist.window", tSetID)
  tWrapObjRef.addOneWindow(me.getWindowId("btm"), VOID, tSetID)
  return 1
end

on render me
  tService = me.getIGComponent("GameList")
  if tService = 0 then
    return 0
  end if
  pVisibleIdList = tService.getMainListIds(pPageMaxSize)
  tIdCount = pVisibleIdList.count
  tJoinedGameId = tService.getJoinedGameId()
  tObservedGameId = tService.getObservedGameId()
  tScrollBars = tIdCount > pPageVisibleSize
  if tScrollBars = 1 then
    tWidth = 212
    tImageSize = tIdCount
  else
    tWidth = 233
    tImageSize = pPageVisibleSize
  end if
  me.setScrollBar(tScrollBars)
  tImage = image(tWidth, pListItemHeight * tImageSize, 32)
  tBackImage = 0
  repeat with i = 1 to tIdCount
    tID = pVisibleIdList[i]
    if tID = tObservedGameId then
      me.renderSlotBackground(tImage, pBackImages[3], i, tScrollBars)
    else
      me.renderSlotBackground(tImage, pBackImages[tBackImage + 1], i, tScrollBars)
    end if
    tItemRef = tService.getGameEntry(tID)
    me.renderShort(tImage, tItemRef, i, tScrollBars, tID = tJoinedGameId)
    tBackImage = not tBackImage
  end repeat
  repeat with i = tIdCount + 1 to pPageVisibleSize
    me.renderSlotBackground(tImage, pBackImages[tBackImage + 1], i, tScrollBars)
    tBackImage = not tBackImage
  end repeat
  tWrapObjRef = me.getWindowWrapper(me)
  if tWrapObjRef = 0 then
    return 0
  end if
  tElement = tWrapObjRef.getElement("ig_gamelist", "ig_list_list")
  if tElement = 0 then
    return 0
  end if
  tElement.feedImage(tImage)
  tWndObj = getWindow(me.getWindowId("btm"))
  if tWndObj = 0 then
    return 0
  end if
  tWndObj.unmerge()
  if tService.getJoinedGameId() = -1 then
    tWndObj.merge("ig_frame_startnew_btm.window")
  else
    tWndObj.merge("ig_frame_blank_btm.window")
  end if
  return 1
end

on getIdFromPoint me, tpoint
  tIndex = (tpoint.locV / pListItemHeight) + 1
  if tIndex < 1 then
    return -1
  end if
  if tIndex > pVisibleIdList.count then
    return -1
  end if
  return pVisibleIdList[tIndex]
end

on renderShort me, tImage, tGameRef, tCount, tScrollBars, tJoinedGame
  if tGameRef = VOID then
    return 0
  end if
  tOffsetV = pListItemHeight * (tCount - 1)
  tWriterPlain = me.getPlainWriter()
  tWriterBold = me.getBoldWriter()
  if not tJoinedGame then
    tIcon = tGameRef.getProperty(#game_type_icon)
    tTextImage = tWriterPlain.render(tGameRef.getProperty(#level_name))
  else
    tIcon = pBackImages[4].duplicate()
    tFigure = getObject(#session).GET("user_figure")
    tsex = getObject(#session).GET("user_sex")
    tHeadImage = me.getHeadImage(tFigure, tsex, 18, 18)
    if tHeadImage.ilk = #image then
      tIcon.copyPixels(tHeadImage, tHeadImage.rect, tHeadImage.rect, [#ink: 36])
    end if
    tTextImage = tWriterBold.render(tGameRef.getProperty(#level_name))
  end if
  if ilk(tTextImage) = #image then
    tPicOffsetH = 36
    tImage.copyPixels(tTextImage, tTextImage.rect + rect(tPicOffsetH, 8 + tOffsetV, tPicOffsetH, 8 + tOffsetV), tTextImage.rect)
  end if
  if ilk(tIcon) = #image then
    tPicOffsetH = ((19 - tIcon.width) / 2) + 8
    tPicOffsetV = ((20 - tIcon.height) / 3) + 3
    tImage.copyPixels(tIcon, tIcon.rect + rect(tPicOffsetH, tOffsetV + tPicOffsetV, tPicOffsetH, tOffsetV + tPicOffsetV), tIcon.rect, [#ink: 36])
  end if
  if tScrollBars = 1 then
    tOffsetH = 6
  else
    tOffsetH = 25
  end if
  tTempImage = pTeamSizeImages[tGameRef.getProperty(#number_of_teams)]
  if ilk(tTempImage) = #image then
    tPicOffsetH = 158 - (tTempImage.width / 3)
    tImage.copyPixels(tTempImage, tTempImage.rect + rect(tOffsetH + tPicOffsetH, 3 + tOffsetV, tOffsetH + tPicOffsetH, 3 + tOffsetV), tTempImage.rect, [#ink: 36])
  end if
  tTempImage = tWriterPlain.render(tGameRef.getPlayerCount() & "/" & tGameRef.getMaxPlayerCount())
  if ilk(tTempImage) = #image then
    tPicOffsetH = 178
    tImage.copyPixels(tTempImage, tTempImage.rect + rect(tPicOffsetH + tOffsetH, 8 + tOffsetV, tPicOffsetH + tOffsetH, 8 + tOffsetV), tTempImage.rect)
  end if
  return 1
end

on renderSlotBackground me, tImage, tBackImage, tCount, tScrollBarSize
  tOffsetY = (tCount - 1) * pListItemHeight
  tTargetRect = rect(0, tOffsetY, tImage.width, tOffsetY + pListItemHeight)
  tImage.copyPixels(tBackImage, tTargetRect, tBackImage.rect)
  return 1
end

on cacheBackImages me
  pBackImages = []
  repeat with tMemName in ["ig_list_px_lblue", "ig_list_px_lite", "ig_list_px_dblue", "ig_icon_face_bg2"]
    tmember = member(getmemnum(tMemName))
    if ilk(tmember) <> #member then
      return error(me, "Cannot find bitmap member" && tMemName, #renderList)
    end if
    pBackImages.append(tmember.image)
  end repeat
  return 1
end

on cacheTeamSizeImages me
  pTeamSizeImages = []
  repeat with tMemName in ["ig_icon_teams_1", "ig_icon_teams_2", "ig_icon_teams_3", "ig_icon_teams_4"]
    tmember = member(getmemnum(tMemName))
    if ilk(tmember) <> #member then
      return error(me, "Cannot find bitmap member" && tMemName, #renderList)
    end if
    pTeamSizeImages.append(tmember.image)
  end repeat
  return 1
end

on setScrollBar me, tstate
  tWndObj = getWindow(me.getWindowId("list"))
  if tWndObj = 0 then
    return 0
  end if
  tElement = tWndObj.getElement("ig_scrollbar")
  if tElement <> 0 then
    tElement.setProperty(#visible, tstate)
  end if
  tElement = tWndObj.getElement("ig_scrollbar_bg")
  if tElement <> 0 then
    tElement.setProperty(#visible, tstate)
  end if
  if tstate = 0 then
    tElement = tWndObj.getElement("ig_gamelist")
    if tElement <> 0 then
      tElement.setOffsetY(0)
    end if
  end if
  return 1
end

on eventProcMouseDown me, tEvent, tSprID, tParam, tWndID
  tService = me.getIGComponent("GameList")
  if tService = 0 then
    return 0
  end if
  case tSprID of
    "ig_gamelist":
      if ilk(tParam) <> #point then
        return 0
      end if
      tID = me.getIdFromPoint(tParam)
      if tID = -1 then
        return 0
      end if
      if not integerp(tID) then
        return 0
      end if
      if tID = tService.getJoinedGameId() then
        return tService.ChangeWindowView("JoinedGame")
      end if
      return tService.setObservedGameId(tID)
  end case
  return 0
end
