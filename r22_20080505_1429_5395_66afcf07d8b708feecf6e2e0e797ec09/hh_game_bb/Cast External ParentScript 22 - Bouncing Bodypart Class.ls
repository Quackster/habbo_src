on update me
  tAnimCntr = 0
  tAction = me.pAction
  tPart = me.pPart
  tdir = me.pBody.pFlipList[me.pDirection + 1]
  me.pXFix = [0, -2, -2, -2, -2, -2, -2, -1][me.pDirection + 1]
  me.pYFix = 0
  repeat with i = 1 to me.pLayerPropList.count
    tdata = me.pLayerPropList[i]
    tmodel = tdata["model"]
    tDrawProps = tdata["drawProps"]
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
      tdata["memString"] = tMemString
      tmember = member(tMemNum)
      tRegPnt = tmember.regPoint
      tX = -tRegPnt[1]
      tY = me.pBody.pBuffer.rect.height - tRegPnt[2] - 20
      me.pBody.pUpdateRect = union(me.pBody.pUpdateRect, tdata["cacheRect"])
      tdata["cacheImage"] = tmember.image
      tdata["cacheRect"] = rect(tX, tY, tX + tdata["cacheImage"].width, tY + tdata["cacheImage"].height)
      tdata["cacheRect"] = tdata["cacheRect"] + [me.pXFix, me.pYFix, me.pXFix, me.pYFix] + rect(me.pBody.pLocFix, me.pBody.pLocFix)
      tDrawProps[#maskImage] = tdata["cacheImage"].createMatte()
      me.pBody.pUpdateRect = union(me.pBody.pUpdateRect, tdata["cacheRect"])
    end if
    if tdata["cacheImage"] <> 0 then
      me.pBody.pBuffer.copyPixels(tdata["cacheImage"], tdata["cacheRect"], tdata["cacheImage"].rect, tDrawProps)
    end if
  end repeat
end
