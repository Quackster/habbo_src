property pAction, pPart, pBody, pDirection, pFlipH, pYFix, pXFix, pAnimList, pFlipPart, pmodel, pCacheRectA, pLastLocFix, pMemString, pCacheImage, pDrawProps, pCacheRectB, pAnimFrame, pTotalFrame, pAnimation

on define me, tPart, tmodel, tColor, tDirection, tAction, tBody, tFlipPart 
  pBody = tBody
  pPart = tPart
  pmodel = tmodel
  pDrawProps = [#maskImage:0, #ink:0, #bgColor:0]
  pCacheImage = 0
  pCacheRectA = rect(0, 0, 0, 0)
  pCacheRectB = rect(0, 0, 0, 0)
  me.defineInk()
  me.setColor(tColor)
  pDirection = tDirection
  pAction = tAction
  pMemString = ""
  pXFix = 0
  pYFix = 0
  pFlipH = 0
  pLastLocFix = point(1000, 1000)
  pAnimation = 0
  pAnimFrame = 1
  pTotalFrame = 1
  pAnimList = [:]
  pFlipPart = ""
  if not voidp(tFlipPart) then
    pFlipPart = tFlipPart
  end if
  return TRUE
end

on setAnimations me, tAnimData 
  if (ilk(tAnimData) = #propList) then
    pAnimList = tAnimData
  end if
end

on update me, tForcedUpdate, tRectMod 
  tAnimCntr = 0
  tAction = pAction
  tPart = pPart
  tdir = pBody.getProp(#pFlipList, (pDirection + 1))
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
    if (pBody.pDirection = 0) then
      pYFix = (pYFix + (pXFix / 2))
      pXFix = (pXFix / 2)
    else
      if (pBody.pDirection = 1) then
        pYFix = (pYFix + pXFix)
        pXFix = 0
      else
        if (pBody.pDirection = 2) then
          pYFix = (pYFix - (pXFix / 2))
          pXFix = (pXFix / 2)
        else
          if (pBody.pDirection = 4) then
            pYFix = (pYFix + (pXFix / 2))
            pXFix = (-pXFix / 2)
          else
            if (pBody.pDirection = 5) then
              pYFix = (pYFix - pXFix)
              pXFix = 0
            else
              if (pBody.pDirection = 6) then
                pYFix = (pYFix - (pXFix / 2))
                pXFix = (-pXFix / 2)
              else
                if (pBody.pDirection = 7) then
                  pXFix = -pXFix
                end if
              end if
            end if
          end if
        end if
      end if
    end if
    if (pBody.pPeopleSize = "sh") then
      tSizeMultiplier = 0.7
    else
      tSizeMultiplier = 1
    end if
    pXFix = (pXFix * tSizeMultiplier)
    pYFix = (pYFix * tSizeMultiplier)
  else
    if (pDirection = tdir) then
      pFlipH = 0
    else
      pFlipH = 1
    end if
    if not voidp(pAnimList.getAt(pAction)) then
      if pAnimList.getAt(pAction).count > 0 then
        tIndex = (pBody.pAnimCounter mod pAnimList.getAt(pAction).count)
        tAnimCntr = pAnimList.getAt(pAction).getAt((tIndex + 1))
      end if
    end if
    if pFlipPart <> "" then
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
    if (pBody.pDirection = "ey") then
      if pBody.pTalking then
        if pAction <> "lay" and ((pBody.pAnimCounter mod 2) = 0) then
          pYFix = -1
        end if
      end if
    else
      if (pBody.pDirection = "ri") then
        if not pBody.pCarrying then
          pMemString = ""
          if pCacheRectA.width > 0 then
            pBody.pUpdateRect = union(pBody.pUpdateRect, pCacheRectA)
            pCacheRectA = rect(0, 0, 0, 0)
          end if
          return()
        end if
      end if
    end if
    tMemString = pBody.pPeopleSize & "_" & tAction & "_" & tPart & "_" & pmodel & "_" & tdir & "_" & tAnimCntr
  end if
  if tFlipHOld <> pFlipH then
    tForcedUpdate = 1
  end if
  tLocFixChanged = pLastLocFix <> point(pXFix, pYFix)
  pLastLocFix = point(pXFix, pYFix)
  if pMemString <> tMemString or tLocFixChanged or tForcedUpdate then
    pMemString = tMemString
    tMemNum = getmemnum(tMemString)
    if tMemNum > 0 then
      tmember = member(tMemNum)
      tRegPnt = tmember.regPoint
      tX = -tRegPnt.getAt(1)
      tY = ((pBody.pBuffer.rect.height - tRegPnt.getAt(2)) - 10)
      pBody.pUpdateRect = union(pBody.pUpdateRect, pCacheRectA)
      pCacheImage = tmember.image
      tLocFix = pBody.pLocFix
      pCacheRectB = pCacheImage.rect
      if pFlipH then
        tX = ((-tX - tmember.width) + pBody.pBuffer.width)
        tLocFix = point(-pBody.getProp(#pLocFix, 1), pBody.getProp(#pLocFix, 2))
        if (pBody.pPeopleSize = "sh") then
          tX = (tX - 2)
        end if
        tRectMod.setAt(1, -tRectMod.getAt(1))
        tRectMod.setAt(3, -tRectMod.getAt(3))
        pCacheRectA = ((rect(tX, tY, (tX + pCacheImage.width), (tY + pCacheImage.height)) + [pXFix, pYFix, pXFix, pYFix]) + rect(tLocFix, tLocFix))
      else
        pCacheRectA = ((rect(tX, tY, (tX + pCacheImage.width), (tY + pCacheImage.height)) + [pXFix, pYFix, pXFix, pYFix]) + rect(tLocFix, tLocFix))
      end if
      pCacheRectA = (pCacheRectA + tRectMod)
      pDrawProps.setAt(#maskImage, pCacheImage.createMatte())
      pBody.pUpdateRect = union(pBody.pUpdateRect, pCacheRectA)
    else
      pBody.pUpdateRect = union(pBody.pUpdateRect, pCacheRectA)
      pCacheRectA = rect(0, 0, 0, 0)
      return()
    end if
  end if
  if pFlipH then
    tDrawRect = pCacheRectA
    tQuad = [point(tDrawRect.getAt(3), tDrawRect.getAt(2)), point(tDrawRect.getAt(1), tDrawRect.getAt(2)), point(tDrawRect.getAt(1), tDrawRect.getAt(4)), point(tDrawRect.getAt(3), tDrawRect.getAt(4))]
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
      tQuad = [point(tDrawRect.getAt(3), tDrawRect.getAt(2)), point(tDrawRect.getAt(1), tDrawRect.getAt(2)), point(tDrawRect.getAt(1), tDrawRect.getAt(4)), point(tDrawRect.getAt(3), tDrawRect.getAt(4))]
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
    if (pPart = "ey") then
      tInk = 36
    else
      if (pPart = "sd") then
        tInk = 32
      else
        if (pPart = "ri") then
          tInk = 8
        else
          if (pPart = "li") then
            tInk = 8
          else
            tInk = 41
          end if
        end if
      end if
    end if
  end if
  pDrawProps.setAt(#ink, tInk)
  return TRUE
end

on setModel me, tmodel 
  pmodel = tmodel
end

on setColor me, tColor 
  if voidp(tColor) then
    return FALSE
  end if
  if (tColor = "") then
    return FALSE
  end if
  if (tColor.ilk = #color) and pDrawProps.getAt(#ink) <> 36 then
    pDrawProps.setAt(#bgColor, tColor)
  else
    pDrawProps.setAt(#bgColor, rgb(255, 255, 255))
  end if
  return TRUE
end

on checkPartNotCarrying me 
  return(not pBody.getPartCarrying(pPart))
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
  return(pMemString)
end

on getColor me 
  return(pDrawProps.getAt(#bgColor))
end

on getDirection me 
  return(pDirection)
end

on getModel me 
  return(pmodel)
end

on getLocation me 
  if voidp(pMemString) then
    return FALSE
  end if
  if not memberExists(pMemString) then
    return FALSE
  end if
  tmember = member(getmemnum(pMemString))
  tImgRect = tmember.rect
  tCntrPoint = point((tImgRect.width / 2), (tImgRect.height / 2))
  tRegPoint = tmember.regPoint
  return((-tRegPoint + tCntrPoint))
end

on getPartID me 
  return(pPart)
end

on copyPicture me, tImg, tdir, tHumanSize, tAction, tAnimFrame 
  tArray = me.getMemberNumber(tdir, tHumanSize, tAction, tAnimFrame)
  tMemNum = tArray.getAt(#memberNumber)
  tFlip = tArray.getAt(#flip)
  if tMemNum <> 0 then
    tmember = member(tMemNum)
    tImage = tmember.image
    tRegPnt = tmember.regPoint
    tY = ((tImg.rect.height - tRegPnt.getAt(2)) - 10)
    tX = -tRegPnt.getAt(1)
    tRect = rect(tX, tY, (tX + tImage.width), (tY + tImage.height))
    if tFlip then
      tRect = rect((tImg.width - (tX + tImage.width)), tY, (tImg.width - tX), (tY + tImage.height))
      tQuad = [point(tRect.getAt(3), tRect.getAt(2)), point(tRect.getAt(1), tRect.getAt(2)), point(tRect.getAt(1), tRect.getAt(4)), point(tRect.getAt(3), tRect.getAt(4))]
      tRect = tQuad
    end if
    tMatte = tImage.createMatte()
    tImg.copyPixels(tImage, tRect, tImage.rect, [#maskImage:tMatte, #ink:pDrawProps.getAt(#ink), #bgColor:pDrawProps.getAt(#bgColor)])
    return TRUE
  end if
  return FALSE
end

on reset me 
  pAction = "std"
end

on skipAnimationFrame me 
  pAnimFrame = (pAnimFrame + 1)
  if pAnimFrame > pTotalFrame then
    pAnimFrame = 1
  end if
  return TRUE
end

on changePartData me, tmodel, tColor 
  if voidp(tmodel) or voidp(tColor) then
    return FALSE
  end if
  pmodel = tmodel
  pDrawProps.setAt(#bgColor, tColor)
  tMemNameList = explode(pMemString, "_")
  tMemNameList.setAt(4, tmodel)
  pMemString = implode(tMemNameList, "_")
  tForced = 1
  me.update(tForced)
end

on setAnimation me, tPart, tAnim 
  if tPart <> pPart then
    return()
  end if
  pAnimation = value(tAnim)
  pTotalFrame = pAnimation.getAt(1).count
  pAnimFrame = 1
end

on remAnimation me 
  pAnimation = 0
  pAnimFrame = 1
  pTotalFrame = 1
end

on animate me 
  if not pAnimation then
    return("")
  end if
  tdir = (pDirection + pAnimation.getAt(#OffD).getAt(pAnimFrame))
  if tdir > 7 then
    tdir = min((tdir - 8), 7)
  else
    if tdir < 0 then
      tdir = max(((7 + tdir) + 1), 0)
    end if
  end if
  tPart = pPart
  if tdir <> pBody.getProp(#pFlipList, (tdir + 1)) then
    tDirOrig = tdir
    tdir = pBody.getProp(#pFlipList, (tdir + 1))
    pFlipH = 1
    if pFlipPart <> "" then
      tMemString = pBody.pPeopleSize & "_" & pAnimation.getAt(#act).getAt(pAnimFrame) & "_" & tPart & "_" & pmodel & "_" & tDirOrig & "_" & pAnimation.getAt(#frm).getAt(pAnimFrame)
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
  pXFix = pAnimation.getAt(#OffX).getAt(pAnimFrame)
  pYFix = pAnimation.getAt(#OffY).getAt(pAnimFrame)
  tMemName = pBody.pPeopleSize & "_" & pAnimation.getAt(#act).getAt(pAnimFrame) & "_" & tPart & "_" & pmodel & "_" & tdir & "_" & pAnimation.getAt(#frm).getAt(pAnimFrame)
  pAnimFrame = (pAnimFrame + 1)
  if pAnimFrame > pTotalFrame then
    pAnimFrame = 1
  end if
  return(tMemName)
end

on flipHorizontal me, tImg 
  tImage = image(tImg.width, tImg.height, tImg.depth)
  tQuad = [point(tImg.width, 0), point(0, 0), point(0, tImg.height), point(tImg.width, tImg.height)]
  tImage.copyPixels(tImg, tQuad, tImg.rect)
  return(tImage)
end

on getMemberNumber me, tdir, tHumanSize, tAction, tAnimFrame, tmodel 
  tFlip = 0
  if not voidp(tdir) then
    if tdir > 0 and tdir < pBody.count(#pFlipList) then
      if tdir <> pBody.getProp(#pFlipList, (tdir + 1)) then
        tdir = pBody.getProp(#pFlipList, (tdir + 1))
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
  if pFlipPart <> "" and (tFlip = 1) then
    tPart = pFlipPart
  end if
  tMemName = tHumanSize & "_" & tAction & "_" & tPart & "_" & tmodel & "_" & tdir & "_" & tAnimFrame
  tNum = getmemnum(tMemName)
  return([#memberNumber:tNum, #flip:tFlip])
end
