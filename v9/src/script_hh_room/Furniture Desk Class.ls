on prepare(me, tdata)
  if tdata.getAt(#stuffdata) = "ON" then
    me.setOn()
    pChanges = 1
  else
    me.setOff()
    pChanges = 0
  end if
  return(1)
  exit
end

on updateStuffdata(me, tValue)
  if tValue = "ON" then
    me.setOn()
  else
    me.setOff()
  end if
  pChanges = 1
  exit
end

on update(me)
  if not pChanges then
    return()
  end if
  if me.count(#pSprList) < 4 then
    return()
  end if
  the itemDelimiter = "_"
  tMemName = undefined.name
  tClass = tMemName.getProp(#item, 1, tMemName.count(#item) - 6)
  tNewNameA = tClass & "_c_0_1_2_" & me.getProp(#pDirection, 1) & "_" & pActive
  tNewNameB = tClass & "_d_0_1_2_" & me.getProp(#pDirection, 1) & "_" & pActive
  tNewNameC = tClass & "_e_0_1_2_" & me.getProp(#pDirection, 1) & "_" & pActive
  if memberExists(tNewNameA) then
    tmember = member(abs(getmemnum(tNewNameA)))
    me.getPropRef(#pSprList, 3).castNum = tmember.number
    me.getPropRef(#pSprList, 3).width = tmember.width
    me.getPropRef(#pSprList, 3).height = tmember.height
    tmember = member(abs(getmemnum(tNewNameB)))
    me.getPropRef(#pSprList, 4).castNum = tmember.number
    me.getPropRef(#pSprList, 4).width = tmember.width
    me.getPropRef(#pSprList, 4).height = tmember.height
    tmember = member(abs(getmemnum(tNewNameC)))
    me.getPropRef(#pSprList, 5).castNum = tmember.number
    me.getPropRef(#pSprList, 5).width = tmember.width
    me.getPropRef(#pSprList, 5).height = tmember.height
  end if
  pChanges = 0
  exit
end

on setOn(me)
  pActive = 1
  exit
end

on setOff(me)
  pActive = 0
  exit
end

on select(me)
  if the doubleClick then
    if pActive then
      tStr = "OFF"
    else
      tStr = "ON"
    end if
    getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", [#string:string(me.getID()), #string:tStr])
  else
    getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short:me.pLocX, #short:me.pLocY])
  end if
  return(1)
  exit
end