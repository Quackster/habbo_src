on prepare(me, tdata)
  if tdata.count = 0 then
    tdata = [#stuffdata:"0"]
  end if
  me.updateStuffdata(tdata.getAt(#stuffdata))
  return(1)
  exit
end

on updateRuntimeData(me, tValue)
  return(1)
  exit
end

on updateStuffdata(me, tValue)
  if tValue = "1" then
    pUpdateFrame = 0
    pActive = 1
    pTimer = the milliSeconds
    pLastFrm = 0
  else
    pUpdateFrame = 0
    pActive = 0
    pLastFrm = 0
    if me.count(#pSprList) > 3 then
      i = 1
      repeat while i <= 4
        tMemName = member.name
        tMemName = tMemName.getProp(#char, 1, length(tMemName) - 1) & 0
        tmember = member(getmemnum(tMemName))
        me.getPropRef(#pSprList, i).castNum = tmember.number
        me.getPropRef(#pSprList, i).width = tmember.width
        me.getPropRef(#pSprList, i).height = tmember.height
        i = 1 + i
      end repeat
    end if
  end if
  exit
end

on update(me)
  if pActive then
    pUpdateFrame = not pUpdateFrame
    if pUpdateFrame then
      pLastFrm = pLastFrm + 1 mod 6
      i = 1
      repeat while i <= 4
        tMemName = member.name
        tMemName = tMemName.getProp(#char, 1, length(tMemName) - 1) & pLastFrm
        tmember = member(getmemnum(tMemName))
        me.getPropRef(#pSprList, i).castNum = tmember.number
        me.getPropRef(#pSprList, i).width = tmember.width
        me.getPropRef(#pSprList, i).height = tmember.height
        i = 1 + i
      end repeat
    end if
  end if
  exit
end