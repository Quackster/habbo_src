property pEventData, pListLine, pWriter, pLineHeight, pListWidth

on construct me
  pEventData = []
  pLineHeight = 20
  pListWidth = 200
  tFont = getStructVariable("struct.font.plain")
  tID = getUniqueID()
  createWriter(tID, tFont)
  pWriter = getWriter(tID)
  return 1
end

on deconstruct me
  return 1
end

on setEvents me, tEventData
  if not listp(tEventData) then
    return 0
  end if
  pEventData = tEventData
end

on generateTestData me, tCount
  pEventData = []
  repeat with i = 1 to tCount
    tEvent = [:]
    tEvent.setaProp(#flatId, i)
    tEvent.setaProp(#host, "host" && i)
    tEvent.setaProp(#time, "time" && i)
    tEvent.setaProp(#name, "name" && i)
    tEvent.setaProp(#desc, "desc" && i)
    pEventData.add(tEvent.duplicate())
  end repeat
end

on renderListImage me
  if not listp(pEventData) then
    return 0
  end if
  tListImage = image(pListWidth, pLineHeight * pEventData.count, 8)
  tListColors = [rgb("#EFEFEF"), rgb("#E1E1E1")]
  tBgImages = []
  repeat with tColor in tListColors
    tImage = image(pListWidth, pLineHeight, 8)
    tImage.fill(tImage.rect, tColor)
    tBgImages.add(tImage)
  end repeat
  tArrowsString = ">>"
  tArrowImage = pWriter.render(tArrowsString).duplicate()
  tMarginH = rect(5, 0, 5, 0)
  tMarginV = rect(0, 5, 0, 5)
  if pEventData.count > 0 then
    repeat with tLine = 1 to pEventData.count
      tLineImage = tBgImages[(tLine mod 2) + 1].duplicate()
      tName = pEventData[tLine].getaProp(#name)
      tTextImage = pWriter.render(tName).duplicate()
      tLineImage.copyPixels(tTextImage, tTextImage.rect + tMarginH + tMarginV, tTextImage.rect)
      tTargetRect = rect(tLineImage.width - tArrowImage.width, 0, tLineImage.width, tArrowImage.height)
      tLineImage.copyPixels(tArrowImage, tTargetRect + tMarginV, tArrowImage.rect)
      tTargetRect = rect(0, (tLine - 1) * pLineHeight, pListWidth, tLine * pLineHeight)
      tListImage.copyPixels(tLineImage, tTargetRect, tLineImage.rect)
      pEventData[tLine].setaProp(#rect, tTargetRect)
    end repeat
  else
    tListImage = image(pListWidth, pLineHeight, 8)
    tLineImage = tBgImages[1].duplicate()
    tTextImage = pWriter.render(getText("roomevent_not_available")).duplicate()
    tLineImage.copyPixels(tTextImage, tTextImage.rect + tMarginH + tMarginV, tTextImage.rect)
    tListImage.copyPixels(tLineImage, tLineImage.rect, tLineImage.rect)
  end if
  return tListImage
end

on getEventAt me, tpoint
  if ilk(tpoint) <> #point then
    return 0
  end if
  tLine = (tpoint[2] / pLineHeight) + 1
  if tLine > pEventData.count then
    return 0
  end if
  if tLine < 1 then
    return 0
  end if
  return pEventData[tLine]
end
