property pTypeAdjusts, pType, pLoc, pTurnPoint, pImageLeft, pImageRight, pMinLocV, pInitMinV, pInitMaxV, pNeedsAdjustV, pMatteLeft, pMatteRight

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
  pTurnPoint = tProps.getaProp(#turnpoint)
  pInitMinV = tProps.getaProp(#initminv)
  pInitMaxV = tProps.getaProp(#initmaxv)
  pImageLeft = image.duplicate()
  pImageRight = image.duplicate()
  me.randomizeLoc(0)
  pMinLocV = pLoc.getAt(2) - abs(pTurnPoint - pLoc.getAt(1)) / 2
  pMatteLeft = pImageLeft.createMatte()
  pMatteRight = pImageRight.createMatte()
  if pLoc.getAt(1) < pTurnPoint then
    pNeedsAdjustV = 1
  else
    pNeedsAdjustV = 0
  end if
end

on getLocV me, tLocH 
  tLocV = abs(tLocH - pTurnPoint / 2) + pMinLocV
  return(tLocV)
end

on randomizeLoc me, tAlignToLeft 
  tMinV = pInitMinV
  tMaxV = pInitMaxV
  if ilk(pImageLeft) = #image then
    tMinV = tMinV - pImageLeft.height / 2
    tMaxV = tMaxV - pImageLeft.height / 2
  end if
  if tAlignToLeft then
    tLocX = random(100) - 150
  else
    tLocX = random(the stageRight - the stageLeft)
  end if
  if tLocX mod 2 = 1 then
    tLocX = tLocX + 1
  end if
  tLocY = tMinV + random(tMaxV - tMinV) - tLocX / 2
  if tLocX > pTurnPoint then
    tLocY = tLocY + tLocX - pTurnPoint
  end if
  pLoc = point(tLocX, tLocY)
  pMinLocV = pLoc.getAt(2) - abs(pTurnPoint - pLoc.getAt(1)) / 2
  pNeedsAdjustV = 1
end

on updateAnim me 
  pLoc.setAt(1, pLoc.getAt(1) + 1)
  pLoc.setAt(2, me.getLocV(pLoc.getAt(1)))
  if pNeedsAdjustV and pLoc.getAt(1) > pTurnPoint then
    pLoc.setAt(2, pLoc.getAt(2) + pTypeAdjusts.getAt(pType).getAt(#adjustV))
  end if
  if the stage > rect.width then
    me.randomizeLoc(1)
  end if
end

on render me, tImage 
  if pLoc.getAt(1) + pImageLeft.width < pTurnPoint then
    tSourceImage = pImageLeft
    tMatte = pMatteLeft
  else
    if pLoc.getAt(1) > pTurnPoint then
      tSourceImage = pImageRight
      tMatte = pMatteRight
    else
      tSourceImage = image(pImageLeft.width, pImageLeft.height * 2, 8)
      tSourceImage.copyPixels(pImageLeft, pImageLeft.rect, pImageLeft.rect)
      tWidthLeft = pTurnPoint - pLoc.getAt(1)
      tSourceImage.fill(tWidthLeft, 0, tSourceImage.width, tSourceImage.height, color(255, 255, 255))
      tWidthRight = pImageLeft.width - tWidthLeft
      tRightSourceRect = rect(tWidthLeft, 0, pImageRight.width, pImageRight.height)
      tOffV = tWidthRight - pImageRight.height + pTypeAdjusts.getAt(pType).getAt(#turnOffV)
      tRightSourceRect = rect(tWidthLeft, 0, pImageRight.width, pImageRight.height)
      tRightTargetRect = tRightSourceRect + rect(0, tOffV, 0, tOffV)
      tSourceImage.copyPixels(pImageRight, tRightTargetRect, tRightSourceRect)
      tMatte = tSourceImage.createMatte()
    end if
  end if
  tTargetRect = tSourceImage.rect + rect(pLoc.getAt(1), pLoc.getAt(2), pLoc.getAt(1), pLoc.getAt(2))
  tImage.copyPixels(tSourceImage, tTargetRect, tSourceImage.rect, [#maskImage:tMatte])
end
