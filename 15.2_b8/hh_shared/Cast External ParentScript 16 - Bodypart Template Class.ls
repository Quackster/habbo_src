property ancestor, pPart, pmodel, pDirection, pDrawProps, pAction, pActionLh, pActionRh, pMemString, pXFix, pYFix, pCacheImage, pCacheRectA, pCacheRectB

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
  defineInk(me)
  setColor(me, tColor)
  pDirection = tDirection
  pAction = tAction
  pActionLh = tAction
  pActionRh = tAction
  pMemString = EMPTY
  pXFix = 0
  pYFix = 0
  return 1
end

on update me
  tAnimCounter = 0
  tAction = pAction
  tPart = pPart
  tdir = me.pFlipList[pDirection + 1]
  pXFix = 0
  pYFix = 0
  case pPart of
    "bd", "lg", "sh":
      if pAction = "wlk" then
        tAnimCounter = me.pAnimCounter
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
        tAnimCounter = me.pAnimCounter
      else
        if tAction = "wav" then
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
        tAnimCounter = me.pAnimCounter
      else
        if tAction = "wav" then
          tAnimCounter = me.pAnimCounter mod 2
          tPart = "l" & pPart.char[2]
          tdir = pDirection
        else
          if tAction = "sig" then
            tAnimCounter = 0
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
        tAnimCounter = me.pAnimCounter mod 2
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
        return 
      end if
      tAction = pActionRh
      tdir = pDirection
    "li":
      tAction = pActionLh
      tdir = pDirection
  end case
  tMemString = me.pPeopleSize & "_" & tAction & "_" & tPart & "_" & pmodel & "_" & tdir & "_" & tAnimCounter
  if pMemString <> tMemString then
    tMemNum = getmemnum(tMemString)
    if tMemNum > 0 then
      pMemString = tMemString
      tmember = member(tMemNum)
      tRegPnt = tmember.regPoint
      tX = -tRegPnt[1]
      tY = me.pBuffer.rect.height - tRegPnt[2] - 10
      me.pUpdateRect = union(me.pUpdateRect, pCacheRectA)
      pCacheImage = tmember.image
      pCacheRectA = rect(tX, tY, tX + pCacheImage.width, tY + pCacheImage.height) + [pXFix, pYFix, pXFix, pYFix] + rect(me.pLocFix, me.pLocFix)
      pCacheRectB = pCacheImage.rect
      pDrawProps[#maskImage] = pCacheImage.createMatte()
      me.pUpdateRect = union(me.pUpdateRect, pCacheRectA)
    else
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
  return (tRegPoint * -1) + tCntrPoint
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
