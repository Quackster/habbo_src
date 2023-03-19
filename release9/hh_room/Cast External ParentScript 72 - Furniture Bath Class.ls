property pChanges, pActive

on prepare me, tdata
  if tdata[#stuffdata] = "ON" then
    me.setOn()
    pChanges = 1
  else
    me.setOff()
    pChanges = 0
  end if
  return 1
end

on updateStuffdata me, tValue
  if tValue = "ON" then
    me.setOn()
  else
    me.setOff()
  end if
  pChanges = 1
end

on update me
  if not pChanges then
    return 
  end if
  if me.pSprList.count < 8 then
    return 
  end if
  if me.pXFactor = 32 then
    tClass = "s_bath"
  else
    tClass = "bath"
  end if
  tNewNameA = tClass & "_e_0_1_2_" & me.pDirection[1] & "_" & pActive
  tNewNameB = tClass & "_f_0_1_2_" & me.pDirection[1] & "_" & pActive
  tNewNameC = tClass & "_g_0_1_2_" & me.pDirection[1] & "_" & pActive
  tNewNameD = tClass & "_h_0_1_2_" & me.pDirection[1] & "_" & pActive
  if memberExists(tNewNameA) then
    tmember = member(abs(getmemnum(tNewNameA)))
    me.pSprList[5].castNum = tmember.number
    me.pSprList[5].width = tmember.width
    me.pSprList[5].height = tmember.height
    tmember = member(abs(getmemnum(tNewNameB)))
    me.pSprList[6].castNum = tmember.number
    me.pSprList[6].width = tmember.width
    me.pSprList[6].height = tmember.height
    tmember = member(abs(getmemnum(tNewNameC)))
    me.pSprList[7].castNum = tmember.number
    me.pSprList[7].width = tmember.width
    me.pSprList[7].height = tmember.height
    tmember = member(abs(getmemnum(tNewNameD)))
    me.pSprList[8].castNum = tmember.number
    me.pSprList[8].width = tmember.width
    me.pSprList[8].height = tmember.height
  end if
  pChanges = 0
end

on setOn me
  pActive = 1
end

on setOff me
  pActive = 0
end

on select me
  if the doubleClick then
    if pActive then
      tStr = "OFF"
    else
      tStr = "ON"
    end if
    getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", [#string: string(me.getID()), #string: tStr])
  else
    getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short: me.pLocX, #short: me.pLocY])
  end if
  return 1
end
