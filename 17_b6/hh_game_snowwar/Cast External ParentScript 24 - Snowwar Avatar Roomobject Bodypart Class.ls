on changePartData me, tmodel, tColor
  if me.pPart = "bd" then
    return 1
  end if
  return me.ancestor.changePartData(tmodel, tColor)
end

on defineActExplicit me, tAct, tTargetPartList
  if tTargetPartList.getOne(me.pPart) then
    me.pAction = tAct
  end if
end

on update me
  tAnimCntr = 0
  tAction = me.pAction
  tPart = me.pPart
  tdir = me.pFlipList[me.pDirection + 1]
  case me.pPart of
    "bd", "lg", "sh":
      if me.pAction = "wlk" then
        tAnimCntr = me.pAnimCounter
      end if
    "lh", "ls":
      if me.pDirection = tdir then
        if not voidp(me.pActionLh) then
          tAction = me.pActionLh
        end if
      else
        if not voidp(me.pActionRh) then
          tAction = me.pActionRh
        end if
      end if
      if tAction = "wlk" then
        tAnimCntr = me.pAnimCounter
      else
        if tAction = "wav" then
          tAnimCntr = me.pAnimCounter mod 2
        else
          if ["crr", "drk", "ohd"].getPos(tAction) <> 0 then
            if me.pDirection >= 4 then
              me.pXFix = -40
              tPart = "r" & me.pPart.char[2]
            end if
            tdir = me.pDirection
          end if
        end if
      end if
    "rh", "rs":
      if me.pDirection = tdir then
        if not voidp(me.pActionRh) then
          tAction = me.pActionRh
        end if
      else
        if not voidp(me.pActionLh) then
          tAction = me.pActionLh
        end if
      end if
      if tAction = "wlk" then
        tAnimCntr = me.pAnimCounter
      else
        if tAction = "wav" then
          tAnimCntr = me.pAnimCounter mod 2
          tPart = "l" & me.pPart.char[2]
          tdir = me.pDirection
        else
          if tAction = "sig" then
            tAnimCntr = 0
            tPart = "l" & me.pPart.char[2]
            tdir = me.pDirection
            tAction = "wav"
          end if
        end if
      end if
    "hd", "fc":
      if me.pTalking then
        if me.pAction = "lay" then
          tAction = "lsp"
        else
          tAction = "spk"
        end if
        tAnimCntr = me.pAnimCounter mod 2
      end if
    "ey":
      if me.pTalking and (me.pAction <> "lay") and ((me.pAnimCounter mod 2) = 0) then
        me.pYFix = -1
      end if
    "hr":
      if me.pTalking and ((me.pAnimCounter mod 2) = 0) then
        if me.pAction <> "lay" then
          tAction = "spk"
        end if
      end if
    "ri":
      if not me.pCarrying then
        me.pMemString = EMPTY
        if me.pCacheRectA.width > 0 then
          me.pUpdateRect = union(me.pUpdateRect, me.pCacheRectA)
          me.pCacheRectA = rect(0, 0, 0, 0)
        end if
        return 
      else
        tAction = me.pActionRh
        tdir = me.pDirection
      end if
    "li":
      tAction = me.pActionLh
      tdir = me.pDirection
  end case
  tMemString = me.pPeopleSize & "_" & tAction & "_" & tPart & "_" & me.pmodel & "_" & tdir & "_" & tAnimCntr
  me.pFlipH = 0
  tLocFixChanged = me.pLastLocFix <> point(me.pXFix, me.pYFix)
  me.pLastLocFix = point(me.pXFix, me.pYFix)
  if (me.pMemString <> tMemString) or tLocFixChanged then
    me.pMemString = tMemString
    tMemNum = getmemnum(tMemString)
    if tMemNum > 0 then
      tmember = member(tMemNum)
      tRegPnt = tmember.regPoint
      tX = -tRegPnt[1]
      tY = me.pBuffer.rect.height - tRegPnt[2] - 10
      me.pUpdateRect = union(me.pUpdateRect, me.pCacheRectA)
      me.pCacheImage = tmember.image
      tLocFix = me.pLocFix
      if me.pFlipH then
        me.pCacheImage = me.flipHorizontal(me.pCacheImage)
        tX = -tX - tmember.width + me.pBuffer.width
        tLocFix = point(-me.pLocFix[1], me.pLocFix[2])
        if me.pPeopleSize = "sh" then
          tX = tX - 2
        end if
      end if
      me.pCacheRectA = rect(tX, tY, tX + me.pCacheImage.width, tY + me.pCacheImage.height) + [me.pXFix, me.pYFix, me.pXFix, me.pYFix] + rect(tLocFix, tLocFix)
      me.pCacheRectB = me.pCacheImage.rect
      me.pDrawProps[#maskImage] = me.pCacheImage.createMatte()
      me.pUpdateRect = union(me.pUpdateRect, me.pCacheRectA)
    else
      me.pUpdateRect = union(me.pUpdateRect, me.pCacheRectA)
      me.pCacheRectA = rect(0, 0, 0, 0)
      return 
    end if
  end if
  me.pXFix = 0
  me.pYFix = 0
  me.pBuffer.copyPixels(me.pCacheImage, me.pCacheRectA, me.pCacheRectB, me.pDrawProps)
end
