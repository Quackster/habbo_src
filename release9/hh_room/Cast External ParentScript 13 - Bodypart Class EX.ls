property ancestor, pPart, pmodel, pDirection, pDrawProps, pAction, pActionLh, pActionRh, pMemString, pXFix, pYFix, pLastLocFix, pCacheImage, pCacheRectA, pCacheRectB, pFlipH, pAnimation, pAnimFrame, pTotalFrame

on deconsturct me
  ancestor = VOID
  return 1
end

on define me, tPart, tmodel, tColor, tDirection, tAction, tAncestor
  ancestor = tAncestor
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
  pActionLh = tAction
  pActionRh = tAction
  pMemString = EMPTY
  pXFix = 0
  pYFix = 0
  pFlipH = 0
  pLastLocFix = point(1000, 1000)
  pAnimation = 0
  pAnimFrame = 1
  pTotalFrame = 1
  return 1
end

on update me
  tAnimCntr = 0
  tAction = pAction
  tPart = pPart
  tdir = me.pFlipList[pDirection + 1]
  pXFix = 0
  pYFix = 0
  if me.pAnimating and me.checkPartNotCarrying() then
    tMemString = me.animate()
    case me.pDirection of
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
    if me.pPeopleSize = "sh" then
      tSizeMultiplier = 0.69999999999999996
    else
      tSizeMultiplier = 1
    end if
    pXFix = pXFix * tSizeMultiplier
    pYFix = pYFix * tSizeMultiplier
  else
    case pPart of
      "bd", "lg", "sh":
        if pAction = "wlk" then
          tAnimCntr = me.pAnimCounter
        end if
      "lh", "ls":
        if pDirection = tdir then
          if not voidp(pActionLh) then
            tAction = pActionLh
          end if
        else
          if not voidp(pActionRh) then
            tAction = pActionRh
          end if
        end if
        if tAction = "wlk" then
          tAnimCntr = me.pAnimCounter
        else
          if tAction = "wav" then
            tAnimCntr = me.pAnimCounter mod 2
          else
            if ["crr", "drk", "ohd"].getPos(tAction) <> 0 then
              if pDirection >= 4 then
                pXFix = -40
                tPart = "r" & pPart.char[2]
              end if
              tdir = pDirection
            end if
          end if
        end if
      "rh", "rs":
        if pDirection = tdir then
          if not voidp(pActionRh) then
            tAction = pActionRh
          end if
        else
          if not voidp(pActionLh) then
            tAction = pActionLh
          end if
        end if
        if tAction = "wlk" then
          tAnimCntr = me.pAnimCounter
        else
          if tAction = "wav" then
            tAnimCntr = me.pAnimCounter mod 2
            tPart = "l" & pPart.char[2]
            tdir = pDirection
          else
            if tAction = "sig" then
              tAnimCntr = 0
              tPart = "l" & pPart.char[2]
              tdir = pDirection
              tAction = "wav"
            end if
          end if
        end if
      "hd", "fc":
        if me.pTalking then
          if pAction = "lay" then
            tAction = "lsp"
          else
            tAction = "spk"
          end if
          tAnimCntr = me.pAnimCounter mod 2
        end if
      "ey":
        if me.pTalking and (pAction <> "lay") and ((me.pAnimCounter mod 2) = 0) then
          pYFix = -1
        end if
      "hr":
        if me.pTalking and ((me.pAnimCounter mod 2) = 0) then
          if pAction <> "lay" then
            tAction = "spk"
          end if
        end if
      "ri":
        if not me.pCarrying then
          pMemString = EMPTY
          if pCacheRectA.width > 0 then
            me.pUpdateRect = union(me.pUpdateRect, pCacheRectA)
            pCacheRectA = rect(0, 0, 0, 0)
          end if
          return 
        else
          tAction = pActionRh
          tdir = pDirection
        end if
      "li":
        tAction = pActionLh
        tdir = pDirection
    end case
    tMemString = me.pPeopleSize & "_" & tAction & "_" & tPart & "_" & pmodel & "_" & tdir & "_" & tAnimCntr
    pFlipH = 0
  end if
  tLocFixChanged = pLastLocFix <> point(pXFix, pYFix)
  pLastLocFix = point(pXFix, pYFix)
  if (pMemString <> tMemString) or tLocFixChanged then
    pMemString = tMemString
    tMemNum = getmemnum(tMemString)
    if tMemNum > 0 then
      tmember = member(tMemNum)
      tRegPnt = tmember.regPoint
      tX = -tRegPnt[1]
      tY = me.pBuffer.rect.height - tRegPnt[2] - 10
      me.pUpdateRect = union(me.pUpdateRect, pCacheRectA)
      pCacheImage = tmember.image
      tLocFix = me.pLocFix
      if pFlipH then
        pCacheImage = me.flipHorizontal(pCacheImage)
        tX = -tX - tmember.width + me.pBuffer.width
        tLocFix = point(-me.pLocFix[1], me.pLocFix[2])
        if me.pPeopleSize = "sh" then
          tX = tX - 2
        end if
      end if
      pCacheRectA = rect(tX, tY, tX + pCacheImage.width, tY + pCacheImage.height) + [pXFix, pYFix, pXFix, pYFix] + rect(tLocFix, tLocFix)
      pCacheRectB = pCacheImage.rect
      pDrawProps[#maskImage] = pCacheImage.createMatte()
      me.pUpdateRect = union(me.pUpdateRect, pCacheRectA)
    else
      me.pUpdateRect = union(me.pUpdateRect, pCacheRectA)
      pCacheRectA = rect(0, 0, 0, 0)
      return 
    end if
  end if
  me.pBuffer.copyPixels(pCacheImage, pCacheRectA, pCacheRectB, pDrawProps)
end

on render me
  if memberExists(pMemString) then
    me.pBuffer.copyPixels(pCacheRectB, pCacheRectA, pCacheRectB, pDrawProps)
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
  if pAction = "std" then
    pAction = tAct
  end if
end

on defineActMultiple me, tAct, tTargetPartList
  if tTargetPartList.getOne(pPart) then
    if pAction = "std" then
      pAction = tAct
    end if
    if (pPart = "ey") and (tAct = "std") then
      pAction = "std"
    end if
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
  if not me.getProperty(#carrying) then
    return 1
  end if
  if pDirection = me.pFlipList[pDirection + 1] then
    tHandParts = ["rh", "rs", "ri"]
  else
    tHandParts = ["lh", "ls", "li", "ri"]
  end if
  if tHandParts.getPos(pPart) then
    return 0
  else
    return 1
  end if
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
  if not memberExists(pMemString) then
    return 0
  end if
  tmember = member(getmemnum(pMemString))
  tImgRect = tmember.rect
  tCntrPoint = point(tImgRect.width / 2, tImgRect.height / 2)
  tRegPoint = tmember.regPoint
  return -tRegPoint + tCntrPoint
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
  if memberExists(tMemName) then
    tmember = member(getmemnum(tMemName))
    tImage = tmember.image
    tRegPnt = tmember.regPoint
    tX = -tRegPnt[1]
    tY = tImg.rect.height - tRegPnt[2] - 10
    tRect = rect(tX, tY, tX + tImage.width, tY + tImage.height)
    tMatte = tImage.createMatte()
    tImg.copyPixels(tImage, tRect, tImage.rect, [#maskImage: tMatte, #ink: pDrawProps[#ink], #bgColor: pDrawProps[#bgColor]])
    return 1
  end if
  return 0
end

on reset me
  pAction = "std"
  pActionLh = VOID
  pActionRh = VOID
end

on skipAnimationFrame me
  pAnimFrame = pAnimFrame + 1
  if pAnimFrame > pTotalFrame then
    pAnimFrame = 1
  end if
  return 1
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
  if pPart = "ri" then
    if pCacheRectA.width > 0 then
      me.pUpdateRect = union(me.pUpdateRect, pCacheRectA)
      pCacheRectA = rect(0, 0, 0, 0)
    end if
    return EMPTY
  end if
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
  if ["hd", "fc", "ey", "hr"].getOne(pPart) <> 0 then
    if ((tdir = 4) and (pDirection = 3)) or ((tdir = 0) and (pDirection = 7)) then
      pFlipH = 1
    else
      pFlipH = 0
    end if
  else
    pFlipH = 0
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

on flipHorizontal me, tImg
  tImage = image(tImg.width, tImg.height, tImg.depth)
  tQuad = [point(tImg.width, 0), point(0, 0), point(0, tImg.height), point(tImg.width, tImg.height)]
  tImage.copyPixels(tImg, tQuad, tImg.rect)
  return tImage
end
