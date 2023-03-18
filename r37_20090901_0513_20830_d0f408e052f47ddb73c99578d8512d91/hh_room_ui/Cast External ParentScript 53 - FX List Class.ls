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
      if tBadgeID = tActiveBadge then
        tListImage.copyPixels(pBgHilite, tTargetRect, pBgHilite.rect)
      end if
      tBadgeImage = member(getmemnum("ctlg_pic_small_fx_" & tBadgeID)).image
      if tBadgeImage.ilk = #image then
        if tBadgeImage.rect = rect(0, 0, 1, 1) then
          tBadgeImage = member(getmemnum("loading_icon")).image
        end if
        tCenteredImage = me.centerImage(tBadgeImage, tTargetRect)
        tListImage.copyPixels(tCenteredImage, tTargetRect, tCenteredImage.rect, [#maskImage: tCenteredImage.createMatte()])
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

on centerImage me, tImage, tRect
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
