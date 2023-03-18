property pAction, pBalance, pDirection, pAnimFrm, pCounter, pBodyColor, pSuitColor, pSuitModel

on define me, tPart, tProps
  pAction = "std"
  pBalance = 2
  pDirection = tProps[#dir]
  pAnimFrm = 0
  pBodyColor = tProps[#figure]["bd"]["color"]
  pSuitColor = tProps[#figure]["ch"]["color"]
  if pSuitColor = rgb(0, 0, 0) then
    pSuitColor = rgb("#EEEEEE")
  end if
  pSuitModel = tProps[#figure]["ch"]["model"]
  pCounter = 0
  return 1
end

on status me, tAction, tBalance
  pAction = tAction
  pBalance = tBalance
  pAnimFrm = 0
  pCounter = 0
end

on prepare me
  if (pAction = "hit1") or (pAction = "hit2") then
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
  repeat with tmodel in [["bd", pBodyColor, "s01"], ["ch", pSuitColor, pSuitModel]]
    tMemName = "shp_" & pAction & "_" & pBalance & "_" & tmodel[1] & "_" & tmodel[3] & "_" & pDirection & "_" & pAnimFrm
    tMemNum = getmemnum(tMemName)
    if tMemNum > 0 then
      tmember = member(tMemNum)
      tImage = tmember.image
      tRegPnt = tmember.regPoint
      tX = -tRegPnt[1] + 6
      tY = tBuffer.rect.height - tRegPnt[2] - 10
      tDstRect = rect(tX, tY, tX + tImage.width, tY + tImage.height)
      tSrcRect = tImage.rect
      tMaskImg = tImage.createMatte()
      tBuffer.copyPixels(tImage, tDstRect, tSrcRect, [#maskImage: tMaskImg, #ink: 41, #bgColor: tmodel[2]])
    end if
  end repeat
end
