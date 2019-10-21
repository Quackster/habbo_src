property pAction, pPart, pDirection, ancestor, pCacheDir, pmodel, pMemString, pCacheRectA, pCacheImage, pDrawProps, pCacheRectB

on deconstruct me 
  ancestor = void()
  return TRUE
end

on define me, tPart, tmodel, tPalette, tColor, tDirection, tAction, tAncestor 
  ancestor = tAncestor
  pPart = tPart
  pmodel = tmodel
  pDrawProps = [#maskImage:0, #ink:0, #bgColor:0, #palette:tPalette]
  pCacheImage = 0
  pCacheRectA = rect(0, 0, 0, 0)
  pCacheRectB = rect(0, 0, 0, 0)
  me.defineInk()
  me.setColor(tColor)
  pDirection = tDirection
  pAction = tAction
  pMemString = ""
  pCacheDir = -1
  return TRUE
end

on update me 
  tAnimCntr = 0
  tAction = pAction
  tPart = pPart
  tdir = me.getProp(#pFlipList, (pDirection + 1))
  tUpdate = 0
  tBodyDir = (me.getProp(#pFlipList, (ancestor.pDirection + 1)) + 1)
  if tBodyDir > 4 then
    tBodyDir = 5
  end if
  if integer(me.pXFactor) > 33 then
    tOffsetList = me.pOffsetList
  else
    tOffsetList = me.pOffsetListSmall
  end if
  if (pPart = "bd") then
    if pPart <> "wlk" then
      if pPart <> "jmp" then
        if (pPart = "bnd") then
          tAnimCntr = me.pAnimCounter
        else
          if pPart <> "pla" then
            if (pPart = "scr") then
              tAnimCntr = (1 mod me.pAnimCounter)
            end if
            if pDirection <> pCacheDir then
              tUpdate = 1
            end if
            tXFix = 0
            tYFix = 0
            if (pPart = "hd") then
              if (me.pMainAction = "jmp") or (me.pMainAction = "scr") or (me.pMainAction = "bnd") then
                tXFix = tOffsetList.getAt("hd_" & me.pMainAction & "_" & me.pAnimCounter).getAt(tBodyDir).getAt(1)
                tYFix = tOffsetList.getAt("hd_" & me.pMainAction & "_" & me.pAnimCounter).getAt(tBodyDir).getAt(2)
              else
                tXFix = tOffsetList.getAt("hd_" & me.pMainAction).getAt(tBodyDir).getAt(1)
                tYFix = tOffsetList.getAt("hd_" & me.pMainAction).getAt(tBodyDir).getAt(2)
              end if
              if (tAction = "snf") or (tAction = "eat") or (tAction = "spk") then
                tAnimCntr = (me.pAnimCounter mod 2)
              end if
              tUpdate = 1
            else
              if (pPart = "tl") then
                if (me.pMainAction = "jmp") or (me.pMainAction = "scr") or (me.pMainAction = "bnd") then
                  tXFix = tOffsetList.getAt("tl_" & me.pMainAction & "_" & me.pAnimCounter).getAt(tBodyDir).getAt(1)
                  tYFix = tOffsetList.getAt("tl_" & me.pMainAction & "_" & me.pAnimCounter).getAt(tBodyDir).getAt(2)
                else
                  tXFix = tOffsetList.getAt("tl_" & me.pMainAction).getAt(tBodyDir).getAt(1)
                  tYFix = tOffsetList.getAt("tl_" & me.pMainAction).getAt(tBodyDir).getAt(2)
                end if
                if (tAction = "wav") then
                  tAnimCntr = (me.pAnimCounter mod 2)
                end if
                tUpdate = 1
              end if
            end if
            tPartSize = getVariable("human.size." & integer(ancestor.pXFactor))
            tAnDir = ancestor.pDirection
            if tAnDir > 3 and tAnDir < 7 and (tPartSize = "sh") then
              tXFix = ((tXFix + integer(ancestor.pXFactor)) - 7)
            end if
            tMemString = me.pMemberNamePrefix & tAction & "_" & tPart & "_" & pmodel & "_" & tdir & "_" & tAnimCntr
            tMemNum = getmemnum(tMemString)
            if pMemString <> tMemString or tUpdate then
              if tMemNum > 0 then
                pMemString = tMemString
                tmember = member(tMemNum)
                tRegPnt = tmember.regPoint
                tX = (-tRegPnt.getAt(1) + tXFix)
                tY = (((me.pBuffer.rect.height - tRegPnt.getAt(2)) - 10) + tYFix)
                me.pUpdateRect = union(me.pUpdateRect, pCacheRectA)
                pCacheImage = tmember.image
                pCacheRectA = (rect(tX, tY, (tX + pCacheImage.width), (tY + pCacheImage.height)) + rect(me.pLocFix, me.pLocFix))
                pCacheRectB = pCacheImage.rect
                pDrawProps.setAt(#maskImage, pCacheImage.createMatte())
                me.pUpdateRect = union(me.pUpdateRect, pCacheRectA)
                pCacheDir = pDirection
              else
                if pCacheRectA.width > 0 then
                  me.pUpdateRect = union(me.pUpdateRect, pCacheRectA)
                  pCacheRectA = rect(0, 0, 0, 0)
                end if
                return()
              end if
            end if
            member(tMemNum).paletteRef = member(getmemnum(pDrawProps.getAt(#palette)))
            me.pBuffer.copyPixels(pCacheImage, pCacheRectA, pCacheRectB, pDrawProps)
          end if
        end if
      end if
    end if
  end if
end

on render me 
  if memberExists(pMemString) then
    me.pBuffer.copyPixels(pCacheRectB, pCacheRectA, pCacheRectB, pDrawProps)
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
  if (pAction = "std") then
    pAction = tAct
  end if
end

on defineActMultiple me, tAct, tTargetPartList 
  if tTargetPartList.getOne(pPart) then
    if (pAction = "std") then
      pAction = tAct
    end if
    if (tAct = "std") then
      pAction = "std"
    end if
  end if
end

on defineInk me, tInk 
  if voidp(tInk) then
    if (pPart = "sd") then
      tInk = 32
    else
      tInk = 41
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

on copyPicture me, tImg, tdir, tHumanSize, tAction, tAnimFrame 
  if voidp(tdir) then
    tdir = "2"
  end if
  if voidp(tHumanSize) then
    tHumanSize = "p"
  end if
  if voidp(tAction) then
    tAction = "std"
  end if
  if voidp(tAnimFrame) then
    tAnimFrame = "0"
  end if
  if (tHumanSize = "p") then
    tOffsetList = me.pOffsetList
  else
    tHumanSize = "s_p"
    tOffsetList = me.pOffsetListSmall
  end if
  if (pPart = "bd") then
    tOffX = 0
    tOffY = 0
  else
    tOffX = tOffsetList.getAt(pPart & "_" & tAction).getAt((integer(tdir) + 1)).getAt(1)
    tOffY = tOffsetList.getAt(pPart & "_" & tAction).getAt((integer(tdir) + 1)).getAt(2)
  end if
  tMemName = tHumanSize & "_" & tAction & "_" & pPart & "_" & pmodel & "_" & tdir & "_" & tAnimFrame
  if memberExists(tMemName) then
    tmember = member(getmemnum(tMemName))
    tImage = tmember.image
    tRegPnt = tmember.regPoint
    tX = (-tRegPnt.getAt(1) + tOffX)
    tY = (((tImg.rect.height - tRegPnt.getAt(2)) - 10) + tOffY)
    tRect = rect(tX, tY, (tX + tImage.width), (tY + tImage.height))
    tMatte = tImage.createMatte()
    tmember.paletteRef = member(getmemnum(pDrawProps.getAt(#palette)))
    tImg.copyPixels(tImage, tRect, tImage.rect, [#maskImage:tMatte, #ink:pDrawProps.getAt(#ink), #bgColor:pDrawProps.getAt(#bgColor)])
    return TRUE
  end if
  return FALSE
end

on reset me 
  pAction = "std"
end
