property pChanges, pRolling, pRollDir, pRollingStartTime, pRollAnimDir, pRollingDirection

on prepare me, tdata 
  if tdata.findPos("DIR") then
    me.setProp(#pDirection, 1, integer(tdata.getAt("DIR")))
    me.setProp(#pDirection, 2, integer(tdata.getAt("DIR")))
    if me.getProp(#pDirection, 1) < 0 or me.pDirection > 7 then
      me.setProp(#pDirection, 1, 0)
    end if
  end if
  pChanges = 0
  pRolling = 0
  pRollDir = me.getProp(#pDirection, 1)
  pRollAnimDir = me.getProp(#pDirection, 1)
  pRollingDirection = me.getProp(#pDirection, 1)
  me.setDir(tdata.getAt("DIR"))
  me.solveMembers()
  me.moveBy(0, 0, 0)
  return(1)
end

on updateStuffdata me, tProp, tValue 
  pRolling = 1
  pChanges = 1
  me.setDir(value(tValue))
end

on update me 
  if not pChanges then
    return()
  end if
  if me.count(#pSprList) < 1 then
    return()
  end if
  if pRolling then
    me.roll()
    me.solveMembers()
    me.moveBy(0, 0, 0)
    pChanges = 1
  else
    me.setProp(#pDirection, 1, pRollDir)
    me.setProp(#pDirection, 2, pRollDir)
    me.solveMembers()
    me.moveBy(0, 0, 0)
    pChanges = 0
  end if
end

on roll me 
  if pRolling and the milliSeconds - pRollingStartTime < 3300 then
    tTime = the milliSeconds - pRollingStartTime
    f = tTime * 1 / 3200 * 3.14159 * 0.5
    pRollAnimDir = pRollAnimDir + cos(f) * float(pRollingDirection)
    me.setProp(#pDirection, 1, abs(integer(pRollAnimDir) mod 8))
    me.setProp(#pDirection, 2, abs(integer(pRollAnimDir) mod 8))
  else
    pRolling = 0
  end if
end

on setDir me, tNewDir 
  if tNewDir < 0 or tNewDir > 7 then
    tNewDir = 0
  end if
  pRollDir = tNewDir
  if pRolling then
    pRollingStartTime = the milliSeconds
    pRollAnimDir = me.getProp(#pDirection, 1)
    if pRollDir mod 2 = 1 then
      pRollingDirection = 1
    else
      pRollingDirection = -1
    end if
  end if
end

on select me 
  if the doubleClick then
    tNewDir = random(8) - 1
    getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", me.getID() & "/" & "DIR" & "/" & tNewDir)
  end if
  return(1)
end
