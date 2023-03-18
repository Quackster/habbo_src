property pPart, pAction, pDirection, pBalance, pAnimFrm, pBodyColor, pCounter

on define me, tPart, tProps
  pAction = "std"
  pBalance = 2
  pAnimFrm = 0
  pPart = tPart
  pDirection = tProps[#dir]
  pBodyColor = tProps[#figure][pPart]["color"]
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
  tMemName = "shp_" & pAction & "_" & pBalance & "_" & pPart & "_" & "s01" & "_" & pDirection & "_" & pAnimFrm
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
    tBuffer.copyPixels(tImage, tDstRect, tSrcRect, [#maskImage: tMaskImg, #ink: 41, #bgColor: pBodyColor])
  end if
end
