property ancestor, pPart, pmodel, pDirection, pDrawProps, pSwimProps, pAction, pActionLh, pActionRh, pMemString, pXFix, pYFix, pLastLocFix, pCacheImage, pCacheRectA, pCacheRectB, pAnimation, pAnimFrame, pTotalFrame

on deconsturct me
  ancestor = VOID
  return 1
end

on define me, tPart, tmodel, tColor, tDirection, tAction, tAncestor
  ancestor = tAncestor
  pPart = tPart
  pmodel = tmodel
  pDrawProps = [#maskImage: 0, #ink: 0, #bgColor: 0]
  pSwimProps = [#maskImage: 0, #ink: 0, #bgColor: rgb(0, 156, 156), #color: rgb(0, 156, 156), #blend: 60]
  pCacheImage = 0
  pCacheRectA = rect(0, 0, 0, 0)
  pCacheRectB = rect(0, 0, 0, 0)
  me.defineInk()
  me.setColor(tColor)
  pDirection = tDirection
  pAction = tAction
  pActionLh = tAction
  pActionRh = tAction
  pMemString = EMPTY
  pXFix = 0
  pYFix = 0
  pLastLocFix = point(1000, 1000)
  pAnimation = 0
  pAnimFrame = 1
  pTotalFrame = 1
  return 1
end

on update me
  tAnimCounter = 0
  tAction = pAction
  tPart = pPart
  tdir = me.pFlipList[pDirection + 1]
  pXFix = 0
  pYFix = 0
  if me.pAnimating then
    tMemString = me.animate()
    tAncestorDir = me.pDirection
    if me.pPeopleSize = "sh" then
      tSizeMultiplier = 0.69999999999999996
    else
      tSizeMultiplier = 1
    end if
    case tAncestorDir of
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
    pXFix = pXFix * tSizeMultiplier
    pYFix = pYFix * tSizeMultiplier
  else
    case pPart of
      "bd", "lg", "sh":
        tUnderWater = 1
        if (pAction = "wlk") or (pAction = "swm") or (pAction = "sws") then
          tAnimCounter = me.pAnimCounter
        end if
      "lh", "ls":
        tUnderWater = 1
        if pDirection = tdir then
          if not voidp(pActionLh) then
            tAction = pActionLh
          end if
        else
          if not voidp(pActionRh) then
            tAction = pActionRh
          end if
        end if
        if (tAction = "wlk") or (pAction = "swm") or (pAction = "sws") then
          tAnimCounter = me.pAnimCounter
        else
          if tAction = "wav" then
            tUnderWater = 0
            tAnimCounter = me.pAnimCounter mod 2
          else
            if ["crr", "drk", "ohd"].getPos(tAction) <> 0 then
              pXFix = -40
              tPart = "r" & pPart.char[2]
              tdir = pDirection
            end if
          end if
        end if
      "rh", "rs":
        tUnderWater = 1
        if pDirection = tdir then
          if not voidp(pActionRh) then
            tAction = pActionRh
          end if
        else
          if not voidp(pActionLh) then
            tAction = pActionLh
          end if
        end if
        if (tAction = "wlk") or (pAction = "swm") or (pAction = "sws") then
          tAnimCounter = me.pAnimCounter
        else
          if tAction = "wav" then
            tUnderWater = 0
            tAnimCounter = me.pAnimCounter mod 2
            tPart = "l" & pPart.char[2]
            tdir = pDirection
          end if
        end if
      "hd", "fc":
        tUnderWater = 0
        if me.pTalking then
          if pAction = "lay" then
            tAction = "lsp"
          else
            tAction = "spk"
          end if
          tAnimCounter = me.pAnimCounter mod 2
        end if
      "ey":
        tUnderWater = 0
        if me.pTalking and (pAction <> "lay") and ((me.pAnimCounter mod 2) = 0) then
          pYFix = -1
        end if
      "hr":
        tUnderWater = 0
        if me.pTalking and ((me.pAnimCounter mod 2) = 0) then
          if pAction <> "lay" then
            tAction = "spk"
          end if
        end if
      "ri":
        if not me.pCarrying then
          return 
        end if
        tAction = pActionRh
        tdir = pDirection
      "li":
        tAction = pActionLh
        tdir = pDirection
      otherwise:
        tUnderWater = 1
    end case
    tMemString = me.pPeopleSize & "_" & tAction & "_" & tPart & "_" & pmodel & "_" & tdir & "_" & tAnimCounter
  end if
  tLocFixChanged = pLastLocFix <> point(pXFix, pYFix)
  pLastLocFix = point(pXFix, pYFix)
  if (pMemString <> tMemString) or tLocFixChanged then
    tMemNum = getmemnum(tMemString)
    if tMemNum > 0 then
      pMemString = tMemString
      tmember = member(tMemNum)
      tRegPnt = tmember.regPoint
      tX = -tRegPnt[1]
      tY = me.pBuffer.rect.height - tRegPnt[2] - 10
      me.pUpdateRect = union(me.pUpdateRect, pCacheRectA)
      pCacheImage = tmember.image
      pCacheRectA = rect(tX, tY, tX + pCacheImage.width, tY + pCacheImage.height)
      pCacheRectB = pCacheImage.rect
      pDrawProps[#maskImage] = pCacheImage.createMatte()
      me.pUpdateRect = union(me.pUpdateRect, pCacheRectA)
    else
      return 
    end if
  end if
  if me.pMainAction = "swm" then
    tRectMod = rect(14, 0, 14, 0) + rect(me.pLocFix, me.pLocFix) + [pXFix, pYFix, pXFix, pYFix]
  else
    tRectMod = rect(me.pLocFix, me.pLocFix) + [pXFix, pYFix, pXFix, pYFix]
  end if
  me.pBuffer.copyPixels(pCacheImage, pCacheRectA + tRectMod, pCacheRectB, pDrawProps)
  if tUnderWater and me.pSwim then
    pSwimProps[#maskImage] = pDrawProps[#maskImage]
    me.pBuffer.copyPixels(pCacheImage, pCacheRectA + tRectMod, pCacheRectB, pSwimProps)
  end if
end

on render me
  if memberExists(pMemString) then
    me.pBuffer.copyPixels(pCacheRectB, pCacheRectA, pCacheRectB, pDrawProps)
    if me.pSwim then
      pSwimProps[#maskImage] = pDrawProps[#maskImage]
      me.pBuffer.copyPixels(pCacheImage, pCacheRectA + [pXFix, pYFix, pXFix, pYFix] + rect(me.pLocFix, me.pLocFix), pCacheRectB, pSwimProps)
    end if
  end if
end

on setItemObj me, tmodel
  if (pPart <> "ri") and (pPart <> "li") then
    return 
  end if
  pmodel = tmodel
end

on defineDir me, tdir, tPart
  if voidp(tPart) or (tPart = pPart) then
    pDirection = tdir
  end if
end

on defineDirMultiple me, tdir, tTargetPartList
  if tTargetPartList.getPos(pPart) = 0 then
    return 
  end if
  pDirection = tdir
end

on defineAct me, tAct, tTargetPartList
  if pAction = "std" then
    pAction = tAct
  end if
end

on defineActMultiple me, tAct, tTargetPartList
  if tTargetPartList.getPos(pPart) = 0 then
    return 
  end if
  if pAction = "std" then
    pAction = tAct
  end if
  if (pPart = "ey") and (tAct = "std") then
    pAction = "std"
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
  pSwimProps[#ink] = tInk
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

on doHandWork me, tAct
  if ["lh", "ls", "li", "rh", "rs", "ri"].getOne(pPart) <> 0 then
    pAction = tAct
  end if
end

on doHandWorkLeft me, tAct
  pActionLh = tAct
end

on doHandWorkRight me, tAct
  pActionRh = tAct
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

on getLocation me
  if voidp(pMemString) then
    return 0
  end if
  tMemNum = getmemnum(pMemString)
  if tMemNum = 0 then
    return 0
  end if
  tImgRect = member(tMemNum).rect
  tCenterPoint = point(tImgRect.width / 2, tImgRect.height / 2)
  tRegPoint = member(tMemNum).regPoint
  return (tRegPoint * -1) + tCenterPoint
end

on copyPicture me, tImg, tdir, tHumanSize, tAction, tAnimFrame
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
  tMemName = tHumanSize & "_" & tAction & "_" & pPart & "_" & pmodel & "_" & tdir & "_" & tAnimFrame
  tMemNum = getmemnum(tMemName)
  if tMemNum = 0 then
    tmodel = "0" & pmodel.char[2..3]
    tMemName = tHumanSize & "_" & tAction & "_" & pPart & "_" & tmodel & "_" & tdir & "_" & tAnimFrame
    tMemNum = getmemnum(tMemName)
    if tMemNum = 0 then
      return 0
    end if
  end if
  tmember = member(tMemNum)
  tImage = tmember.image
  tRegPnt = tmember.regPoint
  tX = -tRegPnt[1]
  tY = tImg.rect.height - tRegPnt[2] - 10
  tRect = rect(tX, tY, tX + tImage.width, tY + tImage.height)
  tMatte = tImage.createMatte()
  tImg.copyPixels(tImage, tRect, tImage.rect, [#maskImage: tMatte, #ink: pDrawProps[#ink], #bgColor: pDrawProps[#bgColor]])
  return 1
end

on reset me, tSwimFlag
  pAction = "std"
  pActionLh = VOID
  pActionRh = VOID
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
    tdir = tdir - (tdir mod 7)
  else
    if tdir < 0 then
      tdir = 7 + tdir + 1
    end if
  end if
  tdir = me.pFlipList[tdir + 1]
  pXFix = pAnimation[#OffX][pAnimFrame]
  pYFix = pAnimation[#OffY][pAnimFrame]
  tMemName = me.pPeopleSize & "_" & pAnimation[#act][pAnimFrame] & "_" & pPart & "_" & pmodel & "_" & tdir & "_" & pAnimation[#frm][pAnimFrame]
  pAnimFrame = pAnimFrame + 1
  if pAnimFrame > pTotalFrame then
    pAnimFrame = 1
  end if
  return tMemName
end
