property pChanges, pActive, pTiming

on prepare me, tdata
  if tdata["FIREON"] = "ON" then
    pChanges = 1
    pActive = 1
  else
    pChanges = 0
    pActive = 0
  end if
  pTiming = 1
  return 1
end

on updateStuffdata me, tProp, tValue
  if tValue = "ON" then
    pActive = 1
  else
    pActive = 0
  end if
  pChanges = 1
end

on update me
  pTiming = not pTiming
  if not pChanges then
    return 
  end if
  if not pTiming then
    return 
  end if
  if me.pSprList.count < 3 then
    return 
  end if
  if pActive then
    tName = me.pSprList[3].member.name
    tName = tName.char[1..length(tName) - 1] & random(11) - 1
    me.pSprList[3].locZ = me.pSprList[2].locZ + 2
    tmember = member(getmemnum(tName))
    pChanges = 1
  else
    if not pActive then
      tName = me.pSprList[3].member.name
      tmember = member(getmemnum(tName.char[1..length(tName) - 1] & "0"))
      pChanges = 0
    end if
  end if
  if tmember.number > 0 then
    me.pSprList[3].castNum = tmember.number
    me.pSprList[3].width = tmember.width
    me.pSprList[3].height = tmember.height
  end if
end

on select me
  if the doubleClick then
    if pActive then
      tStr = "OFF"
    else
      tStr = "ON"
    end if
    getThread(#room).getComponent().getRoomConnection().send(#room, "SETSTUFFDATA /" & me.getID() & "/" & "FIREON" & "/" & tStr)
  end if
  return 1
end
