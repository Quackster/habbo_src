property pimage, pMaxH, pMinV, pMaxV, pTurnPoint, pType, pImageLeft, pImageRight, pLoc

on construct me 
  pLoc = point(0, 0)
  pRefLoc = point(0, 0)
  pImageLeft = image(1, 1, 8)
  pImageRight = image(1, 1, 8)
  pMatteLeft = pimage.createMatte()
  pMatteRight = pimage.createMatte()
  return TRUE
end

on deconstruct me 
  return TRUE
end

on define me, tProps 
  pType = tProps.getaProp(#type)
  pMinV = tProps.getaProp(#minv)
  pMaxV = tProps.getaProp(#maxv)
  pMaxH = tProps.getaProp(#maxh)
  pTurnPoint = tProps.getaProp(#turnpoint)
  tLocX = random(pMaxH)
  tLocY = ((pMinV + random((pMaxV - pMinV))) - (tLocX / 2))
  if tLocX > pTurnPoint then
    tLocY = (tLocY + ((tLocX - pTurnPoint) / 2))
  end if
  pLoc = point(tLocX, tLocY)
  pRefLoc = point(tLocX, tLocY)
  pImageLeft = member(getmemnum("cloud_" & pType & "_left_x")).image.duplicate()
  pImageRight = member(getmemnum("cloud_" & pType & "_right_x")).image.duplicate()
  pMatteLeft = pImageLeft.createMatte()
  pMatteRight = pImageRight.createMatte()
end

on updateAnim me 
  pLoc.setAt(1, (pLoc.getAt(1) + 1))
  tLocY = pLoc.getAt(2)
  if pLoc.getAt(1) > the stage.rect.width then
    pLoc = point(0, random(the stage.rect.height))
  end if
end

on render me, tImage 
  if pLoc.getAt(1) < pTurnPoint then
    tSourceImage = pImageLeft
  else
    tSourceImage = pImageRight
  end if
  tTargetRect = (tSourceImage.rect + rect(pLoc.getAt(1), pLoc.getAt(2), pLoc.getAt(1), pLoc.getAt(2)))
  tImage.copyPixels(tSourceImage, tTargetRect, tSourceImage.rect, [#maskImage:tSourceImage.createMatte()])
end
