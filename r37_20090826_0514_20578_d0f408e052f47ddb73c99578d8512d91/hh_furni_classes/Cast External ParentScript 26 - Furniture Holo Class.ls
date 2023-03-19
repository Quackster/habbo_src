property pActive, pAnimFrm, pDelay

on prepare me, tdata
  pActive = 0
  pAnimFrm = 0
  pDelay = 1
  tValue = integer(tdata[#stuffdata])
  if tValue = 0 then
    me.setOff()
  else
    me.setOn()
  end if
  return 1
end

on updateStuffdata me, tValue
  tValue = integer(tValue)
  if tValue = 0 then
    me.setOff()
  else
    me.setOn()
  end if
end

on update me
  if not pActive then
    return 
  end if
  if me.pSprList.count < 3 then
    return 
  end if
  if pDelay = 0 then
    pAnimFrm = (pAnimFrm + 1) mod 8
    tNameB = me.pSprList[2].member.name
    tNameC = me.pSprList[3].member.name
    tNewNameB = tNameB.char[1..length(tNameB) - 3] & pAnimFrm & "_1"
    tNewNameC = tNameC.char[1..length(tNameC) - 3] & pAnimFrm & "_1"
    tmember = member(getmemnum(tNewNameB))
    me.pSprList[2].castNum = tmember.number
    me.pSprList[2].width = tmember.width
    me.pSprList[2].height = tmember.height
    me.pSprList[2].blend = 36
    tmember = member(getmemnum(tNewNameC))
    me.pSprList[3].castNum = tmember.number
    me.pSprList[3].width = tmember.width
    me.pSprList[3].height = tmember.height
    me.pSprList[3].blend = 70
  else
    if pDelay = 3 then
      me.pSprList[2].blend = 66
      me.pSprList[3].blend = 100
    end if
  end if
  pDelay = (pDelay + 1) mod 4
end

on setHoloLight me
  if me.pSprList.count < 4 then
    return 0
  end if
  tNameA = me.pSprList[1].member.name
  tNameB = me.pSprList[2].member.name
  tNameC = me.pSprList[3].member.name
  tNameD = me.pSprList[4].member.name
  tNewNameA = tNameA.char[1..length(tNameA) - 1] & pActive
  tNewNameB = tNameB.char[1..length(tNameB) - 3] & 0 & "_0"
  tNewNameC = tNameC.char[1..length(tNameC) - 3] & 0 & "_0"
  tNewNameD = tNameD.char[1..length(tNameD) - 1] & pActive
  tmember = member(getmemnum(tNewNameA))
  me.pSprList[1].castNum = tmember.number
  me.pSprList[1].width = tmember.width
  me.pSprList[1].height = tmember.height
  tmember = member(getmemnum(tNewNameB))
  me.pSprList[2].castNum = tmember.number
  me.pSprList[2].width = tmember.width
  me.pSprList[2].height = tmember.height
  me.pSprList[2].ink = 36
  tmember = member(getmemnum(tNewNameC))
  me.pSprList[3].castNum = tmember.number
  me.pSprList[3].width = tmember.width
  me.pSprList[3].height = tmember.height
  me.pSprList[3].ink = 36
  tmember = member(getmemnum(tNewNameD))
  me.pSprList[4].castNum = tmember.number
  me.pSprList[4].width = tmember.width
  me.pSprList[4].height = tmember.height
  me.pSprList[4].ink = 33
end

on setOn me
  pActive = 1
  me.setHoloLight()
end

on setOff me
  pActive = 0
  me.setHoloLight()
end

on select me
  if the doubleClick then
    getThread(#room).getComponent().getRoomConnection().send("USEFURNITURE", [#integer: integer(me.getID()), #integer: 0])
  end if
end
