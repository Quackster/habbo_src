on deconstruct(me)
  ancestor = void()
  return(1)
  exit
end

on define(me, tPart, tmodel, tPalette, tColor, tDirection, tAction, tAncestor)
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
  return(1)
  exit
end

on update(me)
  tAnimCntr = 0
  tAction = pAction
  tPart = pPart
  tdir = me.getProp(#pFlipList, pDirection + 1)
  tUpdate = 0
  tBodyDir = me.getProp(#pFlipList, ancestor.pDirection + 1) + 1
  if tBodyDir > 4 then
    tBodyDir = 5
  end if
  if me = "bd" then
    if me <> "wlk" then
      if me <> "jmp" then
        if me = "bnd" then
          tAnimCntr = me.pAnimCounter
        else
          if me <> "pla" then
            if me = "scr" then
              tAnimCntr = 1 mod me.pAnimCounter
            end if
            tXFix = 0
            tYFix = 0
            if me = "hd" then
              if me.pMainAction = "jmp" or me.pMainAction = "scr" or me.pMainAction = "bnd" then
                tXFix = me.getPropRef(#pOffsetList, "hd_" & me.pMainAction & "_" & me.pAnimCounter).getAt(tBodyDir).getAt(1)
                tYFix = me.getPropRef(#pOffsetList, "hd_" & me.pMainAction & "_" & me.pAnimCounter).getAt(tBodyDir).getAt(2)
              else
                tXFix = me.getPropRef(#pOffsetList, "hd_" & me.pMainAction).getAt(tBodyDir).getAt(1)
                tYFix = me.getPropRef(#pOffsetList, "hd_" & me.pMainAction).getAt(tBodyDir).getAt(2)
              end if
              if tAction = "snf" or tAction = "eat" or tAction = "spk" then
                tAnimCntr = me.pAnimCounter mod 2
              end if
              tUpdate = 1
            else
              if me = "tl" then
                if me.pMainAction = "jmp" or me.pMainAction = "scr" or me.pMainAction = "bnd" then
                  tXFix = me.getPropRef(#pOffsetList, "tl_" & me.pMainAction & "_" & me.pAnimCounter).getAt(tBodyDir).getAt(1)
                  tYFix = me.getPropRef(#pOffsetList, "tl_" & me.pMainAction & "_" & me.pAnimCounter).getAt(tBodyDir).getAt(2)
                else
                  tXFix = me.getPropRef(#pOffsetList, "tl_" & me.pMainAction).getAt(tBodyDir).getAt(1)
                  tYFix = me.getPropRef(#pOffsetList, "tl_" & me.pMainAction).getAt(tBodyDir).getAt(2)
                end if
                if tAction = "wav" then
                  tAnimCntr = me.pAnimCounter mod 2
                end if
                tUpdate = 1
              end if
            end if
            tMemString = "p_" & tAction & "_" & tPart & "_" & pmodel & "_" & tdir & "_" & tAnimCntr
            tMemNum = getmemnum(tMemString)
            if pMemString <> tMemString or tUpdate then
              if tMemNum > 0 then
                pMemString = tMemString
                tmember = member(tMemNum)
                tRegPnt = tmember.regPoint
                tX = -tRegPnt.getAt(1) + tXFix
                tY = rect.height - tRegPnt.getAt(2) - 10 + tYFix
                me.pUpdateRect = union(me.pUpdateRect, pCacheRectA)
                pCacheImage = tmember.image
                pCacheRectA = rect(tX, tY, tX + pCacheImage.width, tY + pCacheImage.height) + rect(me.pLocFix, me.pLocFix)
                pCacheRectB = pCacheImage.rect
                pDrawProps.setAt(#maskImage, pCacheImage.createMatte())
                me.pUpdateRect = union(me.pUpdateRect, pCacheRectA)
              else
                if pCacheRectA.width > 0 then
                  me.pUpdateRect = union(me.pUpdateRect, pCacheRectA)
                  pCacheRectA = rect(0, 0, 0, 0)
                end if
                return()
              end if
            end if
            member(tMemNum).paletteRef = member(getmemnum(pDrawProps.getAt(#palette)))
            me.copyPixels(pCacheImage, pCacheRectA, pCacheRectB, pDrawProps)
            exit
          end if
        end if
      end if
    end if
  end if
end

on render(me)
  if memberExists(pMemString) then
    me.copyPixels(pCacheRectB, pCacheRectA, pCacheRectB, pDrawProps)
  end if
  exit
end

on defineDir(me, tdir, tPart)
  if voidp(tPart) or tPart = pPart then
    pDirection = tdir
  end if
  exit
end

on defineDirMultiple(me, tdir, tTargetPartList)
  if tTargetPartList.getOne(pPart) then
    pDirection = tdir
  end if
  exit
end

on defineAct(me, tAct, tTargetPartList)
  if pAction = "std" then
    pAction = tAct
  end if
  exit
end

on defineActMultiple(me, tAct, tTargetPartList)
  if tTargetPartList.getOne(pPart) then
    if pAction = "std" then
      pAction = tAct
    end if
    if tAct = "std" then
      pAction = "std"
    end if
  end if
  exit
end

on defineInk(me, tInk)
  if voidp(tInk) then
    if me = "sd" then
      tInk = 32
    else
      tInk = 41
    end if
  end if
  pDrawProps.setAt(#ink, tInk)
  return(1)
  exit
end

on setModel(me, tmodel)
  pmodel = tmodel
  exit
end

on setColor(me, tColor)
  if voidp(tColor) then
    return(0)
  end if
  if tColor = "" then
    return(0)
  end if
  if tColor.ilk = #color and pDrawProps.getAt(#ink) <> 36 then
    pDrawProps.setAt(#bgColor, tColor)
  else
    pDrawProps.setAt(#bgColor, rgb(255, 255, 255))
  end if
  return(1)
  exit
end

on layDown(me)
  pAction = "lay"
  exit
end

on getCurrentMember(me)
  return(pMemString)
  exit
end

on getColor(me)
  return(pDrawProps.getAt(#bgColor))
  exit
end

on getDirection(me)
  return(pDirection)
  exit
end

on copyPicture(me, tImg, tdir, tHumanSize, tAction, tAnimFrame)
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
  if pPart = "bd" then
    tOffX = 0
    tOffY = 0
  else
    tOffX = me.getPropRef(#pOffsetList, pPart & "_" & tAction).getAt(integer(tdir) + 1).getAt(1)
    tOffY = me.getPropRef(#pOffsetList, pPart & "_" & tAction).getAt(integer(tdir) + 1).getAt(2)
  end if
  tMemName = tHumanSize & "_" & tAction & "_" & pPart & "_" & pmodel & "_" & tdir & "_" & tAnimFrame
  if memberExists(tMemName) then
    tmember = member(getmemnum(tMemName))
    tImage = tmember.image
    tRegPnt = tmember.regPoint
    tX = -tRegPnt.getAt(1) + tOffX
    tY = rect.height - tRegPnt.getAt(2) - 10 + tOffY
    tRect = rect(tX, tY, tX + tImage.width, tY + tImage.height)
    tMatte = tImage.createMatte()
    tmember.paletteRef = member(getmemnum(pDrawProps.getAt(#palette)))
    tImg.copyPixels(tImage, tRect, tImage.rect, [#maskImage:tMatte, #ink:pDrawProps.getAt(#ink), #bgColor:pDrawProps.getAt(#bgColor)])
    return(1)
  end if
  return(0)
  exit
end

on reset(me)
  pAction = "std"
  exit
end