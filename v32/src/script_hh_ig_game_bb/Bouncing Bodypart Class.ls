on update me 
  tAnimCntr = 0
  tAction = me.pAction
  tPart = me.pPart
  tdir = me.pBody.getProp(#pFlipList, (me.pDirection + 1))
  me.pXFix = [0, -2, -2, -2, -2, -2, -2, -1].getAt((me.pDirection + 1))
  me.pYFix = 0
  i = 1
  repeat while i <= me.count(#pLayerPropList)
    tdata = me.getProp(#pLayerPropList, i)
    tmodel = tdata.getAt("model")
    tDrawProps = tdata.getAt("drawProps")
    if me.pBody.pAnimating then
      tMemString = me.animate(i)
    else
      tAnimCntr = me.pBody.pAnimCounter
      tdir = 1
      tAction = "wlk"
      tMemString = me.pBody.pPeopleSize & "_" & tAction & "_" & tPart & "_" & tmodel & "_" & tdir & "_" & tAnimCntr
    end if
    tMemNum = getmemnum(tMemString)
    if tMemNum > 0 then
      tdata.setAt("memString", tMemString)
      tmember = member(tMemNum)
      tRegPnt = tmember.regPoint
      tX = -tRegPnt.getAt(1)
      tY = ((me.pBody.pBuffer.rect.height - tRegPnt.getAt(2)) - 20)
      me.pBody.pUpdateRect = union(me.pBody.pUpdateRect, tdata.getAt("cacheRect"))
      tdata.setAt("cacheImage", tmember.image)
      tdata.setAt("cacheRect", rect(tX, tY, (tX + tdata.getAt("cacheImage").width), (tY + tdata.getAt("cacheImage").height)))
      tdata.setAt("cacheRect", ((tdata.getAt("cacheRect") + [me.pXFix, me.pYFix, me.pXFix, me.pYFix]) + rect(me.pBody.pLocFix, me.pBody.pLocFix)))
      tDrawProps.setAt(#maskImage, tdata.getAt("cacheImage").createMatte())
      me.pBody.pUpdateRect = union(me.pBody.pUpdateRect, tdata.getAt("cacheRect"))
    end if
    if tdata.getAt("cacheImage") <> 0 then
      me.pBody.pBuffer.copyPixels(tdata.getAt("cacheImage"), tdata.getAt("cacheRect"), tdata.getAt("cacheImage").rect, tDrawProps)
    end if
    i = (1 + i)
  end repeat
end
