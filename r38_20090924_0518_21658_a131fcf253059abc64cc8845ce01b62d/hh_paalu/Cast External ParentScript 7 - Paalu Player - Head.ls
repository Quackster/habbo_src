property pDirection, pDefOffset, pCurOffset, pActOffset, pHitOffset, pBalOffList, pAnimFrm, pAction, pimage

on define me, tPart, tProps
  if tProps[#Dir] = 4 then
    pDirection = 3
    pDefOffset = rect(1, 0, 1, 0)
  else
    pDirection = 7
    pDefOffset = rect(-7, 1, -7, 1)
  end if
  pActOffset = [0, 0, 0, 0]
  pCurOffset = rect(0, 0, 0, 0)
  pBalOffList = [[-4, 2, -4, 2], [-2, 1, -2, 1], 0, [2, 1, 2, 1], [4, 2, 4, 2]]
  if pDirection = 7 then
    pHitOffset = [2, -1, 2, -1]
  else
    pHitOffset = [-2, 1, -2, 1]
  end if
  pimage = tProps[#buffer].duplicate()
  tHeadPartList = getVariable("human.partset.head.sh")
  if tHeadPartList = 0 then
    tHeadPartList = []
  end if
  tFigureData = tProps[#figure]
  repeat with i = 1 to tFigureData.count
    tPartName = tFigureData.getPropAt(i)
    if tHeadPartList.findPos(tPartName) > 0 then
      tdata = [#part: tPartName, #ink: 41]
      tPart = tdata[#part]
      tInk = tdata[#ink]
      tFigure = tFigureData[tPart]
      tMemNum = getmemnum("sh_std_" & tPart & "_" & tFigure["model"] & "_" & pDirection & "_0")
      tColor = tFigure["color"]
      if tMemNum > 0 then
        tmember = member(tMemNum)
        tImage = tmember.image
        tRegPnt = tmember.regPoint
        tX = -tRegPnt[1] + 6
        tY = tProps[#buffer].rect.height - tRegPnt[2] - 10
        tDstRect = rect(tX, tY, tX + tImage.width, tY + tImage.height) + pDefOffset
        tSrcRect = tImage.rect
        tMaskImg = tImage.createMatte()
        pimage.copyPixels(tImage, tDstRect, tSrcRect, [#maskImage: tMaskImg, #ink: tInk, #bgColor: tColor])
      end if
    end if
  end repeat
  pAction = EMPTY
  pAnimFrm = 0
  return 1
end

on status me, tAction, tBalance
  pAction = tAction
  pBalance = tBalance
  pCurOffset = pBalOffList[pBalance + 1]
  pAnimFrm = 0
end

on prepare me
  pAnimFrm = pAnimFrm + 1
  pActOffset = [0, 0, 0, 0]
  if pAnimFrm = 1 then
    case pAction of
      "hit1", "hit2":
        pActOffset = pHitOffset
    end case
  end if
end

on render me, tBuffer
  tBuffer.copyPixels(pimage, pimage.rect + pCurOffset + pActOffset, pimage.rect, [#ink: 36])
end
