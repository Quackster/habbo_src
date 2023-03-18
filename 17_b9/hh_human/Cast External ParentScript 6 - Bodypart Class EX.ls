property pBody, pPart, pmodel, pDirection, pDrawProps, pAction, pMemString, pXFix, pYFix, pLastLocFix, pCacheImage, pCacheRectA, pCacheRectB, pFlipH, pAnimation, pAnimFrame, pTotalFrame, pAnimList, pFlipPart

on define me, tPart, tmodel, tColor, tDirection, tAction, tBody, tFlipPart
  pBody = tBody
  pPart = tPart
  pmodel = tmodel
  pDrawProps = [#maskImage: 0, #ink: 0, #bgColor: 0]
  pCacheImage = 0
  pCacheRectA = rect(0, 0, 0, 0)
  pCacheRectB = rect(0, 0, 0, 0)
  me.defineInk()
  me.setColor(tColor)
  pDirection = tDirection
  pAction = tAction
  pMemString = EMPTY
  pXFix = 0
  pYFix = 0
  pFlipH = 0
  pLastLocFix = point(1000, 1000)
  pAnimation = 0
  pAnimFrame = 1
  pTotalFrame = 1
  pAnimList = [:]
  pFlipPart = EMPTY
  if not voidp(tFlipPart) then
    pFlipPart = tFlipPart
  end if
  return 1
end

on setAnimations me, tAnimData
  if ilk(tAnimData) = #propList then
    pAnimList = tAnimData
  end if
end

on update me, tForcedUpdate, tRectMod
  tAnimCntr = 0
  tAction = pAction
  tPart = pPart
  tdir = pBody.pFlipList[pDirection + 1]
  pXFix = 0
  pYFix = 0
  if voidp(tRectMod) then
    tRectMod = rect(0, 0, 0, 0)
  else
    tRectMod = tRectMod.duplicate()
  end if
  tFlipHOld = pFlipH
  if pBody.pAnimating then
    tMemString = me.animate()
    case pBody.pDirection of
      0:
        pYFix = pYFix + (pXFix / 2)
        pXFix = pXFix / 2
      1:
        pYFix = pYFix + pXFix
        pXFix = 0
      2:
        pYFix = pYFix - (pXFix / 2)
        pXFix = pXFix / 2
      4:
        pYFix = pYFix + (pXFix / 2)
        pXFix = -pXFix / 2
      5:
        pYFix = pYFix - pXFix
        pXFix = 0
      6:
        pYFix = pYFix - (pXFix / 2)
        pXFix = -pXFix / 2
      7:
        pXFix = -pXFix
    end case
    if pBody.pPeopleSize = "sh" then
      tSizeMultiplier = 0.69999999999999996
    else
      tSizeMultiplier = 1
    end if
    pXFix = pXFix * tSizeMultiplier
    pYFix = pYFix * tSizeMultiplier
  else
    if pDirection = tdir then
      pFlipH = 0
    else
      pFlipH = 1
    end if
    if not voidp(pAnimList[pAction]) then
      if pAnimList[pAction].count > 0 then
        tIndex = pBody.pAnimCounter mod pAnimList[pAction].count
        tAnimCntr = pAnimList[pAction][tIndex + 1]
      end if
    end if
    if pFlipPart <> EMPTY then
      tMemString = pBody.pPeopleSize & "_" & tAction & "_" & tPart & "_" & pmodel & "_" & pDirection & "_" & tAnimCntr
      if getmemnum(tMemString) > 0 then
        tdir = pDirection
        pFlipH = 0
      else
        if pDirection <> tdir then
          tPart = pFlipPart
        end if
      end if
    end if
    case pPart of
      "ey":
        if pBody.pTalking then
          if (pAction <> "lay") and ((pBody.pAnimCounter mod 2) = 0) then
            pYFix = -1
          end if
        end if
      "ri":
        if not pBody.pCarrying then
          pMemString = EMPTY
          if pCacheRectA.width > 0 then
            pBody.pUpdateRect = union(pBody.pUpdateRect, pCacheRectA)
            pCacheRectA = rect(0, 0, 0, 0)
          end if
          return 
        end if
    end case
    tMemString = pBody.pPeopleSize & "_" & tAction & "_" & tPart & "_" & pmodel & "_" & tdir & "_" & tAnimCntr
  end if
  if tFlipHOld <> pFlipH then
    tForcedUpdate = 1
  end if
  tLocFixChanged = pLastLocFix <> point(pXFix, pYFix)
  pLastLocFix = point(pXFix, pYFix)
  if (pMemString <> tMemString) or tLocFixChanged or tForcedUpdate then
    pMemString = tMemString
    tMemNum = getmemnum(tMemString)
    if tMemNum > 0 then
      tmember = member(tMemNum)
      tRegPnt = tmember.regPoint
      tX = -tRegPnt[1]
      tY = pBody.pBuffer.rect.height - tRegPnt[2] - 10
      pBody.pUpdateRect = union(pBody.pUpdateRect, pCacheRectA)
      pCacheImage = tmember.image
      tLocFix = pBody.pLocFix
      pCacheRectB = pCacheImage.rect
      if pFlipH then
        tX = -tX - tmember.width + pBody.pBuffer.width
        tLocFix = point(-pBody.pLocFix[1], pBody.pLocFix[2])
        if pBody.pPeopleSize = "sh" then
          tX = tX - 2
        end if
        tRectMod[1] = -tRectMod[1]
        tRectMod[3] = -tRectMod[3]
        pCacheRectA = rect(tX, tY, tX + pCacheImage.width, tY + pCacheImage.height) + [pXFix, pYFix, pXFix, pYFix] + rect(tLocFix, tLocFix)
      else
        pCacheRectA = rect(tX, tY, tX + pCacheImage.width, tY + pCacheImage.height) + [pXFix, pYFix, pXFix, pYFix] + rect(tLocFix, tLocFix)
      end if
      pCacheRectA = pCacheRectA + tRectMod
      pDrawProps[#maskImage] = pCacheImage.createMatte()
      pBody.pUpdateRect = union(pBody.pUpdateRect, pCacheRectA)
    else
      pBody.pUpdateRect = union(pBody.pUpdateRect, pCacheRectA)
      pCacheRectA = rect(0, 0, 0, 0)
      return 
    end if
  end if
  if pFlipH then
    tDrawRect = pCacheRectA
    tQuad = [point(tDrawRect[3], tDrawRect[2]), point(tDrawRect[1], tDrawRect[2]), point(tDrawRect[1], tDrawRect[4]), point(tDrawRect[3], tDrawRect[4])]
    pBody.pBuffer.copyPixels(pCacheImage, tQuad, pCacheRectB, pDrawProps)
  else
    tDrawRect = pCacheRectA
    pBody.pBuffer.copyPixels(pCacheImage, tDrawRect, pCacheRectB, pDrawProps)
  end if
end

on render me
  if memberExists(pMemString) then
    if pFlipH then
      tDrawRect = pCacheRectA
      tQuad = [point(tDrawRect[3], tDrawRect[2]), point(tDrawRect[1], tDrawRect[2]), point(tDrawRect[1], tDrawRect[4]), point(tDrawRect[3], tDrawRect[4])]
      pBody.pBuffer.copyPixels(pCacheImage, tQuad, pCacheRectB, pDrawProps)
    else
      tDrawRect = pCacheRectA
      pBody.pBuffer.copyPixels(pCacheImage, tDrawRect, pCacheRectB, pDrawProps)
    end if
  end if
end

on setItemObj me, tmodel
  if (pPart = "ri") or (pPart = "li") then
    pmodel = tmodel
  end if
end

on defineDir me, tdir, tPart
  if voidp(tPart) or (tPart = pPart) then
    pDirection = tdir
  end if
end

on defineDirMultiple me, tdir, tTargetPartList
  if tTargetPartList.getOne(pPart) then
    pDirection = tdir
  end if
end

on defineAct me, tAct, tTargetPartList
  pAction = tAct
end

on defineActMultiple me, tAct, tTargetPartList
  if tTargetPartList.getOne(pPart) then
    pAction = tAct
  end if
end

on defineInk me, tInk
  if voidp(tInk) then
    case pPart of
      "ey":
        tInk = 36
      "sd":
        tInk = 32
      "ri":
        tInk = 8
      "li":
        tInk = 8
      otherwise:
        tInk = 41
    end case
  end if
  pDrawProps[#ink] = tInk
  return 1
end

on setModel me, tmodel
  pmodel = tmodel
end

on setColor me, tColor
  if voidp(tColor) then
    return 0
  end if
  if tColor = EMPTY then
    return 0
  end if
  if (tColor.ilk = #color) and (pDrawProps[#ink] <> 36) then
    pDrawProps[#bgColor] = tColor
  else
    pDrawProps[#bgColor] = rgb(255, 255, 255)
  end if
  return 1
end

on checkPartNotCarrying me
  return not pBody.getPartCarrying(pPart)
end

on doHandWorkLeft me, tAct
  pAction = tAct
end

on doHandWorkRight me, tAct
  pAction = tAct
end

on layDown me
  pAction = "lay"
end

on getCurrentMember me
  return pMemString
end

on getColor me
  return pDrawProps[#bgColor]
end

on getDirection me
  return pDirection
end

on getModel me
  return pmodel
end

on getLocation me
  if voidp(pMemString) then
    return 0
  end if
  if not memberExists(pMemString) then
    return 0
  end if
  tmember = member(getmemnum(pMemString))
  tImgRect = tmember.rect
  tCntrPoint = point(tImgRect.width / 2, tImgRect.height / 2)
  tRegPoint = tmember.regPoint
  return -tRegPoint + tCntrPoint
end

on getPartID me
  return pPart
end

on copyPicture me, tImg, tdir, tHumanSize, tAction, tAnimFrame
  tArray = me.getMemberNumber(tdir, tHumanSize, tAction, tAnimFrame)
  tMemNum = tArray[#memberNumber]
  tFlip = tArray[#flip]
  if tMemNum <> 0 then
    tmember = member(tMemNum)
    tImage = tmember.image
    tRegPnt = tmember.regPoint
    tY = tImg.rect.height - tRegPnt[2] - 10
    tX = -tRegPnt[1]
    tRect = rect(tX, tY, tX + tImage.width, tY + tImage.height)
    if tFlip then
      tRect = rect(tImg.width - (tX + tImage.width), tY, tImg.width - tX, tY + tImage.height)
      tQuad = [point(tRect[3], tRect[2]), point(tRect[1], tRect[2]), point(tRect[1], tRect[4]), point(tRect[3], tRect[4])]
      tRect = tQuad
    end if
    tMatte = tImage.createMatte()
    tImg.copyPixels(tImage, tRect, tImage.rect, [#maskImage: tMatte, #ink: pDrawProps[#ink], #bgColor: pDrawProps[#bgColor]])
    return 1
  end if
  return 0
end

on reset me
  pAction = "std"
end

on skipAnimationFrame me
  pAnimFrame = pAnimFrame + 1
  if pAnimFrame > pTotalFrame then
    pAnimFrame = 1
  end if
  return 1
end

on changePartData me, tmodel, tColor
  if voidp(tmodel) or voidp(tColor) then
    return 0
  end if
  pmodel = tmodel
  pDrawProps[#bgColor] = tColor
  tMemNameList = explode(pMemString, "_")
  tMemNameList[4] = tmodel
  pMemString = implode(tMemNameList, "_")
  tForced = 1
  me.update(tForced)
end

on setAnimation me, tPart, tAnim
  if tPart <> pPart then
    return 
  end if
  pAnimation = value(tAnim)
  pTotalFrame = pAnimation[1].count
  pAnimFrame = 1
end

on remAnimation me
  pAnimation = 0
  pAnimFrame = 1
  pTotalFrame = 1
end

on animate me
  if not pAnimation then
    return EMPTY
  end if
  tdir = pDirection + pAnimation[#OffD][pAnimFrame]
  if tdir > 7 then
    tdir = min(tdir - 8, 7)
  else
    if tdir < 0 then
      tdir = max(7 + tdir + 1, 0)
    end if
  end if
  tPart = pPart
  if tdir <> pBody.pFlipList[tdir + 1] then
    tDirOrig = tdir
    tdir = pBody.pFlipList[tdir + 1]
    pFlipH = 1
    if pFlipPart <> EMPTY then
      tMemString = pBody.pPeopleSize & "_" & pAnimation[#act][pAnimFrame] & "_" & tPart & "_" & pmodel & "_" & tDirOrig & "_" & pAnimation[#frm][pAnimFrame]
      if getmemnum(tMemString) > 0 then
        tdir = tDirOrig
        pFlipH = 0
      else
        tPart = pFlipPart
      end if
    end if
  else
    pFlipH = 0
  end if
  pXFix = pAnimation[#OffX][pAnimFrame]
  pYFix = pAnimation[#OffY][pAnimFrame]
  tMemName = pBody.pPeopleSize & "_" & pAnimation[#act][pAnimFrame] & "_" & tPart & "_" & pmodel & "_" & tdir & "_" & pAnimation[#frm][pAnimFrame]
  pAnimFrame = pAnimFrame + 1
  if pAnimFrame > pTotalFrame then
    pAnimFrame = 1
  end if
  return tMemName
end

on flipHorizontal me, tImg
  tImage = image(tImg.width, tImg.height, tImg.depth)
  tQuad = [point(tImg.width, 0), point(0, 0), point(0, tImg.height), point(tImg.width, tImg.height)]
  tImage.copyPixels(tImg, tQuad, tImg.rect)
  return tImage
end

on getMemberNumber me, tdir, tHumanSize, tAction, tAnimFrame, tmodel
  tFlip = 0
  if not voidp(tdir) then
    if (tdir > 0) and (tdir < pBody.pFlipList.count) then
      if tdir <> pBody.pFlipList[tdir + 1] then
        tdir = pBody.pFlipList[tdir + 1]
        tFlip = 1
      end if
    end if
  end if
  if voidp(tdir) then
    tdir = "2"
  end if
  if voidp(tHumanSize) then
    tHumanSize = "h"
  end if
  if voidp(tAction) then
    tAction = "std"
  end if
  if voidp(tAnimFrame) then
    tAnimFrame = "0"
  end if
  if voidp(tmodel) then
    tmodel = pmodel
  end if
  tPart = pPart
  if (pFlipPart <> EMPTY) and (tFlip = 1) then
    tPart = pFlipPart
  end if
  tMemName = tHumanSize & "_" & tAction & "_" & tPart & "_" & tmodel & "_" & tdir & "_" & tAnimFrame
  tNum = getmemnum(tMemName)
  return [#memberNumber: tNum, #flip: tFlip]
end
