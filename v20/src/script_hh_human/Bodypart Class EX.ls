property pLayerPropList, pBody, pAction, pPart, pDirection, pAnimList, pFlipPart, pLastLocFix, pXFix, pYFix, pAnimFrame, pTotalFrame, pAnimation, pMemNumCache

on construct me 
  pMemNumCache = [:]
  pLayerPropList = []
end

on clearGraphics me 
  i = 1
  repeat while i <= pLayerPropList.count
    tdata = pLayerPropList.getAt(i)
    pBody.pUpdateRect = union(pBody.pUpdateRect, tdata.getAt("cacheRect"))
    i = 1 + i
  end repeat
end

on resetMemberCache me 
  i = 1
  repeat while i <= pLayerPropList.count
    tdata = pLayerPropList.getAt(i)
    tdata.setAt("memString", "")
    i = 1 + i
  end repeat
end

on define me, tPart, tmodel, tColor, tDirection, tAction, tBody, tFlipPart 
  pBody = tBody
  pPart = tPart
  me.setModel(tmodel)
  me.defineInk()
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
  pFlipPart = ""
  if not voidp(tFlipPart) then
    pFlipPart = tFlipPart
  end if
  return(1)
end

on setAnimations me, tAnimData 
  if ilk(tAnimData) = #propList then
    pAnimList = tAnimData
  end if
end

