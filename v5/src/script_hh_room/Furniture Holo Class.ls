on prepare(me, tdata)
  pActive = 0
  pAnimFrm = 0
  pDelay = 1
  if tdata.getAt("SWITCHON") = "ON" then
    me.setOn()
  else
    me.setOff()
  end if
  return(1)
  exit
end

on updateStuffdata(me, tProp, tValue)
  if tValue = "ON" then
    me.setOn()
  else
    me.setOff()
  end if
  exit
end

on update(me)
  if not pActive then
    return()
  end if
  if me.count(#pSprList) < 3 then
    return()
  end if
  if pDelay = 0 then
    pAnimFrm = pAnimFrm + 1 mod 8
    tNameB = member.name
    tNameC = member.name
    tNewNameB = tNameB.getProp(#char, 1, length(tNameB) - 3) & pAnimFrm & "_1"
    tNewNameC = tNameC.getProp(#char, 1, length(tNameC) - 3) & pAnimFrm & "_1"
    tmember = member(getmemnum(tNewNameB))
    me.getPropRef(#pSprList, 2).castNum = tmember.number
    me.getPropRef(#pSprList, 2).width = tmember.width
    me.getPropRef(#pSprList, 2).height = tmember.height
    me.getPropRef(#pSprList, 2).blend = 36
    tmember = member(getmemnum(tNewNameC))
    me.getPropRef(#pSprList, 3).castNum = tmember.number
    me.getPropRef(#pSprList, 3).width = tmember.width
    me.getPropRef(#pSprList, 3).height = tmember.height
    me.getPropRef(#pSprList, 3).blend = 70
  else
    if pDelay = 3 then
      me.getPropRef(#pSprList, 2).blend = 66
      me.getPropRef(#pSprList, 3).blend = 100
    end if
  end if
  pDelay = pDelay + 1 mod 4
  exit
end

on setHoloLight(me)
  if me.count(#pSprList) = 0 then
    return()
  end if
  tNameA = member.name
  tNameB = member.name
  tNameC = member.name
  tNameD = member.name
  tNewNameA = tNameA.getProp(#char, 1, length(tNameA) - 1) & pActive
  tNewNameB = tNameB.getProp(#char, 1, length(tNameB) - 3) & 0 & "_0"
  tNewNameC = tNameC.getProp(#char, 1, length(tNameC) - 3) & 0 & "_0"
  tNewNameD = tNameD.getProp(#char, 1, length(tNameD) - 1) & pActive
  tmember = member(getmemnum(tNewNameA))
  me.getPropRef(#pSprList, 1).castNum = tmember.number
  me.getPropRef(#pSprList, 1).width = tmember.width
  me.getPropRef(#pSprList, 1).height = tmember.height
  tmember = member(getmemnum(tNewNameB))
  me.getPropRef(#pSprList, 2).castNum = tmember.number
  me.getPropRef(#pSprList, 2).width = tmember.width
  me.getPropRef(#pSprList, 2).height = tmember.height
  me.getPropRef(#pSprList, 2).ink = 36
  tmember = member(getmemnum(tNewNameC))
  me.getPropRef(#pSprList, 3).castNum = tmember.number
  me.getPropRef(#pSprList, 3).width = tmember.width
  me.getPropRef(#pSprList, 3).height = tmember.height
  me.getPropRef(#pSprList, 3).ink = 36
  tmember = member(getmemnum(tNewNameD))
  me.getPropRef(#pSprList, 4).castNum = tmember.number
  me.getPropRef(#pSprList, 4).width = tmember.width
  me.getPropRef(#pSprList, 4).height = tmember.height
  me.getPropRef(#pSprList, 4).ink = 33
  exit
end

on setOn(me)
  pActive = 1
  me.setHoloLight()
  exit
end

on setOff(me)
  pActive = 0
  me.setHoloLight()
  exit
end

on select(me)
  if the doubleClick then
    if pActive = 1 then
      tOnString = "OFF"
    else
      tOnString = "ON"
    end if
    getThread(#room).getComponent().getRoomConnection().send(#room, "SETSTUFFDATA /" & me.getID() & "/" & "SWITCHON" & "/" & tOnString)
  end if
  exit
end