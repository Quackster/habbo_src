property pBadges, pRects, pColumns, pMinRows, pGridSize, pWriterIdPlain, pWriterIdBold, pBg, pBgNew, pBgHilite

on construct me
  pBadges = []
  pRects = [:]
  pColumns = 3
  pMinRows = 4
  pGridSize = 47
  pWriterIdPlain = getUniqueID()
  pWriterIdBold = getUniqueID()
  if memberExists("badge_grid_bg") then
    pBg = member(getmemnum("badge_grid_bg")).image
  else
    pBg = image(1, 1, 8)
  end if
  if memberExists("badge_grid_bg_new") then
    pBgNew = member(getmemnum("badge_grid_bg_new")).image
  else
    pBgNew = image(1, 1, 8)
  end if
  if memberExists("badge_grid_bg_hilite") then
    pBgHilite = member(getmemnum("badge_grid_bg_hilite")).image
  else
    pBgHilite = image(1, 1, 8)
  end if
  return 1
end

on deconstruct me
  me.removeWriters()
  return 1
end

on render me, tBadges, tSelectedBadges, tNewBadges, tActiveBadge
  if voidp(tSelectedBadges) then
    tSelectedBadges = []
  end if
  pBadges = tBadges
  tRows = tBadges.count / pColumns
  if (tBadges.count mod pColumns) > 0 then
    tRows = tRows + 1
  end if
  tRows = max(tRows, pMinRows)
  tListImage = image(pColumns * pGridSize, tRows * pGridSize, 32)
  tRow = 0
  tCol = 0
  tLastIndex = tRows * pColumns
  repeat with tIndex = 1 to tLastIndex
    tTargetRect = rect(tCol * pGridSize, tRow * pGridSize, (tCol + 1) * pGridSize, (tRow + 1) * pGridSize)
    tListImage.copyPixels(pBg, tTargetRect, pBg.rect)
    if tIndex <= tBadges.count then
      tBadgeID = tBadges[tIndex]
      if tNewBadges.getPos(tBadgeID) > 0 then
        tListImage.copyPixels(pBgNew, tTargetRect, pBgNew.rect)
      end if
      if tBadgeID = tActiveBadge then
        tListImage.copyPixels(pBgHilite, tTargetRect, pBgHilite.rect)
      end if
      tBadgeImage = member(getmemnum("badge" && tBadgeID)).image
      if tBadgeImage.ilk = #image then
        if tBadgeImage.rect = rect(0, 0, 1, 1) then
          tBadgeImage = member(getmemnum("loading_icon")).image
        end if
        tCenteredImage = me.centerImage(tBadgeImage, tTargetRect)
        if tSelectedBadges.getPos(tBadgeID) = 0 then
          tListImage.copyPixels(tCenteredImage, tTargetRect, tCenteredImage.rect, [#maskImage: tCenteredImage.createMatte()])
        else
          tListImage.copyPixels(tCenteredImage, tTargetRect, tCenteredImage.rect, [#ink: 36, #blend: 15])
        end if
      end if
    end if
    tCol = tCol + 1
    if tCol >= pColumns then
      tCol = 0
      tRow = tRow + 1
    end if
  end repeat
  return tListImage
end

on getBadgeAt me, tpoint
  if tpoint.ilk <> #point then
    return error(me, "Point expected.", #getBadgeAt, #major)
  end if
  tCol = (tpoint[1] / pGridSize) + 1
  if tCol > pColumns then
    return 0
  end if
  tRow = (tpoint[2] / pGridSize) + 1
  tIndex = ((tRow - 1) * pColumns) + tCol
  if (tIndex > 0) and (tIndex <= pBadges.count) then
    return pBadges[tIndex]
  end if
  return 0
end

on renderAchievements me, tAchievements
  if tAchievements.ilk <> #list then
    return error(me, "Linear list expected.", #renderAchievements, #major)
  end if
  tListImage = image(300, tAchievements.count * pGridSize, 32)
  tBgImage = member(getmemnum("badge_grid_bg")).image
  repeat with tIndex = 1 to tAchievements.count
    tBadgeID = tAchievements[tIndex]
    tbadgerect = rect(0, (tIndex - 1) * pGridSize, pGridSize, tIndex * pGridSize)
    tListImage.copyPixels(tBgImage, tbadgerect, tBgImage.rect)
    tBadgeImage = member(getmemnum("badge" && tBadgeID)).image
    if ilk(tBadgeImage) <> #image then
      tBadgeImage = image(tbadgerect.width, tbadgerect.height, 8)
    end if
    tCenteredImage = me.centerImage(tBadgeImage, tbadgerect)
    tListImage.copyPixels(tCenteredImage, tbadgerect, tCenteredImage.rect, [#maskImage: tCenteredImage.createMatte()])
    tWriter = me.getBoldWriter()
    tNameImage = tWriter.render(getText("badge_name_" & tBadgeID)).duplicate()
    tLeft = tbadgerect[3] + 7
    tRight = tLeft + tNameImage.width
    tTop = tbadgerect[2]
    tBottom = tTop + tNameImage.height
    tNameRect = rect(tLeft, tTop, tRight, tBottom)
    tListImage.copyPixels(tNameImage, tNameRect, tNameImage.rect, [#ink: 36])
    tLeft = tNameRect[1]
    tTop = tNameRect[4]
    tWriter = me.getPlainWriter()
    tWriter.setProperty(#rect, rect(0, 0, 240, 0))
    tDesc = getText("badge_desc_" & tBadgeID)
    tDescImage = tWriter.render(tDesc).duplicate()
    tRight = tLeft + tDescImage.width
    tBottom = tTop + tDescImage.height
    tDescRect = rect(tLeft, tTop, tRight, tBottom)
    if tDescRect[4] > tbadgerect[4] then
      tDescRect[4] = tbadgerect[4]
    end if
    tSourceRect = rect(0, 0, tDescRect.width, tDescRect.height)
    tListImage.copyPixels(tDescImage, tDescRect, tSourceRect, [#ink: 36])
  end repeat
  return tListImage
end

on centerImage me, tImage, tRect
  if ilk(tImage) <> #image then
    return 0
  end if
  tCentered = image(tRect.width, tRect.height, tImage.depth)
  tOffH = (tRect.width - tImage.width) / 2
  tOffV = (tRect.height - tImage.height) / 2
  tTargetRect = tImage.rect + rect(tOffH, tOffV, tOffH, tOffV)
  tCentered.copyPixels(tImage, tTargetRect, tImage.rect)
  return tCentered
end

on getPlainWriter me
  if writerExists(pWriterIdPlain) then
    return getWriter(pWriterIdPlain)
  end if
  tPlainStruct = getStructVariable("struct.font.plain")
  createWriter(pWriterIdPlain, tPlainStruct)
  tWriter = getWriter(pWriterIdPlain)
  tWriter.setProperty(#wordWrap, 1)
  return getWriter(pWriterIdPlain)
end

on getBoldWriter me
  if writerExists(pWriterIdBold) then
    return getWriter(pWriterIdBold)
  end if
  tBoldStruct = getStructVariable("struct.font.bold")
  createWriter(pWriterIdBold, tBoldStruct)
  return getWriter(pWriterIdBold)
end

on removeWriters me
  if writerExists(pWriterIdPlain) then
    removeWriter(pWriterIdPlain)
  end if
  if writerExists(pWriterIdBold) then
    removeWriter(pWriterIdBold)
  end if
end
