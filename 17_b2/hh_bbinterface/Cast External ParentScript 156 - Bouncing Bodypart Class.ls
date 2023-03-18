on update me
  tAnimCntr = 0
  tAction = me.pAction
  tPart = me.pPart
  tdir = me.pFlipList[me.pDirection + 1]
  me.pXFix = [0, -2, -2, -2, -2, -2, -2, -1][me.pDirection + 1]
  me.pYFix = 0
  if me.pAnimating then
    tMemString = me.animate()
  else
    tAnimCntr = me.pAnimCounter
    tdir = 1
    tAction = "wlk"
    tMemString = me.pPeopleSize & "_" & tAction & "_" & tPart & "_" & me.pmodel & "_" & tdir & "_" & tAnimCntr
  end if
  tMemNum = getmemnum(tMemString)
  if tMemNum > 0 then
    me.pMemString = tMemString
    tmember = member(tMemNum)
    tRegPnt = tmember.regPoint
    tX = -tRegPnt[1]
    tY = me.pBuffer.rect.height - tRegPnt[2] - 10
    me.pUpdateRect = union(me.pUpdateRect, me.pCacheRectA)
    me.pCacheImage = tmember.image
    me.pCacheRectA = rect(tX, tY, tX + me.pCacheImage.width, tY + me.pCacheImage.height) + [me.pXFix, me.pYFix, me.pXFix, me.pYFix] + rect(me.pLocFix, me.pLocFix)
    me.pCacheRectB = me.pCacheImage.rect
    me.pDrawProps[#maskImage] = me.pCacheImage.createMatte()
    me.pUpdateRect = union(me.pUpdateRect, me.pCacheRectA)
  else
    return 
  end if
  me.pBuffer.copyPixels(me.pCacheImage, me.pCacheRectA, me.pCacheRectB, me.pDrawProps)
end