on update me, tForcedUpdate, tRectMod 
  tAction = pAction
  tPart = pPart
  tdir = pBody.getProp(#pFlipList, pDirection + 1)
  pXFix = 0
  pYFix = 0
  if voidp(tRectMod) then
    tRectMod = rect(0, 0, 0, 0)
  else
    tRectMod = tRectMod.duplicate()
  end if
  tRectModOrig = tRectMod.duplicate()
  i = 1
  repeat while i <= pLayerPropList.count
    tRectMod = tRectModOrig.duplicate()
    tdata = pLayerPropList.getAt(i)
    tmodel = tdata.getAt("model")
    tDrawProps = tdata.getAt("drawProps")
    tFlipHOld = tdata.getAt("flipH")
    if pBody.pAnimating then
      tMemString = me.animate(i)
    else
      if pDirection = tdir then
        tdata.setAt("flipH", 0)
      else
        tdata.setAt("flipH", 1)
      end if
      tAnimCntr = 0
      if not voidp(pAnimList.getAt(pAction)) then
        if pAnimList.getAt(pAction).count > 0 then
          tIndex = (pBody.pAnimCounter mod pAnimList.getAt(pAction).count)
          tAnimCntr = pAnimList.getAt(pAction).getAt(tIndex + 1)
        end if
      end if
      if pFlipPart <> "" then
        tMemString = pBody.pPeopleSize & "_" & tAction & "_" & tPart & "_" & tmodel & "_" & pDirection & "_" & tAnimCntr
        tMemNum = me.getMemNumFast(tMemString)
        if tMemNum > 0 then
          tdir = pDirection
          tdata.setAt("flipH", 0)
        else
          if pDirection <> tdir then
            tPart = pFlipPart
          end if
        end if
      end if
      tMemString = pBody.pPeopleSize & "_" & tAction & "_" & tPart & "_" & tmodel & "_" & tdir & "_" & tAnimCntr
    end if
    if tFlipHOld <> tdata.getAt("flipH") then
      tForcedUpdate = 1
    end if
    tLocFixChanged = pLastLocFix <> point(pXFix + tRectMod.getAt(1), pYFix + tRectMod.getAt(2))
    pLastLocFix = point(pXFix + tRectMod.getAt(1), pYFix + tRectMod.getAt(2))
    if tdata.getAt("memString") <> tMemString or tLocFixChanged or tForcedUpdate then
      tdata.setAt("memString", tMemString)
      tMemNum = me.getMemNumFast(tMemString)
      if tMemNum > 0 then
        tmember = member(tMemNum)
        tRegPnt = tmember.regPoint
        tX = -tRegPnt.getAt(1)
        tY = rect.height - tRegPnt.getAt(2) - 20
        pBody.pUpdateRect = union(pBody.pUpdateRect, tdata.getAt("cacheRect"))
        tdata.setAt("cacheImage", tmember.image)
        tLocFix = pLocFix.duplicate()
        if tdata.getAt("flipH") then
          tX = pBuffer.width - tX + tmember.width
          tLocFix.setAt(1, -tLocFix.getAt(1))
          if pBody.pPeopleSize = "sh" then
            tX = tX - 2
          end if
          tRectMod.setAt(1, -tRectMod.getAt(1))
          tRectMod.setAt(3, -tRectMod.getAt(3))
        end if
        tdata.setAt("cacheRect", rect(tX, tY, tX + tdata.getAt("cacheImage").width, tY + tdata.getAt("cacheImage").height))
        tdata.setAt("cacheRect", tdata.getAt("cacheRect") + [pXFix, pYFix, pXFix, pYFix] + rect(tLocFix, tLocFix) + tRectMod)
        tDrawProps.setAt(#maskImage, tdata.getAt("cacheImage").createMatte())
        pBody.pUpdateRect = union(pBody.pUpdateRect, tdata.getAt("cacheRect"))
      else
        pBody.pUpdateRect = union(pBody.pUpdateRect, tdata.getAt("cacheRect"))
        tdata.setAt("cacheRect", rect(0, 0, 0, 0))
        tdata.setAt("cacheImage", 0)
      end if
    end if
    tDrawArea = me.getDrawArea(i)
    if tdata.getAt("cacheImage") <> 0 then
      pBuffer.copyPixels(tdata.getAt("cacheImage"), tDrawArea, tdata.getAt("cacheImage").rect, tDrawProps)
    end if
    i = 1 + i
  end repeat
end

on render me 
  i = 1
  repeat while i <= me.count(#pLayerPropList)
    tdata = me.getProp(#pLayerPropList, i)
    if memberExists(tdata.getAt("memString")) then
      tDrawArea = me.getDrawArea(i)
      if tdata.getAt("cacheImage") <> 0 then
        pBuffer.copyPixels(tdata.getAt("cacheImage"), tDrawArea, tdata.getAt("cacheImage").rect, tdata.getAt("drawProps"))
      end if
    end if
    i = 1 + i
  end repeat
end

on defineDir me, tdir, tPart 
  if voidp(tPart) or tPart = pPart then
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

on defineInk me, tInk 
  if voidp(tInk) then
    if pPart = "ey" then
      tInk = 36
    else
      if pPart = "ri" then
        tInk = 8
      else
        if pPart = "li" then
          tInk = 8
        else
          tInk = 41
        end if
      end if
    end if
  end if
  i = 1
  repeat while i <= pLayerPropList.count
    tDrawProps = pLayerPropList.getAt(i).getAt("drawProps")
    tDrawProps.setAt(#ink, tInk)
    i = 1 + i
  end repeat
  return(1)
end

on setModel me, tmodel 
  if ilk(tmodel) <> #list then
    tmodel = [tmodel]
  end if
  me.clearGraphics()
  pLayerPropList = []
  i = 1
  repeat while i <= tmodel.count
    tdata = [:]
    tdata.setAt("model", tmodel.getAt(i))
    tdata.setAt("flipH", 0)
    tdata.setAt("cacheImage", 0)
    tdata.setAt("cacheRect", rect(0, 0, 0, 0))
    tdata.setAt("drawProps", [#maskImage:0, #ink:0, #bgColor:0])
    tdata.setAt("memString", "")
    pLayerPropList.add(tdata)
    i = 1 + i
  end repeat
  me.defineInk()
end

on setColor me, tColorList 
  if voidp(tColorList) then
    return(0)
  end if
  if tColorList = "" then
    return(0)
  end if
  if ilk(tColorList) <> #list then
    tColorList = [tColorList]
  end if
  i = 1
  repeat while i <= pLayerPropList.count
    if tColorList.count < i then
      tColor = tColorList.getAt(1)
    else
      tColor = tColorList.getAt(i)
    end if
    tDrawProps = pLayerPropList.getAt(i).getAt("drawProps")
    if tColor.ilk = #color and tDrawProps.getAt(#ink) <> 36 then
      tDrawProps.setAt(#bgColor, tColor)
    else
      tDrawProps.setAt(#bgColor, rgb(255, 255, 255))
    end if
    i = 1 + i
  end repeat
  return(1)
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

on getColor me 
  i = 1
  repeat while i <= pLayerPropList.count
    tDrawProps = pLayerPropList.getAt(1).getAt("drawProps")
    if tDrawProps.getAt(#bgColor) <> rgb(255, 255, 255) then
      return(tDrawProps.getAt(#bgColor))
    end if
    i = 1 + i
  end repeat
  return(rgb(255, 255, 255))
end

on getDirection me 
  return(pDirection)
end

on getModel me 
  tmodel = []
  i = 1
  repeat while i <= pLayerPropList.count
    tmodel.add(pLayerPropList.getAt(i).getAt("model"))
    i = 1 + i
  end repeat
  return(tmodel)
end

on getLocation me 
  if pLayerPropList.count < 1 then
    return(0)
  end if
  tMemString = pLayerPropList.getAt(1).getAt("memString")
  if voidp(tMemString) then
    return(0)
  end if
  if not memberExists(tMemString) then
    return(0)
  end if
  tmember = member(getmemnum(tMemString))
  tImgRect = tmember.rect
  tCntrPoint = point((tImgRect.width / 2), (tImgRect.height / 2))
  tRegPoint = tmember.regPoint
  return(-tRegPoint + tCntrPoint)
end

on getPartID me 
  return(pPart)
end

on copyPicture me, tImg, tdir, tHumanSize, tAction, tAnimFrame 
  i = 1
  repeat while i <= pLayerPropList.count
    tArray = me.getMemberNumber(tdir, tHumanSize, tAction, tAnimFrame, i)
    tMemNum = tArray.getAt(#memberNumber)
    tFlip = tArray.getAt(#flip)
    tInk = pLayerPropList.getAt(i).getAt("drawProps").getAt(#ink)
    tColor = pLayerPropList.getAt(i).getAt("drawProps").getAt(#bgColor)
    if tMemNum <> 0 then
      tmember = member(tMemNum)
      tImage = tmember.image
      tRegPnt = tmember.regPoint
      tY = rect.height - tRegPnt.getAt(2) - 10
      tX = -tRegPnt.getAt(1)
      tRect = rect(tX, tY, tX + tImage.width, tY + tImage.height)
      if tFlip then
        tRect = rect(tImg.width - tX + tImage.width, tY, tImg.width - tX, tY + tImage.height)
        tQuad = [point(tRect.getAt(3), tRect.getAt(2)), point(tRect.getAt(1), tRect.getAt(2)), point(tRect.getAt(1), tRect.getAt(4)), point(tRect.getAt(3), tRect.getAt(4))]
        tRect = tQuad
      end if
      tMatte = tImage.createMatte()
      tImg.copyPixels(tImage, tRect, tImage.rect, [#maskImage:tMatte, #ink:tInk, #bgColor:tColor])
    end if
    i = 1 + i
  end repeat
  return(1)
end

on reset me 
  pAction = "std"
end

on skipAnimationFrame me 
  pAnimFrame = pAnimFrame + 1
  if pAnimFrame > pTotalFrame then
    pAnimFrame = 1
  end if
  return(1)
end

on changePartData me, tmodel, tColor 
  if voidp(tmodel) or voidp(tColor) then
    return(0)
  end if
  me.setModel(tmodel)
  me.setColor(tColor)
  i = 1
  repeat while i <= pLayerPropList.count
    tMemString = pLayerPropList.getAt(i).getAt("memString")
    tMemNameList = explode(tMemString, "_")
    tMemNameList.setAt(4, tmodel)
    pLayerPropList.getAt(i).setAt("memString", implode(tMemNameList, "_"))
    i = 1 + i
  end repeat
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

on animate me, tLayerIndex 
  if not pAnimation then
    return("")
  end if
  if voidp(tLayerIndex) then
    tLayerIndex = 1
  end if
  if tLayerIndex < 1 or tLayerIndex > pLayerPropList.count then
    return("")
  end if
  tdata = pLayerPropList.getAt(tLayerIndex)
  tmodel = tdata.getAt("model")
  tdir = pDirection + pAnimation.getAt(#OffD).getAt(pAnimFrame)
  if tdir > 7 then
    tdir = min(tdir - 8, 7)
  else
    if tdir < 0 then
      tdir = max(7 + tdir + 1, 0)
    end if
  end if
  tPart = pPart
  if tdir <> pBody.getProp(#pFlipList, tdir + 1) then
    tDirOrig = tdir
    tdir = pBody.getProp(#pFlipList, tdir + 1)
    tdata.setAt("flipH", 1)
    if pFlipPart <> "" then
      tMemString = pBody.pPeopleSize & "_" & pAnimation.getAt(#act).getAt(pAnimFrame) & "_" & tPart & "_" & tmodel & "_" & tDirOrig & "_" & pAnimation.getAt(#frm).getAt(pAnimFrame)
      tMemNum = me.getMemNumFast(tMemString)
      if tMemNum > 0 then
        tdir = tDirOrig
        tdata.setAt("flipH", 0)
      else
        tPart = pFlipPart
      end if
    end if
  else
    tdata.setAt("flipH", 0)
  end if
  pXFix = pAnimation.getAt(#OffX).getAt(pAnimFrame)
  pYFix = pAnimation.getAt(#OffY).getAt(pAnimFrame)
  if pBody.pDirection = 0 then
    pYFix = pYFix + (pXFix / 2)
    pXFix = (pXFix / 2)
  else
    if pBody.pDirection = 1 then
      pYFix = pYFix + pXFix
      pXFix = 0
    else
      if pBody.pDirection = 2 then
        pYFix = pYFix - (pXFix / 2)
        pXFix = (pXFix / 2)
      else
        if pBody.pDirection = 4 then
          pYFix = pYFix + (pXFix / 2)
          pXFix = (-pXFix / 2)
        else
          if pBody.pDirection = 5 then
            pYFix = pYFix - pXFix
            pXFix = 0
          else
            if pBody.pDirection = 6 then
              pYFix = pYFix - (pXFix / 2)
              pXFix = (-pXFix / 2)
            else
              if pBody.pDirection = 7 then
                pXFix = -pXFix
              end if
            end if
          end if
        end if
      end if
    end if
  end if
  if pBody.pPeopleSize = "sh" then
    tSizeMultiplier = 0.7
  else
    tSizeMultiplier = 1
  end if
  pXFix = (pXFix * tSizeMultiplier)
  pYFix = (pYFix * tSizeMultiplier)
  tMemName = pBody.pPeopleSize & "_" & pAnimation.getAt(#act).getAt(pAnimFrame) & "_" & tPart & "_" & tmodel & "_" & tdir & "_" & pAnimation.getAt(#frm).getAt(pAnimFrame)
  pAnimFrame = pAnimFrame + 1
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

on getMemberNumber me, tdir, tHumanSize, tAction, tAnimFrame, tLayerIndex, tmodel 
  tFlip = 0
  if not voidp(tdir) then
    if tdir > 0 and tdir < pBody.count(#pFlipList) then
      if tdir <> pBody.getProp(#pFlipList, tdir + 1) then
        tdir = pBody.getProp(#pFlipList, tdir + 1)
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
  if tLayerIndex < 1 or tLayerIndex > pLayerPropList.count then
    tLayerIndex = 1
  end if
  if voidp(tmodel) then
    if pLayerPropList.count >= tLayerIndex then
      tmodel = pLayerPropList.getAt(tLayerIndex).getAt("model")
    else
      tmodel = ""
    end if
  end if
  tPart = pPart
  if pFlipPart <> "" and tFlip = 1 then
    tPart = pFlipPart
  end if
  tMemName = tHumanSize & "_" & tAction & "_" & tPart & "_" & tmodel & "_" & tdir & "_" & tAnimFrame
  tNum = me.getMemNumFast(tMemName)
  return([#memberNumber:tNum, #flip:tFlip])
end

on getDrawArea me, tLayerIndex 
  if tLayerIndex < 1 or tLayerIndex > pLayerPropList.count then
    return(rect(0, 0, 0, 0))
  end if
  tdata = pLayerPropList.getAt(tLayerIndex)
  tRect = tdata.getAt("cacheRect")
  if tdata.getAt("flipH") then
    tDrawArea = [point(tRect.getAt(3), tRect.getAt(2)), point(tRect.getAt(1), tRect.getAt(2)), point(tRect.getAt(1), tRect.getAt(4)), point(tRect.getAt(3), tRect.getAt(4))]
  else
    tDrawArea = tRect
  end if
  return(tDrawArea.duplicate())
end

on getMemNumFast me, tName 
  tNum = pMemNumCache.getAt(tName)
  if voidp(tNum) then
    tNum = getmemnum(tName)
    pMemNumCache.addProp(tName, tNum)
    if pMemNumCache.count > 20 then
      pMemNumCache.deleteAt(1)
    end if
  end if
  return(tNum)
end
