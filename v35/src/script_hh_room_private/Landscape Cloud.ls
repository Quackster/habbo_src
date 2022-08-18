property pLoc, pType, pTurnPointList, pNextTurnPointH, pLastTurnPoint, pOffsetV, pCurrentSide, pImageLeft, pImageRight, pMatteLeft, pMatteRight, pSkip, pNeedsAdjustV, pTypeAdjusts, pLandscapeType, pWallHeight

on construct me
  pSkip = 0
  pTypeAdjusts = [:]
  pTypeAdjusts["0"] = [:]
  pTypeAdjusts["1"] = [:]
  pTypeAdjusts["2"] = [:]
  pTypeAdjusts["0"][#turnOffV] = 10
  pTypeAdjusts["1"][#turnOffV] = 12
  pTypeAdjusts["2"][#turnOffV] = 6
  pTypeAdjusts["0"][#adjustV] = 18
  pTypeAdjusts["1"][#adjustV] = 11
  pTypeAdjusts["2"][#adjustV] = 7
  return 1
end

on deconstruct me
  return 1
end

on define me, tProps
  pType = string(tProps.getaProp(#type))
  pTurnPointList = tProps.getaProp(#turnPointList)
  pWallHeight = tProps.getaProp(#wallheight)
  pLandscapeType = tProps.getaProp(#landscape)
  tMemberId = tProps.getaProp(#memberid)
  if voidp(pLandscapeType) then
    pLandscapeType = "landscape"
  end if
  tMemNum = getmemnum(((tMemberId & pType) & "_left"))
  if (tMemNum = 0) then
    return error(me, ((("Cloud graphic not found:" && tMemberId) & pType) & "_left"), #define)
  end if
  pImageLeft = member(tMemNum).image.duplicate()
  tMemNum = getmemnum(((tMemberId & pType) & "_right"))
  if (tMemNum = 0) then
    return error(me, ((("Cloud graphic not found:" && tMemberId) & pType) & "_right"), #define)
  end if
  pImageRight = member(tMemNum).image.duplicate()
  pMatteLeft = pImageLeft.createMatte()
  pMatteRight = pImageRight.createMatte()
  me.randomizeLoc(0)
  return 1
end

on saveNextTurnPoint me
  if (pTurnPointList = VOID) then
    return 0
  end if
  tLocH = pLoc[1]
  repeat with i = 1 to pTurnPointList.count
    tpoint = pTurnPointList.getPropAt(i)
    tTurnH = tpoint.locH
    if ((tTurnH > tLocH) and (pCurrentSide <> pTurnPointList[i])) then
      pNextTurnPointH = tTurnH
      return tTurnH
      next repeat
    end if
    pLastTurnPoint = tpoint
    pCurrentSide = pTurnPointList[i]
  end repeat
  pNextTurnPointH = 0
  return 0
end

on getLocV me, tLocH
  if (pCurrentSide = #left) then
    tLocV = (me.pLastTurnPoint.locV + ((pLastTurnPoint.locH - tLocH) / 2))
  else
    tLocV = (me.pLastTurnPoint.locV + ((tLocH - pLastTurnPoint.locH) / 2))
  end if
  return (tLocV + pOffsetV)
end

on randomizeLoc me, tAlignToLeft
  if tAlignToLeft then
    tLocX = (random(100) - 150)
  else
    tLocX = random((the stageRight - the stageLeft))
  end if
  if ((tLocX mod 2) = 1) then
    tLocX = (tLocX + 1)
  end if
  pCurrentSide = #left
  pOffsetV = (random((pWallHeight - (2 * pImageLeft.height))) + pImageLeft.height)
  pLoc = point(tLocX, 0)
  me.saveNextTurnPoint()
  tLocY = me.getLocV(tLocX)
  pLoc = point(tLocX, tLocY)
end

on updateAnim me
  pLoc[1] = (pLoc[1] + 1)
  pLoc[2] = me.getLocV(pLoc[1])
  if (pLoc[1] > the stage.rect.width) then
    me.randomizeLoc(1)
  end if
end

on render me, tImage
  if (((pLoc[1] + pImageLeft.width) < pNextTurnPointH) or (pNextTurnPointH = 0)) then
    if (pCurrentSide = #left) then
      tSourceImage = pImageLeft
      tSourceRect = tSourceImage.rect
      tMatte = pMatteLeft
    else
      tSourceImage = pImageRight
      tSourceRect = (tSourceImage.rect + rect(0, pTypeAdjusts[pType][#adjustV], 0, pTypeAdjusts[pType][#adjustV]))
      tMatte = pMatteRight
    end if
  else
    if (pLoc[1] < pNextTurnPointH) then
      if (pCurrentSide = #left) then
        tSourceImage = image(pImageLeft.width, (pImageLeft.height * 2), 8)
        tSourceImage.copyPixels(pImageLeft, pImageLeft.rect, pImageLeft.rect)
        tWidthLeft = (pNextTurnPointH - pLoc[1])
        tSourceImage.fill(tWidthLeft, 0, tSourceImage.width, tSourceImage.height, color(255, 255, 255))
        tWidthRight = (pImageLeft.width - tWidthLeft)
        tOffV = ((tWidthRight - pImageRight.height) + pTypeAdjusts[pType][#turnOffV])
        tRightSourceRect = rect(tWidthLeft, 0, pImageRight.width, pImageRight.height)
        tRightTargetRect = (tRightSourceRect + rect(0, tOffV, 0, tOffV))
        tSourceImage.copyPixels(pImageRight, tRightTargetRect, tRightSourceRect)
      else
        tSourceImage = image(pImageRight.width, (pImageRight.height * 2), 8)
        tWidthRight = (pNextTurnPointH - pLoc[1])
        tWidthLeft = (pImageLeft.width - tWidthRight)
        tOffV = (pImageRight.height / 2)
        tSourceRect = rect(0, 0, tWidthRight, pImageRight.height)
        tTargetRect = (tSourceRect + rect(0, tOffV, 0, tOffV))
        tSourceImage.copyPixels(pImageRight, tTargetRect, tSourceRect)
        tOffV = tWidthRight
        tSourceRect = rect(tWidthRight, 0, pImageLeft.width, pImageLeft.height)
        tTargetRect = (tSourceRect + rect(0, tOffV, 0, tOffV))
        tSourceImage.copyPixels(pImageLeft, tTargetRect, tSourceRect)
      end if
      tSourceRect = tSourceImage.rect
      tMatte = tSourceImage.createMatte()
    else
      me.saveNextTurnPoint()
      return me.render(tImage)
    end if
  end if
  tTargetRect = (tSourceRect + rect(pLoc[1], pLoc[2], pLoc[1], pLoc[2]))
  tImage.copyPixels(tSourceImage, tTargetRect, tSourceImage.rect, [#maskImage: tMatte])
end
