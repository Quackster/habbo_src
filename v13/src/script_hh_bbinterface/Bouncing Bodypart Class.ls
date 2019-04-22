on update me 
  tAnimCntr = 0
  tAction = me.pAction
  tPart = me.pPart
  tdir = me.getProp(#pFlipList, me.pDirection + 1)
  me.pXFix = [0, -2, -2, -2, -2, -2, -2, -1].getAt(me.pDirection + 1)
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
    tX = -tRegPnt.getAt(1)
    tY = undefined.height - tRegPnt.getAt(2) - 10
    me.pUpdateRect = union(me.pUpdateRect, me.pCacheRectA)
    me.pCacheImage = tmember.image
    me.pCacheRectA = rect(tX, tY, tX + me.width, tY + me.height) + [me.pXFix, me.pYFix, me.pXFix, me.pYFix] + rect(me.pLocFix, me.pLocFix)
    me.pCacheRectB = me.rect
    me.setProp(#pDrawProps, #maskImage, me.createMatte())
    me.pUpdateRect = union(me.pUpdateRect, me.pCacheRectA)
  else
    return()
  end if
  me.copyPixels(me.pCacheImage, me.pCacheRectA, me.pCacheRectB, me.pDrawProps)
end
