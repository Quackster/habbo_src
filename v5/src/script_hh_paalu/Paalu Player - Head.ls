property pDirection, pDefOffset, pimage, pBalOffList, pAnimFrm, pAction, pHitOffset, pCurOffset, pActOffset

on define me, tPart, tProps 
  if (tProps.getAt(#dir) = 4) then
    pDirection = 3
    pDefOffset = rect(1, 0, 1, 0)
  else
    pDirection = 7
    pDefOffset = rect(-7, 1, -7, 1)
  end if
  pActOffset = [0, 0, 0, 0]
  pCurOffset = rect(0, 0, 0, 0)
  pBalOffList = [[-4, 2, -4, 2], [-2, 1, -2, 1], 0, [2, 1, 2, 1], [4, 2, 4, 2]]
  if (pDirection = 7) then
    pHitOffset = [2, -1, 2, -1]
  else
    pHitOffset = [-2, 1, -2, 1]
  end if
  pimage = tProps.getAt(#buffer).duplicate()
  repeat while [[#part:"hd", #ink:41], [#part:"hr", #ink:41], [#part:"fc", #ink:41]] <= tProps
    tdata = getAt(tProps, tPart)
    tPart = tdata.getAt(#part)
    tInk = tdata.getAt(#ink)
    tFigure = tProps.getAt(#figure).getAt(tPart)
    tMemNum = getmemnum("sh_std_" & tPart & "_" & tFigure.getAt("model") & "_" & pDirection & "_0")
    tColor = tFigure.getAt("color")
    if tMemNum > 0 then
      tmember = member(tMemNum)
      tImage = tmember.image
      tRegPnt = tmember.regPoint
      tX = (-tRegPnt.getAt(1) + 6)
      tY = ((tProps.getAt(#buffer).rect.height - tRegPnt.getAt(2)) - 10)
      tDstRect = (rect(tX, tY, (tX + tImage.width), (tY + tImage.height)) + pDefOffset)
      tSrcRect = tImage.rect
      tMaskImg = tImage.createMatte()
      pimage.copyPixels(tImage, tDstRect, tSrcRect, [#maskImage:tMaskImg, #ink:tInk, #bgColor:tColor])
    end if
  end repeat
  pAction = ""
  pAnimFrm = 0
  return TRUE
end

on status me, tAction, tBalance 
  pAction = tAction
  pBalance = tBalance
  pCurOffset = pBalOffList.getAt((pBalance + 1))
  pAnimFrm = 0
end

on prepare me 
  pAnimFrm = (pAnimFrm + 1)
  pActOffset = [0, 0, 0, 0]
  if (pAnimFrm = 1) then
    if pAction <> "hit1" then
      if (pAction = "hit2") then
        pActOffset = pHitOffset
      end if
    end if
  end if
end

on render me, tBuffer 
  tBuffer.copyPixels(pimage, ((pimage.rect + pCurOffset) + pActOffset), pimage.rect, [#ink:36])
end
