property pActive, pTimer, pLastFrm

on prepare me, tdata 
  if (tdata.count = 0) then
    tdata = ["p":"0"]
  end if
  me.updateStuffdata("p", tdata.getAt(1))
  return TRUE
end

on updateStuffdata me, tProp, tValue 
  if (integer(tValue) = 1) then
    pTimer = 0
    pActive = 1
    pLastFrm = 0
  else
    pTimer = 0
    pActive = 0
    pLastFrm = 0
    if me.count(#pSprList) > 3 then
      i = 1
      repeat while i <= 4
        tMemName = me.getPropRef(#pSprList, i).member.name
        tMemName = tMemName.getProp(#char, 1, (length(tMemName) - 1)) & 0
        tmember = member(getmemnum(tMemName))
        me.getPropRef(#pSprList, i).castNum = tmember.number
        me.getPropRef(#pSprList, i).width = tmember.width
        me.getPropRef(#pSprList, i).height = tmember.height
        i = (1 + i)
      end repeat
    end if
  end if
end

on update me 
  if pActive then
    pTimer = not pTimer
    if pTimer then
      pLastFrm = ((pLastFrm + 1) mod 6)
      i = 1
      repeat while i <= 4
        tMemName = me.getPropRef(#pSprList, i).member.name
        tMemName = tMemName.getProp(#char, 1, (length(tMemName) - 1)) & pLastFrm
        tmember = member(getmemnum(tMemName))
        me.getPropRef(#pSprList, i).castNum = tmember.number
        me.getPropRef(#pSprList, i).width = tmember.width
        me.getPropRef(#pSprList, i).height = tmember.height
        i = (1 + i)
      end repeat
    end if
  end if
end
