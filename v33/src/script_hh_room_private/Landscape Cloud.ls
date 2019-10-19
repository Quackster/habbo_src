property pTypeAdjusts, pLandscapeType, pType, pImageLeft, pImageRight, pTurnPointList, pLoc, pCurrentSide, pLastTurnPoint, pOffsetV, pWallHeight, pNextTurnPointH, pMatteLeft, pMatteRight

on construct me 
  pSkip = 0
  pTypeAdjusts = [:]
  pTypeAdjusts.setAt("0", [:])
  pTypeAdjusts.setAt("1", [:])
  pTypeAdjusts.setAt("2", [:])
  pTypeAdjusts.getAt("0").setAt(#turnOffV, 10)
  pTypeAdjusts.getAt("1").setAt(#turnOffV, 12)
  pTypeAdjusts.getAt("2").setAt(#turnOffV, 6)
  pTypeAdjusts.getAt("0").setAt(#adjustV, 18)
  pTypeAdjusts.getAt("1").setAt(#adjustV, 11)
  pTypeAdjusts.getAt("2").setAt(#adjustV, 7)
  return(1)
end

on deconstruct me 
  return(1)
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
  tMemNum = getmemnum(tMemberId & pType & "_left")
  if tMemNum = 0 then
    return(error(me, "Cloud graphic not found:" && tMemberId & pType & "_left", #define))
  end if
  pImageLeft = image.duplicate()
  tMemNum = getmemnum(tMemberId & pType & "_right")
  if tMemNum = 0 then
    return(error(me, "Cloud graphic not found:" && tMemberId & pType & "_right", #define))
  end if
  pImageRight = image.duplicate()
  pMatteLeft = pImageLeft.createMatte()
  pMatteRight = pImageRight.createMatte()
  me.randomizeLoc(0)
  return(1)
end

on saveNextTurnPoint me 
  if pTurnPointList = void() then
    return(0)
  end if
  tLocH = pLoc.getAt(1)
  i = 1
  repeat while i <= pTurnPointList.count
    tpoint = pTurnPointList.getPropAt(i)
    tTurnH = tpoint.locH
    if tTurnH > tLocH and pCurrentSide <> pTurnPointList.getAt(i) then
      pNextTurnPointH = tTurnH
      return(tTurnH)
    else
      pLastTurnPoint = tpoint
      pCurrentSide = pTurnPointList.getAt(i)
    end if
    i = 1 + i
  end repeat
  pNextTurnPointH = 0
  return(0)
end

on getLocV me, tLocH 
  if pCurrentSide = #left then
    tLocV = me.locV + (pLastTurnPoint.locH - tLocH / 2)
  else
    tLocV = me.locV + (tLocH - pLastTurnPoint.locH / 2)
  end if
  return(tLocV + pOffsetV)
end

on randomizeLoc me, tAlignToLeft 
  if tAlignToLeft then
    tLocX = random(100) - 150
  else
    tLocX = random(the stageRight - the stageLeft)
  end if
  if (tLocX mod 2) = 1 then
    tLocX = tLocX + 1
  end if
  pCurrentSide = #left
  pOffsetV = random(pWallHeight - (2 * pImageLeft.height)) + pImageLeft.height
  pLoc = point(tLocX, 0)
  me.saveNextTurnPoint()
  tLocY = me.getLocV(tLocX)
  pLoc = point(tLocX, tLocY)
end

on updateAnim me 
  pLoc.setAt(1, pLoc.getAt(1) + 1)
  pLoc.setAt(2, me.getLocV(pLoc.getAt(1)))
  if the stage > rect.width then
    me.randomizeLoc(1)
  end if
end

on render me, tImage 
  if pLoc.getAt(1) + pImageLeft.width < pNextTurnPointH or pNextTurnPointH = 0 then
    if pCurrentSide = #left then
      tSourceImage = pImageLeft
      tSourceRect = tSourceImage.rect
      tMatte = pMatteLeft
    else
      tSourceImage = pImageRight
      tSourceRect = tSourceImage.rect + rect(0, pTypeAdjusts.getAt(pType).getAt(#adjustV), 0, pTypeAdjusts.getAt(pType).getAt(#adjustV))
      tMatte = pMatteRight
    end if
  else
    if pLoc.getAt(1) < pNextTurnPointH then
      if pCurrentSide = #left then
        tSourceImage = image(pImageLeft.width, (pImageLeft.height * 2), 8)
        tSourceImage.copyPixels(pImageLeft, pImageLeft.rect, pImageLeft.rect)
        tWidthLeft = pNextTurnPointH - pLoc.getAt(1)
        tSourceImage.fill(tWidthLeft, 0, tSourceImage.width, tSourceImage.height, color(255, 255, 255))
        tWidthRight = pImageLeft.width - tWidthLeft
        tOffV = tWidthRight - pImageRight.height + pTypeAdjusts.getAt(pType).getAt(#turnOffV)
        tRightSourceRect = rect(tWidthLeft, 0, pImageRight.width, pImageRight.height)
        tRightTargetRect = tRightSourceRect + rect(0, tOffV, 0, tOffV)
        tSourceImage.copyPixels(pImageRight, tRightTargetRect, tRightSourceRect)
      else
        tSourceImage = image(pImageRight.width, (pImageRight.height * 2), 8)
        tWidthRight = pNextTurnPointH - pLoc.getAt(1)
        tWidthLeft = pImageLeft.width - tWidthRight
        tOffV = (pImageRight.height / 2)
        tSourceRect = rect(0, 0, tWidthRight, pImageRight.height)
        tTargetRect = tSourceRect + rect(0, tOffV, 0, tOffV)
        tSourceImage.copyPixels(pImageRight, tTargetRect, tSourceRect)
        tOffV = tWidthRight
        tSourceRect = rect(tWidthRight, 0, pImageLeft.width, pImageLeft.height)
        tTargetRect = tSourceRect + rect(0, tOffV, 0, tOffV)
        tSourceImage.copyPixels(pImageLeft, tTargetRect, tSourceRect)
      end if
      tSourceRect = tSourceImage.rect
      tMatte = tSourceImage.createMatte()
    else
      me.saveNextTurnPoint()
      return(me.render(tImage))
    end if
  end if
  tTargetRect = tSourceRect + rect(pLoc.getAt(1), pLoc.getAt(2), pLoc.getAt(1), pLoc.getAt(2))
  tImage.copyPixels(tSourceImage, tTargetRect, tSourceImage.rect, [#maskImage:tMatte])
end
