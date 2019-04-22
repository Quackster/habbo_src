on prepare(me, tdata)
  if tdata.getAt(#stuffdata) = "ON" then
    pChanges = 1
    pActive = 1
  else
    pChanges = 0
    pActive = 0
  end if
  pTiming = 1
  return(1)
  exit
end

on updateStuffdata(me, tValue)
  if tValue = "ON" then
    pActive = 1
  else
    pActive = 0
  end if
  pChanges = 1
  exit
end

on update(me)
  pTiming = not pTiming
  if not pChanges then
    return()
  end if
  if not pTiming then
    return()
  end if
  if me.count(#pSprList) < 3 then
    return()
  end if
  if pActive then
    tName = undefined.name
    tName = tName.getProp(#char, 1, length(tName) - 1) & random(11) - 1
    me.getPropRef(#pSprList, 3).locZ = me.getPropRef(#pSprList, 2).locZ + 2
    tmember = member(getmemnum(tName))
    pChanges = 1
  else
    if not pActive then
      tName = undefined.name
      tmember = member(getmemnum(tName.getProp(#char, 1, length(tName) - 1) & "0"))
      pChanges = 0
    end if
  end if
  if tmember.number > 0 then
    me.getPropRef(#pSprList, 3).castNum = tmember.number
    me.getPropRef(#pSprList, 3).width = tmember.width
    me.getPropRef(#pSprList, 3).height = tmember.height
  end if
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
  end if
  return(1)
  exit
end