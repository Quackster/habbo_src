property pLoc, pType, pimage, pTurnPoint, pMinLocV, pImageLeft, pImageRight, pMatteLeft, pMatteRight, pSkip, pInitMinV, pInitMaxV, pNeedsAdjustV, pTypeAdjusts

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
  pTurnPoint = tProps.getaProp(#turnpoint)
  pInitMinV = tProps.getaProp(#initminv)
  pInitMaxV = tProps.getaProp(#initmaxv)
  pImageLeft = member(getmemnum((("landscape_cloud_" & pType) & "_left"))).image.duplicate()
  pImageRight = member(getmemnum((("landscape_cloud_" & pType) & "_right"))).image.duplicate()
  me.randomizeLoc(0)
  pMinLocV = (pLoc[2] - (abs((pTurnPoint - pLoc[1])) / 2))
  pMatteLeft = pImageLeft.createMatte()
  pMatteRight = pImageRight.createMatte()
  if (pLoc[1] < pTurnPoint) then
    pNeedsAdjustV = 1
  else
    pNeedsAdjustV = 0
  end if
end

on getLocV me, tLocH
  tLocV = (abs(((tLocH - pTurnPoint) / 2)) + pMinLocV)
  return tLocV
end

on randomizeLoc me, tAlignToLeft
  tMinV = pInitMinV
  tMaxV = pInitMaxV
  if (ilk(pImageLeft) = #image) then
    tMinV = (tMinV - (pImageLeft.height / 2))
    tMaxV = (tMaxV - (pImageLeft.height / 2))
  end if
  if tAlignToLeft then
    tLocX = (random(100) - 150)
  else
    tLocX = random((the stageRight - the stageLeft))
  end if
  if ((tLocX mod 2) = 1) then
    tLocX = (tLocX + 1)
  end if
  tLocY = ((tMinV + random((tMaxV - tMinV))) - (tLocX / 2))
  if (tLocX > pTurnPoint) then
    tLocY = (tLocY + (tLocX - pTurnPoint))
  end if
  pLoc = point(tLocX, tLocY)
  pMinLocV = (pLoc[2] - (abs((pTurnPoint - pLoc[1])) / 2))
  pNeedsAdjustV = 1
end

on updateAnim me
  pLoc[1] = (pLoc[1] + 1)
  pLoc[2] = me.getLocV(pLoc[1])
  if (pNeedsAdjustV and (pLoc[1] > pTurnPoint)) then
    pLoc[2] = (pLoc[2] + pTypeAdjusts[pType][#adjustV])
  end if
  if (pLoc[1] > the stage.rect.width) then
    me.randomizeLoc(1)
  end if
end

on render me, tImage
  if ((pLoc[1] + pImageLeft.width) < pTurnPoint) then
    tSourceImage = pImageLeft
    tMatte = pMatteLeft
  else
    if (pLoc[1] > pTurnPoint) then
      tSourceImage = pImageRight
      tMatte = pMatteRight
    else
      tSourceImage = image(pImageLeft.width, (pImageLeft.height * 2), 8)
      tSourceImage.copyPixels(pImageLeft, pImageLeft.rect, pImageLeft.rect)
      tWidthLeft = (pTurnPoint - pLoc[1])
      tSourceImage.fill(tWidthLeft, 0, tSourceImage.width, tSourceImage.height, color(255, 255, 255))
      tWidthRight = (pImageLeft.width - tWidthLeft)
      tRightSourceRect = rect(tWidthLeft, 0, pImageRight.width, pImageRight.height)
      tOffV = ((tWidthRight - pImageRight.height) + pTypeAdjusts[pType][#turnOffV])
      tRightSourceRect = rect(tWidthLeft, 0, pImageRight.width, pImageRight.height)
      tRightTargetRect = (tRightSourceRect + rect(0, tOffV, 0, tOffV))
      tSourceImage.copyPixels(pImageRight, tRightTargetRect, tRightSourceRect)
      tMatte = tSourceImage.createMatte()
    end if
  end if
  tTargetRect = (tSourceImage.rect + rect(pLoc[1], pLoc[2], pLoc[1], pLoc[2]))
  tImage.copyPixels(tSourceImage, tTargetRect, tSourceImage.rect, [#maskImage: tMatte])
end
