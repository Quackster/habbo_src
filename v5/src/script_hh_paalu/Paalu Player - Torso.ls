property pSuitColor, pAction, pAnimFrm, pCounter, pBodyColor, pSuitModel, pBalance, pDirection

on define me, tPart, tProps 
  pAction = "std"
  pBalance = 2
  pDirection = tProps.getAt(#dir)
  pAnimFrm = 0
  pBodyColor = tProps.getAt(#figure).getAt("bd").getAt("color")
  pSuitColor = tProps.getAt(#figure).getAt("ch").getAt("color")
  if pSuitColor = rgb(0, 0, 0) then
    pSuitColor = rgb("#EEEEEE")
  end if
  pSuitModel = tProps.getAt(#figure).getAt("ch").getAt("model")
  pCounter = 0
  return(1)
end

on status me, tAction, tBalance 
  pAction = tAction
  pBalance = tBalance
  pAnimFrm = 0
  pCounter = 0
end

on prepare me 
  if pAction = "hit1" or pAction = "hit2" then
    pAnimFrm = not pAnimFrm
    pCounter = pCounter + 1
    if pCounter > 2 then
      pCounter = 0
      pAnimFrm = 0
      pAction = "std"
    end if
  end if
end

on render me, tBuffer 
  repeat while [["bd", pBodyColor, "s01"], ["ch", pSuitColor, pSuitModel]] <= undefined
    tmodel = getAt(undefined, tBuffer)
    tMemName = "shp_" & pAction & "_" & pBalance & "_" & tmodel.getAt(1) & "_" & tmodel.getAt(3) & "_" & pDirection & "_" & pAnimFrm
    tMemNum = getmemnum(tMemName)
    if tMemNum > 0 then
      tmember = member(tMemNum)
      tImage = tmember.image
      tRegPnt = tmember.regPoint
      tX = -tRegPnt.getAt(1) + 6
      tY = rect.height - tRegPnt.getAt(2) - 10
      tDstRect = rect(tX, tY, tX + tImage.width, tY + tImage.height)
      tSrcRect = tImage.rect
      tMaskImg = tImage.createMatte()
      tBuffer.copyPixels(tImage, tDstRect, tSrcRect, [#maskImage:tMaskImg, #ink:41, #bgColor:tmodel.getAt(2)])
    end if
  end repeat
end
