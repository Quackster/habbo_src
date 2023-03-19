property pUpdateFrame, pActive, pLastFrm, pTimer

on prepare me, tdata
  if tdata.count = 0 then
    tdata = ["p": "0"]
  end if
  me.updateStuffdata("p", tdata[1])
  return 1
end

on updateStuffdata me, tProp, tValue
  if integer(tValue) = 1 then
    pUpdateFrame = 0
    pActive = 1
    pTimer = the milliSeconds
    pLastFrm = 0
  else
    pUpdateFrame = 0
    pActive = 0
    pLastFrm = 0
    if me.pSprList.count > 3 then
      repeat with i = 1 to 4
        tMemName = me.pSprList[i].member.name
        tMemName = tMemName.char[1..length(tMemName) - 1] & 0
        tmember = member(getmemnum(tMemName))
        me.pSprList[i].castNum = tmember.number
        me.pSprList[i].width = tmember.width
        me.pSprList[i].height = tmember.height
      end repeat
    end if
  end if
end

on update me
  if pActive then
    pUpdateFrame = not pUpdateFrame
    if pUpdateFrame then
      pLastFrm = (pLastFrm + 1) mod 6
      repeat with i = 1 to 4
        tMemName = me.pSprList[i].member.name
        tMemName = tMemName.char[1..length(tMemName) - 1] & pLastFrm
        tmember = member(getmemnum(tMemName))
        me.pSprList[i].castNum = tmember.number
        me.pSprList[i].width = tmember.width
        me.pSprList[i].height = tmember.height
      end repeat
      if (the milliSeconds - pTimer) > 20000 then
        me.updateStuffdata(0)
      end if
    end if
  end if
end