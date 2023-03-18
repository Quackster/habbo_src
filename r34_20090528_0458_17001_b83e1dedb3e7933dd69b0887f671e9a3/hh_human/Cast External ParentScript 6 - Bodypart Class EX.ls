property pBody, pPart, pDirection, pAction, pXFix, pYFix, pLastLocFix, pLayerPropList, pAnimation, pAnimFrame, pTotalFrame, pFrameSkipCounter, pFrameSkipTotal, pAnimList, pFlipPart, pMemNumCache

on construct me
  pMemNumCache = [:]
  pLayerPropList = []
end

on clearGraphics me
  repeat with i = 1 to pLayerPropList.count
    tdata = pLayerPropList[i]
    pBody.pUpdateRect = union(pBody.pUpdateRect, tdata["cacheRect"])
  end repeat
end

on resetMemberCache me
  repeat with i = 1 to pLayerPropList.count
    tdata = pLayerPropList[i]
    tdata["memString"] = EMPTY
  end repeat
end

on define me, tPart, tmodel, tColor, tDirection, tAction, tBody, tFlipPart, tInk
  pBody = tBody
  pPart = tPart
  me.setModel(tmodel)
  me.defineInk(tInk)
  me.setColor(tColor)
  pDirection = tDirection
  pAction = tAction
  pXFix = 0
  pYFix = 0
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
  tRectModOrig = tRectMod.duplicate()
  if pBody.pAnimating then
    me.animateUpdate()
  end if
  tLocFixChanged = pLastLocFix <> point(pXFix + tRectMod[1], pYFix + tRectMod[2])
  pLastLocFix = point(pXFix + tRectMod[1], pYFix + tRectMod[2])
  repeat with i = 1 to pLayerPropList.count
    tRectMod = tRectModOrig.duplicate()
    tdata = pLayerPropList[i]
    tmodel = tdata["model"]
    tDrawProps = tdata["drawProps"]
    tFlipHOld = tdata["flipH"]
    if pBody.pAnimating then
      tMemString = me.animate(i)
    end if
    if (tMemString = VOID) or (tMemString = EMPTY) then
      if pDirection = tdir then
        tdata["flipH"] = 0
      else
        tdata["flipH"] = 1
      end if
      tAnimCntr = 0
      if not voidp(pAnimList[pAction]) then
        if pAnimList[pAction].count > 0 then
          tIndex = pBody.pAnimCounter mod pAnimList[pAction].count
          tAnimCntr = pAnimList[pAction][tIndex + 1]
        end if
      end if
      if pFlipPart <> EMPTY then
        tMemString = pBody.pPeopleSize & "_" & tAction & "_" & tPart & "_" & tmodel & "_" & pDirection & "_" & tAnimCntr
        tMemNum = me.getMemNumFast(tMemString)
        if tMemNum > 0 then
          tdir = pDirection
          tdata["flipH"] = 0
        else
          if pDirection <> tdir then
            tPart = pFlipPart
          end if
        end if
      end if
      tMemString = pBody.pPeopleSize & "_" & tAction & "_" & tPart & "_" & tmodel & "_" & tdir & "_" & tAnimCntr
    end if
    if tFlipHOld <> tdata["flipH"] then
      tForcedUpdate = 1
    end if
    if (tdata["memString"] <> tMemString) or tLocFixChanged or tForcedUpdate then
      tdata["memString"] = tMemString
      tMemNum = me.getMemNumFast(tMemString)
      if tMemNum > 0 then
        tmember = member(tMemNum)
        tRegPnt = tmember.regPoint
        tX = -tRegPnt[1]
        tY = pBody.pBuffer.rect.height - tRegPnt[2] - 20
        pBody.pUpdateRect = union(pBody.pUpdateRect, tdata["cacheRect"])
        tdata["cacheImage"] = tmember.image
        tLocFix = pBody.pLocFix.duplicate()
        if tdata["flipH"] then
          tX = pBody.pBuffer.width - (tX + tmember.width)
          tLocFix[1] = -tLocFix[1]
          if pBody.pPeopleSize = "sh" then
            tX = tX - 2
          end if
          tRectMod[1] = -tRectMod[1]
          tRectMod[3] = -tRectMod[3]
        end if
        tdata["cacheRect"] = rect(tX, tY, tX + tdata["cacheImage"].width, tY + tdata["cacheImage"].height)
        tdata["cacheRect"] = tdata["cacheRect"] + [pXFix, pYFix, pXFix, pYFix] + rect(tLocFix, tLocFix) + tRectMod
        tDrawProps[#maskImage] = tdata["cacheImage"].createMatte()
        pBody.pUpdateRect = union(pBody.pUpdateRect, tdata["cacheRect"])
      else
        pBody.pUpdateRect = union(pBody.pUpdateRect, tdata["cacheRect"])
        tdata["cacheRect"] = rect(0, 0, 0, 0)
        tdata["cacheImage"] = 0
      end if
    end if
    tDrawArea = me.getDrawArea(i)
    if tdata["cacheImage"] <> 0 then
      pBody.pBuffer.copyPixels(tdata["cacheImage"], tDrawArea, tdata["cacheImage"].rect, tDrawProps)
    end if
    tMemString = VOID
  end repeat
  if integerp(pFrameSkipTotal) then
    if pFrameSkipCounter < (pFrameSkipTotal - 1) then
      pFrameSkipCounter = pFrameSkipCounter + 1
      return 
    end if
    pFrameSkipCounter = 0
  end if
  if pBody.pAnimating then
    pAnimFrame = pAnimFrame + 1
    if pAnimFrame > pTotalFrame then
      pAnimFrame = 1
    end if
  end if
end

on render me
  repeat with i = 1 to me.pLayerPropList.count
    tdata = me.pLayerPropList[i]
    if memberExists(tdata["memString"]) then
      tDrawArea = me.getDrawArea(i)
      if tdata["cacheImage"] <> 0 then
        pBody.pBuffer.copyPixels(tdata["cacheImage"], tDrawArea, tdata["cacheImage"].rect, tdata["drawProps"])
      end if
    end if
  end repeat
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

on defineBlend me, tBlend
  repeat with i = 1 to pLayerPropList.count
    tDrawProps = pLayerPropList[i]["drawProps"]
    tDrawProps[#blend] = tBlend
  end repeat
end

on defineInk me, tInk
  if voidp(tInk) then
    case pPart of
      "ey":
        tInk = 36
      "ri":
        tInk = 8
      "li":
        tInk = 8
      otherwise:
        tInk = 41
    end case
  end if
  repeat with i = 1 to pLayerPropList.count
    tDrawProps = pLayerPropList[i]["drawProps"]
    tDrawProps[#ink] = tInk
  end repeat
  return 1
end

on setModel me, tmodel
  if ilk(tmodel) <> #list then
    tmodel = [tmodel]
  end if
  me.clearGraphics()
  pLayerPropList = []
  repeat with i = 1 to tmodel.count
    tdata = [:]
    tdata["model"] = tmodel[i]
    tdata["flipH"] = 0
    tdata["cacheImage"] = 0
    tdata["cacheRect"] = rect(0, 0, 0, 0)
    tdata["drawProps"] = [#maskImage: 0, #ink: 0, #bgColor: 0]
    tdata["memString"] = EMPTY
    pLayerPropList.add(tdata)
  end repeat
  me.defineInk()
end

on setColor me, tColorList
  if voidp(tColorList) then
    return 0
  end if
  if tColorList = EMPTY then
    return 0
  end if
  if ilk(tColorList) <> #list then
    tColorList = [tColorList]
  end if
  repeat with i = 1 to pLayerPropList.count
    if tColorList.count < i then
      tColor = tColorList[1]
    else
      tColor = tColorList[i]
    end if
    tDrawProps = pLayerPropList[i]["drawProps"]
    if (tColor.ilk = #color) and (tDrawProps[#ink] <> 36) then
      tDrawProps[#bgColor] = tColor
      next repeat
    end if
    tDrawProps[#bgColor] = rgb(255, 255, 255)
  end repeat
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

on getColor me
  repeat with i = 1 to pLayerPropList.count
    tDrawProps = pLayerPropList[1]["drawProps"]
    if tDrawProps[#bgColor] <> rgb(255, 255, 255) then
      return tDrawProps[#bgColor]
    end if
  end repeat
  return rgb(255, 255, 255)
end

on getDirection me
  return pDirection
end

on getModel me
  tmodel = []
  repeat with i = 1 to pLayerPropList.count
    tmodel.add(pLayerPropList[i]["model"])
  end repeat
  return tmodel
end

on getLocation me
  if pLayerPropList.count < 1 then
    return 0
  end if
  tMemString = pLayerPropList[1]["memString"]
  if voidp(tMemString) then
    return 0
  end if
  if not memberExists(tMemString) then
    return 0
  end if
  tmember = member(getmemnum(tMemString))
  tImgRect = tmember.rect
  tCntrPoint = point(tImgRect.width / 2, tImgRect.height / 2)
  tRegPoint = tmember.regPoint
  return -tRegPoint + tCntrPoint
end

on getPartID me
  return pPart
end

on copyPicture me, tImg, tdir, tHumanSize, tAction, tAnimFrame
  repeat with i = 1 to pLayerPropList.count
    tArray = me.getMemberNumber(tdir, tHumanSize, tAction, tAnimFrame, i)
    tMemNum = tArray[#memberNumber]
    tFlip = tArray[#flip]
    tInk = pLayerPropList[i]["drawProps"][#ink]
    tColor = pLayerPropList[i]["drawProps"][#bgColor]
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
      tImg.copyPixels(tImage, tRect, tImage.rect, [#maskImage: tMatte, #ink: tInk, #bgColor: tColor])
    end if
  end repeat
  return 1
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
  me.setModel(tmodel)
  me.setColor(tColor)
  repeat with i = 1 to pLayerPropList.count
    tMemString = pLayerPropList[i]["memString"]
    tMemNameList = explode(tMemString, "_")
    tMemNameList[4] = tmodel
    pLayerPropList[i]["memString"] = implode(tMemNameList, "_")
  end repeat
  tForced = 1
  me.update(tForced)
end

on setAnimation me, tPart, tAnim
  if (tPart <> pPart) and (tPart <> "all") then
    return 
  end if
  pAnimation = value(tAnim)
  if pAnimation.findPos(#frm) = 0 then
    pTotalFrame = 1
  else
    pTotalFrame = pAnimation.getaProp(#frm).count
  end if
  pFrameSkipTotal = pAnimation.getaProp(#skip)
  pAnimFrame = 1
end

on remAnimation me
  pAnimation = 0
  pAnimFrame = 1
  pTotalFrame = 1
  pXFix = 0
  pYFix = 0
end

on animateUpdate me
  if ilk(pAnimation) <> #propList then
    return 
  end if
  if pAnimation.findPos(#randomX) <> VOID then
    if pAnimFrame > 1 then
      return 1
    end if
    tXFixRandom = random(pBody.pBuffer.width)
  else
    tXFixRandom = 0
  end if
  tFixes = pAnimation.getaProp(#OffX)
  if tFixes <> VOID then
    if tFixes.count < pAnimFrame then
      pXFix = tFixes[1] + tXFixRandom
    else
      pXFix = tFixes[pAnimFrame] + tXFixRandom
    end if
  else
    pXFix = tXFixRandom
  end if
  if pAnimation.findPos(#randomY) <> VOID then
    if pAnimFrame > 1 then
      return 1
    end if
    tYFixRandom = -random(pBody.pBuffer.height)
  else
    tYFixRandom = 0
  end if
  tFixes = pAnimation.getaProp(#OffY)
  if tFixes <> VOID then
    if tFixes.count < pAnimFrame then
      pYFix = tFixes[1] + tYFixRandom
    else
      pYFix = tFixes[pAnimFrame] + tYFixRandom
    end if
  else
    pYFix = tYFixRandom
  end if
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
    tSizeMultiplier = 0.5
  else
    tSizeMultiplier = 1
  end if
  pXFix = pXFix * tSizeMultiplier
  pYFix = pYFix * tSizeMultiplier
end

on animate me, tLayerIndex
  if not pAnimation then
    return EMPTY
  end if
  if voidp(tLayerIndex) then
    tLayerIndex = 1
  end if
  if (tLayerIndex < 1) or (tLayerIndex > pLayerPropList.count) then
    return EMPTY
  end if
  tdata = pLayerPropList[tLayerIndex]
  tmodel = tdata["model"]
  tFixes = pAnimation.getaProp(#OffD)
  if tFixes <> VOID then
    if tFixes.count < pAnimFrame then
      tdir = pDirection + tFixes[1]
    else
      tdir = pDirection + tFixes[pAnimFrame]
    end if
  else
    tdir = pDirection
  end if
  if tdir > 7 then
    tdir = min(tdir - 8, 7)
  else
    if tdir < 0 then
      tdir = max(7 + tdir + 1, 0)
    end if
  end if
  if pAnimation.getaProp(#namebase) <> 0 then
    tPart = pAnimation.getaProp(#namebase)
  else
    tPart = pPart
  end if
  tActions = pAnimation.getaProp(#act)
  if tActions = VOID then
    tAnimAct = pAction
  else
    if tActions.count < pAnimFrame then
      tAnimAct = tActions[1]
    else
      tAnimAct = tActions[pAnimFrame]
    end if
  end if
  tFrames = pAnimation.getaProp(#frm)
  if tFrames <> VOID then
    if tFrames.count < pAnimFrame then
      tAnimFrame = tFrames[1]
    else
      tAnimFrame = tFrames[pAnimFrame]
    end if
  else
    tAnimFrame = 0
  end if
  if tdir <> pBody.pFlipList[tdir + 1] then
    tDirOrig = tdir
    tdir = pBody.pFlipList[tdir + 1]
    tdata["flipH"] = 1
    if pFlipPart <> EMPTY then
      tMemString = pBody.pPeopleSize & "_" & tAnimAct & "_" & tPart & "_" & tmodel & "_" & tDirOrig & "_" & tAnimFrame
      tMemNum = me.getMemNumFast(tMemString)
      if tMemNum > 0 then
        tdir = tDirOrig
        tdata["flipH"] = 0
      else
        tPart = pFlipPart
      end if
    end if
  else
    tdata["flipH"] = 0
  end if
  tMemName = pBody.pPeopleSize & "_" & tAnimAct & "_" & tPart & "_" & tmodel & "_" & tdir & "_" & tAnimFrame
  return tMemName
end

on flipHorizontal me, tImg
  tImage = image(tImg.width, tImg.height, tImg.depth)
  tQuad = [point(tImg.width, 0), point(0, 0), point(0, tImg.height), point(tImg.width, tImg.height)]
  tImage.copyPixels(tImg, tQuad, tImg.rect)
  return tImage
end

on getMemberNumber me, tdir, tHumanSize, tAction, tAnimFrame, tLayerIndex, tmodel
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
  if voidp(tLayerIndex) then
    tLayerIndex = 1
  end if
  if (tLayerIndex < 1) or (tLayerIndex > pLayerPropList.count) then
    tLayerIndex = 1
  end if
  if voidp(tmodel) then
    if pLayerPropList.count >= tLayerIndex then
      tmodel = pLayerPropList[tLayerIndex]["model"]
    else
      tmodel = EMPTY
    end if
  end if
  tPart = pPart
  if (pFlipPart <> EMPTY) and (tFlip = 1) then
    tPart = pFlipPart
  end if
  tMemName = tHumanSize & "_" & tAction & "_" & tPart & "_" & tmodel & "_" & tdir & "_" & tAnimFrame
  tNum = me.getMemNumFast(tMemName)
  return [#memberNumber: tNum, #flip: tFlip]
end

on getDrawArea me, tLayerIndex
  if (tLayerIndex < 1) or (tLayerIndex > pLayerPropList.count) then
    return rect(0, 0, 0, 0)
  end if
  tdata = pLayerPropList[tLayerIndex]
  tRect = tdata["cacheRect"]
  if tdata["flipH"] then
    tDrawArea = [point(tRect[3], tRect[2]), point(tRect[1], tRect[2]), point(tRect[1], tRect[4]), point(tRect[3], tRect[4])]
  else
    tDrawArea = tRect
  end if
  return tDrawArea.duplicate()
end

on getMemNumFast me, tName
  tNum = pMemNumCache[tName]
  if voidp(tNum) then
    tNum = getmemnum(tName)
    pMemNumCache.addProp(tName, tNum)
    if pMemNumCache.count > 20 then
      pMemNumCache.deleteAt(1)
    end if
  end if
  return tNum
end
